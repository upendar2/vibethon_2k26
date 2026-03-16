<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<%
    String regdno = (String) session.getAttribute("regdno");
    if (regdno == null) { response.sendRedirect("login/login.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Internal Marks</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/studentHeaderFooter.css">
    <style>
        .marks-container { max-width: 850px; margin: 20px auto; background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); }
        .marks-header { display: flex; align-items: center; gap: 15px; margin-bottom: 30px; border-bottom: 2px solid #f1f5f9; padding-bottom: 15px; }
        .marks-table { width: 100%; border-collapse: collapse; }
        .marks-table th { background: #1e293b; color: white; padding: 15px; text-align: center; }
        .marks-table td { padding: 15px; border-bottom: 1px solid #eee; text-align: center; font-weight: 500; }
        .subject-col { text-align: left !important; color: var(--primary-blue); font-weight: 600 !important; }
        .score-badge { background: #f1f5f9; padding: 5px 12px; border-radius: 15px; color: var(--text-dark); }
        .low-score { color: #e11d48; }
    </style>
</head>
<body>
    <%@ include file="header.jsp" %>
    <main class="page-content">
        <div class="marks-container">
            <div class="marks-header">
                <i class="fas fa-chart-bar fa-2x" style="color: var(--primary-blue);"></i>
                <h2>Mid-Term Assessment Results</h2>
            </div>
            
            <table class="marks-table">
                <thead>
                    <tr>
                        <th class="subject-col">Subject</th>
                        <th>Mid-I (20)</th>
                        <th>Mid-II (20)</th>
                        <th>Avg / Best</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try (Connection con = DbConnection.getConne()) {
                        String sql = "SELECT s.subject_name, m.mid1_marks, m.mid2_marks " +
                                     "FROM student_marks m " +
                                     "JOIN subjects s ON m.subject_id = s.subject_id " +
                                     "WHERE m.regd_no = ?";
                        PreparedStatement ps = con.prepareStatement(sql);
                        ps.setString(1, regdno);
                        ResultSet rs = ps.executeQuery();

                        boolean dataFound = false;
                        while (rs.next()) {
                            dataFound = true;
                            int m1 = rs.getInt("mid1_marks");
                            int m2 = rs.getInt("mid2_marks");
                %>
                    <tr>
                        <td class="subject-col"><%= rs.getString("subject_name") %></td>
                        <td><span class="score-badge <%= m1 < 8 ? "low-score" : "" %>"><%= m1 %></span></td>
                        <td><span class="score-badge <%= m2 < 8 ? "low-score" : "" %>"><%= m2 %></span></td>
                        <td style="font-weight: 700;"><%= (m1 + m2) / 2.0 %></td>
                    </tr>
                <%
                        }
                        if (!dataFound) {
                            out.print("<tr><td colspan='4' style='padding:40px; color:#94a3b8;'>No marks uploaded yet.</td></tr>");
                        }
                    } catch (Exception e) { e.printStackTrace(); }
                %>
                </tbody>
            </table>
        </div>
    </main>
    <%@ include file="footer.jsp" %>
</body>
</html>