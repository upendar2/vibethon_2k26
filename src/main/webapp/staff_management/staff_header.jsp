<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Security Check: Ensure user is logged in and has the 'staff' role
    String staffNames = (String) session.getAttribute("userName");
    String staffIds = (String) session.getAttribute("regdno"); // This is the 'id' from users table
    String userRoles = (String) session.getAttribute("userRole");

    if (staffIds == null || userRoles == null || !userRoles.equalsIgnoreCase("staff")) {
        // Redirect to login if session is invalid or role is not staff
        response.sendRedirect(request.getContextPath() + "/login/login.jsp?error=unauthorized");
        return;
    }
%>

<header class="admin-header">
    <%-- Left Side: Branding --%>
    <div class="header-title">
        <i class="fa-solid fa-chalkboard-user"></i>
        <h1>Staff Portal</h1>
    </div>

    <%-- Right Side: User Info & Actions --%>
    <div class="header-user-info">
        <span class="welcome-message">
            Welcome, <strong><%= staffNames %></strong> (ID: <%= staffIds %>)
        </span>
        
        <%-- Dashboard Link --%>
        <a href="${pageContext.request.contextPath}/staff_management/staff_dashboard.jsp" class="header-button">
            <i class="fa-solid fa-gauge-high"></i>
            <span>Dashboard</span>
        </a>

        <%-- Logout Button --%>
        <a href="${pageContext.request.contextPath}/logout.jsp" class="header-button logout-button">
            <i class="fa-solid fa-right-from-bracket"></i>
            <span>Logout</span>
        </a>
    </div>
</header>

<style>
    /* This styling mimics your adminHeaderFooter.css 
       to ensure the UI is identical across management roles.
    */
    .admin-header {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        background-color: #1f2937; /* Dark Gray from your theme */
        color: #f9fafb;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 30px;
        height: 70px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        z-index: 1000;
        box-sizing: border-box;
    }

    .header-title {
        display: flex;
        align-items: center;
        gap: 12px;
    }

    .header-title i {
        font-size: 1.5rem;
        color: #3b82f6; /* Theme Blue */
    }

    .header-title h1 {
        margin: 0;
        font-size: 1.3rem;
        font-weight: 600;
        letter-spacing: 0.5px;
    }

    .header-user-info {
        display: flex;
        align-items: center;
        gap: 20px;
    }

    .welcome-message {
        color: #d1d5db;
        font-size: 0.95rem;
    }

    .welcome-message strong {
        color: #ffffff;
    }

    .header-button {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        text-decoration: none;
        font-weight: 500;
        padding: 8px 15px;
        border-radius: 6px;
        border: 1px solid rgba(255, 255, 255, 0.2);
        color: #d1d5db;
        background-color: transparent;
        transition: all 0.2s ease-in-out;
        white-space: nowrap;
        font-size: 0.9rem;
    }

    .header-button:hover {
        background-color: rgba(255, 255, 255, 0.1);
        color: #ffffff;
        border-color: rgba(255, 255, 255, 0.5);
    }

    .logout-button {
        border-color: rgba(239, 68, 68, 0.4);
        color: #f87171;
    }

    .logout-button:hover {
        background-color: #ef4444;
        border-color: #ef4444;
        color: white;
    }

    /* Responsive Logic */
    @media (max-width: 768px) {
        .welcome-message {
            display: none; /* Hide text on small screens */
        }
        .header-title h1 {
            font-size: 1.1rem;
        }
        .admin-header {
            padding: 0 15px;
        }
    }
</style>