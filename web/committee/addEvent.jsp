<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.util.List,com.ehadir.bean.Category,com.ehadir.util.HtmlUtil" %>
<%
    // Guard: committee sahaja
    if (!"committee".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    // Kategori belum dimuat: minta servlet ambil dari database
    if (request.getAttribute("categories") == null) {
        request.getRequestDispatcher("/committee/addEventServlet").forward(request, response);
        return;
    }

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
            errorMessage = "Capacity must be a number between 1 and 1000.";
        } else if (error.equals("date")) {
            errorMessage = "Invalid date and time.";
        } else if (error.equals("pastdate")) {
            errorMessage = "Event date and time must be in the future.";
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
    <title>E-Hadir - Add Event</title>
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
            <h2 class="fw-bold mb-1">Add Event</h2>
            <p class="eh-muted mb-4">Create a new event for your club.</p>

            <% if (!errorMessage.equals("")) { %>
            <div class="alert alert-danger rounded-4" role="alert">
                <i class="fa-solid fa-circle-exclamation me-2"></i><%= errorMessage %>
            </div>
            <% } %>

            <div class="eh-card card">
                <div class="card-body p-4">
                    <form action="<%= ctx %>/committee/addEventServlet" method="post">
                        <div class="row g-3">
                            <div class="col-md-8">
                                <label class="form-label">Event Title</label>
                                <input class="form-control" type="text" name="title" maxlength="150" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Category</label>
                                <select class="form-select" name="categoryId" required>
                                    <option value="">-- Select --</option>
                                    <% for (Category c : categories) { %>
                                    <option value="<%= c.getCategoryId() %>"><%= HtmlUtil.esc(c.getCategoryName()) %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label">Description</label>
                                <textarea class="form-control" name="description" rows="3" maxlength="500"></textarea>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Venue</label>
                                <input class="form-control" type="text" name="venue" maxlength="100" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Date and Time</label>
                                <input class="form-control" type="datetime-local" name="eventDate" required>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Capacity</label>
                                <input class="form-control" type="number" name="capacity" min="1" max="1000" required>
                            </div>
                        </div>

                        <div class="mt-4 d-flex gap-2">
                            <button class="btn btn-eh-primary" type="submit">
                                <i class="fa-solid fa-floppy-disk me-2"></i>Save Event
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