<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.ehadir.util.HtmlUtil" %>
<nav class="navbar eh-topbar px-3">
    <span class="navbar-brand fw-bold text-white mb-0">
        <i class="fa-solid fa-ticket me-2"></i>E-Hadir Admin
    </span>
    <div class="d-flex align-items-center gap-3">
        <span class="text-white small d-none d-md-inline"><%= HtmlUtil.esc((String) session.getAttribute("email")) %></span>
        <a href="<%= request.getContextPath() %>/logout.jsp" class="btn btn-sm btn-light">
            <i class="fa-solid fa-right-from-bracket me-1"></i>Logout
        </a>
    </div>
</nav>