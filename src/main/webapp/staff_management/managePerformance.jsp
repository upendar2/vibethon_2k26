<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<%@ include file="staff_header.jsp" %>

<%
    // Get parameters passed from the dashboard
    String subjectIdStr = request.getParameter("sid");
    String className = request.getParameter("cls");
    String yearStr = request.getParameter("yr");

    if (subjectIdStr == null || className == null) {
        response.sendRedirect("staff_dashboard.jsp");
        return;
    }

    int subjectId = Integer.parseInt(subjectIdStr);
    int joinYear = Integer.parseInt(yearStr);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Manage Performance | AU IT&CA</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/adminHeaderFooter.css">
    <style>
        .performance-card {
            background: white;
            max-width: 1100px;
            margin: 30px auto;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .header-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #f1f5f9;
            padding-bottom: 15px;
            margin-bottom: 25px;
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        .data-table th {
            background: #f8fafc;
            color: var(--text-dark);
            padding: 12px;
            text-align: left;
            border-bottom: 2px solid #e2e8f0;
        }
        .data-table td {
            padding: 12px;
            border-bottom: 1px solid #e2e8f0;
        }
        .mark-input {
            width: 70px;
            padding: 8px;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            text-align: center;
        }
        .save-btn {
            background: #0056b3;
            color: white;
            padding: 12px 25px;
            border: none;
            border-radius: 6px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 20px;
            float: right;
        }
        .save-btn:hover { background: #004494; }
    </style>
</head>
<body style="background-color: #f1f5f9; padding-top: 80px;">

    <div class="performance-card">
        <div class="header-info">
            <div>
                <h2 style="color: var(--primary-blue);"><%= className %> Performance</h2>
                <p style="color: #64748b;">Batch: <%= joinYear %> | Subject ID: <%= subjectId %></p>
            </div>
            <a href="staff_dashboard.jsp" class="header-button"><i class="fas fa-arrow-left"></i> Back</a>
        </div>

        <form action="${pageContext.request.contextPath}/SavePerformanceServlet" method="POST">
            <input type="hidden" name="subjectId" value="<%= subjectId %>">
            <input type="hidden" name="className" value="<%= className %>">
            <input type="hidden" name="joinYear" value="<%= joinYear %>">

            <table class="data-table">
                <thead>
                    <tr>
                        <th>Regd No</th>
                        <th>Student Name</th>
                        <th>Mid-1 (20)</th>
                        <th>Mid-2 (20)</th>
                        <th>Attendance (%)</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection con = DbConnection.getConne();
                            // Left join to get existing marks if they exist
                            String sql = "SELECT s.regd_no, s.name, p.mid1_marks, p.mid2_marks, p.attendance_percent " +
                                         "FROM students s " +
                                         "LEFT JOIN student_performance p ON s.regd_no = p.regd_no AND p.subject_id = ? " +
                                         "WHERE s.class_name = ? AND s.join_year = ? " +
                                         "ORDER BY s.regd_no ASC";
                            
                            PreparedStatement ps = con.prepareStatement(sql);
                            ps.setInt(1, subjectId);
                            ps.setString(2, className);
                            ps.setInt(3, joinYear);
                            ResultSet rs = ps.executeQuery();

                            while (rs.next()) {
                                String rno = rs.getString("regd_no");
                    %>
                        <tr>
                            <td><strong><%= rno %></strong></td>
                            <td><%= rs.getString("name") %></td>
                            <td>
                                <input type="number" name="mid1_<%= rno %>" value="<%= rs.getInt("mid1_marks") %>" class="mark-input" min="0" max="20">
                            </td>
                            <td>
                                <input type="number" name="mid2_<%= rno %>" value="<%= rs.getInt("mid2_marks") %>" class="mark-input" min="0" max="20">
                            </td>
                            <td>
                                <input type="number" name="att_<%= rno %>" value="<%= rs.getBigDecimal("attendance_percent") %>" class="mark-input" step="0.01" min="0" max="100">
                            </td>
                        </tr>
                    <%
                            }
                            con.close();
                        } catch (Exception e) { e.printStackTrace(); }
                    %>
                </tbody>
            </table>
            <button type="submit" class="save-btn"><i class="fas fa-save"></i> Save All Records</button>
        </form>
        <div style="clear: both;"></div>
    </div>

</body>
</html>