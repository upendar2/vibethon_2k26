<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<%@ include file="staff_header.jsp" %>

<%
    String subjectId = request.getParameter("sid");
    String className = request.getParameter("cls");
    String yearStr = request.getParameter("yr");
    
    String todayDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    String selectedDate = request.getParameter("viewDate");
    if (selectedDate == null || selectedDate.equals("")) {
        selectedDate = todayDate;
    }

    boolean isReadOnly = !selectedDate.equals(todayDate);
    String subjectName = "Attendance Registry";

    try {
        Connection con = DbConnection.getConne();
        PreparedStatement psSub = con.prepareStatement("SELECT subject_name FROM subjects WHERE subject_id = ?");
        psSub.setInt(1, Integer.parseInt(subjectId));
        ResultSet rsSub = psSub.executeQuery();
        if(rsSub.next()) subjectName = rsSub.getString("subject_name");
        con.close();
    } catch(Exception e) { e.printStackTrace(); }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Attendance Manager | AU IT&CA</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/adminHeaderFooter.css">
    <style>
        body { font-family: 'Inter', sans-serif; color: #1e293b; background: #f1f5f9; }
        .attendance-container { max-width: 1000px; margin: 30px auto; background: white; padding: 40px; border-radius: 16px; box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1); }
        
        /* Table Layout */
        .data-table { width: 100%; border-collapse: collapse; }
        .data-table th { text-align: left; padding: 15px; background: #f8fafc; color: #64748b; font-size: 0.8rem; text-transform: uppercase; border-bottom: 2px solid #e2e8f0; }
        .data-table td { padding: 12px 15px; border-bottom: 1px solid #e2e8f0; vertical-align: middle; }
        
        /* High Visibility Registration Number */
        .reg-no-text { font-size: 1.1rem; font-weight: 800; color: #0f172a; letter-spacing: -0.02em; }
        .student-name { font-weight: 500; color: #475569; font-size: 1rem; }

        /* Button Group Styling */
        .status-group { display: flex; gap: 4px; background: #f1f5f9; padding: 4px; border-radius: 10px; width: fit-content; margin: 0 auto; }
        
        .toggle-btn { 
            border: none; padding: 8px 20px; border-radius: 7px; font-weight: 700; font-size: 0.85rem;
            cursor: pointer; transition: all 0.2s; color: #64748b; background: transparent;
        }

        /* Active States */
        input[value="Present"]:checked + .toggle-btn { background: #10b981; color: white; box-shadow: 0 4px 6px -1px rgba(16, 185, 129, 0.3); }
        input[value="Absent"]:checked + .toggle-btn { background: #ef4444; color: white; box-shadow: 0 4px 6px -1px rgba(239, 68, 68, 0.3); }
        
        .hidden-radio { display: none; }
        
        /* Focus Effect for Shortcuts */
        .row-focus { background: #f0f9ff; }
        .status-group:focus-within { outline: 2px solid #3b82f6; outline-offset: 4px; }

        /* Badge for Read-Only */
        .badge { padding: 8px 16px; border-radius: 8px; font-weight: 700; font-size: 0.9rem; }
        .badge-present { background: #dcfce7; color: #166534; }
        .badge-absent { background: #fee2e2; color: #991b1b; }

        .save-footer { margin-top: 35px; display: flex; justify-content: space-between; align-items: center; padding-top: 20px; border-top: 2px solid #f1f5f9; }
        .btn-submit { background: #0f172a; color: white; border: none; padding: 14px 40px; border-radius: 10px; font-weight: 700; cursor: pointer; font-size: 1rem; }
    </style>
</head>
<body style="padding-top: 80px;">

    <div class="attendance-container">
        <div style="margin-bottom: 30px;">
            <h2 style="margin:0; font-weight: 800; color: #0f172a;"><%= subjectName %></h2>
            <p style="margin:5px 0; color: #3b82f6; font-weight: 600; font-size: 1.1rem;"><%= className %> • Session <%= yearStr %></p>
        </div>

        <form id="attendanceForm" action="${pageContext.request.contextPath}/SaveDailyAttendanceServlet" method="POST">
            <input type="hidden" name="subjectId" value="<%= subjectId %>">
            <input type="hidden" name="attendanceDate" value="<%= selectedDate %>">
            
            <table class="data-table" id="attendanceTable">
                <thead>
                    <tr>
                        <th style="width: 220px;">Regd. Number</th>
                        <th>Student Name</th>
                        <th style="text-align: center;">Attendance Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try {
                            Connection con = DbConnection.getConne();
                            String sql = "SELECT s.regd_no, s.name, a.status FROM students s LEFT JOIN student_attendance a ON s.regd_no = a.regd_no AND a.subject_id = ? AND a.attendance_date = ?::date WHERE s.class = ? AND s.joinyear = ? ORDER BY s.regd_no ASC";
                            PreparedStatement ps = con.prepareStatement(sql);
                            ps.setInt(1, Integer.parseInt(subjectId));
                            ps.setString(2, selectedDate);
                            ps.setString(3, className);
                            ps.setInt(4, Integer.parseInt(yearStr));
                            ResultSet rs = ps.executeQuery();
                            int rowIdx = 0;
                            while (rs.next()) {
                                String rno = rs.getString("regd_no");
                                String status = (rs.getString("status") != null) ? rs.getString("status") : "Present"; 
                    %>
                        <tr class="attendance-row" id="row_<%= rowIdx %>">
                            <td class="reg-no-text"><%= rno %></td>
                            <td class="student-name"><%= rs.getString("name") %></td>
                            <td style="text-align: center;">
                                <% if (!isReadOnly) { %>
                                    <div class="status-group" tabindex="0" data-row="<%= rowIdx %>">
                                        <label>
                                            <input type="radio" name="status_<%= rno %>" value="Present" class="hidden-radio" <%= status.equals("Present")?"checked":"" %>>
                                            <span class="toggle-btn">PRESENT</span>
                                        </label>
                                        <label>
                                            <input type="radio" name="status_<%= rno %>" value="Absent" class="hidden-radio" <%= status.equals("Absent")?"checked":"" %>>
                                            <span class="toggle-btn">ABSENT</span>
                                        </label>
                                    </div>
                                <% } else { %>
                                    <span class="badge <%= status.equals("Present") ? "badge-present" : "badge-absent" %>">
                                        <%= status.toUpperCase() %>
                                    </span>
                                <% } %>
                            </td>
                        </tr>
                    <% rowIdx++; } con.close(); } catch (Exception e) { e.printStackTrace(); } %>
                </tbody>
            </table>

            <% if (!isReadOnly) { %>
                <div class="save-footer">
                    <div style="color: #64748b; font-size: 0.9rem; font-weight: 600;">
                        <i class="fa-solid fa-keyboard"></i> Use <kbd>P</kbd> or <kbd>A</kbd> to mark and jump.
                    </div>
                    <button type="submit" class="btn-submit">
                        <i class="fa-solid fa-cloud-arrow-up"></i> SAVE ATTENDANCE
                    </button>
                </div>
            <% } %>
        </form>
    </div>

    <script>
        // Default focus on first row
        window.onload = () => {
            const firstGroup = document.querySelector('.status-group');
            if(firstGroup) firstGroup.focus();
        };

        document.addEventListener('keydown', function(e) {
            const activeGroup = document.activeElement;
            if (!activeGroup || !activeGroup.classList.contains('status-group')) return;

            const rowIdx = parseInt(activeGroup.dataset.row);
            const key = e.key.toLowerCase();

            if (key === 'p' || key === 'a') {
                e.preventDefault();
                const val = (key === 'p') ? 'Present' : 'Absent';
                const radio = activeGroup.querySelector(`input[value="${val}"]`);
                if(radio) {
                    radio.checked = true;
                    // Visual feedback
                    activeGroup.closest('tr').classList.remove('row-focus');
                    focusNext(rowIdx);
                }
            } else if (e.key === 'ArrowDown') {
                e.preventDefault();
                focusNext(rowIdx);
            } else if (e.key === 'ArrowUp') {
                e.preventDefault();
                focusRow(rowIdx - 1);
            }
        });

        function focusNext(idx) {
            focusRow(idx + 1);
        }

        function focusRow(idx) {
            const nextGroup = document.querySelector(`[data-row="${idx}"]`);
            if (nextGroup) {
                // Clear previous highlights
                document.querySelectorAll('.attendance-row').forEach(r => r.classList.remove('row-focus'));
                // Highlight and focus
                nextGroup.closest('tr').classList.add('row-focus');
                nextGroup.focus();
            }
        }
    </script>
</body>
</html>