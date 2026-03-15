package com.example;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/GetLiveCountServlet")
public class GetLiveCountServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String sid = request.getParameter("sid");
        int count = 0;

        try (Connection con = DbConnection.getConne()) {
            String sql = "SELECT COUNT(*) FROM student_attendance WHERE subject_id = ? AND attendance_date = CURRENT_DATE";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(sid));
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
            response.getWriter().write(String.valueOf(count));
        } catch (Exception e) {
            response.getWriter().write("0");
        }
    }
}