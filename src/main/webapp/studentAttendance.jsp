<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection, java.text.SimpleDateFormat" %>
<%
    String regdno = (String) session.getAttribute("regdno");
    if (regdno == null) { response.sendRedirect("login/login.jsp"); return; }

    // Date Filtering Logic
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    
    // Default endDate to today if not provided
    if (endDate == null || endDate.isEmpty()) {
        endDate = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Attendance</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/studentHeaderFooter.css">
    <style>
        .attendance-container { max-width: 900px; margin: 20px auto; background: #fff; padding: 25px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
        .filter-section { display: flex; gap: 15px; align-items: flex-end; margin-bottom: 25px; background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; }
        .filter-group { display: flex; flex-direction: column; gap: 5px; }
        .filter-group label { font-size: 0.85rem; font-weight: 600; color: var(--text-medium); }
        .date-input { padding: 8px; border: 1px solid var(--border-color); border-radius: 5px; }
        .btn-filter { background: var(--primary-blue); color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer; height: 38px; }
        
        .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 15px; margin-bottom: 25px; }
        .stat-card { padding: 15px; border-radius: 10px; text-align: center; border: 1px solid #e2e8f0; }
        .stat-card h4 { margin: 0; color: var(--text-light); font-size: 0.9rem; }
        .stat-card p { margin: 5px 0 0; font-size: 1.5rem; font-weight: 700; color: var(--primary-blue); }
        
        .attendance-table { width: 100%; border-collapse: collapse; }
        .attendance-table th { text-align: left; padding: 12px; background: #f1f5f9; border-bottom: 2px solid #e2e8f0; }
        .attendance-table td { padding: 12px; border-bottom: 1px solid #eee; }
        .status-present { color: var(--success-color); font-weight: 600; }
        .status-absent { color: var(--danger-color); font-weight: 600; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <main class="page-content">
        <div class="attendance-container">
            <h3><i class="fas fa-calendar-check"></i> Attendance Record</h3>
            
            <form class="filter-section" method="GET">
                <div class="filter-group">
                    <label>From Date</label>
                    <input type="date" name="startDate" value="<%= startDate != null ? startDate : "" %>" class="date-input">
                </div>
                <div class="filter-group">
                    <label>To Date</label>
                    <input type="date" name="endDate" value="<%= endDate %>" class="date-input">
                </div>
                <button type="submit" class="btn-filter">Filter</button>
            </form>

            <%
                int totalClasses = 0;
                int presentCount = 0;
                StringBuilder tableRows = new StringBuilder();

                try (Connection con = DbConnection.getConne()) {
                    String sql = "SELECT a.attendance_date, a.status, s.subject_name " +
                                 "FROM student_attendance a " +
                                 "JOIN subjects s ON a.subject_id = s.subject_id " +
                                 "WHERE a.regd_no = ? ";
                    
                    if (startDate != null && !startDate.isEmpty()) {
                        sql += "AND a.attendance_date >= '" + startDate + "' ";
                    }
                    sql += "AND a.attendance_date <= '" + endDate + "' ";
                    sql += "ORDER BY a.attendance_date DESC";

                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1, regdno);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        totalClasses++;
                        String status = rs.getString("status");
                        if ("Present".equalsIgnoreCase(status)) presentCount++;
                        
                        tableRows.append("<tr>")
                                 .append("<td>").append(rs.getString("attendance_date")).append("</td>")
                                 .append("<td>").append(rs.getString("subject_name")).append("</td>")
                                 .append("<td class='").append(status.equalsIgnoreCase("Present") ? "status-present" : "status-absent").append("'>")
                                 .append(status).append("</td>")
                                 .append("</tr>");
                    }
                } catch (Exception e) { e.printStackTrace(); }

                double percentage = (totalClasses > 0) ? (double) presentCount / totalClasses * 100 : 0;
            %>

            <div class="stat-grid">
                <div class="stat-card"><h4>Total Classes</h4><p><%= totalClasses %></p></div>
                <div class="stat-card"><h4>Attended</h4><p><%= presentCount %></p></div>
                <div class="stat-card"><h4>Percentage</h4><p><%= String.format("%.2f", percentage) %>%</p></div>
            </div>

            <table class="attendance-table">
                <thead>
                    <tr><th>Date</th><th>Subject</th><th>Status</th></tr>
                </thead>
                <tbody>
                    <%= tableRows.length() > 0 ? tableRows.toString() : "<tr><td colspan='3' style='text-align:center'>No records found.</td></tr>" %>
                </tbody>
            </table>
        </div>
    </main>
    <%@ include file="footer.jsp" %>
</body>
</html>