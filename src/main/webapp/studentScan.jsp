<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<%
    String sid = request.getParameter("sid");
    String tsParam = request.getParameter("ts"); // Get timestamp from QR
    
    long currentTime = System.currentTimeMillis();
    long qrTime = (tsParam != null) ? Long.parseLong(tsParam) : 0;
    long diffMinutes = (currentTime - qrTime) / (1000 * 60);

    boolean isExpired = (diffMinutes >= 3); // 3 Minute Expiry Logic

    // Capture IP and Check Double Entry (Logic remains same as previous)
    String studentIp = request.getHeader("X-Forwarded-For");
    if (studentIp == null || studentIp.isEmpty()) studentIp = request.getRemoteAddr();
    else studentIp = studentIp.split(",")[0].trim();

    boolean isAlreadyMarked = false;
    // ... (Your existing DB check for isAlreadyMarked goes here) ...
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QR Attendance</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #f1f5f9; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; }
        .scan-card { background: white; width: 90%; max-width: 400px; padding: 30px; border-radius: 16px; box-shadow: 0 10px 25px rgba(0,0,0,0.1); text-align: center; }
        .icon-box { width: 70px; height: 70px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; font-size: 30px; }
        .input-field { width: 100%; padding: 12px; border: 2px solid #e2e8f0; border-radius: 8px; margin-top: 10px; font-size: 1rem; box-sizing: border-box; }
        .submit-btn { width: 100%; background: #0056b3; color: white; border: none; padding: 14px; border-radius: 8px; font-weight: bold; margin-top: 20px; cursor: pointer; }
    </style>
</head>
<body>

<div class="scan-card">
    <% if (isExpired) { %>
        <div class="icon-box" style="background:#fee2e2; color:#dc2626;"><i class="fas fa-hourglass-end"></i></div>
        <h2>QR Expired</h2>
        <p>This QR code has expired. Please ask the teacher to generate a new one.</p>
        <button onclick="location.reload()" class="submit-btn" style="background:#64748b;">Retry Scan</button>

    <% } else if (isAlreadyMarked) { %>
        <div class="icon-box" style="background:#fef3c7; color:#92400e;"><i class="fas fa-user-check"></i></div>
        <h2>Already Recorded</h2>
        <p>Attendance from this device/IP is already submitted for today.</p>

    <% } else { %>
        <div class="icon-box" style="background:#e0f2fe; color:#0056b3;"><i class="fas fa-qrcode"></i></div>
        <h2>Mark Presence</h2>
        <p>QR valid for <%= 3 - diffMinutes %> more minutes.</p>

        <form id="attendanceForm">
            <input type="hidden" name="sid" value="<%= sid %>">
            <input type="hidden" name="ip" value="<%= studentIp %>">
            <input type="hidden" name="dev" value="<%= request.getHeader("User-Agent") %>">

            <div style="text-align:left;">
                <label style="font-weight:600;">Registration Number</label>
                <input type="text" name="regdno" class="input-field" required placeholder="Ex: 424207321001">
            </div>
            
            <button type="button" onclick="submitAttendance()" class="submit-btn">
                Confirm Attendance
            </button>
        </form>
    <% } %>
</div>

<script>
function submitAttendance() {
    const form = document.getElementById('attendanceForm');
    const formData = new FormData(form);

    Swal.fire({
        title: 'Submitting...',
        didOpen: () => { Swal.showLoading(); }
    });

    fetch('${pageContext.request.contextPath}/SubmitQRServlet', {
        method: 'POST',
        body: new URLSearchParams(formData)
    })
    .then(response => {
        if (response.ok) {
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: 'Attendance added successfully!',
            }).then(() => { location.reload(); });
        } else {
            throw new Error();
        }
    })
    .catch(() => {
        Swal.fire({ icon: 'error', title: 'Failed', text: 'Could not mark attendance.' });
    });
}
</script>

</body>
</html>