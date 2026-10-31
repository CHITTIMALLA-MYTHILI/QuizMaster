<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.LeaderboardEntry" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    List<LeaderboardEntry> entries = (List<LeaderboardEntry>) request.getAttribute("entries");
    if (entries == null) {
        response.sendRedirect("leaderboard");
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
    <title>Hall of Fame — Leaderboard — QuizMaster</title>
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
            <a href="results" class="qm-navbar-link"><i class="fa-solid fa-square-poll-vertical me-1"></i> My Results</a>
            <a href="ai-study-assistant" class="qm-navbar-link"><i class="fa-solid fa-wand-magic-sparkles me-1 text-primary"></i> AI Study Assistant</a>
            <a href="ai-tutor" class="qm-navbar-link"><i class="fa-solid fa-robot me-1 text-primary"></i> AI Tutor</a>
            <a href="leaderboard" class="qm-navbar-link active"><i class="fa-solid fa-trophy me-1"></i> Leaderboard</a>
        </div>
        <div class="qm-navbar-user">
            <span class="username-display"><i class="fa-solid fa-circle-user text-info me-1"></i> <%= studentName %></span>
            <a href="logout" class="btn btn-danger btn-sm"><i class="fa-solid fa-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper">
        <div class="container" style="max-width: 900px;">
            <div class="page-header text-center mb-4">
                <div class="mb-2">
                    <span class="badge badge-warning px-3 py-2 fs-sm"><i class="fa-solid fa-crown me-1"></i> Hall of Fame</span>
                </div>
                <h1 class="page-title">QuizMaster Leaderboard</h1>
                <p class="page-subtitle">Celebrating top-scoring examination performances across all subjects.</p>
            </div>

            <!-- Quiz Filter Form -->
            <div class="card mb-4 border-0 shadow-sm p-3 bg-white">
                <form action="leaderboard" method="get" class="d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div class="d-flex align-items-center gap-2 flex-grow">
                        <label class="form-label mb-0 fw-semibold text-muted text-nowrap"><i class="fa-solid fa-filter me-1"></i> Filter by Quiz:</label>
                        <select name="quizId" class="form-control" onchange="this.form.submit()">
                            <option value="">Overall Top Scorers</option>
                            <% if (quizzes != null) {
                                for (Quiz q : quizzes) {
                            %>
                                <option value="<%= q.getQuizId() %>" <%= (selectedQuizId != null && selectedQuizId == q.getQuizId()) ? "selected" : "" %>>
                                    <%= q.getTitle() %>
                                </option>
                            <%  }
                            } %>
                        </select>
                    </div>
                    <% if (selectedQuizId != null) { %>
                        <a href="leaderboard" class="btn btn-outline-gray btn-sm">Clear Filter</a>
                    <% } %>
                </form>
            </div>

            <!-- Leaderboard Table -->
            <div class="card border-0 shadow-sm overflow-hidden">
                <div class="card-body p-0">
                    <% if (entries.isEmpty()) { %>
                        <div class="empty-state">
                            <div class="empty-icon"><i class="fa-solid fa-trophy text-muted"></i></div>
                            <h4 class="empty-title">No Rankings Available Yet</h4>
                            <p class="empty-desc">Take examinations to be the first champion featured on this leaderboard!</p>
                            <a href="quizzes" class="btn btn-primary mt-2">Take a Quiz Now</a>
                        </div>
                    <% } else { %>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th style="width: 70px;">Rank</th>
                                        <th>Student Name</th>
                                        <th>Quiz Title</th>
                                        <th>Score</th>
                                        <th>Percentage</th>
                                        <th>Grade</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        int rank = 1;
                                        for (LeaderboardEntry e : entries) {
                                            String medal = "";
                                            if (rank == 1) medal = "🥇";
                                            else if (rank == 2) medal = "🥈";
                                            else if (rank == 3) medal = "🥉";
                                    %>
                                        <tr class="<%= (rank <= 3) ? "fw-semibold" : "" %>">
                                            <td>
                                                <% if (rank <= 3) { %>
                                                    <span class="fs-5"><%= medal %></span>
                                                <% } else { %>
                                                    <span class="badge badge-gray">#<%= rank %></span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <div class="fw-bold"><%= e.getStudentName() %></div>
                                            </td>
                                            <td class="text-muted"><%= e.getQuizTitle() %></td>
                                            <td>
                                                <span class="badge badge-primary fs-sm">
                                                    <%= e.getScore() %> / <%= e.getTotalMarks() %>
                                                </span>
                                            </td>
                                            <td class="fw-bold text-success"><%= String.format("%.2f", e.getPercentage()) %>%</td>
                                            <td>
                                                <span class="badge <%= "F".equalsIgnoreCase(e.getGrade()) ? "badge-danger" : "badge-success" %> px-3 py-1">
                                                    <%= e.getGrade() %>
                                                </span>
                                            </td>
                                        </tr>
                                    <%
                                            rank++;
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </div>
            </div>

            <div class="text-center mt-4">
                <a href="dashboard.jsp" class="btn btn-outline-gray">
                    <i class="fa-solid fa-arrow-left me-1"></i> Back to Dashboard
                </a>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
