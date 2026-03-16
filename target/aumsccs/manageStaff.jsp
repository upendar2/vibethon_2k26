<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.DbConnection"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Manage Staff | Admin Portal</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/adminHeaderFooter.css">

<style>
    :root {
        --theme-blue: #0056b3;
        --theme-blue-hover: #004494;
        --form-bg: #ffffff;
        --input-bg: #ffffff;
    }

    body { background-color: #f8f9fa; }

    .assignment-wrapper {
        max-width: 800px;
        margin: 40px auto;
        padding: 0 15px;
    }

    /* Action Bar Styling */
    .admin-action-bar {
        display: flex;
        gap: 15px;
        margin-bottom: 25px;
        justify-content: center;
    }

    .action-tab {
        padding: 12px 20px;
        background: white;
        border-radius: 8px;
        text-decoration: none;
        color: var(--text-medium);
        font-weight: 600;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        transition: 0.3s;
        border: 1px solid #e2e8f0;
    }

    .action-tab.active {
        background: var(--theme-blue);
        color: white;
        border-color: var(--theme-blue);
    }

    .action-tab:hover:not(.active) {
        transform: translateY(-2px);
        border-color: var(--theme-blue);
        color: var(--theme-blue);
    }

    .assignment-card {
        background-color: var(--form-bg);
        padding: 35px;
        border-radius: 10px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        border: 1px solid var(--border-color);
        margin-bottom: 30px;
    }

    .assignment-card h2 {
        margin-top: 0;
        font-size: 1.4rem;
        color: var(--text-dark);
        display: flex;
        align-items: center;
        gap: 12px;
        border-bottom: 2px solid #eee;
        padding-bottom: 15px;
        margin-bottom: 30px;
    }

    .form-group { margin-bottom: 20px; }
    .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: var(--text-medium); }
    
    .form-control {
        width: 100%;
        padding: 12px;
        border: 1px solid var(--border-color);
        border-radius: 6px;
        outline: none;
    }

    .submit-btn {
        width: 100%;
        padding: 14px;
        background-color: var(--theme-blue);
        color: white;
        border: none;
        border-radius: 6px;
        font-weight: 600;
        cursor: pointer;
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 10px;
    }

    #toast {
        visibility: hidden;
        min-width: 300px;
        background-color: #333;
        color: #fff;
        text-align: center;
        border-radius: 6px;
        padding: 16px;
        position: fixed;
        left: 50%;
        transform: translateX(-50%);
        bottom: 30px;
        z-index: 1000;
    }
    .btn-back {
            padding: 8px 15px;
            border-radius: 6px;
            color: var(--text-label);
            font-weight: 600;
            text-decoration: none;
            background-color: #e5e7eb; /* Tailwind gray-200 */
            transition: background-color 0.2s;
            border: 1px solid var(--border-color);
            display: inline-flex; /* Align icon and text */
            align-items: center;
        }
        .btn-back:hover {
            background-color: #d1d5db; /* Tailwind gray-300 */
        }

    #toast.show { visibility: visible; animation: fadein 0.5s, fadeout 0.5s 2.5s; }
    @keyframes fadein { from {bottom: 0; opacity: 0;} to {bottom: 30px; opacity: 1;} }
    @keyframes fadeout { from {bottom: 30px; opacity: 1;} to {bottom: 0; opacity: 0;} }
</style>
</head>
<body>

	<%@ include file="admin_header.jsp"%>

	<main class="page-content">
		<div class="assignment-wrapper">
            <a href="admin_dashboard.jsp" class="btn-back mt-4 sm:mt-0">
                    <i class="fas fa-arrow-left"></i>Back to List
                </a>
            <div class="admin-action-bar">
               
                
                <a href="viewAssignments.jsp" class="action-tab">
                    <i class="fas fa-list"></i> View Assigned Subjects
                </a>
            </div>

			<div class="assignment-card">
			
				<h2><i class="fas fa-chalkboard-teacher"></i> Staff Subjects Assignment</h2>

				<form id="staffForm" action="AssignStaffServlet" method="POST">
				
					<div class="form-group">
						<label for="staffId">Staff Member</label> 
                        <select name="staffId" id="staffId" class="form-control" required>
							<option value="" disabled selected>Select a staff member...</option>
							<%
							try (Connection con = DbConnection.getConne();
                                 Statement st = con.createStatement();
                                 ResultSet rsStaff = st.executeQuery("SELECT id, name FROM users WHERE role = 'staff'")) {
								while (rsStaff.next()) {
							%>
							<option value="<%=rsStaff.getString("id")%>"><%=rsStaff.getString("name")%></option>
							<%
								}
							} catch (Exception e) { e.printStackTrace(); }
							%>
						</select>
					</div>

					<div class="form-group">
						<label for="subjectId">Subject</label> 
                        <select name="subjectId" id="subjectId" class="form-control" required>
							<option value="" disabled selected>Select a subject...</option>
							<%
							try (Connection con = DbConnection.getConne();
                                 Statement st = con.createStatement();
                                 ResultSet rsSub = st.executeQuery("SELECT subject_id, subject_name FROM subjects")) {
								while (rsSub.next()) {
							%>
							<option value="<%=rsSub.getInt("subject_id")%>"><%=rsSub.getString("subject_name")%></option>
							<%
								}
							} catch (Exception e) { e.printStackTrace(); }
							%>
						</select>
					</div>

					<div class="form-group">
						<label for="joinYear">Batch Year (Join Year)</label> 
                        <input type="number" name="joinYear" id="joinYear" class="form-control" placeholder="e.g. 2024" min="2000" max="2099" required>
					</div>

					<div class="form-group">
						<label>Class Name:</label> 
                        <select name="className" class="form-control" required>
							<option value="MSC-CS">MSc Computer Science</option>
							<option value="MCA">MCA</option>
							<option value="BTECH-IT">B.Tech IT</option>
						</select>
					</div>

					<button type="submit" class="submit-btn">
						<i class="fas fa-check-circle"></i> Assign Subject
					</button>
				</form>
			</div>
            
            
		</div>
	</main>

	<div id="toast"></div>

	<%@ include file="footer.jsp"%>

	<script>
		window.onload = function() {
			const urlParams = new URLSearchParams(window.location.search);
			if (urlParams.has('status')) {
				const status = urlParams.get('status');
				const message = urlParams.get('message');
				if (status === 'success') {
					showToast("Assignment Successfully Saved!", "#22c55e");
				} else {
					showToast("Error: " + (message || "Failed to save"), "#ef4444");
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