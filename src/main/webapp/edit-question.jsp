<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="com.quizmaster.model.Question" %>
<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    Question question = (Question) request.getAttribute("question");
    Quiz quiz = (Quiz) request.getAttribute("quiz");

    if (question == null || quiz == null) {
        response.sendRedirect("admin-quizzes");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Question #<%= question.getQuestionId() %> — QuizMaster</title>
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
        <div class="container" style="max-width: 820px;">
            <div class="mb-3">
                <a href="admin-questions?quizId=<%= question.getQuizId() %>" class="text-muted">
                    <i class="fa-solid fa-arrow-left me-1"></i> Back to <%= quiz.getTitle() %> Questions
                </a>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <h4 class="fw-bold mb-0 text-primary">
                            <i class="fa-solid fa-pen me-2"></i> Edit Question #<%= question.getQuestionId() %>
                        </h4>
                        <span class="badge badge-primary"><%= quiz.getTitle() %></span>
                    </div>
                </div>

                <div class="card-body p-4">
                    <form action="editQuestion" method="post">
                        <input type="hidden" name="questionId" value="<%= question.getQuestionId() %>">
                        <input type="hidden" name="quizId" value="<%= question.getQuizId() %>">

                        <div class="form-group mb-3">
                            <label class="form-label" for="questionText">Question Text <span class="text-danger">*</span></label>
                            <textarea id="questionText" name="questionText" class="form-control" rows="3" required><%= question.getQuestionText() %></textarea>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="optionA">Option A <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text fw-bold">A</span>
                                    <input type="text" id="optionA" name="optionA" class="form-control" value="<%= question.getOptionA() %>" required>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="optionB">Option B <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text fw-bold">B</span>
                                    <input type="text" id="optionB" name="optionB" class="form-control" value="<%= question.getOptionB() %>" required>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="optionC">Option C <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text fw-bold">C</span>
                                    <input type="text" id="optionC" name="optionC" class="form-control" value="<%= question.getOptionC() %>" required>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="optionD">Option D <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text fw-bold">D</span>
                                    <input type="text" id="optionD" name="optionD" class="form-control" value="<%= question.getOptionD() %>" required>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="correctOption">Correct Option <span class="text-danger">*</span></label>
                                <select id="correctOption" name="correctOption" class="form-control" required>
                                    <option value="A" <%= "A".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>Option A</option>
                                    <option value="B" <%= "B".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>Option B</option>
                                    <option value="C" <%= "C".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>Option C</option>
                                    <option value="D" <%= "D".equalsIgnoreCase(question.getCorrectOption()) ? "selected" : "" %>>Option D</option>
                                </select>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="marks">Question Marks <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" id="marks" name="marks" class="form-control"
                                           min="1" max="100" value="<%= question.getMarks() %>" required>
                                    <span class="input-group-text bg-light">marks</span>
                                </div>
                            </div>
                        </div>

                        <div class="form-group mb-4">
                            <label class="form-label" for="explanation">Explanation (Optional)</label>
                            <textarea id="explanation" name="explanation" class="form-control" rows="2"
                                      placeholder="Explain why this option is correct..."><%= question.getExplanation() != null ? question.getExplanation() : "" %></textarea>
                        </div>

                        <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                            <a href="admin-questions?quizId=<%= question.getQuizId() %>" class="btn btn-outline-gray">Cancel</a>
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="fa-solid fa-check me-2"></i> Update Question
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
