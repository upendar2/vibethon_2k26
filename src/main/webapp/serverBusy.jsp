<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Server Busy | AU IT&CA</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/header/style.css">
    <style>
        .busy-container {
            height: 80vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            padding: 20px;
        }
        .busy-icon {
            font-size: 80px;
            color: #f59e0b; /* Warning Orange */
            margin-bottom: 20px;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }
        .busy-card {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            max-width: 500px;
        }
        .refresh-btn {
            margin-top: 25px;
            padding: 12px 25px;
            background: #3b82f6;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
        }
    </style>
</head>
<body style="background: #f1f5f9;">

    <%@ include file="header.jsp" %>

    <div class="busy-container">
        <div class="busy-card">
            <i class="fas fa-clock busy-icon"></i>
            <h1 style="color: #1f2937;">Server is Busy</h1>
            <p style="color: #6b7280; line-height: 1.6;">
                We currently have the maximum number of users allowed. 
                Please wait a few minutes and try again.
            </p>
            <button class="refresh-btn" onclick="window.location.reload()">
                <i class="fas fa-sync"></i> Try Again Now
            </button>
        </div>
    </div>

</body>
</html>