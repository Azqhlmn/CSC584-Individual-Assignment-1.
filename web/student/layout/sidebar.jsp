<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String uri = request.getRequestURI();
%>
<div class="list-group eh-sidebar">
    <a href="<%= ctx %>/student/studentDashboard.jsp"
       class="list-group-item list-group-item-action<%= uri.endsWith("/student/studentDashboard.jsp") ? " active" : "" %>">
        <i class="fa-solid fa-gauge me-2"></i>Dashboard
    </a>
    <a href="<%= ctx %>/student/eventList.jsp"
       class="list-group-item list-group-item-action<%= uri.endsWith("/student/eventList.jsp") ? " active" : "" %>">
        <i class="fa-solid fa-calendar-days me-2"></i>Browse Events
    </a>
    <a href="<%= ctx %>/student/myTickets.jsp"
       class="list-group-item list-group-item-action<%= uri.endsWith("/student/myTickets.jsp") ? " active" : "" %>">
        <i class="fa-solid fa-ticket me-2"></i>My Tickets
    </a>
</div>