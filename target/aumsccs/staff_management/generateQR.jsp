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
    <div class="qr-card">
        <a href="staff_dashboard.jsp" style="float:left; color:#64748b; text-decoration:none;"><i class="fas fa-arrow-left"></i> Back</a>
        <h2 style="color:#1e293b;">Live Attendance Session</h2>
        <p><%= cls %> | Batch <%= yr %></p>
        
        <div id="qrcode-canvas"></div>
        
        <p style="color: #ef4444; font-weight: bold;"><i class="fas fa-stopwatch"></i> This QR is dynamic and valid for this session only.</p>
    </div>

<script>
    var siteBaseUrl = window.location.origin; 
    var projectPath = "${pageContext.request.contextPath}";
    
    // Generate current timestamp
    var startTime = Date.now(); 
    
    // The URL now includes the 'ts' (timestamp) parameter
    var qrData = siteBaseUrl + projectPath + "/studentScan.jsp?sid=<%= sid %>&ts=" + startTime;

    new QRCode(document.getElementById("qrcode-canvas"), {
        text: qrData,
        width: 250,
        height: 250
    });

    // Optional: Auto-refresh the page every 3 minutes to generate a new valid QR
    setTimeout(function() {
        location.reload();
    }, 180000); 
</script>
</body>
</html>