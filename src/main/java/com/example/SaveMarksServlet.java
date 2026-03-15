package com.example;

import java.io.IOException;
import java.sql.*;
import java.util.Enumeration;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SaveMarksServlet")
public class SaveMarksServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Retrieve the subject ID
        String subjectIdStr = request.getParameter("subjectId");
        if (subjectIdStr == null) {
            response.sendRedirect("staff_management/staff_dashboard.jsp?status=error&message=Missing Subject ID");
            return;
        }

        int subjectId = Integer.parseInt(subjectIdStr);
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DbConnection.getConne();
            
            // 2. Prepare the Insert Statement
            // Note: We do NOT use ON CONFLICT because you specified editing is NOT possible.
            String sql = "INSERT INTO student_marks (regd_no, subject_id, mid1_marks, mid2_marks) VALUES (?, ?, ?, ?)";
            ps = con.prepareStatement(sql);

            // 3. Iterate through parameters to find mid1_ inputs
            // We use mid1_ as the key to extract the Registration Number
            Enumeration<String> parameterNames = request.getParameterNames();
            boolean dataFound = false;

            while (parameterNames.hasMoreElements()) {
                String paramName = parameterNames.nextElement();

                if (paramName.startsWith("mid1_")) {
                    String regdNo = paramName.substring(5); // Extract '4242...' from 'mid1_4242...'
                    
                    // Retrieve Mid-1 and Mid-2 marks for this specific student
                    int mid1 = Integer.parseInt(request.getParameter("mid1_" + regdNo));
                    int mid2 = Integer.parseInt(request.getParameter("mid2_" + regdNo));

                    ps.setString(1, regdNo);
                    ps.setInt(2, subjectId);
                    ps.setInt(3, mid1);
                    ps.setInt(4, mid2);
                    
                    ps.addBatch(); // Batching for high performance
                    dataFound = true;
                }
            }

            if (dataFound) {
                ps.executeBatch();
                // 4. Redirect to Dashboard with success
                response.sendRedirect("staff_management/staff_dashboard.jsp?status=success&message=Marks Submitted Permanently");
            } else {
                response.sendRedirect("staff_management/staff_dashboard.jsp?status=error&message=No data received");
            }

        } catch (BatchUpdateException bue) {
            // This happens if the UNIQUE constraint is violated (Marks already exist)
            response.sendRedirect("staff_management/staff_dashboard.jsp?status=error&message=Marks already exist for this class.");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("staff_management/staff_dashboard.jsp?status=error&message=Database Error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("staff_management/staff_dashboard.jsp?status=error&message=Internal Error");
        } finally {
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
}