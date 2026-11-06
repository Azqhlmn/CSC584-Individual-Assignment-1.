<%@ page contentType="text/html;charset=UTF-8" language="java" import="com.ehadir.util.HtmlUtil" %>
<%
    // Guard: committee sahaja
    if (!"committee".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Hadir - Committee Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/ehadir.css" rel="stylesheet">
</head>
<body class="eh-ui-body">
<jsp:include page="/committee/layout/topbar.jsp"/>

<div class="container-fluid">
    <div class="row">
        <div class="col-12 col-md-3 col-lg-2 py-4">
            <jsp:include page="/committee/layout/sidebar.jsp"/>
        </div>
        <div class="col-12 col-md-9 col-lg-10 py-4">
            <h2 class="fw-bold mb-1">Committee Dashboard</h2>
            <p class="eh-muted mb-4">Welcome, <%= HtmlUtil.esc((String) session.getAttribute("name")) %></p>

            <div class="row g-3">
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number">5</div><div class="eh-muted">My Events</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number">118</div><div class="eh-muted">Registrations</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number">76%</div><div class="eh-muted">Attendance Rate</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number">32</div><div class="eh-muted">Seats Left</div>
                    </div>
                </div>
            </div>

            <div class="eh-card card p-4 mt-3">
                <h5 class="fw-bold">Charts</h5>
                <p class="eh-muted mb-0">Carta registrations per event dan attendance akan dipaparkan di sini (Chart.js).</p>
            </div>
            <p class="eh-muted small mt-3">Nombor di atas data contoh. Nanti diambil dari database.</p>
        </div>
    </div>
</div>
</body>
</html>