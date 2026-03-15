package com.example;

import java.io.IOException;
import java.sql.*;
import java.util.Enumeration;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/SaveDailyAttendanceServlet")
public class SaveDailyAttendanceServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // Retrieve session data
        String staffId = (String) session.getAttribute("regdno");
        
        // Retrieve parameters from the form
        String subjectIdStr = request.getParameter("subjectId");
        String selectedDate = request.getParameter("attendanceDate"); // This comes from the hidden input in JSP
        
        // Basic Validation
        if (staffId == null || subjectIdStr == null || selectedDate == null) {
            response.sendRedirect("staff_management/staff_dashboard.jsp?status=error&message=Invalid Session or Data");
            return;
        }

        int subjectId = Integer.parseInt(subjectIdStr);
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DbConnection.getConne();
            
            /* UPSERT Logic: 
               Attempts to insert. If a record with the same (regd_no, subject_id, attendance_date) 
               already exists (due to the UNIQUE constraint), it updates the existing status instead.
            */
            String sql = "INSERT INTO student_attendance (regd_no, subject_id, status, staff_id, attendance_date) " +
                         "VALUES (?, ?, ?, ?, ?::date) " +
                         "ON CONFLICT (regd_no, subject_id, attendance_date) " +
                         "DO UPDATE SET " +
                         "status = EXCLUDED.status, " +
                         "staff_id = EXCLUDED.staff_id";
            
            ps = con.prepareStatement(sql);

            // Iterate through parameters to find student statuses
            Enumeration<String> params = request.getParameterNames();
            boolean hasData = false;

            while (params.hasMoreElements()) {
                String paramName = params.nextElement();
                
                if (paramName.startsWith("status_")) {
                    String regdNo = paramName.substring(7); // Extract regd_no from status_4242...
                    String status = request.getParameter(paramName);

                    ps.setString(1, regdNo);
                    ps.setInt(2, subjectId);
                    ps.setString(3, status);
                    ps.setString(4, staffId);
                    ps.setString(5, selectedDate);
                    
                    ps.addBatch(); // Performance optimization
                    hasData = true;
                }
            }
            
            if (hasData) {
                ps.executeBatch();
                // Redirect back with success message
                response.sendRedirect("staff_management/staff_dashboard.jsp?status=success&message=Attendance saved for " + selectedDate);
            } else {
                response.sendRedirect("staff_management/staff_dashboard.jsp?status=error&message=No student records found");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            // Likely a database constraint issue or connection error
            response.sendRedirect("staff_management/staff_dashboard.jsp?status=error&message=Database Error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staff_management/staff_dashboard.jsp?status=error&message=General Error occurred");
        } finally {
            // Clean up resources
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
}