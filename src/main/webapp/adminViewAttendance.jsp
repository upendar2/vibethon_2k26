<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection, java.util.*"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Attendance Analytics | Admin Dashboard</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/adminHeaderFooter.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<style>
:root {
	--primary: #0056b3;
	--danger: #dc2626;
	--success: #10b981;
	--warning: #f59e0b;
}

body {
	background-color: #f8fafc;
	font-family: 'Segoe UI', Tahoma, sans-serif;
}

.filter-card {
	background: white;
	padding: 25px;
	border-radius: 15px;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
	margin-bottom: 25px;
}

.form-grid {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
	gap: 20px;
	align-items: end;
}

.summary-container {
	display: grid;
	grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
	gap: 20px;
	margin-bottom: 25px;
}

.stat-card {
	background: white;
	padding: 20px;
	border-radius: 12px;
	box-shadow: 0 4px 10px rgba(0, 0, 0, 0.03);
	text-align: center;
	border-bottom: 5px solid var(--primary);
}

.stat-card.red {
	border-bottom-color: var(--danger);
}

.stat-card h3 {
	margin: 0;
	font-size: 2rem;
	color: #1e293b;
}

.stat-card p {
	margin: 5px 0 0;
	color: #64748b;
	font-weight: 600;
	text-transform: uppercase;
	font-size: 0.8rem;
}

.report-wrapper {
	background: white;
	border-radius: 15px;
	overflow: hidden;
	box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
}

.data-table {
	width: 100%;
	border-collapse: collapse;
}

.data-table th {
	background: var(--primary);
	color: white;
	padding: 15px;
	font-size: 0.85rem;
	text-transform: uppercase;
}

.data-table td {
	padding: 12px 15px;
	border-bottom: 1px solid #f1f5f9;
	text-align: center;
}

.pct-badge {
	padding: 5px 12px;
	border-radius: 20px;
	font-weight: 700;
	font-size: 0.85rem;
}

.bg-low {
	background: #fee2e2;
	color: var(--danger);
}

.bg-good {
	background: #dcfce7;
	color: #166534;
}

.btn-bulk {
	background: #8b5cf6;
	color: white;
	border: none;
	padding: 10px 20px;
	border-radius: 8px;
	font-weight: bold;
	cursor: pointer;
	transition: 0.3s;
}

.btn-bulk:hover {
	background: #7c3aed;
	transform: translateY(-2px);
}

.select-field, .date-field {
	width: 100%;
	padding: 10px;
	border: 1px solid #e2e8f0;
	border-radius: 8px;
	margin-top: 5px;
}

.btn-back {
	padding: 8px 15px;
	border-radius: 6px;
	color: var(--text-label);
	font-weight: 600;
	text-decoration: none;
	background-color: #e5e7eb;
	transition: background-color 0.2s;
	border: 1px solid var(--border-color);
	display: inline-flex;
	align-items: center;
}

.btn-back:hover {
	background-color: #d1d5db;
}
</style>
</head>
<body>

	<%@ include file="admin_header.jsp"%>

	<div class="dashboard-wrapper"
		style="padding: 20px; max-width: 1400px; margin: auto;">

		<div style="display: flex; align-items: center; gap: 20px; margin-bottom: 25px;">
			<a href="admin_dashboard.jsp" class="btn-back"> 
				<i class="fas fa-arrow-left" style="margin-right: 8px;"></i>Back to List
			</a>
			<h2 style="color: #1e293b; margin: 0;">
				<i class="fas fa-chart-line"></i> Attendance Analytics
			</h2>
		</div>

		<div class="filter-card">
			<form method="GET" class="form-grid">
				<div>
					<label>Class/Course</label> <select name="class"
						class="select-field" required>
						<option value="" disabled selected>-- Select Type --</option>
						<option value="MSC-CS"
							<%="MSC-CS".equals(request.getParameter("class")) ? "selected" : ""%>>MSc
							Computer Science</option>
						<option value="MCA"
							<%="MCA".equals(request.getParameter("class")) ? "selected" : ""%>>MCA</option>
						<option value="BTECH-IT"
							<%="BTECH-IT".equals(request.getParameter("class")) ? "selected" : ""%>>B.Tech
							IT</option>
					</select>
				</div>
				<div>
					<label>Join Year</label> <select name="joinyear"
						class="select-field" required>
						<option value="" disabled selected>-- Year --</option>
						<%
						for (int i = 2024; i <= 2030; i++) {
							String selected = String.valueOf(i).equals(request.getParameter("joinyear")) ? "selected" : "";
						%>
						<option value="<%=i%>" <%=selected%>><%=i%></option>
						<%
						}
						%>
					</select>
				</div>
				<div>
					<label>Start Date</label> <input type="date" name="from"
						class="date-field"
						value="<%=request.getParameter("from") != null ? request.getParameter("from") : ""%>"
						required>
				</div>
				<div>
					<label>End Date</label> <input type="date" id="endDate" name="to"
						class="date-field"
						value="<%=request.getParameter("to") != null ? request.getParameter("to") : ""%>"
						required>
				</div>
				<button type="submit" class="save-btn"
					style="background: var(--primary); height: 45px; border-radius: 8px;">
					<i class="fas fa-sync"></i> Generate Report
				</button>
			</form>
		</div>

		<%
		String sCls = request.getParameter("class");
		String sYr = request.getParameter("joinyear");
		String fromDate = request.getParameter("from");
		String toDate = request.getParameter("to");

		if (sCls != null && sYr != null && fromDate != null && toDate != null) {
			int totalStudents = 0;
			int lowAttendanceCount = 0;
		%>

		<div class="summary-container">
			<div class="stat-card">
				<h3 id="countTotal">0</h3>
				<p>Total Students</p>
			</div>
			<div class="stat-card red">
				<h3 id="countLow">0</h3>
				<p>Students Below 75%</p>
			</div>
			<div
				style="display: flex; align-items: center; justify-content: center;">
				<button onclick="sendBulkAlerts()" class="btn-bulk">
					<i class="fas fa-envelope-open-text"></i> Notify All Low Attendance
				</button>
			</div>
		</div>

		<div class="report-wrapper">
			<table class="data-table" id="attendanceTable">
				<thead>
					<tr>
						<th>Regd No</th>
						<th style="text-align: left;">Student Name</th>
						<th>Classes Held</th>
						<th>Attended</th>
						<th>Percentage</th>
						<th>Action</th>
					</tr>
				</thead>
				<tbody>
					<%
					try (Connection con = DbConnection.getConne()) {
						String sql = "SELECT s.regd_no, s.name, s.email, "
						+ "(SELECT COUNT(DISTINCT sa2.attendance_date) FROM student_attendance sa2 "
						+ " JOIN students s2 ON sa2.regd_no = s2.regd_no "
						+ " WHERE s2.class = s.class AND sa2.attendance_date BETWEEN ? AND ?) as total, "
						+ "(SELECT COUNT(*) FROM student_attendance sa3 "
						+ " WHERE sa3.regd_no = s.regd_no AND sa3.attendance_date BETWEEN ? AND ?) as attended "
						+ "FROM students s WHERE s.class = ? AND s.joinyear = ?";

						PreparedStatement ps = con.prepareStatement(sql);
						ps.setDate(1, java.sql.Date.valueOf(fromDate));
						ps.setDate(2, java.sql.Date.valueOf(toDate));
						ps.setDate(3, java.sql.Date.valueOf(fromDate));
						ps.setDate(4, java.sql.Date.valueOf(toDate));
						ps.setString(5, sCls);
						ps.setInt(6, Integer.parseInt(sYr));

						ResultSet rs = ps.executeQuery();
						while (rs.next()) {
							totalStudents++;
							int totalHeld = rs.getInt("total");
							int attendedCount = rs.getInt("attended");
							double pct = (totalHeld > 0) ? ((double) attendedCount / totalHeld) * 100 : 0.0;
							if (pct < 75)
						lowAttendanceCount++;
					%>
					<tr>
						<td><strong><%=rs.getString("regd_no")%></strong></td>
						<td style="text-align: left;"><%=rs.getString("name")%></td>
						<td><%=totalHeld%></td>
						<td><%=attendedCount%></td>
						<td><span
							class="pct-badge <%=(pct < 75 ? "bg-low" : "bg-good")%>"
							data-pct="<%=String.format("%.2f", pct)%>"
							data-status="<%=(pct < 75 ? "low" : "good")%>"> <%=String.format("%.2f", pct)%>%
						</span></td>
						<td>
							<button
								onclick="sendSingleAlert('<%=rs.getString("email")%>', '<%=String.format("%.2f", pct)%>')"
								class="mail-btn" data-email="<%=rs.getString("email")%>"
								style="background: none; border: none; color: var(--primary); cursor: pointer; font-size: 1.1rem;">
								<i class="fas fa-paper-plane"></i>
							</button>
						</td>
					</tr>
					<%
					}
					} catch (Exception e) {
					out.println("<tr><td colspan='6' style='color:red;'>SQL Error: " + e.getMessage() + "</td></tr>");
					}
					%>
				</tbody>
			</table>
		</div>

		<script>
                document.getElementById('countTotal').innerText = "<%=totalStudents%>";
                document.getElementById('countLow').innerText = "<%=lowAttendanceCount%>";
            </script>

		<%
		}
		%>
	</div>
	

	<script>
        if(!document.getElementById('endDate').value) {
            document.getElementById('endDate').valueAsDate = new Date();
        }

        async function callEmailServlet(emails, percentages) {
            const params = new URLSearchParams();
            emails.forEach(e => params.append('email', e));
            percentages.forEach(p => params.append('percent', p));

            const res = await fetch('${pageContext.request.contextPath}/SendAttendanceAlertServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params
            });
            return res.json();
        }

        function sendSingleAlert(email, pct) {
            Swal.fire({ title: 'Sending Notification...', allowOutsideClick: false, didOpen: () => Swal.showLoading() });
            callEmailServlet([email], [pct]).then(data => {
                if(data.status === 'success') Swal.fire('Success', 'Email sent to ' + email, 'success');
                else Swal.fire('Error', 'Failed to send email.', 'error');
            });
        }

        async function sendBulkAlerts() {
            const rows = document.querySelectorAll("#attendanceTable tbody tr");
            let emails = [];
            let percents = [];

            rows.forEach(row => {
                const badge = row.querySelector(".pct-badge");
                if (badge.getAttribute("data-status") === 'low') {
                    emails.push(row.querySelector(".mail-btn").getAttribute("data-email"));
                    percents.push(badge.getAttribute("data-pct"));
                }
            });

            if (emails.length === 0) {
                Swal.fire('Info', 'No students are below 75% in this list.', 'info');
                return;
            }

            const confirm = await Swal.fire({
                title: 'Bulk Action',
                text: `Send warning emails to ${emails.length} students?`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#8b5cf6',
                confirmButtonText: 'Yes, Send Now'
            });

            if (confirm.isConfirmed) {
                Swal.fire({ title: 'Processing Queue...', allowOutsideClick: false, didOpen: () => Swal.showLoading() });
                const data = await callEmailServlet(emails, percents);
                if(data.status === 'success') Swal.fire('Complete', data.message, 'success');
                else Swal.fire('Warning', data.message, 'warning');
            }
        }
    </script>
</body>
</html>