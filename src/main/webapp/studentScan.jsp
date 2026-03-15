<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<%
    // 1. Capture the Subject ID from the QR link
    String sid = request.getParameter("sid");
    
    // 2. Capture the REAL Student IP (Handling Render's Proxy)
    String studentIp = request.getHeader("X-Forwarded-For");
    if (studentIp == null || studentIp.isEmpty()) {
        studentIp = request.getRemoteAddr();
    } else {
        // Render's X-Forwarded-For can be a comma-separated list; take the first one
        studentIp = studentIp.split(",")[0].trim();
    }
    
    // 3. Capture Device Fingerprint (User Agent)
    String deviceId = request.getHeader("User-Agent");

    boolean isAlreadyMarked = false;
    String subjectName = "Subject";

    try {
        Connection con = DbConnection.getConne();
        
        // Check if this IP has already been used today for this specific subject
        String checkSql = "SELECT 1 FROM student_attendance WHERE subject_id = ? AND attendance_date = CURRENT_DATE AND ip_address = ?";
        PreparedStatement ps = con.prepareStatement(checkSql);
        ps.setInt(1, Integer.parseInt(sid));
        ps.setString(2, studentIp);
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            isAlreadyMarked = true;
        }

        // Fetch subject name for display
        PreparedStatement psSub = con.prepareStatement("SELECT subject_name FROM subjects WHERE subject_id = ?");
        psSub.setInt(1, Integer.parseInt(sid));
        ResultSet rsSub = psSub.executeQuery();
        if(rsSub.next()) subjectName = rsSub.getString("subject_name");

        con.close();
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mark Attendance | AU Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        :root { --primary: #0056b3; --error: #dc2626; --success: #10b981; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f1f5f9; margin: 0; display: flex; align-items: center; justify-content: center; min-height: 100vh; }
        .scan-card { background: white; width: 90%; max-width: 400px; padding: 30px; border-radius: 16px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); text-align: center; }
        .icon-circle { width: 70px; height: 70px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; font-size: 30px; }
        .bg-err { background: #fee2e2; color: var(--error); }
        .bg-std { background: #e0f2fe; color: var(--primary); }
        h2 { margin: 0 0 10px; color: #1e293b; }
        p { color: #64748b; font-size: 0.95rem; line-height: 1.5; }
        .form-group { text-align: left; margin-top: 25px; }
        label { display: block; font-weight: 600; margin-bottom: 8px; color: #475569; }
        .input-field { width: 100%; padding: 12px; border: 2px solid #e2e8f0; border-radius: 8px; box-sizing: border-box; font-size: 1rem; transition: 0.3s; }
        .input-field:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 4px rgba(0, 86, 179, 0.1); }
        .submit-btn { width: 100%; background: var(--primary); color: white; border: none; padding: 14px; border-radius: 8px; font-size: 1rem; font-weight: 700; margin-top: 20px; cursor: pointer; transition: 0.2s; }
        .submit-btn:hover { background: #004494; transform: translateY(-1px); }
        .ip-badge { display: inline-block; font-size: 0.75rem; background: #f8fafc; padding: 4px 10px; border-radius: 4px; color: #94a3b8; margin-top: 15px; }
    </style>
</head>
<body>

    <div class="scan-card">
        <% if(isAlreadyMarked) { %>
            <div class="icon-circle bg-err">
                <i class="fas fa-user-lock"></i>
            </div>
            <h2>Access Denied</h2>
            <p>Attendance has already been recorded from this device/network for <strong><%= subjectName %></strong> today.</p>
            <p style="font-size: 0.8rem;">To prevent fraud, only one submission per device is allowed.</p>
        <% } else { %>
            <div class="icon-circle bg-std">
                <i class="fas fa-qrcode"></i>
            </div>
            <h2>Verify Identity</h2>
            <p>You are marking attendance for:<br><strong><%= subjectName %></strong></p>

            <form action="${pageContext.request.contextPath}/SubmitQRServlet" method="POST">
                <input type="hidden" name="sid" value="<%= sid %>">
                <input type="hidden" name="ip" value="<%= studentIp %>">
                <input type="hidden" name="dev" value="<%= deviceId %>">

                <div class="form-group">
                    <label for="regdno">Registration Number</label>
                    <input type="text" id="regdno" name="regdno" class="input-field" 
                           placeholder="Ex: 424207321001" required autocomplete="off">
                </div>
                
                <button type="submit" class="submit-btn">
                    <i class="fas fa-check-circle"></i> Confirm Presence
                </button>
            </form>
        <% } %>

        <div class="ip-badge">
            Network ID: <%= studentIp %>
        </div>
    </div>

</body>
</html>