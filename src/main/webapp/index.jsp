<%@ page contentType="text/html;charset=UTF-8" %>
<%
    if (session.getAttribute("studentId") != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    if (session.getAttribute("adminLoggedIn") != null) {
        response.sendRedirect("admin-dashboard");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QuizMaster — Online Examination Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
</head>
<body>

    <!-- Header / Nav -->
    <header class="qm-navbar">
        <a class="qm-navbar-brand" href="index.jsp">
            <i class="fa-solid fa-graduation-cap text-info"></i> QuizMaster
        </a>
        <div class="qm-navbar-links">
            <a href="login.jsp" class="qm-navbar-link"><i class="fa-solid fa-user me-1"></i> Student Login</a>
            <a href="register.jsp" class="qm-navbar-link"><i class="fa-solid fa-user-plus me-1"></i> Register</a>
            <a href="admin-login.jsp" class="qm-navbar-link"><i class="fa-solid fa-lock me-1"></i> Admin</a>
        </div>
    </header>

    <!-- Hero Section -->
    <main class="page-wrapper" style="padding-top: 50px; padding-bottom: 70px;">
        <div class="container text-center">
            <div style="max-width: 800px; margin: 0 auto;">
                <div class="mb-4">
                    <span class="badge badge-primary px-3 py-2 fs-sm">
                        <i class="fa-solid fa-sparkles me-1"></i> Next-Gen Examination Experience
                    </span>
                </div>
                <h1 class="display-4 fw-bold mb-3" style="color: var(--primary-dark); letter-spacing: -0.5px;">
                    Online Examination Portal
                </h1>
                <p class="lead text-muted mb-5" style="font-size: 1.25rem;">
                    Test your knowledge, compete on real-time leaderboards, and get instant detailed analysis with QuizMaster.
                </p>

                <div class="d-flex justify-content-center gap-3 flex-wrap mb-5">
                    <a href="login.jsp" class="btn btn-primary btn-lg px-4 shadow-sm">
                        <i class="fa-solid fa-right-to-bracket me-2"></i> Student Login
                    </a>
                    <a href="register.jsp" class="btn btn-outline btn-lg px-4">
                        <i class="fa-solid fa-user-plus me-2"></i> Create Account
                    </a>
                    <a href="admin-login.jsp" class="btn btn-outline-gray btn-lg px-4">
                        <i class="fa-solid fa-shield-halved me-2"></i> Admin Portal
                    </a>
                </div>
            </div>

            <!-- Features Section -->
            <div class="row g-4 mt-4 text-start">
                <div class="col-md-4">
                    <div class="card h-100 p-4 border-0 shadow-sm">
                        <div class="stat-icon stat-icon-blue mb-3">
                            <i class="fa-solid fa-laptop-code text-primary"></i>
                        </div>
                        <h4 class="fw-bold mb-2">Timed Examinations</h4>
                        <p class="text-muted mb-0">
                            Strict server-synchronized countdown timer with automatic submission and question navigation.
                        </p>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="card h-100 p-4 border-0 shadow-sm">
                        <div class="stat-icon stat-icon-green mb-3">
                            <i class="fa-solid fa-chart-line text-success"></i>
                        </div>
                        <h4 class="fw-bold mb-2">Instant Evaluation</h4>
                        <p class="text-muted mb-0">
                            Automatic scoring, accurate percentage and letter grade calculation with full answer breakdown.
                        </p>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="card h-100 p-4 border-0 shadow-sm">
                        <div class="stat-icon stat-icon-purple mb-3">
                            <i class="fa-solid fa-trophy text-warning"></i>
                        </div>
                        <h4 class="fw-bold mb-2">Real-Time Leaderboard</h4>
                        <p class="text-muted mb-0">
                            Measure your performance against peers and rank top positions across various quiz categories.
                        </p>
                    </div>
                </div>
            </div>

            <footer class="mt-5 pt-5 text-muted fs-sm">
                <p>&copy; 2026 QuizMaster. Built with Java Servlets, JSP & MySQL.</p>
            </footer>
        </div>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>