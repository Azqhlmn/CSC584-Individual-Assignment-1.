<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.List,java.text.SimpleDateFormat,com.ehadir.bean.Event,com.ehadir.util.HtmlUtil" %>
<%
    // Guard: student sahaja
    if (!"student".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    // Data belum dimuat: minta servlet ambil dari database
    if (request.getAttribute("events") == null) {
        request.getRequestDispatcher("/student/eventListServlet").forward(request, response);
        return;
    }

    List<Event> events = (List<Event>) request.getAttribute("events");
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy, h:mm a");
    String ctx = request.getContextPath();

    String error = request.getParameter("error");
    String errorMessage = "";
    if (error != null) {
        if (error.equals("full")) {
            errorMessage = "Sorry, this event is already full.";
        } else if (error.equals("already")) {
            errorMessage = "You have already registered for this event.";
        } else if (error.equals("ended")) {
            errorMessage = "This event has already started or ended.";
        } else if (error.equals("canceled")) {
            errorMessage = "This event has been canceled.";
        } else if (error.equals("notfound") || error.equals("invalid")) {
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
    <title>E-Hadir - Browse Events</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <link href="<%= ctx %>/css/ehadir.css" rel="stylesheet">
</head>
<body class="eh-ui-body">
<jsp:include page="/student/layout/topbar.jsp"/>

<div class="container-fluid">
    <div class="row">
        <div class="col-12 col-md-3 col-lg-2 py-4">
            <jsp:include page="/student/layout/sidebar.jsp"/>
        </div>
        <div class="col-12 col-md-9 col-lg-10 py-4">
            <h2 class="fw-bold mb-1">Browse Events</h2>
            <p class="eh-muted mb-4">Register for a club event to get your digital ticket.</p>

            <% if (!errorMessage.equals("")) { %>
            <div class="alert alert-danger rounded-4" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i><%= errorMessage %>
            </div>
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
                                    <th>Venue</th>
                                    <th>Seats</th>
                                    <th class="text-end">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (events.isEmpty()) { %>
                                <tr><td colspan="6" class="text-center eh-muted py-4">No events available.</td></tr>
                            <% } %>
                            <% for (Event e : events) { %>
                                <tr>
                                    <td>
                                        <div class="fw-bold"><%= HtmlUtil.esc(e.getTitle()) %></div>
                                        <span class="badge text-bg-light"><%= HtmlUtil.esc(e.getCategoryName()) %></span>
                                    </td>
                                    <td><%= HtmlUtil.esc(e.getClubName()) %></td>
                                    <td><%= fmt.format(e.getEventDate()) %></td>
                                    <td><%= HtmlUtil.esc(e.getVenue()) %></td>
                                    <td><%= e.getRegistered() %> / <%= e.getCapacity() %></td>
                                    <td class="text-end">
                                    <% if (e.isRegisteredByMe()) { %>
                                        <a href="<%= ctx %>/student/myTicketsServlet" class="btn btn-sm btn-success">
                                            <i class="fa-solid fa-circle-check me-1"></i>Registered
                                        </a>
                                    <% } else if (e.isEnded()) { %>
                                        <span class="badge bg-secondary">Ended</span>
                                    <% } else if ("full".equals(e.getStatus()) || e.getSeatsLeft() == 0) { %>
                                        <span class="badge bg-warning text-dark">Full</span>
                                    <% } else { %>
                                        <form action="<%= ctx %>/student/registerEventServlet" method="post" class="d-inline">
                                            <input type="hidden" name="eventId" value="<%= e.getEventId() %>">
                                            <button type="submit" class="btn btn-sm btn-eh-primary">
                                                <i class="fa-solid fa-ticket me-1"></i>Register
                                            </button>
                                        </form>
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