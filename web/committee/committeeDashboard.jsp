<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.List,com.ehadir.util.HtmlUtil" %>
<%
    // Guard: committee sahaja
    if (!"committee".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    // Data belum dimuat: minta servlet ambil dari database
    if (request.getAttribute("myEvents") == null) {
        request.getRequestDispatcher("/committee/committeeDashboardServlet").forward(request, response);
        return;
    }
    int myEvents = ((Integer) request.getAttribute("myEvents")).intValue();
    int regTotal = ((Integer) request.getAttribute("regTotal")).intValue();
    String attendanceRate = (String) request.getAttribute("attendanceRate");
    int seatsLeft = ((Integer) request.getAttribute("seatsLeft")).intValue();
    List<String> labels = (List<String>) request.getAttribute("chartLabels");
    List<Integer> registered = (List<Integer>) request.getAttribute("chartRegistered");
    List<Integer> capacity = (List<Integer>) request.getAttribute("chartCapacity");
    int attAttended = ((Integer) request.getAttribute("attAttended")).intValue();
    int attAbsent = ((Integer) request.getAttribute("attAbsent")).intValue();
    int attPending = ((Integer) request.getAttribute("attPending")).intValue();
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Hadir - Committee Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <link href="<%= ctx %>/css/ehadir.css" rel="stylesheet">
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
                        <div class="eh-stat-number"><%= myEvents %></div><div class="eh-muted">My Events</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number"><%= regTotal %></div><div class="eh-muted">Registrations</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number"><%= attendanceRate %></div><div class="eh-muted">Attendance Rate</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="eh-card card p-3 text-center">
                        <div class="eh-stat-number"><%= seatsLeft %></div><div class="eh-muted">Seats Left (upcoming)</div>
                    </div>
                </div>
            </div>

            <div class="row g-3 mt-1">
                <div class="col-12 col-xl-8">
                    <div class="eh-card card p-4">
                        <h5 class="fw-bold">Registrations per Event</h5>
                        <div style="position:relative;height:300px"><canvas id="regChart"></canvas></div>
                    </div>
                </div>
                <div class="col-12 col-xl-4">
                    <div class="eh-card card p-4">
                        <h5 class="fw-bold">Attendance Status</h5>
                        <div style="position:relative;height:300px"><canvas id="attChart"></canvas></div>
                    </div>
                </div>
            </div>
            <p class="eh-muted small mt-3">
                Attendance rate dikira daripada pelajar yang sudah ditanda (attended + absent). Event yang dibatalkan tidak dipaparkan dalam carta.
            </p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
<script>
new Chart(document.getElementById('regChart'), {
    type: 'bar',
    data: {
        labels: [<% for (int i = 0; i < labels.size(); i++) { %>"<%= HtmlUtil.js(labels.get(i)) %>"<%= i < labels.size() - 1 ? "," : "" %><% } %>],
        datasets: [
            { label: 'Registered', backgroundColor: '#3d5af1',
              data: [<% for (int i = 0; i < registered.size(); i++) { %><%= registered.get(i) %><%= i < registered.size() - 1 ? "," : "" %><% } %>] },
            { label: 'Capacity', backgroundColor: '#c9d3ff',
              data: [<% for (int i = 0; i < capacity.size(); i++) { %><%= capacity.get(i) %><%= i < capacity.size() - 1 ? "," : "" %><% } %>] }
        ]
    },
    options: { responsive: true, maintainAspectRatio: false,
               scales: { y: { beginAtZero: true, ticks: { precision: 0 } } } }
});
new Chart(document.getElementById('attChart'), {
    type: 'doughnut',
    data: {
        labels: ['Attended', 'Absent', 'Pending'],
        datasets: [{ backgroundColor: ['#2e9e5b', '#d64545', '#d99a00'],
                     data: [<%= attAttended %>, <%= attAbsent %>, <%= attPending %>] }]
    },
    options: { responsive: true, maintainAspectRatio: false }
});
</script>
</body>
</html>