<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="staff_header.jsp" %>
<%
    String sid = request.getParameter("sid");
    String cls = request.getParameter("cls");
    String yr = request.getParameter("yr");
    long timestamp = System.currentTimeMillis(); 
%>
<!DOCTYPE html>
<html>
<head>
    <title>QR Session | AU IT&CA</title>
    <%-- Inclde QRsode librdrdy --%>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <style>
        .qr-card { max-width: 500px; margin: 40px auto; background: white; padding: 40px; border-radius: 15px; text-align: center; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        #qrcode-canvas { margin: 25px auto; display: inline-block; padding: 15px; border: 5px solid #0056b3; border-radius: 10px; }
    </style>
</head>
<body style="background: #f1f5f9; padding-top: 80px;">
    <%-- Add this inside your generateQR.jsp layout --%>
<div class="qr-card">
    <h2 style="color:#1e293b;">Live Attendance Session</h2>
    <p><%= cls %> | Batch <%= yr %></p>
    
    <div style="margin: 20px 0; padding: 15px; background: #e0f2fe; border-radius: 10px; border: 2px solid #0056b3;">
        <span style="font-size: 0.9rem; color: #0056b3; font-weight: bold; text-transform: uppercase;">Students Checked In</span>
        <div id="liveCount" style="font-size: 3.5rem; font-weight: 800; color: #1e293b;">0</div>
    </div>

    <div id="qrcode-canvas"></div>
    
    <p id="timer" style="color: #ef4444; font-weight: bold; margin-top:15px;"></p>
</div>

<script>
    // 1. Existing QR Generation Logic
    var currentUrl = window.location.origin;
    var contextPath = "<%= request.getContextPath() %>";
    var studentLink = currentUrl + contextPath + "/studentScan.jsp?sid=<%= sid %>&cls=<%= cls %>&yr=<%= yr %>&ts=<%= timestamp %>";
    new QRCode(document.getElementById("qrcode-canvas"), {
        text: studentLink,
        width: 250,
        height: 250});

    // 2. LIVE COUNT LOGIC
    function updateCount() {
        fetch('${pageContext.request.contextPath}/GetLiveCountServlet?sid=<%= sid %>')
            .then(response => response.text())
            .then(data => {
                document.getElementById('liveCount').innerText = data;
            })
            .catch(err => console.error("Error fetching count:", err));
    }

    // Refresh count every 3 seconds
    setInterval(updateCount, 3000);
    updateCount(); // Initial call

    // 3. 3-MINUTE COUNTDOWN TIMER
    var distance = 180000; // 3 minutes in ms
    var x = setInterval(function() {
        var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        var seconds = Math.floor((distance % (1000 * 60)) / 1000);
        document.getElementById("timer").innerHTML = "<i class='fas fa-clock'></i> QR Expires in: " + minutes + "m " + seconds + "s ";
        distance -= 1000;
        if (distance < 0) {
            clearInterval(x);
            document.getElementById("timer").innerHTML = "QR EXPIRED";
            document.getElementById("qrcode-canvas").style.opacity = "0.2";
        }
    }, 1000);
</script>
</body>
</html>