<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<%@ include file="staff_header.jsp" %>

<%
    String subjectId = request.getParameter("sid");
    String className = request.getParameter("cls");
    String yearStr = request.getParameter("yr");
    
    // Default to today if no date is picked
    String selectedDate = request.getParameter("targetDate");
    if (selectedDate == null || selectedDate.equals("")) {
        selectedDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }

    int totalStudents = 0;
    int totalPresents = 0;
    int totalAbsents = 0;
    double attendancePercentage = 0.0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Attendance Report | AU IT&CA</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/adminHeaderFooter.css">
    
    <style>
        .visit-wrapper { max-width: 1000px; margin: 30px auto; padding: 0 20px; }
        
        /* Top Navigation Bar */
        .top-nav { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .back-link { text-decoration: none; color: #475569; font-weight: 600; display: flex; align-items: center; gap: 8px; transition: 0.2s; }
        .back-link:hover { color: var(--primary-blue); }

        .report-card { background: white; padding: 30px; border-radius: 12px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); border: 1px solid #e2e8f0; }

        /* Stats Dashboard Section */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin: 25px 0; }
        .stat-box { padding: 20px; border-radius: 10px; text-align: center; border: 1px solid #f1f5f9; }
        .stat-value { display: block; font-size: 1.8rem; font-weight: 800; margin-bottom: 5px; }
        .stat-label { font-size: 0.8rem; font-weight: 600; color: #64748b; text-transform: uppercase; }
        
        .bg-blue { background: #eff6ff; color: #1e40af; }
        .bg-green { background: #f0fdf4; color: #166534; }
        .bg-red { background: #fef2f2; color: #991b1b; }
        .bg-gold { background: #fffbeb; color: #92400e; }

        /* Table Styling */
        .data-table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .data-table th { background: #f8fafc; padding: 15px; text-align: left; border-bottom: 2px solid #e2e8f0; color: #475569; }
        .data-table td { padding: 15px; border-bottom: 1px solid #f1f5f9; }
        
        .status-pill { padding: 5px 12px; border-radius: 20px; font-weight: bold; font-size: 0.8rem; }
        .present-pill { background: #dcfce7; color: #15803d; }
        .absent-pill { background: #fee2e2; color: #b91c1c; }

        @media (max-width: 768px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
    </style>
</head>
<body style="background: #f1f5f9; padding-top: 85px;">

    <div class="visit-wrapper">
        
        <div class="top-nav">
            <a href="staff_dashboard.jsp" class="back-link">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
            <div class="date-display">
                <i class="far fa-calendar-check"></i> <strong><%= selectedDate %></strong>
            </div>
        </div>

        <div class="report-card">
            <h2 style="margin:0; color:#1e293b;"><%= className %> Attendance Log</h2>
            <p style="color: #64748b; margin-top:5px;">Subject ID: <%= subjectId %> | Batch: <%= yearStr %></p>

            <form action="visitAttendance.jsp" method="GET" style="margin-top:20px; display:flex; gap:10px; align-items:flex-end;">
                <input type="hidden" name="sid" value="<%= subjectId %>">
                <input type="hidden" name="cls" value="<%= className %>">
                <input type="hidden" name="yr" value="<%= yearStr %>">
                <div style="flex-grow:1">
                    <label style="font-size:0.8rem; font-weight:700; color:#475569">Change Date:</label>
                    <input type="date" name="targetDate" value="<%= selectedDate %>" class="form-control" style="width:100%; padding:8px; margin-top:5px;">
                </div>
                <button type="submit" class="save-btn" style="margin:0; padding:10px 20px; background:#3b82f6;">
                    <i class="fas fa-filter"></i> Visit
                </button>
            </form>

            <%
                // Fetch data and calculate stats
                try {
                    Connection con = DbConnection.getConne();
                    // Query to get student list + attendance for that specific date
                    String sql = "SELECT s.regd_no, s.name, a.status " +
                                 "FROM students s " +
                                 "LEFT JOIN student_attendance a ON s.regd_no = a.regd_no " +
                                 "AND a.subject_id = ? AND a.attendance_date = ?::date " +
                                 "WHERE s.class = ? AND s.joinyear = ? " +
                                 "ORDER BY s.regd_no ASC";
                    
                    PreparedStatement ps = con.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                    ps.setInt(1, Integer.parseInt(subjectId));
                    ps.setString(2, selectedDate);
                    ps.setString(3, className);
                    ps.setInt(4, Integer.parseInt(yearStr));
                    
                    ResultSet rs = ps.executeQuery();
                    
                    // First pass: Calculate stats
                    while(rs.next()){
                        totalStudents++;
                        String status = rs.getString("status");
                        if("Present".equalsIgnoreCase(status)) totalPresents++;
                        else if("Absent".equalsIgnoreCase(status)) totalAbsents++;
                    }
                    if(totalStudents > 0) attendancePercentage = ((double)totalPresents / totalStudents) * 100;
                    
                    // Move cursor back to start for the table
                    rs.beforeFirst();
            %>

            <div class="stats-grid">
                <div class="stat-box bg-blue">
                    <span class="stat-value"><%= totalStudents %></span>
                    <span class="stat-label">Strength</span>
                </div>
                <div class="stat-box bg-green">
                    <span class="stat-value"><%= totalPresents %></span>
                    <span class="stat-label">Presents</span>
                </div>
                <div class="stat-box bg-red">
                    <span class="stat-value"><%= totalAbsents %></span>
                    <span class="stat-label">Absents</span>
                </div>
                <div class="stat-box bg-gold">
                    <span class="stat-value"><%= String.format("%.1f", attendancePercentage) %>%</span>
                    <span class="stat-label">Attendance</span>
                </div>
            </div>

            <table class="data-table">
                <thead>
                    <tr>
                        <th>Registration No</th>
                        <th>Student Name</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% while(rs.next()){ 
                        String status = rs.getString("status");
                    %>
                        <tr>
                            <td><strong><%= rs.getString("regd_no") %></strong></td>
                            <td><%= rs.getString("name") %></td>
                            <td>
                                <% if(status != null) { %>
                                    <span class="status-pill <%= status.equalsIgnoreCase("Present") ? "present-pill" : "absent-pill" %>">
                                        <i class="fas <%= status.equalsIgnoreCase("Present") ? "fa-check" : "fa-x" %>"></i> 
                                        <%= status.toUpperCase() %>
                                    </span>
                                <% } else { %>
                                    <span style="color:#94a3b8; font-size:0.8rem;">No record for this day</span>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
            
            <%
                    con.close();
                } catch(Exception e) {
                    out.print("<div class='bg-red' style='padding:10px; margin-top:20px; border-radius:5px;'>Error: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>

    <%@ include file="../footer.jsp" %>
</body>
</html>