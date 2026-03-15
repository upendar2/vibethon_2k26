<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection" %>
<%
    // Session Security Check
    String staffId = (String) session.getAttribute("regdno");
    String staffName = (String) session.getAttribute("userName");
    String role = (String) session.getAttribute("userRole");

    if (staffId == null || !"staff".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/login/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Dashboard | AU IT&CA Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/adminHeaderFooter.css">
    
    <style>
        body { background-color: #f1f5f9; }
        .dashboard-wrapper { max-width: 1300px; margin: 0 auto; padding: 20px; }

        /* Welcome Section */
        .staff-hero {
            background: white;
            padding: 25px;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-left: 6px solid #0056b3;
        }

        /* Class Card Grid */
        .class-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(380px, 1fr));
            gap: 25px;
        }

        .class-card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
        }

        .class-card:hover { transform: translateY(-5px); box-shadow: 0 12px 20px rgba(0,0,0,0.1); }

        .card-header { background: #f8fafc; padding: 20px; border-bottom: 1px solid #e2e8f0; }
        .subject-title { color: #0056b3; font-size: 1.1rem; font-weight: 700; margin: 0; display: block; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        
        .status-badge {
            display: inline-block;
            margin-top: 8px;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .card-body { padding: 20px; flex-grow: 1; color: #475569; font-size: 0.9rem; }
        
        /* Four Column Action Buttons */
        .card-actions { 
            padding: 12px; 
            display: grid; 
            grid-template-columns: repeat(4, 1fr); 
            gap: 6px; 
            background: #f8fafc;
            border-top: 1px solid #e2e8f0;
        }

        .action-btn {
            text-align: center;
            padding: 8px 2px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.75rem;
            transition: 0.2s;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 4px;
        }

        .btn-take { background-color: #10b981; color: white; }
        .btn-qr { background-color: #8b5cf6; color: white; } /* Purple for QR */
        .btn-visit { background-color: #64748b; color: white; }
        .btn-marks { background-color: #3b82f6; color: white; }
        
        .btn-locked { background-color: #cbd5e1; color: #64748b; cursor: not-allowed; }
        .action-btn:hover:not(.btn-locked) { opacity: 0.8; transform: scale(1.02); }

        .no-data { grid-column: 1/-1; text-align: center; padding: 50px; color: #94a3b8; }
    </style>
</head>
<body>

    <%@ include file="staff_header.jsp" %>

    <main class="page-content">
        <div class="dashboard-wrapper">
            
            <section class="staff-hero">
                <div>
                    <h2 style="margin:0;">Welcome, <strong><%= staffName %></strong></h2>
                    <p style="margin:5px 0 0 0; color:#64748b;">
                        <i class="far fa-calendar-alt"></i> Today: <%= new java.text.SimpleDateFormat("EEEE, dd MMM yyyy").format(new java.util.Date()) %>
                    </p>
                </div>
            </section>

            <div class="class-grid">
                <%
                    Connection con = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;
                    try {
                        con = DbConnection.getConne();
                        String sql = "SELECT sa.subject_id, s.subject_name, sa.class_name, sa.join_year " +
                                     "FROM staff_assignments sa " +
                                     "JOIN subjects s ON sa.subject_id = s.subject_id " +
                                     "WHERE sa.staff_id = ? ORDER BY sa.class_name ASC";
                        
                        ps = con.prepareStatement(sql);
                        ps.setString(1, staffId);
                        rs = ps.executeQuery();

                        boolean hasClasses = false;
                        while (rs.next()) {
                            hasClasses = true;
                            int subId = rs.getInt("subject_id");
                            String subName = rs.getString("subject_name");
                            String clsName = rs.getString("class_name");
                            int year = rs.getInt("join_year");

                            // Check if attendance is already submitted for TODAY
                            boolean isSubmitted = false;
                            String checkSql = "SELECT 1 FROM student_attendance WHERE subject_id = ? AND attendance_date = CURRENT_DATE LIMIT 1";
                            PreparedStatement psCheck = con.prepareStatement(checkSql);
                            psCheck.setInt(1, subId);
                            ResultSet rsCheck = psCheck.executeQuery();
                            if(rsCheck.next()) isSubmitted = true;
                            rsCheck.close();
                            psCheck.close();
                %>
                    <div class="class-card">
                        <div class="card-header">
                            <span class="subject-title" title="<%= subName %>"><%= subName %></span>
                            <% if(isSubmitted) { %>
                                <span class="status-badge" style="background:#dcfce7; color:#166534;">
                                    <i class="fas fa-check-circle"></i> Today's Entry Done
                                </span>
                            <% } else { %>
                                <span class="status-badge" style="background:#fff7ed; color:#9a3412;">
                                    <i class="fas fa-clock"></i> Pending Attendance
                                </span>
                            <% } %>
                        </div>
                        
                        <div class="card-body">
                            <div style="margin-bottom: 5px;"><i class="fas fa-graduation-cap"></i> <strong>Class:</strong> <%= clsName %></div>
                            <div><i class="fas fa-users"></i> <strong>Batch:</strong> <%= year %></div>
                        </div>

                        <div class="card-actions">
                            <%-- 1. Manual Take Attendance --%>
                            <% if(!isSubmitted) { %>
                                <a href="takeAttendance.jsp?sid=<%= subId %>&cls=<%= clsName %>&yr=<%= year %>" class="action-btn btn-take">
                                    <i class="fas fa-keyboard"></i> Manual
                                </a>
                                <%-- 2. QR Generation --%>
                                <a href="generateQR.jsp?sid=<%= subId %>&cls=<%= clsName %>&yr=<%= year %>" class="action-btn btn-qr">
                                    <i class="fas fa-qrcode"></i> QR
                                </a>
                            <% } else { %>
                                <div class="action-btn btn-locked" title="Submission complete">
                                    <i class="fas fa-lock"></i> Locked
                                </div>
                                <div class="action-btn btn-locked" title="Submission complete">
                                    <i class="fas fa-lock"></i> Locked
                                </div>
                            <% } %>

                            <%-- 3. Visit History --%>
                            <a href="visitAttendance.jsp?sid=<%= subId %>&cls=<%= clsName %>&yr=<%= year %>" class="action-btn btn-visit">
                                <i class="fas fa-history"></i> Visit
                            </a>

                            <%-- 4. Internal Marks --%>
                            <a href="manageMarks.jsp?sid=<%= subId %>&cls=<%= clsName %>&yr=<%= year %>" class="action-btn btn-marks">
                                <i class="fas fa-file-pen"></i> Marks
                            </a>
                        </div>
                    </div>
                <%
                        }
                        if(!hasClasses) {
                            out.println("<div class='no-data'>No subjects assigned to you yet.</div>");
                        }
                    } catch (Exception e) { 
                        out.println("<div class='no-data'>Error loading classes: " + e.getMessage() + "</div>");
                    } 
                    finally { if(con != null) con.close(); }
                %>
            </div>
        </div>
    </main>

    <%@ include file="../footer.jsp" %>
</body>
</html>