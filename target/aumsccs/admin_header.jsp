<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    //String adminName = (String) session.getAttribute("userName");
    // Redirect to logout if session is invalid or user is not an admin
    //if (adminName == null || "student".equals(adminName)) {
    //    response.sendRedirect("logout.jsp");
     //   return;
   // }
    String adminName = (String) session.getAttribute("userName");
    String staffIds = (String) session.getAttribute("regdno"); // This is the 'id' from users table
    String userRoles = (String) session.getAttribute("userRole");

    if (staffIds == null || userRoles == null || !userRoles.equalsIgnoreCase("admin")) {
        // Redirect to login if session is invalid or role is not staff
        response.sendRedirect(request.getContextPath() + "/login/login.jsp?error=unauthorized");
        return;
    }
%>

<header class="admin-header">
    <div class="header-title">
        <i class="fas fa-shield-alt"></i>
        <h1>Admin Portal</h1>
    </div>
    <div class="header-user-info">
        <a href="admin_dashboard.jsp" class="header-button">
            <i class="fas fa-home"></i> Dashboard
        </a>
        <span class="welcome-message">Welcome, <strong><%= adminName %></strong></span>
        <a href="logout.jsp" class="header-button logout-button">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</header>