<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>View Staff Assignments | Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/adminHeaderFooter.css">
    <style>
        .view-container {
            max-width: 1100px;
            margin: 30px auto;
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: var(--shadow);
            border: 1px solid var(--border-color);
        }
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .data-table th {
            background-color: var(--header-bg);
            color: white;
            padding: 12px;
            text-align: left;
        }
        .data-table td {
            padding: 12px;
            border-bottom: 1px solid #eee;
            color: var(--text-dark);
        }
        .data-table tr:hover {
            background-color: #f1f5f9;
        }
        .badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85rem;
            font-weight: 600;
            background: var(--light-blue-bg);
            color: var(--primary-blue);
        }
    </style>
</head>
<body>
    <%@ include file="admin_header.jsp" %>

    <main class="page-content">
        <div class="view-container">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <h2><i class="fas fa-clipboard-list"></i> Staff-Subject Mapping</h2>
                <a href="manageStaff.jsp" class="header-button"><i class="fas fa-plus"></i> Add New Assignment</a>
            </div>

            <table class="data-table">
                <thead>
                    <tr>
                        <th>Staff Name</th>
                        <th>Subject</th>
                        <th>Class</th>
                        <th>Batch Year</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection con = DbConnection.getConne();
                            // Join tables to get Name and Subject Title
                            String sql = "SELECT sa.assignment_id, u.name as staff_name, s.subject_name, " +
                                         "sa.class_name, sa.join_year " +
                                         "FROM staff_assignments sa " +
                                         "JOIN users u ON sa.staff_id = u.id " +
                                         "JOIN subjects s ON sa.subject_id = s.subject_id " +
                                         "ORDER BY sa.join_year DESC, sa.class_name ASC";
                            
                            Statement st = con.createStatement();
                            ResultSet rs = st.executeQuery(sql);

                            while(rs.next()) {
                    %>
                        <tr>
                            <td><strong><%= rs.getString("staff_name") %></strong></td>
                            <td><%= rs.getString("subject_name") %></td>
                            <td><span class="badge"><%= rs.getString("class_name") %></span></td>
                            <td><%= rs.getInt("join_year") %></td>
                            <td>
                                <a href="DeleteAssignmentServlet?id=<%= rs.getInt("assignment_id") %>" 
                                   onclick="return confirm('Remove this assignment?')" 
                                   style="color: var(--accent-red);"><i class="fas fa-trash"></i></a>
                            </td>
                        </tr>
                    <%
                            }
                            con.close();
                        } catch(Exception e) {
                            out.print("<tr><td colspan='5'>Error loading data: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
    </main>

    <%@ include file="footer.jsp" %>
</body>
</html>