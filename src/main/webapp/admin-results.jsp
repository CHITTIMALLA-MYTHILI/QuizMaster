<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Result" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    List<Result> results = (List<Result>) request.getAttribute("results");
    if (results == null) {
        response.sendRedirect("admin-results");
        return;
    }

    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    Integer selectedQuizId = (Integer) request.getAttribute("selectedQuizId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examination Results & Attempts — Admin — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
</head>
<body>

    <!-- Admin Navbar -->
    <header class="qm-navbar" style="background: #0f172a;">
        <a class="qm-navbar-brand" href="admin-dashboard">
            <i class="fa-solid fa-graduation-cap text-info"></i> QuizMaster <span class="badge badge-warning ms-2">Admin</span>
        </a>
        <div class="qm-navbar-links">
            <a href="admin-dashboard" class="qm-navbar-link"><i class="fa-solid fa-gauge me-1"></i> Dashboard</a>
            <a href="admin-quizzes" class="qm-navbar-link"><i class="fa-solid fa-book me-1"></i> Quizzes</a>
            <a href="createQuiz" class="qm-navbar-link"><i class="fa-solid fa-plus me-1"></i> New Quiz</a>
            <a href="admin-results" class="qm-navbar-link active"><i class="fa-solid fa-square-poll-vertical me-1"></i> Results</a>
        </div>
        <div class="qm-navbar-user">
            <span><i class="fa-solid fa-circle-user text-warning me-1"></i> <%= session.getAttribute("adminUsername") %></span>
            <a href="adminLogout" class="btn btn-danger btn-sm"><i class="fa-solid fa-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper">
        <div class="container">
            <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h1 class="page-title">Student Examination Results</h1>
                    <p class="page-subtitle">Inspect completed attempts, evaluate student performance, and view question breakdowns.</p>
                </div>
            </div>

            <!-- Quiz Filter Bar -->
            <div class="card mb-4 border-0 shadow-sm p-3 bg-white">
                <form action="admin-results" method="get" class="d-flex align-items-center gap-3 flex-wrap">
                    <label class="form-label mb-0 fw-semibold text-muted"><i class="fa-solid fa-filter me-1"></i> Filter by Quiz:</label>
                    <select name="quizId" class="form-control" style="max-width: 350px;" onchange="this.form.submit()">
                        <option value="">All Quizzes (<%= results.size() %> attempts)</option>
                        <% if (quizzes != null) {
                            for (Quiz q : quizzes) {
                        %>
                            <option value="<%= q.getQuizId() %>" <%= (selectedQuizId != null && selectedQuizId == q.getQuizId()) ? "selected" : "" %>>
                                <%= q.getTitle() %> (<%= q.getCategory() %>)
                            </option>
                        <%  }
                        } %>
                    </select>
                    <% if (selectedQuizId != null) { %>
                        <a href="admin-results" class="btn btn-sm btn-outline-gray">Clear Filter</a>
                    <% } %>
                </form>
            </div>

            <!-- Results Table -->
            <div class="card">
                <div class="card-body p-0">
                    <% if (results.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon"><i class="fa-solid fa-file-excel text-muted"></i></div>
                            <h4 class="empty-title">No Examination Attempts Found</h4>
                            <p class="empty-desc">No students have completed the selected examination yet.</p>
                        </div>
                    <% } else { %>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Result ID</th>
                                        <th>Student</th>
                                        <th>Quiz Title</th>
                                        <th>Score / Marks</th>
                                        <th>Percentage</th>
                                        <th>Grade</th>
                                        <th>Correct / Total</th>
                                        <th>Date</th>
                                        <th class="text-end">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Result r : results) { %>
                                        <tr>
                                            <td class="text-muted fw-bold">#<%= r.getResultId() %></td>
                                            <td>
                                                <div class="fw-bold"><%= r.getStudentName() != null ? r.getStudentName() : "Student #" + r.getStudentId() %></div>
                                                <small class="text-muted">Student ID: <%= r.getStudentId() %></small>
                                            </td>
                                            <td class="fw-semibold"><%= r.getQuizTitle() != null ? r.getQuizTitle() : "Quiz #" + r.getQuizId() %></td>
                                            <td>
                                                <span class="badge badge-primary fs-sm">
                                                    <%= r.getScore() %> / <%= r.getTotalMarks() %>
                                                </span>
                                            </td>
                                            <td class="fw-bold"><%= String.format("%.1f", r.getPercentage()) %>%</td>
                                            <td>
                                                <span class="badge <%= "F".equalsIgnoreCase(r.getGrade()) ? "badge-danger" : "badge-success" %> px-3 py-1">
                                                    <%= r.getGrade() %>
                                                </span>
                                            </td>
                                            <td>
                                                <span class="text-success fw-bold"><%= r.getCorrectCount() %></span> <span class="text-muted">/</span>
                                                <span class="text-danger"><%= r.getIncorrectCount() %></span> <span class="text-muted">/</span>
                                                <span class="text-muted"><%= r.getUnansweredCount() %></span>
                                            </td>
                                            <td class="text-muted fs-sm"><%= r.getCreatedAt() != null ? r.getCreatedAt().toString().substring(0, 16) : "" %></td>
                                            <td class="text-end">
                                                <a href="admin-attempt-detail?attemptId=<%= r.getAttemptId() %>" class="btn btn-sm btn-outline" title="Inspect Full Attempt">
                                                    <i class="fa-solid fa-magnifying-glass me-1"></i> Audit
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
