package com.example;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/DeleteAssignmentServlet")
public class DeleteAssignmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Retrieve the unique assignment_id from the URL
        String idParam = request.getParameter("id");
        
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("viewAssignments.jsp?status=error&message=Invalid Assignment ID");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;

        try {
            int assignmentId = Integer.parseInt(idParam);
            con = DbConnection.getConne();

            // SQL to delete based on the primary key
            String sql = "DELETE FROM staff_assignments WHERE assignment_id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, assignmentId);

            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                // Success: Redirect back to the list view
                response.sendRedirect("viewAssignments.jsp?status=success&message=Assignment deleted successfully");
            } else {
                response.sendRedirect("viewAssignments.jsp?status=error&message=No record found to delete");
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("viewAssignments.jsp?status=error&message=Invalid format for ID");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("viewAssignments.jsp?status=error&message=Database error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("viewAssignments.jsp?status=error&message=Internal server error");
        } finally {
            // Close database resources
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
}