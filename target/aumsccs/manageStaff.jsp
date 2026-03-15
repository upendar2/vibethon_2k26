<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Staff Assignment | Admin Portal</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

<%-- Linking your provided CSS file --%>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/adminHeaderFooter.css">

<style>
/* Overriding and adding specific styles for the Manage Staff Form 
           using your theme variables.
        */
:root {
	/* These match your adminHeaderFooter.css precisely */
	--theme-blue: #0056b3;
	--theme-blue-hover: #004494;
	--form-bg: #ffffff;
	--input-bg: #ffffff;
}

body {
	/* Your CSS already handles font and padding-top: 70px */
	background-color: #f8f9fa;
}

.assignment-wrapper {
	max-width: 700px;
	margin: 40px auto;
	padding: 0 15px;
}

.assignment-card {
	background-color: var(--form-bg);
	padding: 35px;
	border-radius: 10px;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
	border: 1px solid var(--border-color);
}

.assignment-card h2 {
	margin-top: 0;
	font-size: 1.6rem;
	color: var(--text-dark);
	display: flex;
	align-items: center;
	justify-content: center;
	gap: 12px;
	border-bottom: 2px solid #eee;
	padding-bottom: 15px;
	margin-bottom: 30px;
	font-weight: 600;
}

.assignment-card h2 i {
	color: var(--theme-blue);
}

.form-group {
	margin-bottom: 20px;
}

.form-group label {
	display: block;
	margin-bottom: 8px;
	font-weight: 600;
	font-size: 0.95rem;
	color: var(--text-medium);
}

.form-control {
	width: 100%;
	padding: 12px 15px;
	background-color: var(--input-bg);
	border: 1px solid var(--border-color);
	border-radius: 6px;
	color: var(--text-dark);
	font-size: 1rem;
	transition: border-color 0.2s, box-shadow 0.2s;
	outline: none;
	font-family: 'Inter', sans-serif;
}

.form-control:focus {
	border-color: var(--theme-blue);
	box-shadow: 0 0 0 3px rgba(0, 86, 179, 0.1);
}

.submit-btn {
	width: 100%;
	padding: 14px;
	background-color: var(--theme-blue);
	color: white;
	border: none;
	border-radius: 6px;
	font-size: 1rem;
	font-weight: 600;
	cursor: pointer;
	transition: background 0.2s;
	display: flex;
	justify-content: center;
	align-items: center;
	gap: 10px;
	margin-top: 10px;
}

.submit-btn:hover {
	background-color: var(--theme-blue-hover);
}

/* Toast Styling matching your theme */
#toast {
	visibility: hidden;
	min-width: 300px;
	background-color: var(--text-dark);
	color: #fff;
	text-align: center;
	border-radius: 6px;
	padding: 16px;
	position: fixed;
	z-index: 1001;
	left: 50%;
	transform: translateX(-50%);
	bottom: 40px;
	font-size: 1rem;
	box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

#toast.show {
	visibility: visible;
	animation: fadein 0.5s, fadeout 0.5s 2.5s;
}

@
keyframes fadein {
	from {bottom: 0;
	opacity: 0;
}

to {
	bottom: 40px;
	opacity: 1;
}

}
@
keyframes fadeout {
	from {bottom: 40px;
	opacity: 1;
}

to {
	bottom: 0;
	opacity: 0;
}
}
</style>
</head>
<body>

	<%-- Using the Header file that uses your adminHeaderFooter.css --%>
	<%@ include file="admin_header.jsp"%>

	<main class="page-content">
		<div class="assignment-wrapper">
			<div class="assignment-card">
				<h2>
					<i class="fas fa-chalkboard-teacher"></i> Staff Subject Assignment
				</h2>

				<form id="staffForm" action="AssignStaffServlet" method="POST">

					<div class="form-group">
						<label for="staffId">Staff Member</label> <select name="staffId"
							id="staffId" class="form-control" required>
							<option value="" disabled selected>Select a staff
								member...</option>
							<%
							Connection con = null;
							Statement st = null;
							ResultSet rsStaff = null;
							try {
								con = DbConnection.getConne();
								st = con.createStatement();
								rsStaff = st.executeQuery("SELECT id, name FROM users WHERE role = 'staff'");
								while (rsStaff.next()) {
							%>
							<option value="<%=rsStaff.getString("id")%>"><%=rsStaff.getString("name")%></option>
							<%
							}
							} catch (Exception e) {
							e.printStackTrace();
							}
							%>
						</select>
					</div>

					<div class="form-group">
						<label for="subjectId">Subject</label> <select name="subjectId"
							id="subjectId" class="form-control" required>
							<option value="" disabled selected>Select a subject...</option>
							<%
							try {
								ResultSet rsSub = st.executeQuery("SELECT subject_id, subject_name FROM subjects");
								while (rsSub.next()) {
							%>
							<option value="<%=rsSub.getInt("subject_id")%>"><%=rsSub.getString("subject_name")%></option>
							<%
							}
							} catch (Exception e) {
							e.printStackTrace();
							} finally {
							if (rsStaff != null)
							rsStaff.close();
							if (st != null)
							st.close();
							if (con != null)
							con.close();
							}
							%>
						</select>
					</div>

					<div class="form-group">
						<label for="joinYear">Batch Year (Join Year)</label> <input
							type="number" name="joinYear" id="joinYear" class="form-control"
							placeholder="e.g. 2024" min="2000" max="2099" required>
					</div>

					<div class="form-group">
						<label>Class Name:</label> <select name="className"
							class="form-control" required>
							<option value="MSC-CS">MSc Computer Science</option>
							<option value="MCA">MCA</option>
							<option value="BTECH-IT">B.Tech IT</option>
						</select>
					</div>

					<button type="submit" class="submit-btn">
						<i class="fas fa-check-circle"></i> Assign Subject
					</button>
				</form>
				<div style="text-align: right; margin-bottom: 20px;">
					<a href="viewAssignments.jsp" class="header-button"
						style="color: var(--theme-blue); border-color: var(--theme-blue);">
						<i class="fas fa-list-ul"></i> View Existing Assignments
					</a>
				</div>
			</div>
		</div>
	</main>

	<div id="toast"></div>

	<%@ include file="footer.jsp"%>

	<script>
		// Check for status from Servlet via URL parameters
		window.onload = function() {
			const urlParams = new URLSearchParams(window.location.search);
			if (urlParams.has('status')) {
				const status = urlParams.get('status');
				const message = urlParams.get('message');
				if (status === 'success') {
					showToast("Assignment Successfully Saved!", "#22c55e");
				} else {
					showToast("Error: " + (message || "Failed to save"),
							"#ef4444");
				}
			}
		}

		function showToast(message, color) {
			const toast = document.getElementById("toast");
			toast.innerText = message;
			toast.style.backgroundColor = color;
			toast.className = "show";
			setTimeout(function() {
				toast.className = toast.className.replace("show", "");
			}, 3000);
		}
	</script>
</body>
</html>