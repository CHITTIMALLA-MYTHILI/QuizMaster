<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Result" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    List<Result> results = (List<Result>) request.getAttribute("results");
    if (results == null) {
        response.sendRedirect("results");
        return;
    }

    Integer completedCount = (Integer) request.getAttribute("completedCount");
    if (completedCount == null) completedCount = results.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Results & Examination History — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
</head>
<body>

    <!-- Student Navbar -->
    <header class="qm-navbar">
        <a class="qm-navbar-brand" href="dashboard.jsp">
            <i class="fa-solid fa-graduation-cap text-info"></i> QuizMaster
        </a>
        <div class="qm-navbar-links">
            <a href="dashboard.jsp" class="qm-navbar-link"><i class="fa-solid fa-gauge me-1"></i> Dashboard</a>
            <a href="quizzes" class="qm-navbar-link"><i class="fa-solid fa-book-open me-1"></i> Browse Quizzes</a>
            <a href="results" class="qm-navbar-link active"><i class="fa-solid fa-square-poll-vertical me-1"></i> My Results</a>
            <a href="ai-study-assistant" class="qm-navbar-link"><i class="fa-solid fa-wand-magic-sparkles me-1 text-primary"></i> AI Study Assistant</a>
            <a href="ai-tutor" class="qm-navbar-link"><i class="fa-solid fa-robot me-1 text-primary"></i> AI Tutor</a>
            <a href="leaderboard" class="qm-navbar-link"><i class="fa-solid fa-trophy me-1"></i> Leaderboard</a>
        </div>
        <div class="qm-navbar-user">
            <span class="username-display"><i class="fa-solid fa-circle-user text-info me-1"></i> <%= studentName %></span>
            <a href="logout" class="btn btn-danger btn-sm"><i class="fa-solid fa-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper">
        <div class="container">
            <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h1 class="page-title">My Examination History</h1>
                    <p class="page-subtitle">Track your completed tests, percentages, letter grades, and review detailed answers.</p>
                </div>
                <div>
                    <a href="quizzes" class="btn btn-primary"><i class="fa-solid fa-play me-1"></i> Take Another Quiz</a>
                </div>
            </div>

            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <% if (results.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon"><i class="fa-solid fa-square-poll-vertical text-muted"></i></div>
                            <h4 class="empty-title">No Examinations Taken Yet</h4>
                            <p class="empty-desc">You haven't completed any quizzes yet. Explore our published quizzes and challenge yourself!</p>
                            <a href="quizzes" class="btn btn-primary mt-2"><i class="fa-solid fa-book-open me-1"></i> Browse Quizzes</a>
                        </div>
                    <% } else { %>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Quiz Title</th>
                                        <th>Score</th>
                                        <th>Percentage</th>
                                        <th>Grade</th>
                                        <th>Correct / Incorrect</th>
                                        <th>Date Completed</th>
                                        <th class="text-end">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        int index = 1;
                                        for (Result r : results) {
                                    %>
                                        <tr>
                                            <td class="text-muted fw-bold">#<%= index++ %></td>
                                            <td>
                                                <div class="fw-bold fs-6"><%= r.getQuizTitle() != null ? r.getQuizTitle() : "Quiz #" + r.getQuizId() %></div>
                                                <small class="text-muted">Attempt #<%= r.getAttemptId() %></small>
                                            </td>
                                            <td>
                                                <span class="badge badge-primary fs-sm">
                                                    <%= r.getScore() %> / <%= r.getTotalMarks() %>
                                                </span>
                                            </td>
                                            <td class="fw-bold"><%= String.format("%.2f", r.getPercentage()) %>%</td>
                                            <td>
                                                <span class="badge <%= "F".equalsIgnoreCase(r.getGrade()) ? "badge-danger" : "badge-success" %> px-3 py-1">
                                                    <%= r.getGrade() %>
                                                </span>
                                            </td>
                                            <td>
                                                <span class="text-success fw-bold"><%= r.getCorrectCount() %> correct</span>,
                                                <span class="text-danger"><%= r.getIncorrectCount() %> wrong</span>
                                            </td>
                                            <td class="text-muted fs-sm"><%= r.getCreatedAt() != null ? r.getCreatedAt().toString().substring(0, 16) : "" %></td>
                                            <td class="text-end">
                                                <a href="view-result?resultId=<%= r.getResultId() %>" class="btn btn-sm btn-outline" title="Review Detailed Answers">
                                                    <i class="fa-solid fa-eye me-1"></i> Review
                                                </a>
                                                <a href="leaderboard?quizId=<%= r.getQuizId() %>" class="btn btn-sm btn-outline-gray" title="Quiz Leaderboard">
                                                    <i class="fa-solid fa-trophy"></i>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>