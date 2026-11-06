<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Hadir - Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/ehadir.css" rel="stylesheet">
</head>
<body class="eh-ui-body">

<main class="min-vh-100 d-flex align-items-center justify-content-center py-5 px-3">
    <div class="container">
        <div class="row justify-content-center align-items-center g-4">
            <div class="col-12 col-lg-5">
                <div class="mb-4 text-center text-lg-start">
                    <div class="eh-brand-badge mb-3 mx-auto mx-lg-0">
                        <i class="fa-solid fa-ticket"></i>
                    </div>
                    <h1 class="eh-page-title">E-Hadir</h1>
                    <p class="eh-page-subtitle">
                        Student Event &amp; Workshop Ticketing. Browse club events, register for workshops, and get your digital ticket.
                    </p>
                </div>
            </div>

            <div class="col-12 col-md-8 col-lg-5">
                <div class="eh-card card">
                    <div class="card-body p-4 p-lg-5">
                        <div class="text-center mb-4">
                            <h2 class="fw-bold mb-1">Welcome Back</h2>
                            <p class="eh-muted mb-0">Sign in to continue</p>
                        </div>

                        <%
                        String error = request.getParameter("error");

                        if ("1".equals(request.getParameter("registered"))) {
                        %>
                        <div class="alert alert-success rounded-4" role="alert">
                            <i class="fa-solid fa-circle-check me-2"></i>Registration successful. Please login.
                        </div>
                        <%
                        }
                        if ("1".equals(request.getParameter("loggedout"))) {
                        %>
                        <div class="alert alert-info rounded-4" role="alert">
                            <i class="fa-solid fa-circle-info me-2"></i>You have been logged out.
                        </div>
                        <%
                        }

                        if (error != null) {
                            String errorMessage = "";

                            if (error.equals("empty")) {
                                errorMessage = "Please fill in all required fields.";
                            } else if (error.equals("invalid")) {
                                errorMessage = "Invalid email or password.";
                            } else if (error.equals("wrongrole")) {
                                errorMessage = "Incorrect user type selected. Please select the correct role.";
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

                        <form action="<%=request.getContextPath()%>/loginServlet" method="post">
                            <div class="mb-3">
                                <label class="form-label">User Type</label>
                                <select class="form-select" name="userType" required>
                                    <option value="">-- Select User Type --</option>
                                    <option value="student">Student</option>
                                    <option value="committee">Club Committee</option>
                                    <option value="admin">Admin</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-regular fa-envelope"></i></span>
                                    <input class="form-control" type="email" name="email" placeholder="Enter your email" required>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label">Password</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fa-solid fa-lock"></i></span>
                                    <input class="form-control" type="password" name="password" placeholder="Enter your password" required>
                                </div>
                            </div>

                            <button class="btn btn-eh-primary w-100" type="submit">
                                <i class="fa-solid fa-right-to-bracket me-2"></i>Login
                            </button>
                        </form>

                        <div class="text-center mt-4">
                            <span class="eh-muted">New student?</span>
                            <a href="register.jsp" class="fw-bold">Register Here</a>
                        </div>

                        <div class="text-center mt-3 small eh-muted">
                            Demo: student@ehadir.my / student123<br>
                            committee@ehadir.my / committee123<br>
                            admin@ehadir.my / admin123
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>