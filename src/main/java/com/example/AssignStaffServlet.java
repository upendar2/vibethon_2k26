package com.example;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/AssignStaffServlet")
public class AssignStaffServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Retrieve parameters from the JSP form
        String staffId = request.getParameter("staffId");
        int subjectId = Integer.parseInt(request.getParameter("subjectId"));
        int joinYear = Integer.parseInt(request.getParameter("joinYear"));
        String className = request.getParameter("className");

        Connection con = null;
        PreparedStatement psCheck = null;
        PreparedStatement psInsert = null;

        try {
            con = DbConnection.getConne();

            // 2. Check if this assignment already exists to avoid duplicates
            String checkSql = "SELECT COUNT(*) FROM staff_assignments WHERE staff_id = ? AND subject_id = ? AND class_name = ? AND join_year = ?";
            psCheck = con.prepareStatement(checkSql);
            psCheck.setString(1, staffId);
            psCheck.setInt(2, subjectId);
            psCheck.setString(3, className);
            psCheck.setInt(4, joinYear);
            
            ResultSet rs = psCheck.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                // Already assigned
                response.sendRedirect("manageStaff.jsp?status=error&message=Subject already assigned to this staff for this class.");
                return;
            }

            // 3. Insert new assignment
            String insertSql = "INSERT INTO staff_assignments (staff_id, subject_id, class_name, join_year) VALUES (?, ?, ?, ?)";
            psInsert = con.prepareStatement(insertSql);
            psInsert.setString(1, staffId);
            psInsert.setInt(2, subjectId);
            psInsert.setString(3, className);
            psInsert.setInt(4, joinYear);

            int rows = psInsert.executeUpdate();

            if (rows > 0) {
                // Success: Redirect back to the form with success status
                response.sendRedirect("manageStaff.jsp?status=success");
            } else {
                response.sendRedirect("manageStaff.jsp?status=error&message=Failed to save assignment.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("manageStaff.jsp?status=error&message=Database Error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manageStaff.jsp?status=error&message=Internal Error.");
        } finally {
            // 4. Close resources
            try { if (psCheck != null) psCheck.close(); } catch (SQLException e) {}
            try { if (psInsert != null) psInsert.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
}