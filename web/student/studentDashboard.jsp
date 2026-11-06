<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.ehadir.util.HtmlUtil" %>
<%
    // Guard: student sahaja
    if (!"student".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Hadir - Student Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/ehadir.css" rel="stylesheet">
</head>
<body class="eh-ui-body">
<jsp:include page="/student/layout/topbar.jsp"/>

<div class="container-fluid">
    <div class="row">
        <div class="col-12 col-md-3 col-lg-2 py-4">
            <jsp:include page="/student/layout/sidebar.jsp"/>
        </div>
        <div class="col-12 col-md-9 col-lg-10 py-4">
            <h2 class="fw-bold mb-1">Student Dashboard</h2>
            <p class="eh-muted mb-4">Welcome, <%= HtmlUtil.esc((String) session.getAttribute("name")) %></p>

            <div class="row g-3">
                <div class="col-6 col-lg-4">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number">2</div><div class="eh-muted">My Tickets</div>
                    </div>
                </div>
                <div class="col-6 col-lg-4">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number">6</div><div class="eh-muted">Upcoming Events</div>
                    </div>
                </div>
                <div class="col-12 col-lg-4">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number">1</div><div class="eh-muted">Events Attended</div>
                    </div>
                </div>
            </div>

            <a href="<%= request.getContextPath() %>/student/eventList.jsp" class="btn btn-eh-primary mt-4">
                <i class="fa-solid fa-calendar-days me-2"></i>Browse Events
            </a>
            <p class="eh-muted small mt-3">Nombor di atas data contoh. Nanti diambil dari database.</p>
        </div>
    </div>
</div>
</body>
</html>