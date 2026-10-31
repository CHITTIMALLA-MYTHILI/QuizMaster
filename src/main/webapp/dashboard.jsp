<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.dao.QuizDAO" %>
<%@ page import="com.quizmaster.dao.ResultDAO" %>
<%@ page import="com.quizmaster.dao.AttemptDAO" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="com.quizmaster.model.Result" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int studentId = (Integer) session.getAttribute("studentId");
    String studentName = (String) session.getAttribute("studentName");

    QuizDAO quizDAO = new QuizDAO();
    ResultDAO resultDAO = new ResultDAO();
    AttemptDAO attemptDAO = new AttemptDAO();

    List<Quiz> availableQuizzes = quizDAO.getPublishedQuizzes();
    List<Result> recentResults = resultDAO.getResultsByStudentId(studentId);
    int completedCount = attemptDAO.getCompletedAttemptsCountByStudent(studentId);

    // Calculate Average Score across attempts
    double avgScore = 0.0;
    if (recentResults != null && !recentResults.isEmpty()) {
        double sum = 0.0;
        for (Result r : recentResults) {
            sum += r.getPercentage();
        }
        avgScore = sum / recentResults.size();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
</head>
<body>

    <!-- Student Navbar -->
    <header class="qm-navbar">
        <a class="qm-navbar-brand" href="dashboard.jsp">
            <i class="fa-solid fa-graduation-cap"></i> QuizMaster
        </a>
        <div class="qm-navbar-links">
            <a href="dashboard.jsp" class="qm-navbar-link active"><i class="fa-solid fa-gauge me-1"></i> Dashboard</a>
            <a href="quizzes" class="qm-navbar-link"><i class="fa-solid fa-book-open me-1"></i> Browse Quizzes</a>
            <a href="results" class="qm-navbar-link"><i class="fa-solid fa-square-poll-vertical me-1"></i> My Results</a>
            <a href="ai-study-assistant" class="qm-navbar-link"><i class="fa-solid fa-wand-magic-sparkles me-1 text-primary"></i> AI Study Assistant</a>
            <a href="ai-tutor" class="qm-navbar-link"><i class="fa-solid fa-robot me-1 text-primary"></i> AI Tutor</a>
            <a href="leaderboard" class="qm-navbar-link"><i class="fa-solid fa-trophy me-1"></i> Leaderboard</a>
        </div>
        <div class="qm-navbar-user">
            <span class="username-display"><i class="fa-regular fa-user-circle me-1 text-primary"></i> <%= studentName %></span>
            <a href="logout" class="btn btn-outline-gray btn-sm text-danger"><i class="fa-solid fa-arrow-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper">
        <div class="container">
            <!-- Welcome Header -->
            <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h1 class="page-title">Welcome back, <%= studentName %>!</h1>
                    <p class="page-subtitle">Ready to test your skills? Take a new assessment or review past performances.</p>
                </div>
                <div class="d-flex gap-2">
                    <a href="ai-study-assistant" class="btn btn-outline-primary btn-lg shadow-sm">
                        <i class="fa-solid fa-wand-magic-sparkles me-2"></i> AI Study Assistant
                    </a>
                    <a href="quizzes" class="btn btn-primary btn-lg shadow-sm">
                        <i class="fa-solid fa-circle-play me-2"></i> Take an Examination
                    </a>
                </div>
            </div>

            <!-- Statistics Grid (4 Cards as requested in section 6) -->
            <div class="grid grid-4 section-gap">
                <div class="stat-card">
                    <div class="stat-icon stat-icon-blue">
                        <i class="fa-solid fa-book-open"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= availableQuizzes != null ? availableQuizzes.size() : 0 %></div>
                        <div class="stat-label">Available Quizzes</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon stat-icon-green">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= completedCount %></div>
                        <div class="stat-label">Completed Exams</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon stat-icon-orange">
                        <i class="fa-solid fa-chart-line"></i>
                    </div>
                    <div>
                        <div class="stat-value"><%= String.format("%.1f", avgScore) %>%</div>
                        <div class="stat-label">Average Score</div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon stat-icon-purple">
                        <i class="fa-solid fa-trophy"></i>
                    </div>
                    <div>
                        <div class="stat-value">Rankings</div>
                        <div class="stat-label"><a href="leaderboard" class="text-primary fw-semibold">View Board →</a></div>
                    </div>
                </div>
            </div>

            <!-- Main Dashboard Panels -->
            <div class="row g-4">
                <!-- Available Examinations Panel -->
                <div class="col-lg-7">
                    <div class="card h-100">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="fw-bold mb-0"><i class="fa-solid fa-clipboard-list me-2 text-primary"></i> Available Examinations</h5>
                            <a href="quizzes" class="btn btn-sm btn-outline">Browse All</a>
                        </div>
                        <div class="card-body p-4">
                            <% if (availableQuizzes == null || availableQuizzes.isEmpty()) { %>
                                <div class="empty-state">
                                    <div class="empty-icon"><i class="fa-regular fa-calendar-xmark text-muted"></i></div>
                                    <h5 class="empty-title">No Quizzes Published Yet</h5>
                                    <p class="empty-desc">There are no examinations available at this moment. Please check back later.</p>
                                </div>
                            <% } else { %>
                                <div class="d-flex flex-column gap-3">
                                    <%
                                        int count = 0;
                                        for (Quiz q : availableQuizzes) {
                                            if (count++ >= 3) break;
                                    %>
                                        <div class="p-3 rounded border d-flex justify-content-between align-items-center flex-wrap gap-2 hover-shadow bg-white">
                                            <div>
                                                <div class="d-flex align-items-center gap-2 mb-1">
                                                    <span class="badge badge-primary fs-sm"><%= q.getCategory() %></span>
                                                    <span class="text-muted fs-sm"><i class="fa-regular fa-clock me-1"></i> <%= q.getDuration() %> mins</span>
                                                    <span class="text-muted fs-sm"><i class="fa-solid fa-award me-1"></i> <%= q.getTotalMarks() %> marks</span>
                                                </div>
                                                <h5 class="fw-bold mb-0 text-navy"><%= q.getTitle() %></h5>
                                            </div>
                                            <a href="instructions.jsp?quizId=<%= q.getQuizId() %>" class="btn btn-sm btn-primary">
                                                Instructions <i class="fa-solid fa-arrow-right ms-1"></i>
                                            </a>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Recent Performance Panel -->
                <div class="col-lg-5">
                    <div class="card h-100">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="fw-bold mb-0"><i class="fa-solid fa-chart-simple me-2 text-success"></i> Recent Performance</h5>
                            <a href="results" class="btn btn-sm btn-outline">Full History</a>
                        </div>
                        <div class="card-body p-0">
                            <% if (recentResults == null || recentResults.isEmpty()) { %>
                                <div class="empty-state py-5">
                                    <div class="empty-icon"><i class="fa-solid fa-award text-muted"></i></div>
                                    <h5 class="empty-title">No Examinations Taken</h5>
                                    <p class="empty-desc">Take your first quiz to see your performance metrics and grades here.</p>
                                </div>
                            <% } else { %>
                                <div class="table-wrap">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Quiz</th>
                                                <th>Score</th>
                                                <th>Grade</th>
                                                <th class="text-end">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                int resCount = 0;
                                                for (Result r : recentResults) {
                                                    if (resCount++ >= 4) break;
                                            %>
                                                <tr>
                                                    <td>
                                                        <div class="fw-bold"><%= r.getQuizTitle() %></div>
                                                        <small class="text-muted"><%= String.format("%.1f", r.getPercentage()) %>%</small>
                                                    </td>
                                                    <td><span class="badge badge-primary"><%= r.getScore() %> / <%= r.getTotalMarks() %></span></td>
                                                    <td>
                                                        <span class="badge <%= "F".equalsIgnoreCase(r.getGrade()) ? "badge-danger" : "badge-success" %>">
                                                            <%= r.getGrade() %>
                                                        </span>
                                                    </td>
                                                    <td class="text-end">
                                                        <a href="view-result?resultId=<%= r.getResultId() %>" class="btn btn-sm btn-outline-gray">
                                                            Review
                                                        </a>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>