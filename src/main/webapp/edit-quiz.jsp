<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    Quiz quiz = (Quiz) request.getAttribute("quiz");
    if (quiz == null) {
        response.sendRedirect("admin-quizzes");
        return;
    }

    List<String> categories = (List<String>) request.getAttribute("categories");
    int currentMarksSum = (Integer) request.getAttribute("currentMarksSum");
    int questionCount = (Integer) request.getAttribute("questionCount");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Quiz — <%= quiz.getTitle() %> — QuizMaster</title>
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
            <a href="admin-quizzes" class="qm-navbar-link active"><i class="fa-solid fa-book me-1"></i> Quizzes</a>
            <a href="createQuiz" class="qm-navbar-link"><i class="fa-solid fa-plus me-1"></i> New Quiz</a>
            <a href="admin-results" class="qm-navbar-link"><i class="fa-solid fa-square-poll-vertical me-1"></i> Results</a>
        </div>
        <div class="qm-navbar-user">
            <span><i class="fa-solid fa-circle-user text-warning me-1"></i> <%= session.getAttribute("adminUsername") %></span>
            <a href="adminLogout" class="btn btn-danger btn-sm"><i class="fa-solid fa-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper">
        <div class="container" style="max-width: 760px;">
            <div class="mb-3">
                <a href="admin-quizzes" class="text-muted"><i class="fa-solid fa-arrow-left me-1"></i> Back to Quizzes</a>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <h2 class="fw-bold mb-1" style="color: var(--primary);">
                            <i class="fa-solid fa-pen-to-square me-2 text-primary"></i> Edit Quiz #<%= quiz.getQuizId() %>
                        </h2>
                        <a href="admin-questions?quizId=<%= quiz.getQuizId() %>" class="btn btn-sm btn-outline">
                            <i class="fa-solid fa-list-ol me-1"></i> Questions (<%= questionCount %>)
                        </a>
                    </div>
                    <p class="text-muted mb-0">Modify title, category, duration or target marks.</p>
                </div>

                <div class="card-body p-4">
                    <%
                        String error = (String) session.getAttribute("errorMessage");
                        if (error != null) {
                            session.removeAttribute("errorMessage");
                    %>
                        <div class="alert alert-danger">
                            <i class="fa-solid fa-triangle-exclamation mt-1"></i>
                            <div><%= error %></div>
                        </div>
                    <%
                        }
                    %>

                    <form action="editQuiz" method="post">
                        <input type="hidden" name="quizId" value="<%= quiz.getQuizId() %>">

                        <div class="form-group mb-3">
                            <label class="form-label" for="title">Quiz Title <span class="text-danger">*</span></label>
                            <input type="text" id="title" name="title" class="form-control"
                                   value="<%= quiz.getTitle() %>" required>
                        </div>

                        <div class="form-group mb-3">
                            <label class="form-label" for="description">Quiz Description</label>
                            <textarea id="description" name="description" class="form-control" rows="3"><%= quiz.getDescription() != null ? quiz.getDescription() : "" %></textarea>
                        </div>

                        <div class="form-group mb-3">
                            <label class="form-label" for="category">Subject Category</label>
                            <select id="category" name="category" class="form-control">
                                <%
                                    String[] allCats = {"Programming", "Database", "Web Development", "Mathematics", "General Science", "Aptitude", "General"};
                                    for (String c : allCats) {
                                %>
                                    <option value="<%= c %>" <%= c.equalsIgnoreCase(quiz.getCategory()) ? "selected" : "" %>><%= c %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <div class="form-group">
                                    <label class="form-label" for="duration">Duration (Minutes) <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <input type="number" id="duration" name="duration" class="form-control"
                                               min="1" max="300" value="<%= quiz.getDuration() %>" required>
                                        <span class="input-group-text bg-light">mins</span>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <div class="form-group">
                                    <label class="form-label" for="totalMarks">Total Marks <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <input type="number" id="totalMarks" name="totalMarks" class="form-control"
                                               min="1" max="1000" value="<%= quiz.getTotalMarks() %>" required>
                                        <span class="input-group-text bg-light">marks</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="alert alert-warning fs-sm mb-4">
                            <i class="fa-solid fa-triangle-exclamation me-2"></i>
                            <strong>Marks Accounting Note:</strong> Currently, questions for this quiz total <strong><%= currentMarksSum %> marks</strong>. If you change Total Marks away from <%= currentMarksSum %>, the quiz will be automatically set to Draft until questions are updated to match.
                        </div>

                        <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                            <a href="admin-quizzes" class="btn btn-outline-gray">Cancel</a>
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="fa-solid fa-check me-2"></i> Save Changes
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
