<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String uri = request.getRequestURI();
%>
<div class="list-group eh-sidebar">
    <a href="<%= ctx %>/admin/adminDashboard.jsp"
       class="list-group-item list-group-item-action<%= uri.endsWith("/admin/adminDashboard.jsp") ? " active" : "" %>">
        <i class="fa-solid fa-gauge me-2"></i>Dashboard
    </a>
    <a href="<%= ctx %>/admin/manageEvents.jsp"
       class="list-group-item list-group-item-action<%= uri.endsWith("/admin/manageEvents.jsp") ? " active" : "" %>">
        <i class="fa-solid fa-calendar-xmark me-2"></i>Manage Events
    </a>
</div>