package com.listners;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*") // Intercepts every page
public class TrafficControlFilter implements Filter {

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // Logic: If server is full AND this user doesn't already have a session
        if (UserLimitListener.isServerBusy() && session == null) {
            // Check if they are already on the busy page to avoid infinite loops
            if (!req.getRequestURI().endsWith("serverBusy.jsp") && !req.getRequestURI().contains("/header/")) {
                res.sendRedirect(req.getContextPath() + "/serverBusy.jsp");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}