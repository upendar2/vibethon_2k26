<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Success | AU Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f1f5f9;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }
        .success-container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            text-align: center;
            max-width: 400px;
            width: 90%;
        }
        .checkmark-wrapper {
            width: 80px;
            height: 80px;
            background: #dcfce7;
            color: #166534;
            font-size: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            animation: scaleIn 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        h2 {
            color: #1e293b;
            margin-bottom: 10px;
        }
        p {
            color: #64748b;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .home-btn {
            display: inline-block;
            background: #0056b3;
            color: white;
            text-decoration: none;
            padding: 12px 30px;
            border-radius: 8px;
            font-weight: 600;
            transition: 0.3s;
        }
        .home-btn:hover {
            background: #004494;
            transform: translateY(-2px);
        }
        @keyframes scaleIn {
            from { transform: scale(0); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
    </style>
</head>
<body>

    <div class="success-container">
        <div class="checkmark-wrapper">
            <i class="fas fa-check"></i>
        </div>
        <h2>Attendance Recorded!</h2>
        <p>Your presence has been successfully verified and logged into the portal. You may now close this window or return to the dashboard.</p>
        
        <a href="login/login.jsp" class="home-btn">
            <i class="fas fa-home"></i> Back to Home
        </a>
        
        <div style="margin-top: 20px; font-size: 0.8rem; color: #94a3b8;">
            Session ID: <%= java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase() %>
        </div>
    </div>

</body>
</html>