<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.List,java.text.SimpleDateFormat,com.ehadir.bean.Event,com.ehadir.util.HtmlUtil" %>
<%
    // Guard: admin sahaja
    if (!"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    // Data belum dimuat: minta servlet ambil dari database
    if (request.getAttribute("events") == null) {
        request.getRequestDispatcher("/admin/adminEventsServlet").forward(request, response);
        return;
    }

    List<Event> events = (List<Event>) request.getAttribute("events");
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy, h:mm a");
    String ctx = request.getContextPath();

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
    String errorMessage = "";
    if (error != null) {
        if (error.equals("notcanceled")) {
            errorMessage = "Only canceled events can be deleted.";
        } else if (error.equals("notfound")) {
            errorMessage = "Event not found.";
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
    <title>E-Hadir - Manage Events</title>
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
            <h2 class="fw-bold mb-1">Manage Events</h2>
            <p class="eh-muted mb-4">All events from every club. Only canceled events can be deleted.</p>

            <% if ("deleted".equals(msg)) { %>
            <div class="alert alert-success rounded-4"><i class="fa-solid fa-circle-check me-2"></i>Event deleted.</div>
            <% } %>
            <% if (!errorMessage.equals("")) { %>
            <div class="alert alert-danger rounded-4"><i class="fa-solid fa-circle-exclamation me-2"></i><%= errorMessage %></div>
            <% } %>

            <div class="eh-card card">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th>Event</th>
                                    <th>Club</th>
                                    <th>Date</th>
                                    <th>Registered</th>
                                    <th>Status</th>
                                    <th class="text-end">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (events.isEmpty()) { %>
                                <tr><td colspan="6" class="text-center eh-muted py-4">No events.</td></tr>
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
                                        <div class="small eh-muted"><%= HtmlUtil.esc(e.getVenue()) %></div>
                                    </td>
                                    <td><%= HtmlUtil.esc(e.getClubName()) %></td>
                                    <td><%= fmt.format(e.getEventDate()) %></td>
                                    <td><%= e.getRegistered() %> / <%= e.getCapacity() %></td>
                                    <td><span class="badge <%= badge %> text-capitalize"><%= HtmlUtil.esc(st) %></span></td>
                                    <td class="text-end">
                                    <% if ("canceled".equals(st)) { %>
                                        <form action="<%= ctx %>/admin/deleteEventServlet" method="post" class="d-inline"
                                              onsubmit="return confirm('Delete this event and its <%= e.getRegistered() %> registration(s)? This cannot be undone.');">
                                            <input type="hidden" name="eventId" value="<%= e.getEventId() %>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="fa-solid fa-trash me-1"></i>Delete
                                            </button>
                                        </form>
                                    <% } else { %>
                                        <span class="eh-muted">-</span>
                                    <% } %>
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