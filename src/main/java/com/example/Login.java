package com.example;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/LoginPage")
public class Login extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String input = request.getParameter("emailid");
        String password = request.getParameter("password");
        String contextPath = request.getContextPath();
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DbConnection.getConne();
            String hashedPassword = HashPassword.hashPassword(password);
            
            // --- Step 1: Attempt to log in as a student from the 'students' table ---
            String studentSql = input.contains("@")
                ? "SELECT * FROM students WHERE email = ? AND password = ?"
                : "SELECT * FROM students WHERE regd_no = ? AND password = ?";
            
            ps = con.prepareStatement(studentSql);
            ps.setString(1, input);
            ps.setString(2, hashedPassword);
            rs = ps.executeQuery();

            if (rs.next()) {
                handleLoginSuccess(request, rs, "student");
                out.print("success:" + contextPath + "/studentpage.jsp");
                return; 
            }
            
            rs.close();
            ps.close();

            // --- Step 2: Attempt to log in as a user (Admin/Staff) from the 'users' table ---
            String userSql;
            if (input.contains("@")) {
                userSql = "SELECT * FROM users WHERE email = ? AND password = ?";
                ps = con.prepareStatement(userSql);
                ps.setString(1, input);
                ps.setString(2, hashedPassword);
            } else if (input.matches("\\d+")) {
                userSql = "SELECT * FROM users WHERE id = ? AND password = ?";
                ps = con.prepareStatement(userSql);
                ps.setString(1, input);
                ps.setString(2, hashedPassword);
            } else {
                ps = null; 
            }

            if (ps != null) {
                rs = ps.executeQuery();
                if (rs.next()) {
                    String role = rs.getString("role");
                    handleLoginSuccess(request, rs, role);
                    
                    // --- UPDATED LOGIC FOR STAFF ROLE ---
                    String redirectUrl;
                    if ("admin".equalsIgnoreCase(role)) {
                        redirectUrl = contextPath + "/admin_dashboard.jsp";
                    } else if ("staff".equalsIgnoreCase(role)) {
                        redirectUrl = contextPath + "/staff_management/staff_dashboard.jsp";
                    } else {
                        redirectUrl = contextPath + "/studentpage.jsp";
                    }
                    
                    out.print("success:" + redirectUrl);
                    return;
                }
            }
            
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("Login Failed! Invalid ID/Email or password.");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("An internal server error occurred.");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
            out.flush();
        }
    }

    private void handleLoginSuccess(HttpServletRequest request, ResultSet rs, String role) throws SQLException {
        HttpSession session = request.getSession(true);
        String name = rs.getString("name");
        String userId;

        if ("student".equalsIgnoreCase(role)) {
            userId = rs.getString("regd_no");
        } else {
            userId = String.valueOf(rs.getInt("id"));
        }
        
        session.setAttribute("regdno", userId); 
        session.setAttribute("userName", name);
        session.setAttribute("userRole", role);
    }
}