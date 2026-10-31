<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session.getAttribute("studentId") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Login — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
</head>
<body class="auth-wrapper">

    <div class="auth-card">
        <div class="auth-logo">
            <div class="auth-logo-icon">
                <i class="fa-solid fa-graduation-cap"></i>
            </div>
            <h1 class="auth-logo-title">Welcome to QuizMaster</h1>
            <p class="auth-logo-sub">Your online examination portal</p>
        </div>

        <%
            String registered = request.getParameter("registered");
            if ("true".equals(registered)) {
        %>
            <div class="alert alert-success">
                <i class="fa-solid fa-circle-check mt-1"></i>
                <div>Account created successfully! Please sign in.</div>
            </div>
        <%
            }
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-triangle-exclamation mt-1"></i>
                <div><%= error %></div>
            </div>
        <%
            }
            String savedEmail = (String) request.getAttribute("email");
            if (savedEmail == null) savedEmail = "";
        %>

        <form action="login" method="post">
            <div class="form-group mb-3">
                <label class="form-label" for="email">Email Address</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="fa-regular fa-envelope text-muted"></i></span>
                    <input type="email" id="email" name="email" class="form-control border-start-0 ps-0"
                           placeholder="student@example.com" value="<%= savedEmail %>" required autofocus>
                </div>
            </div>

            <div class="form-group mb-4">
                <label class="form-label" for="password">Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0"><i class="fa-solid fa-lock text-muted"></i></span>
                    <input type="password" id="password" name="password" class="form-control border-start-0 border-end-0 ps-0"
                           placeholder="Enter your password" required>
                    <button class="btn btn-outline-gray bg-white border-start-0" type="button" onclick="togglePassword('password', 'pwIcon')">
                        <i class="fa-regular fa-eye text-muted" id="pwIcon"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn btn-primary btn-block btn-lg mb-3">
                Sign In to Examination Portal
            </button>
        </form>

        <div class="text-center mt-3 pt-3 border-top">
            <p class="text-muted fs-sm mb-2">
                Don't have an account? <a href="register.jsp" class="fw-bold">Create Account</a>
            </p>
            <p class="text-muted fs-sm mb-0">
                <a href="admin-login.jsp" class="text-muted"><i class="fa-solid fa-shield-halved me-1"></i> Administrator Access</a> · 
                <a href="index.jsp" class="text-muted"><i class="fa-solid fa-house me-1"></i> Home</a>
            </p>
        </div>
    </div>

    <script>
        function togglePassword(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            if (input.type === 'password') {
                input.type = 'text';
                icon.className = 'fa-regular fa-eye-slash text-muted';
            } else {
                input.type = 'password';
                icon.className = 'fa-regular fa-eye text-muted';
            }
        }
    </script>
</body>
</html>