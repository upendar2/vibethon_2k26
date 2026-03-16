package com.example;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.util.Collections;

@WebServlet("/SendAttendanceAlertServlet")
public class SendAttendanceAlertServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Get multiple values for bulk, or single for one student
        String[] emails = request.getParameterValues("email");
        String[] percentages = request.getParameterValues("percent");

        if (emails == null || percentages == null || emails.length == 0) {
            response.setStatus(400);
            out.print("{\"status\":\"error\", \"message\":\"No data received.\"}");
            return;
        }

        int successCount = 0;
        int failureCount = 0;

        for (int i = 0; i < emails.length; i++) {
            String email = emails[i];
            String pct = percentages[i];
            
            // Build the Themed HTML Content
            String htmlBody = "<h3>Attendance Status Notification</h3>" +
                              "<p>Dear Student,</p>" +
                              "<p>Your current attendance percentage has been calculated: " +
                              "<b style='color:" + (Double.parseDouble(pct) < 75 ? "#dc2626" : "#10b981") + ";'>" + pct + "%</b></p>" +
                              "<p>" + (Double.parseDouble(pct) < 75 
                                ? "Your attendance is currently below the required 75%. Please prioritize your upcoming classes." 
                                : "Your attendance is satisfactory. Keep up the good work!") + "</p>" +
                              "<br><p>Regards,<br>Academic Administration</p>";

            // ROUTING: EmailSender.sendEmail will check IS_RENDER automatically
            // We pass Collections.emptyList() to avoid the NullPointerException you saw earlier
            boolean sent = EmailSender.sendEmail(email, "Attendance Progress Alert", "Your attendance is " + pct + "%", htmlBody, Collections.emptyList());
            
            if (sent) successCount++;
            else failureCount++;
        }

        if (failureCount == 0) {
            out.print("{\"status\":\"success\", \"message\":\"" + successCount + " email(s) sent successfully.\"}");
        } else {
            out.print("{\"status\":\"partial\", \"message\":\"" + successCount + " sent, " + failureCount + " failed.\"}");
        }
        
        out.flush();
    }
}