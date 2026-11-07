<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.List,com.ehadir.util.HtmlUtil" %>
<%
    // Guard: admin sahaja
    if (!"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    // Data belum dimuat: minta servlet ambil dari database
    if (request.getAttribute("totalEvents") == null) {
        request.getRequestDispatcher("/admin/adminDashboardServlet").forward(request, response);
        return;
    }
    int totalEvents = ((Integer) request.getAttribute("totalEvents")).intValue();
    int canceledEvents = ((Integer) request.getAttribute("canceledEvents")).intValue();
    int regTotal = ((Integer) request.getAttribute("regTotal")).intValue();
    int students = ((Integer) request.getAttribute("students")).intValue();
    List<String> clubLabels = (List<String>) request.getAttribute("clubLabels");
    List<Integer> clubRegs = (List<Integer>) request.getAttribute("clubRegs");
    int evOpen = ((Integer) request.getAttribute("evOpen")).intValue();
    int evFull = ((Integer) request.getAttribute("evFull")).intValue();
    int evCanceled = ((Integer) request.getAttribute("evCanceled")).intValue();
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Hadir - Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <link href="<%= ctx %>/css/ehadir.css" rel="stylesheet">
</head>
<body class="eh-ui-body">
<jsp:include page="/admin/layout/topbar.jsp"/>

<div class="container-fluid">
    <div class="row">
        <div class="col-12 col-md-3 col-lg-2 py-4">
            <jsp:include page="/admin/layout/sidebar.jsp"/>
        </div>
        <div class="col-12 col-md-9 col-lg-10 py-4">
            <h2 class="fw-bold mb-1">Admin Dashboard</h2>
            <p class="eh-muted mb-4">Welcome, <%= HtmlUtil.esc((String) session.getAttribute("name")) %></p>

            <div class="row g-3">
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number"><%= totalEvents %></div><div class="eh-muted">Total Events</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number"><%= canceledEvents %></div><div class="eh-muted">Canceled Events</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number"><%= regTotal %></div><div class="eh-muted">Registrations</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number"><%= students %></div><div class="eh-muted">Students</div>
                    </div>
                </div>
            </div>

            <div class="row g-3 mt-1">
                <div class="col-12 col-xl-7">
                    <div class="eh-card card p-4">
                        <h5 class="fw-bold">Registrations per Club</h5>
                        <div style="position:relative;height:300px"><canvas id="clubChart"></canvas></div>
                    </div>
                </div>
                <div class="col-12 col-xl-5">
                    <div class="eh-card card p-4">
                        <h5 class="fw-bold">Events by Status</h5>
                        <div style="position:relative;height:300px"><canvas id="statusChart"></canvas></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<script>
new Chart(document.getElementById('clubChart'), {
    type: 'bar',
    data: {
        labels: [<% for (int i = 0; i < clubLabels.size(); i++) { %>"<%= HtmlUtil.js(clubLabels.get(i)) %>"<%= i < clubLabels.size() - 1 ? "," : "" %><% } %>],
        datasets: [{ label: 'Registrations', backgroundColor: '#3d5af1',
                     data: [<% for (int i = 0; i < clubRegs.size(); i++) { %><%= clubRegs.get(i) %><%= i < clubRegs.size() - 1 ? "," : "" %><% } %>] }]
    },
    options: { responsive: true, maintainAspectRatio: false,
               scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
});
new Chart(document.getElementById('statusChart'), {
    type: 'doughnut',
    data: {
        labels: ['Open', 'Full', 'Canceled'],
        datasets: [{ backgroundColor: ['#2e9e5b', '#d99a00', '#d64545'],
                     data: [<%= evOpen %>, <%= evFull %>, <%= evCanceled %>] }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});
</script>
</body>
</html>