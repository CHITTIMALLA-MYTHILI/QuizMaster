<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    if (quizzes == null) {
        response.sendRedirect("quizzes");
        return;
    }

    List<String> categories = (List<String>) request.getAttribute("categories");
    String searchQuery = (String) request.getAttribute("searchQuery");
    if (searchQuery == null) searchQuery = "";
    String selectedCategory = (String) request.getAttribute("selectedCategory");
    if (selectedCategory == null) selectedCategory = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Quizzes — QuizMaster</title>
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
            <a href="quizzes" class="qm-navbar-link active"><i class="fa-solid fa-book-open me-1"></i> Browse Quizzes</a>
            <a href="results" class="qm-navbar-link"><i class="fa-solid fa-square-poll-vertical me-1"></i> My Results</a>
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
            <div class="page-header">
                <h1 class="page-title">Published Examinations</h1>
                <p class="page-subtitle">Select an examination, review instructions, and test your knowledge against time.</p>
            </div>

            <!-- Search and Filter Bar -->
            <div class="card mb-4 border-0 shadow-sm p-4 bg-white">
                <form action="quizzes" method="get" class="row g-3 align-items-center">
                    <div class="col-md-6">
                        <div class="input-group">
                            <span class="input-group-text bg-light"><i class="fa-solid fa-magnifying-glass text-muted"></i></span>
                            <input type="text" name="search" class="form-control"
                                   placeholder="Search quizzes by title or keywords..."
                                   value="<%= searchQuery %>">
                        </div>
                    </div>
                    <div class="col-md-4">
                        <select name="category" class="form-control" onchange="this.form.submit()">
                            <option value="">All Categories</option>
                            <% if (categories != null) {
                                for (String cat : categories) {
                            %>
                                <option value="<%= cat %>" <%= cat.equalsIgnoreCase(selectedCategory) ? "selected" : "" %>>
                                    <%= cat %>
                                </option>
                            <%  }
                            } %>
                        </select>
                    </div>
                    <div class="col-md-2 d-flex gap-2">
                        <button type="submit" class="btn btn-primary flex-grow">Filter</button>
                        <% if (!searchQuery.isEmpty() || !selectedCategory.isEmpty()) { %>
                            <a href="quizzes" class="btn btn-outline-gray" title="Reset Filters"><i class="fa-solid fa-rotate-left"></i></a>
                        <% } %>
                    </div>
                </form>
            </div>

            <!-- Quizzes Grid -->
            <% if (quizzes.isEmpty()) { %>
                <div class="card p-5 text-center">
                    <div class="empty-state">
                        <div class="empty-icon"><i class="fa-solid fa-folder-open text-muted"></i></div>
                        <h4 class="empty-title">No Quizzes Found</h4>
                        <p class="empty-desc">
                            <% if (!searchQuery.isEmpty() || !selectedCategory.isEmpty()) { %>
                                No published examinations match your search criteria. Try resetting the filters.
                            <% } else { %>
                                There are currently no published examinations available. Please check back later.
                            <% } %>
                        </p>
                        <% if (!searchQuery.isEmpty() || !selectedCategory.isEmpty()) { %>
                            <a href="quizzes" class="btn btn-primary">Clear Filters</a>
                        <% } %>
                    </div>
                </div>
            <% } else { %>
                <div class="grid grid-3 section-gap">
                    <% for (Quiz q : quizzes) { %>
                        <div class="quiz-card">
                            <div class="d-flex justify-content-between align-items-start mb-2">
                                <span class="badge badge-primary"><%= q.getCategory() %></span>
                                <span class="badge badge-published fs-sm"><i class="fa-solid fa-circle text-success me-1" style="font-size: 7px;"></i> Available</span>
                            </div>
                            <h3 class="quiz-card-title"><%= q.getTitle() %></h3>
                            <p class="quiz-card-desc"><%= q.getDescription() != null ? q.getDescription() : "No detailed description provided." %></p>

                            <div class="quiz-meta border-top pt-3">
                                <div class="quiz-meta-item">
                                    <i class="fa-regular fa-clock text-primary"></i> <%= q.getDuration() %> mins
                                </div>
                                <div class="quiz-meta-item">
                                    <i class="fa-solid fa-award text-success"></i> <%= q.getTotalMarks() %> marks
                                </div>
                                <div class="quiz-meta-item">
                                    <i class="fa-solid fa-list-ol text-info"></i> <%= q.getNumberOfQuestions() %> questions
                                </div>
                            </div>

                            <a href="instructions.jsp?quizId=<%= q.getQuizId() %>" class="btn btn-primary btn-block mt-3">
                                <i class="fa-solid fa-circle-play me-2"></i> View Instructions & Start
                            </a>
                        </div>
                    <% } %>
                </div>
            <% } %>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>