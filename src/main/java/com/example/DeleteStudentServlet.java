package com.example;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/deleteStudent")
public class DeleteStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String message = "";
        String status = "error";
        String regdNo = request.getParameter("regdno");

        if (regdNo == null || regdNo.trim().isEmpty()) {
            message = "Error: Registration number is missing.";
        } else {
            Connection con = null;
            try {
                con = DbConnection.getConne();
                // --- Start Transaction ---
                con.setAutoCommit(false);

                // 1. Delete Grades (Child of Results)
                String deleteGradesSql = "DELETE FROM student_grades WHERE result_id IN " +
                                         "(SELECT result_id FROM semester_results WHERE student_regn_no = ?)";
                try (PreparedStatement psGrades = con.prepareStatement(deleteGradesSql)) {
                    psGrades.setString(1, regdNo);
                    psGrades.executeUpdate();
                }

                // 2. Delete Semester Results
                String deleteResultsSql = "DELETE FROM semester_results WHERE student_regn_no = ?";
                try (PreparedStatement psResults = con.prepareStatement(deleteResultsSql)) {
                    psResults.setString(1, regdNo);
                    psResults.executeUpdate();
                }

                // 3. Delete Attendance
                String deleteAttendanceSql = "DELETE FROM student_attendance WHERE regd_no = ?";
                try (PreparedStatement psAttendance = con.prepareStatement(deleteAttendanceSql)) {
                    psAttendance.setString(1, regdNo);
                    psAttendance.executeUpdate();
                }

                // 4. Finally, Delete the Student
                String deleteStudentSql = "DELETE FROM students WHERE regd_no = ?";
                int rowsAffected = 0;
                try (PreparedStatement psStudent = con.prepareStatement(deleteStudentSql)) {
                    psStudent.setString(1, regdNo);
                    rowsAffected = psStudent.executeUpdate();
                }

                if (rowsAffected > 0) {
                    // --- Commit changes only if the student was actually found and deleted ---
                    con.commit();
                    status = "success";
                    message = "Student " + regdNo + " and all associated records deleted successfully.";
                } else {
                    con.rollback();
                    message = "Error: Student not found.";
                }

            } catch (SQLException e) {
                // --- If any step fails, roll back everything ---
                if (con != null) {
                    try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
                }
                status = "error";
                message = "Database error: " + e.getMessage();
                e.printStackTrace();
            } finally {
                // --- Clean up ---
                if (con != null) {
                    try {
                        con.setAutoCommit(true);
                        con.close();
                    } catch (SQLException ex) { ex.printStackTrace(); }
                }
            }
        }

        // Redirect with encoded message
        response.sendRedirect("studentManagement.jsp?status=" + status + "&message=" + URLEncoder.encode(message, "UTF-8"));
    }
}