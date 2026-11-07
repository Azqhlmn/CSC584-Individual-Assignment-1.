<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.List,java.text.SimpleDateFormat,com.ehadir.bean.Event,com.ehadir.bean.Registration,com.ehadir.util.HtmlUtil" %>
<%
    // Guard: committee sahaja
    if (!"committee".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    // Data belum dimuat: minta servlet ambil dari database
    if (request.getAttribute("clubEvents") == null) {
        request.getRequestDispatcher("/committee/attendanceServlet").forward(request, response);
        return;
    }

    List<Event> clubEvents = (List<Event>) request.getAttribute("clubEvents");
    Event selected = (Event) request.getAttribute("selectedEvent");
    List<Registration> regs = (List<Registration>) request.getAttribute("registrations");
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy");
    String ctx = request.getContextPath();

    int attended = 0;
    int absent = 0;
    int pending = 0;
    for (Registration r : regs) {
        if ("attended".equals(r.getAttendanceStatus())) {
            attended++;
        } else if ("absent".equals(r.getAttendanceStatus())) {
            absent++;
        } else {
            pending++;
        }
    }

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
    String errorMessage = "";
    if (error != null) {
        if (error.equals("notfound")) {
            errorMessage = "Ticket code not found for this event.";
        } else if (error.equals("invalid")) {
            errorMessage = "Invalid request.";
        } else if (error.equals("system")) {
            errorMessage = "Unexpected system error occurred.";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Hadir - Attendance</title>
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
            <h2 class="fw-bold mb-1">Attendance</h2>
            <p class="eh-muted mb-4">Select an event, then mark each student as attended or absent.</p>

            <% if ("updated".equals(msg)) { %>
            <div class="alert alert-success rounded-4"><i class="fa-solid fa-circle-check me-2"></i>Attendance updated.</div>
            <% } else if ("checkedin".equals(msg)) { %>
            <div class="alert alert-success rounded-4"><i class="fa-solid fa-circle-check me-2"></i>Ticket checked in.</div>
            <% } %>
            <% if (!errorMessage.equals("")) { %>
            <div class="alert alert-danger rounded-4"><i class="fa-solid fa-circle-exclamation me-2"></i><%= errorMessage %></div>
            <% } %>

            <div class="eh-card card mb-3">
                <div class="card-body p-4">
                    <form action="<%= ctx %>/committee/attendanceServlet" method="get" class="row g-2 align-items-end">
                        <div class="col-md-9">
                            <label class="form-label">Event</label>
                            <select class="form-select" name="eventId" required>
                                <option value="">-- Select event --</option>
                                <% for (Event e : clubEvents) { %>
                                <option value="<%= e.getEventId() %>"<%= (selected != null && selected.getEventId() == e.getEventId()) ? " selected" : "" %>>
                                    <%= HtmlUtil.esc(e.getTitle()) %> (<%= fmt.format(e.getEventDate()) %>)
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-md-3 d-grid">
                            <button class="btn btn-eh-primary" type="submit">
                                <i class="fa-solid fa-magnifying-glass me-2"></i>Show
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <% if (selected != null) { %>

            <div class="row g-3 mb-3">
                <div class="col-6 col-lg-3"><div class="eh-card card p-3 text-center"><div class="eh-stat-number"><%= regs.size() %></div><div class="eh-muted">Registered</div></div></div>
                <div class="col-6 col-lg-3"><div class="eh-card card p-3 text-center"><div class="eh-stat-number"><%= attended %></div><div class="eh-muted">Attended</div></div></div>
                <div class="col-6 col-lg-3"><div class="eh-card card p-3 text-center"><div class="eh-stat-number"><%= absent %></div><div class="eh-muted">Absent</div></div></div>
                <div class="col-6 col-lg-3"><div class="eh-card card p-3 text-center"><div class="eh-stat-number"><%= pending %></div><div class="eh-muted">Pending</div></div></div>
            </div>

            <div class="eh-card card mb-3">
                <div class="card-body p-4">
                    <form action="<%= ctx %>/committee/updateAttendanceServlet" method="post" class="row g-2 align-items-end">
                        <input type="hidden" name="eventId" value="<%= selected.getEventId() %>">
                        <div class="col-md-9">
                            <label class="form-label">Quick check-in by ticket code</label>
                            <input class="form-control" type="text" name="ticketCode" placeholder="EH-2026-00001" required>
                        </div>
                        <div class="col-md-3 d-grid">
                            <button class="btn btn-eh-primary" type="submit">
                                <i class="fa-solid fa-right-to-bracket me-2"></i>Check in
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="eh-card card">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Ticket Code</th>
                                    <th>Student</th>
                                    <th>Student ID</th>
                                    <th>Status</th>
                                    <th class="text-end">Mark as</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (regs.isEmpty()) { %>
                                <tr><td colspan="5" class="text-center eh-muted py-4">No students have registered for this event yet.</td></tr>
                            <% } %>
                            <% for (Registration r : regs) {
                                   String st = r.getAttendanceStatus();
                                   String badge = "bg-warning text-dark";
                                   if ("attended".equals(st)) {
                                       badge = "bg-success";
                                   } else if ("absent".equals(st)) {
                                       badge = "bg-danger";
                                   }
                            %>
                                <tr>
                                    <td><span class="eh-ticket-code"><%= HtmlUtil.esc(r.getTicketCode()) %></span></td>
                                    <td><%= HtmlUtil.esc(r.getStudentName()) %></td>
                                    <td><%= HtmlUtil.esc(r.getStudentId()) %></td>
                                    <td><span class="badge <%= badge %> text-capitalize"><%= HtmlUtil.esc(st) %></span></td>
                                    <td class="text-end">
                                        <form action="<%= ctx %>/committee/updateAttendanceServlet" method="post" class="d-inline">
                                            <input type="hidden" name="eventId" value="<%= selected.getEventId() %>">
                                            <input type="hidden" name="regId" value="<%= r.getRegId() %>">
                                            <button type="submit" name="status" value="attended" class="btn btn-sm btn-success">Attended</button>
                                            <button type="submit" name="status" value="absent" class="btn btn-sm btn-danger">Absent</button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <% } %>
        </div>
    </div>
</div>
</body>
</html>