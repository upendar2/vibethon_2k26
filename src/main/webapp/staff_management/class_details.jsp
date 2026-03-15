<%
    String subjectId = request.getParameter("subjectId");
    String className = request.getParameter("class");
    int year = Integer.parseInt(request.getParameter("year"));
%>

<h2>Class: <%= className %> | Subject: <%= subjectId %></h2>

<table border="1" class="data-table">
    <tr>
        <th>Regd No</th>
        <th>Student Name</th>
        <th>Mid-1 Marks</th>
        <th>Mid-2 Marks</th>
        <th>Attendance %</th>
        <th>Action</th>
    </tr>
    <%-- Loop through students where class_name = className AND join_year = year --%>
    <%-- Add forms/inputs for each student to save data to student_performance table --%>
</table>