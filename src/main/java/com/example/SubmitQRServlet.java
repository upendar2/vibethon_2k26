package com.example;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/SubmitQRServlet")
public class SubmitQRServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        String regdNo = request.getParameter("regdno");
        String sid = request.getParameter("sid");
        String cls = request.getParameter("cls");
        String yr = request.getParameter("yr");
        String ip = request.getParameter("ip");

        try (Connection con = DbConnection.getConne()) {
            // 1. CHECK IF STUDENT EXISTS IN THIS SPECIFIC CLASS
            String verifySql = "SELECT name FROM students WHERE regd_no = ? AND class = ? AND joinyear = ?";
            PreparedStatement psVerify = con.prepareStatement(verifySql);
            psVerify.setString(1, regdNo);
            psVerify.setString(2, cls);
            psVerify.setInt(3, Integer.parseInt(yr));
            ResultSet rs = psVerify.executeQuery();

            if (rs.next()) {
                // 2. STUDENT EXISTS -> PROCEED TO MARK ATTENDANCE
                String sql = "INSERT INTO student_attendance (regd_no, subject_id, status, attendance_date, ip_address) VALUES (?, ?, 'Present', CURRENT_DATE, ?)";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, regdNo);
                ps.setInt(2, Integer.parseInt(sid));
                ps.setString(3, ip);
                ps.executeUpdate();

                out.print("{\"status\":\"success\", \"message\":\"Attendance marked for " + rs.getString("name") + "\"}");
            } else {
                // 3. STUDENT NOT FOUND IN THIS CLASS
                response.setStatus(400);
                out.print("{\"status\":\"error\", \"message\":\"Registration number not found in " + cls + ".\"}");
            }
        } catch (SQLException e) {
            response.setStatus(400);
            if (e.getSQLState().equals("23505")) { // Unique violation (IP check)
                out.print("{\"status\":\"error\", \"message\":\"This device has already submitted attendance.\"}");
            } else {
                out.print("{\"status\":\"error\", \"message\":\"Database Error: " + e.getMessage() + "\"}");
            }
        }
    }
}