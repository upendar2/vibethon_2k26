package com.example;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/SubmitQRServlet")
public class SubmitQRServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Set response type to JSON for the SweetAlert2 popup
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // 1. Retrieve parameters from the student scan form
        String regdNo = request.getParameter("regdno");
        String subjectId = request.getParameter("sid");
        String className = request.getParameter("cls");
        String joinYear = request.getParameter("yr");
        String ipAddress = request.getParameter("ip");
        String deviceFingerprint = request.getParameter("dev");

        Connection con = null;
        try {
            con = DbConnection.getConne();
            
            // 2. STEP ONE: Verify if this Registration Number exists in THIS specific class
            // This prevents students from other sections/years from scanning.
            String verifySql = "SELECT name FROM students WHERE regd_no = ? AND class = ? AND joinyear = ?";
            PreparedStatement psVerify = con.prepareStatement(verifySql);
            psVerify.setString(1, regdNo);
            psVerify.setString(2, className);
            psVerify.setInt(3, Integer.parseInt(joinYear));
            
            ResultSet rsVerify = psVerify.executeQuery();

            if (rsVerify.next()) {
                String studentName = rsVerify.getString("name");

                // 3. STEP TWO: Insert the attendance record
                // The database UNIQUE constraint on (subject_id, attendance_date, ip_address) 
                // will automatically block a second submission from the same device.
                String insertSql = "INSERT INTO student_attendance " +
                                 "(regd_no, subject_id, status, attendance_date, ip_address, device_fingerprint) " +
                                 "VALUES (?, ?, 'Present', CURRENT_DATE, ?, ?)";
                
                PreparedStatement psInsert = con.prepareStatement(insertSql);
                psInsert.setString(1, regdNo);
                psInsert.setInt(2, Integer.parseInt(subjectId));
                psInsert.setString(3, ipAddress);
                psInsert.setString(4, deviceFingerprint);
                
                psInsert.executeUpdate();

                // SUCCESS: Send JSON response
                out.print("{\"status\":\"success\", \"message\":\"Attendance marked for " + studentName + "!\"}");
            } else {
                // FAILURE: Student not found in this class
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"status\":\"error\", \"message\":\"Registration No " + regdNo + " not registered in " + className + ".\"}");
            }

        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            // Handle the "One Device Only" error (PostgreSQL Error Code 23505)
            if ("23505".equals(e.getSQLState())) {
                out.print("{\"status\":\"error\", \"message\":\"This device has already submitted attendance for today.\"}");
            } else {
                out.print("{\"status\":\"error\", \"message\":\"Database Error: " + e.getMessage() + "\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"status\":\"error\", \"message\":\"Internal Server Error.\"}");
            e.printStackTrace();
        } finally {
            try { if (con != null) con.close(); } catch (SQLException e) {}
            out.flush();
            out.close();
        }
    }
}