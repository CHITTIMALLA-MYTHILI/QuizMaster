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
    <title>Student Registration — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
</head>
<body class="auth-wrapper">

    <div class="auth-card" style="max-width: 520px;">
        <div class="auth-logo">
            <div class="auth-logo-icon">
                <i class="fa-solid fa-user-plus text-primary"></i>
            </div>
            <h1 class="auth-logo-title">Student Registration</h1>
            <p class="auth-logo-sub">Create your QuizMaster account</p>
        </div>

        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <div class="alert alert-danger">
                <i class="fa-solid fa-triangle-exclamation mt-1"></i>
                <div><%= error %></div>
            </div>
        <%
            }
        %>

        <form action="register" method="post" id="regForm">
            <div class="form-group mb-3">
                <label class="form-label" for="name">Full Name</label>
                <div class="input-group">
                    <span class="input-group-text bg-light"><i class="fa-solid fa-user text-muted"></i></span>
                    <input type="text" id="name" name="name" class="form-control"
                           placeholder="John Doe" required autofocus>
                </div>
            </div>

            <div class="form-group mb-3">
                <label class="form-label" for="email">Email Address</label>
                <div class="input-group">
                    <span class="input-group-text bg-light"><i class="fa-solid fa-envelope text-muted"></i></span>
                    <input type="email" id="email" name="email" class="form-control"
                           placeholder="john@example.com" required>
                </div>
            </div>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label" for="department">Department</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="fa-solid fa-building-columns text-muted"></i></span>
                        <input type="text" id="department" name="department" class="form-control"
                               placeholder="e.g. IT, CS, Mech" required>
                    </div>
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label" for="year">Year of Study</label>
                    <div class="input-group">
                        <span class="input-group-text bg-light"><i class="fa-solid fa-calendar-days text-muted"></i></span>
                        <select id="year" name="year" class="form-control" required>
                            <option value="">Select Year</option>
                            <option value="1">1st Year</option>
                            <option value="2">2nd Year</option>
                            <option value="3">3rd Year</option>
                            <option value="4">4th Year</option>
                        </select>
                    </div>
                </div>
            </div>

            <div class="form-group mb-3">
                <label class="form-label" for="password">Password (min 6 characters)</label>
                <div class="input-group">
                    <span class="input-group-text bg-light"><i class="fa-solid fa-lock text-muted"></i></span>
                    <input type="password" id="password" name="password" class="form-control"
                           placeholder="Create secure password" minlength="6" required>
                </div>
            </div>

            <div class="form-group mb-4">
                <label class="form-label" for="confirmPassword">Confirm Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-light"><i class="fa-solid fa-check-double text-muted"></i></span>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control"
                           placeholder="Repeat password" minlength="6" required>
                </div>
                <div id="passwordMismatch" class="text-danger fs-sm mt-1" style="display: none;">
                    Passwords do not match!
                </div>
            </div>

            <button type="submit" class="btn btn-primary btn-block btn-lg mb-3">
                <i class="fa-solid fa-user-plus me-2"></i> Register Account
            </button>
        </form>

        <div class="text-center mt-3 pt-3 border-top">
            <p class="text-muted fs-sm mb-0">
                Already registered? <a href="login.jsp" class="fw-bold">Sign In here</a> | 
                <a href="index.jsp" class="text-muted"><i class="fa-solid fa-house me-1"></i> Home</a>
            </p>
        </div>
    </div>

    <script>
        document.getElementById('regForm').addEventListener('submit', function(e) {
            const p1 = document.getElementById('password').value;
            const p2 = document.getElementById('confirmPassword').value;
            const mismatch = document.getElementById('passwordMismatch');
            if (p1 !== p2) {
                e.preventDefault();
                mismatch.style.display = 'block';
            } else {
                mismatch.style.display = 'none';
            }
        });
    </script>
</body>
</html>