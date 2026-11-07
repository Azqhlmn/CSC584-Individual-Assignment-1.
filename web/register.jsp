<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Hadir - Register</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/ehadir.css" rel="stylesheet">
    <script>
    function validateForm() {
        var pw = document.getElementById("password").value;
        var cf = document.getElementById("confirmPassword").value;
        if (pw.length < 8) { alert("Password mesti sekurang-kurangnya 8 aksara."); return false; }
        if (pw !== cf) { alert("Password dan Confirm password tidak sama."); return false; }
        return true;
    }
    </script>
</head>
<body class="eh-ui-body">
<main class="min-vh-100 d-flex align-items-center justify-content-center py-5 px-3">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 col-lg-8 col-xl-7">
                <div class="text-center mb-4">
                    <div class="eh-brand-badge mx-auto mb-3">
                        <i class="fa-solid fa-user-plus"></i>
                    </div>
                    <h1 class="eh-page-title">Student Registration</h1>
                    <p class="eh-page-subtitle mx-auto">Create your student account to register for club events and workshops.</p>
                </div>

                <div class="eh-card card">
                    <div class="card-body p-4 p-lg-5">
                        <%
                        String error = request.getParameter("error");
                        if (error != null) {
                            String errorMessage = "";
                            if (error.equals("empty")) {
                                errorMessage = "Please fill in all required fields.";
                            } else if (error.equals("studentid")) {
                                errorMessage = "Student ID must be 10 digits.";
                            } else if (error.equals("email")) {
                                errorMessage = "Email format is invalid.";
                            } else if (error.equals("password")) {
                                errorMessage = "Password must be at least 8 characters.";
                            } else if (error.equals("mismatch")) {
                                errorMessage = "Passwords do not match.";
                            } else if (error.equals("duplicate")) {
                                errorMessage = "Student ID or email is already registered.";
                            } else if (error.equals("system")) {
                                errorMessage = "Unexpected system error occurred. Make sure the Java DB server is running.";
                            }
                            if (!errorMessage.equals("")) {
                        %>
                        <div class="alert alert-danger rounded-4" role="alert">
                            <i class="fa-solid fa-circle-exclamation me-2"></i><%= errorMessage %>
                        </div>
                        <%
                            }
                        }
                        %>

                        <form action="<%=request.getContextPath()%>/registerServlet" method="post" onsubmit="return validateForm()">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Student ID (10 digits)</label>
                                    <input class="form-control" type="text" name="studentId" pattern="[0-9]{10}" title="10 digit nombor" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Full Name</label>
                                    <input class="form-control" type="text" name="name" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Email</label>
                                    <input class="form-control" type="email" name="email" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Password (min 8 characters)</label>
                                    <input class="form-control" type="password" id="password" name="password" minlength="8" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Confirm Password</label>
                                    <input class="form-control" type="password" id="confirmPassword" name="confirmPassword" minlength="8" required>
                                </div>
                            </div>

                            <div class="d-grid gap-2 mt-4">
                                <button class="btn btn-eh-primary" type="submit">
                                    <i class="fa-solid fa-user-plus me-2"></i>Register
                                </button>
                                <a href="login.jsp" class="btn btn-eh-soft">
                                    <i class="fa-solid fa-arrow-left me-2"></i>Back to Login
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>