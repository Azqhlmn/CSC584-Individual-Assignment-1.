<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String uri = request.getRequestURI();
%>
<div class="list-group eh-sidebar">
    <a href="<%= ctx %>/committee/committeeDashboard.jsp"
       class="list-group-item list-group-item-action<%= uri.endsWith("/committee/committeeDashboard.jsp") ? " active" : "" %>">
        <i class="fa-solid fa-gauge me-2"></i>Dashboard
    </a>
    <a href="<%= ctx %>/committee/manageEvents.jsp"
       class="list-group-item list-group-item-action<%= uri.endsWith("/committee/manageEvents.jsp") ? " active" : "" %>">
        <i class="fa-solid fa-calendar-days me-2"></i>Manage Events
    </a>
    <a href="<%= ctx %>/committee/addEvent.jsp"
       class="list-group-item list-group-item-action<%= uri.endsWith("/committee/addEvent.jsp") ? " active" : "" %>">
        <i class="fa-solid fa-circle-plus me-2"></i>Add Event
    </a>
    <a href="<%= ctx %>/committee/attendance.jsp"
       class="list-group-item list-group-item-action<%= uri.endsWith("/committee/attendance.jsp") ? " active" : "" %>">
        <i class="fa-solid fa-clipboard-check me-2"></i>Attendance
    </a>
</div>