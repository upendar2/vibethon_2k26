package com.example;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/GetStaffSubjectsServlet")
public class GetStaffSubjectsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String staffId = request.getParameter("staffId");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        StringBuilder json = new StringBuilder("[");
        try (Connection con = DbConnection.getConne()) {
            // SQL exactly matching your schema image
            String sql = "SELECT sa.subject_id, s.subject_name, sa.class_name, sa.join_year " +
                         "FROM staff_assignments sa " +
                         "JOIN subjects s ON sa.subject_id = s.subject_id " +
                         "WHERE sa.staff_id = ?";
            
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, staffId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                // We MANUALLY name the keys here to match the JSP
                json.append("{")
                    .append("\"id\":").append(rs.getInt("subject_id")).append(",")
                    .append("\"name\":\"").append(rs.getString("subject_name")).append("\",")
                    .append("\"cls\":\"").append(rs.getString("class_name")).append("\",")
                    .append("\"yr\":\"").append(rs.getString("join_year")).append("\"")
                    .append("},");
            }
            if (json.length() > 1) json.setLength(json.length() - 1); 
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        
        json.append("]");
        out.print(json.toString());
        out.flush();
    }
}