<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Marks Audit | Direct Selection</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/adminHeaderFooter.css">
    <style>
        .filter-card { background: #fff; padding: 40px; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); max-width: 600px; margin: 50px auto; border: 1px solid #e2e8f0; }
        .form-group { margin-bottom: 25px; }
        .form-group label { display: block; font-weight: 700; margin-bottom: 10px; color: #1e293b; font-size: 0.95rem; }
        .custom-select { width: 100%; padding: 14px; border: 2px solid #cbd5e1; border-radius: 10px; font-size: 1rem; background: white; outline: none; }
        .custom-select:focus { border-color: #0056b3; }
        .btn-view { width: 100%; padding: 16px; background: #0f172a; color: white; border: none; border-radius: 10px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 10px; transition: 0.3s; }
        .btn-view:hover { background: #1e293b; transform: translateY(-2px); }
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
<body style="background: #f1f5f9;">

    <%@ include file="admin_header.jsp" %>

    <div class="filter-card">
    <a href="admin_dashboard.jsp" class="btn-back mt-4 sm:mt-0">
                    <i class="fas fa-arrow-left"></i>Back to List
                </a>
        <div style="text-align: center; margin-bottom: 30px;">
            <i class="fas fa-list-check" style="font-size: 40px; color: #0056b3; margin-bottom: 15px;"></i>
            <h2 style="margin:0; color: #0f172a;">View Student Marks</h2>
            <p style="color: #64748b;">Select criteria to generate the marks ledger</p>
        </div>

        <form action="adminViewMarks.jsp" method="GET">
            <div class="form-group">
                <label>Select Subject</label>
                <select name="sid" class="custom-select" required>
                    <option value="" disabled selected>-- Choose Subject --</option>
                    <%
                    try (Connection con = DbConnection.getConne();
                         Statement st = con.createStatement();
                         ResultSet rs = st.executeQuery("SELECT subject_id, subject_name FROM subjects ORDER BY subject_name")) {
                        while (rs.next()) {
                            out.print("<option value='" + rs.getInt("subject_id") + "'>" + rs.getString("subject_name") + "</option>");
                        }
                        
                    } catch (Exception e) { e.printStackTrace(); }
                    %>
                </select>
            </div>

            <div class="form-group">
                <label>Select Class</label>
                <select name="cls" class="custom-select" required>
                    <option value="" disabled selected>-- Choose Class --</option>
                    <option value="MSC-CS">MSc Computer Science</option>
                    <option value="MCA">MCA</option>
                    <option value="BTECH-IT">B.Tech IT</option>
                </select>
            </div>

            <div class="form-group">
                <label>Batch Year (Join Year)</label>
                <select name="yr" class="custom-select" required>
                    <option value="" disabled selected>-- Select Year --</option>
                    <% 
                    int currentYear = java.time.Year.now().getValue();
                    for(int i = currentYear; i >= 2020; i--) { 
                    %>
                        <option value="<%= i %>"><%= i %></option>
                    <% } %>
                </select>
            </div>

            <button type="submit" class="btn-view">
                <i class="fas fa-table"></i> Generate Marks Report
            </button>
        </form>
    </div>
   <%@ include file="../footer.jsp" %>

</body>
</html>