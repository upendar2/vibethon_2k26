<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<%@ include file="staff_header.jsp" %>

<%
    String subjectId = request.getParameter("sid");
    String className = request.getParameter("cls");
    String yearStr = request.getParameter("yr");
    
    boolean isAlreadySubmitted = false;
    String subjectName = "Subject";

    try {
        Connection con = DbConnection.getConne();
        PreparedStatement psSub = con.prepareStatement("SELECT subject_name FROM subjects WHERE subject_id = ?");
        psSub.setInt(1, Integer.parseInt(subjectId));
        ResultSet rsSub = psSub.executeQuery();
        if(rsSub.next()) subjectName = rsSub.getString("subject_name");

        PreparedStatement psCheck = con.prepareStatement("SELECT 1 FROM student_marks WHERE subject_id = ? AND regd_no IN (SELECT regd_no FROM students WHERE class = ?) LIMIT 1");
        psCheck.setInt(1, Integer.parseInt(subjectId));
        psCheck.setString(2, className);
        ResultSet rsCheck = psCheck.executeQuery();
        if(rsCheck.next()) isAlreadySubmitted = true;
        
        con.close();
    } catch(Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Manage Internal Marks | AU IT&CA</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/adminHeaderFooter.css">
    
    <style>
        body { font-family: 'Inter', sans-serif; color: #1e293b; }
        .marks-container { max-width: 1050px; margin: 20px auto; background: white; padding: 35px; border-radius: 12px; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }
        
        /* Navigation Bar */
        .top-nav { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; padding-bottom: 15px; }

        /* Professional Input Styling */
        input[type=number]::-webkit-inner-spin-button, 
        input[type=number]::-webkit-outer-spin-button { -webkit-appearance: none; margin: 0; }
        input[type=number] { -moz-appearance: textfield; }

        .mark-input { 
            width: 70px; 
            padding: 10px; 
            border: 1.5px solid #e2e8f0; 
            border-radius: 8px; 
            text-align: center; 
            font-weight: 600; 
            font-size: 1rem; 
            transition: all 0.2s ease;
            color: #0f172a;
        }
        .mark-input:focus { border-color: #3b82f6; background: #f8fafc; outline: none; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }
        .mark-input:disabled { background: #f1f5f9; color: #94a3b8; cursor: not-allowed; border-color: #f1f5f9; }
        
        /* Table Design */
        .data-table { width: 100%; border-collapse: separate; border-spacing: 0; }
        .data-table th { 
            background: #f8fafc; 
            padding: 14px; 
            font-size: 0.75rem; 
            text-transform: uppercase; 
            letter-spacing: 0.05em; 
            color: #64748b; 
            border-bottom: 2px solid #e2e8f0;
            text-align: left;
        }
        .data-table td { padding: 12px 14px; border-bottom: 1px solid #f1f5f9; font-size: 0.95rem; }
        .focused-row { background-color: #f0f7ff !important; }

        /* Component Styles */
        .header-button { 
            display: inline-flex; align-items: center; gap: 8px; 
            padding: 10px 18px; border-radius: 8px; font-weight: 500; 
            font-size: 0.875rem; transition: transform 0.1s; text-decoration: none;
        }
        .header-button:active { transform: translateY(1px); }
        
        .status-banner { display: flex; align-items: center; gap: 12px; padding: 16px; border-radius: 10px; margin-bottom: 25px; font-size: 0.95rem; }
        .locked-banner { background-color: #fff1f2; color: #9f1239; border: 1px solid #ffe4e6; }
        .info-banner { background-color: #f0f9ff; color: #075985; border: 1px solid #e0f2fe; }

        kbd { 
            background: #fff; border: 1px solid #cbd5e1; border-radius: 4px; 
            padding: 2px 6px; font-family: sans-serif; font-size: 0.8rem; box-shadow: 0 1px 1px rgba(0,0,0,0.1);
        }

        .submit-section { border-top: 1px solid #f1f5f9; margin-top: 30px; padding-top: 20px; display: flex; justify-content: flex-end; }
        .save-btn { 
            background: #0f172a; color: white; border: none; padding: 12px 32px; 
            border-radius: 8px; font-weight: 600; cursor: pointer; display: flex; align-items: center; gap: 10px;
            transition: background 0.2s;
        }
        .save-btn:hover { background: #334155; }
    </style>
</head>
<body style="background: #f8fafc; padding-top: 85px;">

    <div class="marks-wrapper" style="max-width: 1100px; margin: auto; padding: 0 20px;">
        
        <div class="top-nav">
            <a href="staff_dashboard.jsp" class="header-button" style="background:#fff; color:#475569; border:1px solid #e2e8f0; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                <i class="fas fa-arrow-left"></i> Dashboard
            </a>
            
            <div style="text-align: center;">
                <h2 style="margin:0; color:#0f172a; font-weight: 700;"><%= subjectName %></h2>
                <span style="font-size: 0.85rem; color: #64748b; font-weight: 500;">Class: <%= className %> • Session: <%= yearStr %></span>
            </div>

            <a href="visitMarks.jsp?sid=<%= subjectId %>&cls=<%= className %>&yr=<%= yearStr %>" class="header-button" style="background:#3b82f6; color:white;">
                <i class="fas fa-eye"></i> View Reports
            </a>
        </div>

        <div class="marks-container">
            <% if(isAlreadySubmitted) { %>
                <div class="status-banner locked-banner">
                    <i class="fas fa-lock" style="font-size: 1.2rem;"></i>
                    <div>
                        <strong>Entry Locked</strong><br>
                        <small>Records are finalized and cannot be edited. Please contact the administrator for corrections.</small>
                    </div>
                </div>
            <% } else { %>
                <div class="status-banner info-banner">
                    <i class="fas fa-keyboard" style="font-size: 1.2rem;"></i>
                    <div>
                        <strong>Smart Navigation Enabled</strong><br>
                        <small>Use <kbd>↑</kbd> <kbd>↓</kbd> to move between students and <kbd>←</kbd> <kbd>→</kbd> to switch between Mid columns.</small>
                    </div>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/SaveMarksServlet" method="POST" id="marksForm">
                <input type="hidden" name="subjectId" value="<%= subjectId %>">
                
                <table class="data-table" id="marksTable">
                    <thead>
                        <tr>
                            <th style="width: 180px;">Regd No</th>
                            <th>Student Name</th>
                            <th style="text-align:center; width: 140px;">Mid-Term 1</th>
                            <th style="text-align:center; width: 140px;">Mid-Term 2</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection con = DbConnection.getConne();
                                String sql = "SELECT regd_no, name FROM students WHERE class = ? AND joinyear = ? ORDER BY regd_no ASC";
                                PreparedStatement ps = con.prepareStatement(sql);
                                ps.setString(1, className);
                                ps.setInt(2, Integer.parseInt(yearStr));
                                ResultSet rs = ps.executeQuery();
                                int rowIdx = 0;
                                while (rs.next()) {
                                    String rno = rs.getString("regd_no");
                        %>
                            <tr>
                                <td style="font-family: 'JetBrains Mono', monospace; font-size: 0.85rem; color: #475569;"><%= rno %></td>
                                <td style="font-weight: 500;"><%= rs.getString("name") %></td>
                                <td style="text-align:center;">
                                    <input type="number" name="mid1_<%= rno %>" class="mark-input" 
                                           min="0" max="20" required data-row="<%= rowIdx %>" data-col="0"
                                           <%= isAlreadySubmitted ? "disabled value='--'" : "placeholder='0'" %>>
                                </td>
                                <td style="text-align:center;">
                                    <input type="number" name="mid2_<%= rno %>" class="mark-input" 
                                           min="0" max="20" required data-row="<%= rowIdx %>" data-col="1"
                                           <%= isAlreadySubmitted ? "disabled value='--'" : "placeholder='0'" %>>
                                </td>
                            </tr>
                        <%
                                    rowIdx++;
                                }
                                con.close();
                            } catch (Exception e) { e.printStackTrace(); }
                        %>
                    </tbody>
                </table>

                <% if(!isAlreadySubmitted) { %>
                    <div class="submit-section">
                        <button type="submit" class="save-btn">
                            <i class="fas fa-check-double"></i> Finalize & Submit Marks
                        </button>
                    </div>
                <% } %>
            </form>
        </div>
    </div>

    <script>
        const table = document.getElementById('marksTable');
        if(table) {
            table.addEventListener('keydown', function(e) {
                if (e.target.classList.contains('mark-input')) {
                    const row = parseInt(e.target.dataset.row);
                    const col = parseInt(e.target.dataset.col);
                    let target;

                    if (e.key === 'ArrowDown') {
                        e.preventDefault();
                        target = document.querySelector(`[data-row="${row + 1}"][data-col="${col}"]`);
                    } else if (e.key === 'ArrowUp') {
                        e.preventDefault();
                        target = document.querySelector(`[data-row="${row - 1}"][data-col="${col}"]`);
                    } else if (e.key === 'ArrowRight' && e.target.selectionEnd === e.target.value.length) {
                        target = document.querySelector(`[data-row="${row}"][data-col="${col + 1}"]`);
                    } else if (e.key === 'ArrowLeft' && e.target.selectionStart === 0) {
                        target = document.querySelector(`[data-row="${row}"][data-col="${col - 1}"]`);
                    }

                    if (target) {
                        target.focus();
                        target.select();
                    }
                }
            });

            table.addEventListener('focusin', (e) => {
                if(e.target.classList.contains('mark-input')) {
                    e.target.closest('tr').classList.add('focused-row');
                }
            });
            table.addEventListener('focusout', (e) => {
                if(e.target.classList.contains('mark-input')) {
                    e.target.closest('tr').classList.remove('focused-row');
                }
            });
        }
    </script>
</body>
</html>