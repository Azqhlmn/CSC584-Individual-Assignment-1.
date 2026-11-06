<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.List,java.text.SimpleDateFormat,com.ehadir.bean.Registration,com.ehadir.util.HtmlUtil" %>
<%
    // Guard: student sahaja
    if (!"student".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    // Data belum dimuat: minta servlet ambil dari database
    if (request.getAttribute("tickets") == null) {
        request.getRequestDispatcher("/student/myTicketsServlet").forward(request, response);
        return;
    }

    List<Registration> tickets = (List<Registration>) request.getAttribute("tickets");
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy, h:mm a");
    String ctx = request.getContextPath();

    String msg = request.getParameter("msg");
    String error = request.getParameter("error");
    String errorMessage = "";
    if (error != null) {
        if (error.equals("notpending")) {
            errorMessage = "Only tickets that are still pending can be canceled.";
        } else if (error.equals("ended")) {
            errorMessage = "This event has already started or ended.";
        } else if (error.equals("notfound") || error.equals("invalid")) {
            errorMessage = "Ticket not found.";
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
    <title>E-Hadir - My Tickets</title>
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
            <h2 class="fw-bold mb-1">My Tickets</h2>
            <p class="eh-muted mb-4">Show your ticket code to the committee when you arrive.</p>

            <% if ("registered".equals(msg)) { %>
            <div class="alert alert-success rounded-4" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i>Registration successful. Your ticket is below.
            </div>
            <% } else if ("canceled".equals(msg)) { %>
            <div class="alert alert-info rounded-4" role="alert">
                <i class="fa-solid fa-circle-info me-2"></i>Your registration has been canceled.
            </div>
            <% } %>
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
                                    <th>Ticket Code</th>
                                    <th>Event</th>
                                    <th>Date</th>
                                    <th>Venue</th>
                                    <th>Attendance</th>
                                    <th class="text-end">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (tickets.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="text-center eh-muted py-4">
                                        You have no tickets yet.
                                        <a href="<%= ctx %>/student/eventList.jsp">Browse events</a>
                                    </td>
                                </tr>
                            <% } %>
                            <% for (Registration r : tickets) {
                                   String st = r.getAttendanceStatus();
                                   String badge = "bg-secondary";
                                   if ("attended".equals(st)) {
                                       badge = "bg-success";
                                   } else if ("absent".equals(st)) {
                                       badge = "bg-danger";
                                   } else if ("pending".equals(st)) {
                                       badge = "bg-warning text-dark";
                                   }
                            %>
                                <tr>
                                    <td><span class="eh-ticket-code"><%= HtmlUtil.esc(r.getTicketCode()) %></span></td>
                                    <td>
                                        <div class="fw-bold"><%= HtmlUtil.esc(r.getEventTitle()) %></div>
                                        <div class="small eh-muted"><%= HtmlUtil.esc(r.getClubName()) %></div>
                                    </td>
                                    <td><%= fmt.format(r.getEventDate()) %></td>
                                    <td><%= HtmlUtil.esc(r.getVenue()) %></td>
                                    <td><span class="badge <%= badge %> text-capitalize"><%= HtmlUtil.esc(st) %></span></td>
                                    <td class="text-end">
                                    <% if (r.isCanCancel()) { %>
                                        <form action="<%= ctx %>/student/cancelTicketServlet" method="post" class="d-inline"
                                              onsubmit="return confirm('Cancel this registration?');">
                                            <input type="hidden" name="regId" value="<%= r.getRegId() %>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="fa-solid fa-xmark me-1"></i>Cancel
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