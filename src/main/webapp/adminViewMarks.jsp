<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>


<%
    String subjectId = request.getParameter("sid");
    String className = request.getParameter("cls");
    String yearStr = request.getParameter("yr");
    String midType = request.getParameter("midType");
    if(midType == null) midType = "mid1";

    // New Variable for Subject Name
    String subjectName = "Loading..."; 
    int passCount = 0;
    int failCount = 0;
    int totalStudents = 0;

    // Fetch Subject Name from Database
    try {
        Connection con = DbConnection.getConne();
        String subSql = "SELECT subject_name FROM subjects WHERE subject_id = ?";
        PreparedStatement psSub = con.prepareStatement(subSql);
        psSub.setInt(1, Integer.parseInt(subjectId));
        ResultSet rsSub = psSub.executeQuery();
        if(rsSub.next()) {
            subjectName = rsSub.getString("subject_name");
        }
        con.close();
    } catch(Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Marks Analysis | AU IT&CA</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/adminHeaderFooter.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { font-family: 'Inter', sans-serif; color: #334155; }
        .marks-container { box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); }
        
        /* Professional Table Styling */
        .data-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .data-table th { 
            background-color: #f8fafc; 
            color: #64748b; 
            text-transform: uppercase; 
            font-size: 12px; 
            letter-spacing: 0.05em; 
            padding: 12px 15px; 
            border-bottom: 2px solid #e2e8f0;
            text-align: left;
        }
        .data-table td { padding: 14px 15px; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
        .data-table tr:hover { background-color: #f8fafc; }

        /* Badge Styling */
        .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 5px; }
        .badge-pass { background: #dcfce7; color: #166534; }
        .badge-fail { background: #fee2e2; color: #991b1b; }

        /* Form styling */
        .select-input { 
            padding: 8px 12px; 
            border: 1px solid #cbd5e1; 
            border-radius: 6px; 
            outline: none; 
            cursor: pointer;
            font-family: inherit;
        }
        .back-link { text-decoration: none; color: #64748b; font-weight: 500; transition: color 0.2s; }
        .back-link:hover { color: #0056b3; }

        /* Summary Cards */
        .summary-box { display: flex; gap: 20px; margin-bottom: 25px; }
        .stat-card { background: #f8fafc; padding: 15px; border-radius: 8px; flex: 1; border: 1px solid #e2e8f0; }
        .stat-card small { color: #64748b; display: block; margin-bottom: 5px; }
        .stat-card span { font-size: 20px; font-weight: 700; color: #1e293b; }
        
        /* New Style for Subject Display */
        .subject-header {
            background: #f1f5f9;
            padding: 10px 15px;
            border-radius: 6px;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            color: #475569;
            font-weight: 600;
            margin-bottom: 15px;
        }
         .btn-back {
            padding: 8px 15px;
            border-radius: 6px;
            color: var(--text-label);
            font-weight: 600;
            text-decoration: none;
            background-color: #e5e7eb; /* Tailwind gray-200 */
            transition: background-color 0.2s;
            border: 1px solid var(--border-color);
            display: inline-flex; /* Align icon and text */
            align-items: center;
        }
        .btn-back:hover {
            background-color: #d1d5db; /* Tailwind gray-300 */
        }
    </style>
</head>

<body style="background: #f1f5f9; padding-top: 85px;">
<%@ include file="admin_header.jsp" %>
    <div class="marks-container" style="max-width:1000px; margin:auto; background:white; padding:40px; border-radius:12px;">
        
        <div class="top-nav" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:30px;">
             <a href="adminMarksDirectFilter.jsp" class="btn-back mt-4 sm:mt-0">
                    <i class="fas fa-arrow-left"></i>Back to List
                </a>
            <form method="GET" action="adminViewMarks.jsp">
                <input type="hidden" name="sid" value="<%= subjectId %>">
                <input type="hidden" name="cls" value="<%= className %>">
                <input type="hidden" name="yr" value="<%= yearStr %>">
                <select name="midType" onchange="this.form.submit()" class="select-input">
                    <option value="mid1" <%= midType.equals("mid1")?"selected":"" %>>Assessment: Mid-Term 1</option>
                    <option value="mid2" <%= midType.equals("mid2")?"selected":"" %>>Assessment: Mid-Term 2</option>
                </select>
            </form>
        </div>

        <div style="margin-bottom: 20px;">
            <div class="subject-header">
                <i class="fas fa-book"></i> Subject: <%= subjectName %>
            </div>
            <h2 style="color:#1e293b; margin:0;"><%= midType.toUpperCase() %> Performance Report</h2>
            <p style="color:#64748b; margin:5px 0 0 0;">Class: <%= className %> | Year: <%= yearStr %></p>
        </div>

        <table class="data-table">
            <thead>
                <tr>
                    <th>Registration No</th>
                    <th>Student Name</th>
                    <th>Score (Out of 20)</th>
                    <th>Performance Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try {
                        Connection con = DbConnection.getConne();
                        String sql = "SELECT s.regd_no, s.name, m.mid1_marks, m.mid2_marks " +
                                     "FROM students s " +
                                     "LEFT JOIN student_marks m ON s.regd_no = m.regd_no AND m.subject_id = ? " +
                                     "WHERE s.class= ? AND s.joinyear = ? ORDER BY s.regd_no ASC";
                        PreparedStatement ps = con.prepareStatement(sql);
                        ps.setInt(1, Integer.parseInt(subjectId));
                        ps.setString(2, className);
                        ps.setInt(3, Integer.parseInt(yearStr));
                        ResultSet rs = ps.executeQuery();
                        while(rs.next()){
                            int score = midType.equals("mid1") ? rs.getInt("mid1_marks") : rs.getInt("mid2_marks");
                            totalStudents++;
                            if(score >= 8) passCount++; else failCount++;
                %>
                    <tr>
                        <td style="font-family: monospace; font-weight: 600;"><%= rs.getString("regd_no") %></td>
                        <td style="font-weight: 500;"><%= rs.getString("name") %></td>
                        <td style="font-weight:700; font-size: 16px;"><%= score %></td>
                        <td>
                            <% if(score >= 8) { %>
                                <span class="status-badge badge-pass"><i class="fas fa-check-circle"></i> Qualified</span>
                            <% } else { %>
                                <span class="status-badge badge-fail"><i class="fas fa-exclamation-circle"></i> Remark</span>
                            <% } %>
                        </td>
                    </tr>
                <% } con.close(); } catch(Exception e){ out.print(e.getMessage()); } %>
            </tbody>
        </table>

        <div class="summary-box" style="margin-top: 30px; border-top: 1px solid #e2e8f0; padding-top: 20px;">
            <div class="stat-card">
                <small>Total Students</small>
                <span><%= totalStudents %></span>
            </div>
            <div class="stat-card">
                <small>Qualified</small>
                <span style="color: #166534;"><%= passCount %></span>
            </div>
            <div class="stat-card">
                <small>Remarks Required</small>
                <span style="color: #991b1b;"><%= failCount %></span>
            </div>
        </div>
    </div>
    <%@ include file="../footer.jsp" %>
</body>
</html>