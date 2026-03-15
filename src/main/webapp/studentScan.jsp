<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<%
    String sid = request.getParameter("sid");
    String cls = request.getParameter("cls"); // Class Name from QR
    String yr = request.getParameter("yr");   // Join Year from QR
    String tsParam = request.getParameter("ts"); 
    
    long currentTime = System.currentTimeMillis();
    long qrTime = (tsParam != null) ? Long.parseLong(tsParam) : 0;
    boolean isExpired = (currentTime - qrTime) > (3 * 60 * 1000); // 3 Minutes

    String studentIp = request.getHeader("X-Forwarded-For");
    if (studentIp == null || studentIp.isEmpty()) studentIp = request.getRemoteAddr();
    else studentIp = studentIp.split(",")[0].trim();

    boolean isAlreadyMarked = false;
    String subjectName = "Subject";

    try {
        Connection con = DbConnection.getConne();
        // 1. IP Double-Entry Check
        String checkSql = "SELECT 1 FROM student_attendance WHERE subject_id = ? AND attendance_date = CURRENT_DATE AND ip_address = ?";
        PreparedStatement ps = con.prepareStatement(checkSql);
        ps.setInt(1, Integer.parseInt(sid));
        ps.setString(2, studentIp);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) isAlreadyMarked = true;

        // 2. Subject Name for UI
        PreparedStatement psSub = con.prepareStatement("SELECT subject_name FROM subjects WHERE subject_id = ?");
        psSub.setInt(1, Integer.parseInt(sid));
        ResultSet rsSub = psSub.executeQuery();
        if(rsSub.next()) subjectName = rsSub.getString("subject_name");
        con.close();
    } catch(Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Attendance</title>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        body { font-family: sans-serif; background: #f1f5f9; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .card { background: white; padding: 30px; border-radius: 15px; width: 90%; max-width: 380px; text-align: center; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        .input-box { width: 100%; padding: 12px; margin: 15px 0; border: 2px solid #e2e8f0; border-radius: 8px; box-sizing: border-box; font-size: 1rem; }
        .btn { width: 100%; padding: 12px; background: #0056b3; color: white; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; }
    </style>
</head>
<body>
    <div class="card">
        <% if(isExpired) { %>
            <h2 style="color:red;">QR Expired</h2>
            <p>Please ask the teacher for a new QR code.</p>
        <% } else if(isAlreadyMarked) { %>
            <h2 style="color:orange;">Already Marked</h2>
            <p>This device has already submitted attendance for today.</p>
        <% } else { %>
            <h2><%= subjectName %></h2>
            <p>Class: <%= cls %> (<%= yr %>)</p>
            <form id="attForm">
                <input type="hidden" name="sid" value="<%= sid %>">
                <input type="hidden" name="cls" value="<%= cls %>">
                <input type="hidden" name="yr" value="<%= yr %>">
                <input type="hidden" name="ip" value="<%= studentIp %>">
                
                <input type="text" name="regdno" class="input-box" placeholder="Enter Regd Number" required>
                <button type="button" onclick="submitData()" class="btn">Submit Attendance</button>
            </form>
        <% } %>
    </div>

    <script>
    function submitData() {
        const formData = new URLSearchParams(new FormData(document.getElementById('attForm')));
        Swal.fire({ title: 'Verifying...', didOpen: () => Swal.showLoading() });

        fetch('${pageContext.request.contextPath}/SubmitQRServlet', {
            method: 'POST',
            body: formData
        })
        .then(async res => {
            const data = await res.json();
            if(res.ok) {
                Swal.fire('Success', data.message, 'success').then(() => {
                    window.location.href = 'attendanceSuccess.jsp';
                });
            } else {
                Swal.fire('Error', data.message, 'error');
            }
        })
        .catch(() => Swal.fire('Error', 'Connection failed', 'error'));
    }
    </script>
</body>
</html>