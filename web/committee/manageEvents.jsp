<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.List,java.text.SimpleDateFormat,com.ehadir.bean.Event,com.ehadir.util.HtmlUtil" %>
<%
    // Guard: committee sahaja
    if (!"committee".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    // Data belum dimuat: minta servlet ambil dari database
    if (request.getAttribute("events") == null) {
        request.getRequestDispatcher("/committee/manageEventsServlet").forward(request, response);
        return;
    }

    List<Event> events = (List<Event>) request.getAttribute("events");
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy, h:mm a");
    String ctx = request.getContextPath();

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Hadir - Manage Events</title>
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
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h2 class="fw-bold mb-1">Manage Events</h2>
                    <p class="eh-muted mb-0">Events organized by your club.</p>
                </div>
                <a href="<%= ctx %>/committee/addEvent.jsp" class="btn btn-eh-primary">
                    <i class="fa-solid fa-circle-plus me-2"></i>Add Event
                </a>
            </div>

            <% if ("added".equals(msg)) { %>
            <div class="alert alert-success rounded-4"><i class="fa-solid fa-circle-check me-2"></i>Event created.</div>
            <% } else if ("updated".equals(msg)) { %>
            <div class="alert alert-success rounded-4"><i class="fa-solid fa-circle-check me-2"></i>Event updated.</div>
            <% } %>
            <% if ("notfound".equals(error)) { %>
            <div class="alert alert-danger rounded-4"><i class="fa-solid fa-circle-exclamation me-2"></i>Event not found.</div>
            <% } else if ("system".equals(error)) { %>
            <div class="alert alert-danger rounded-4"><i class="fa-solid fa-circle-exclamation me-2"></i>Unexpected system error occurred.</div>
            <% } %>

            <div class="eh-card card">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Event</th>
                                    <th>Date</th>
                                    <th>Venue</th>
                                    <th>Registered</th>
                                    <th>Status</th>
                                    <th class="text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (events.isEmpty()) { %>
                                <tr><td colspan="6" class="text-center eh-muted py-4">No events yet. Click Add Event to create one.</td></tr>
                            <% } %>
                            <% for (Event e : events) {
                                   String st = e.getStatus();
                                   String badge = "bg-success";
                                   if ("full".equals(st)) {
                                       badge = "bg-warning text-dark";
                                   } else if ("canceled".equals(st)) {
                                       badge = "bg-danger";
                                   }
                            %>
                                <tr>
                                    <td>
                                        <div class="fw-bold"><%= HtmlUtil.esc(e.getTitle()) %></div>
                                        <span class="badge text-bg-light"><%= HtmlUtil.esc(e.getCategoryName()) %></span>
                                    </td>
                                    <td><%= fmt.format(e.getEventDate()) %></td>
                                    <td><%= HtmlUtil.esc(e.getVenue()) %></td>
                                    <td><%= e.getRegistered() %> / <%= e.getCapacity() %></td>
                                    <td>
                                        <span class="badge <%= badge %> text-capitalize"><%= HtmlUtil.esc(st) %></span>
                                        <% if (e.isEnded() && !"canceled".equals(st)) { %>
                                        <span class="badge bg-secondary">Ended</span>
                                        <% } %>
                                    </td>
                                    <td class="text-end">
                                        <a href="<%= ctx %>/committee/updateEventServlet?eventId=<%= e.getEventId() %>"
                                           class="btn btn-sm btn-outline-primary">
                                            <i class="fa-solid fa-pen me-1"></i>Edit
                                        </a>
                                        <a href="<%= ctx %>/committee/attendanceServlet?eventId=<%= e.getEventId() %>"
                                           class="btn btn-sm btn-outline-success">
                                            <i class="fa-solid fa-clipboard-check me-1"></i>Attendance
                                        </a>
                                    </td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>