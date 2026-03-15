package com.example;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/SubmitQRServlet")
public class SubmitQRServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String regdNo = request.getParameter("regdno");
        String subjectId = request.getParameter("sid");
        String ipAddress = request.getParameter("ip");
        String deviceId = request.getParameter("dev");

        try (Connection con = DbConnection.getConne()) {
            // Final check: Does this student exist and is he in the correct class?
            // (Optional logic here)

            String sql = "INSERT INTO student_attendance (regd_no, subject_id, status, staff_id, attendance_date, ip_address, device_fingerprint) " +
                         "VALUES (?, ?, 'Present', 'QR_SYSTEM', CURRENT_DATE, ?, ?)";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, regdNo);
            ps.setInt(2, Integer.parseInt(subjectId));
            ps.setString(3, ipAddress);
            ps.setString(4, deviceId);
            
            ps.executeUpdate();
            
            // Redirect to a clean success page
            response.sendRedirect("attendanceSuccess.jsp");

        } catch (SQLException e) {
            // Error 23505 is Unique Violation in PostgreSQL
            if (e.getSQLState().equals("23505")) {
                response.sendRedirect("studentScan.jsp?sid=" + subjectId + "&error=duplicate");
            } else {
                e.printStackTrace();
                response.sendRedirect("studentScan.jsp?sid=" + subjectId + "&error=system");
            }
        }
    }
}