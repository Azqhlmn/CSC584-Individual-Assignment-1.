<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.List,com.ehadir.bean.Category,com.ehadir.bean.Event,com.ehadir.util.DateUtil,com.ehadir.util.HtmlUtil" %>
<%
    // Guard: committee sahaja
    if (!"committee".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    // Data event belum dimuat: minta servlet ambil dari database
    if (request.getAttribute("event") == null) {
        request.getRequestDispatcher("/committee/updateEventServlet").forward(request, response);
        return;
    }

    Event ev = (Event) request.getAttribute("event");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    String ctx = request.getContextPath();

    String error = request.getParameter("error");
    String errorMessage = "";
    if (error != null) {
        if (error.equals("empty")) {
            errorMessage = "Please fill in all required fields.";
        } else if (error.equals("toolong")) {
            errorMessage = "Text is too long (title max 150, venue max 100, description max 500 characters).";
        } else if (error.equals("invalid")) {
            errorMessage = "Invalid category selected.";
        } else if (error.equals("capacity")) {
            errorMessage = "Capacity must be between 1 and 1000, and cannot be lower than the number already registered.";
        } else if (error.equals("date")) {
            errorMessage = "Invalid date and time.";
        } else if (error.equals("system")) {
            errorMessage = "Unexpected system error occurred.";
        }
    }
    int minCapacity = Math.max(1, ev.getRegistered());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Hadir - Update Event</title>
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
            <h2 class="fw-bold mb-1">Update Event</h2>
            <p class="eh-muted mb-4"><%= ev.getRegistered() %> student(s) registered so far.</p>

            <% if (!errorMessage.equals("")) { %>
            <div class="alert alert-danger rounded-4" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i><%= errorMessage %>
            </div>
            <% } %>

            <div class="eh-card card">
                <div class="card-body p-4">
                    <form action="<%= ctx %>/committee/updateEventServlet" method="post">
                        <input type="hidden" name="eventId" value="<%= ev.getEventId() %>">
                        <div class="row g-3">
                            <div class="col-md-8">
                                <label class="form-label">Event Title</label>
                                <input class="form-control" type="text" name="title" maxlength="150"
                                       value="<%= HtmlUtil.esc(ev.getTitle()) %>" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Category</label>
                                <select class="form-select" name="categoryId" required>
                                    <% for (Category c : categories) { %>
                                    <option value="<%= c.getCategoryId() %>"<%= c.getCategoryId() == ev.getCategoryId() ? " selected" : "" %>>
                                        <%= HtmlUtil.esc(c.getCategoryName()) %>
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Description</label>
                                <textarea class="form-control" name="description" rows="3" maxlength="500"><%= HtmlUtil.esc(ev.getDescription()) %></textarea>
                            </div>
                            <div class="col-md-5">
                                <label class="form-label">Venue</label>
                                <input class="form-control" type="text" name="venue" maxlength="100"
                                       value="<%= HtmlUtil.esc(ev.getVenue()) %>" required>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Date and Time</label>
                                <input class="form-control" type="datetime-local" name="eventDate"
                                       value="<%= DateUtil.toInput(ev.getEventDate()) %>" required>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Capacity</label>
                                <input class="form-control" type="number" name="capacity"
                                       min="<%= minCapacity %>" max="1000" value="<%= ev.getCapacity() %>" required>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Status</label>
                                <select class="form-select" name="status">
                                    <option value="open"<%= !"canceled".equals(ev.getStatus()) ? " selected" : "" %>>Open</option>
                                    <option value="canceled"<%= "canceled".equals(ev.getStatus()) ? " selected" : "" %>>Canceled</option>
                                </select>
                            </div>
                        </div>
                        <p class="small eh-muted mt-3 mb-0">
                            "Open" bertukar kepada "Full" secara automatik bila semua tempat dah diambil.
                        </p>

                        <div class="mt-4 d-flex gap-2">
                            <button class="btn btn-eh-primary" type="submit">
                                <i class="fa-solid fa-floppy-disk me-2"></i>Save Changes
                            </button>
                            <a href="<%= ctx %>/committee/manageEvents.jsp" class="btn btn-eh-soft">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
</body>
</html>