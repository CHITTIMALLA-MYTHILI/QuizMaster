<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="com.quizmaster.model.Question" %>
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

    List<Question> questions = (List<Question>) request.getAttribute("questions");
    int currentMarksSum = (Integer) request.getAttribute("currentMarksSum");
    boolean marksMatch = (currentMarksSum == quiz.getTotalMarks());
    int marksDiff = quiz.getTotalMarks() - currentMarksSum;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Questions — <%= quiz.getTitle() %> — QuizMaster</title>
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
        <div class="container">
            <div class="mb-3">
                <a href="admin-quizzes" class="text-muted"><i class="fa-solid fa-arrow-left me-1"></i> Back to Quizzes</a>
            </div>

            <div class="page-header d-flex justify-content-between align-items-start flex-wrap gap-3">
                <div>
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <span class="badge badge-primary"><%= quiz.getCategory() %></span>
                        <% if (quiz.isPublished()) { %>
                            <span class="badge badge-published"><i class="fa-solid fa-globe me-1"></i> Published</span>
                        <% } else { %>
                            <span class="badge badge-draft"><i class="fa-solid fa-pen-ruler me-1"></i> Draft</span>
                        <% } %>
                    </div>
                    <h1 class="page-title"><%= quiz.getTitle() %></h1>
                    <p class="page-subtitle"><%= quiz.getDescription() != null ? quiz.getDescription() : "No description provided." %></p>
                </div>
                <div class="d-flex gap-2">
                    <a href="add-question.jsp?quizId=<%= quiz.getQuizId() %>" class="btn btn-primary">
                        <i class="fa-solid fa-circle-plus me-1"></i> Add Question
                    </a>
                    <a href="editQuiz?quizId=<%= quiz.getQuizId() %>" class="btn btn-outline-gray">
                        <i class="fa-solid fa-gear me-1"></i> Edit Quiz
                    </a>
                </div>
            </div>

            <!-- Marks Alignment Banner -->
            <div class="card mb-4 border-0 shadow-sm" style="background: <%= marksMatch ? "#f0fdf4" : "#fffbeb" %>; border-left: 5px solid <%= marksMatch ? "var(--success)" : "var(--warning)" %> !important;">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                        <div>
                            <h5 class="fw-bold mb-1" style="color: <%= marksMatch ? "#166534" : "#92400e" %>;">
                                <i class="fa-solid <%= marksMatch ? "fa-circle-check" : "fa-triangle-exclamation" %> me-2"></i>
                                Marks Accounting: <%= currentMarksSum %> of <%= quiz.getTotalMarks() %> Marks Assigned
                            </h5>
                            <p class="mb-0 text-muted fs-sm">
                                <% if (marksMatch) { %>
                                    Question marks sum precisely matches configured quiz total marks. Ready to publish!
                                <% } else if (marksDiff > 0) { %>
                                    You need <strong><%= marksDiff %> more marks</strong> to publish this quiz.
                                <% } else { %>
                                    Current question marks exceed configured total by <strong><%= -marksDiff %> marks</strong>.
                                <% } %>
                            </p>
                        </div>
                        <div class="text-end">
                            <span class="fs-4 fw-bold <%= marksMatch ? "text-success" : "text-warning" %>">
                                <%= currentMarksSum %> / <%= quiz.getTotalMarks() %>
                            </span>
                            <div class="text-muted fs-sm"><%= questions.size() %> questions configured</div>
                        </div>
                    </div>
                </div>
            </div>

            <%
                String successMsg = (String) request.getAttribute("successMessage");
                if (successMsg != null) {
            %>
                <div class="alert alert-success">
                    <i class="fa-solid fa-circle-check mt-1"></i>
                    <div><%= successMsg %></div>
                </div>
            <%
                }
                String errorMsg = (String) request.getAttribute("errorMessage");
                if (errorMsg != null) {
            %>
                <div class="alert alert-danger">
                    <i class="fa-solid fa-triangle-exclamation mt-1"></i>
                    <div><%= errorMsg %></div>
                </div>
            <%
                }
            %>

            <!-- Questions Table -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold mb-0"><i class="fa-solid fa-list-ol me-2 text-primary"></i> Question List (<%= questions.size() %>)</h5>
                    <a href="add-question.jsp?quizId=<%= quiz.getQuizId() %>" class="btn btn-sm btn-primary">
                        <i class="fa-solid fa-plus me-1"></i> Add Another Question
                    </a>
                </div>
                <div class="card-body p-0">
                    <%
                        if (questions.isEmpty()) {
                    %>
                        <div class="empty-state">
                            <div class="empty-icon"><i class="fa-solid fa-clipboard-question text-muted"></i></div>
                            <h4 class="empty-title">No Questions Added Yet</h4>
                            <p class="empty-desc">This quiz has 0 questions. Add questions to meet the <%= quiz.getTotalMarks() %> total marks requirement.</p>
                            <a href="add-question.jsp?quizId=<%= quiz.getQuizId() %>" class="btn btn-primary">
                                <i class="fa-solid fa-plus me-1"></i> Add First Question
                            </a>
                        </div>
                    <%
                        } else {
                    %>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th style="width: 50px;">#</th>
                                        <th>Question</th>
                                        <th>Options</th>
                                        <th>Correct</th>
                                        <th>Marks</th>
                                        <th class="text-end">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        int qIndex = 1;
                                        for (Question q : questions) {
                                    %>
                                        <tr>
                                            <td class="text-muted fw-bold">Q<%= qIndex++ %></td>
                                            <td>
                                                <div class="fw-semibold mb-1" style="max-width: 450px;"><%= q.getQuestionText() %></div>
                                                <% if (q.getExplanation() != null && !q.getExplanation().trim().isEmpty()) { %>
                                                    <small class="text-muted d-block"><i class="fa-solid fa-lightbulb text-warning me-1"></i> <%= q.getExplanation() %></small>
                                                <% } %>
                                            </td>
                                            <td class="fs-sm">
                                                <div><strong>A:</strong> <%= q.getOptionA() %></div>
                                                <div><strong>B:</strong> <%= q.getOptionB() %></div>
                                                <div><strong>C:</strong> <%= q.getOptionC() %></div>
                                                <div><strong>D:</strong> <%= q.getOptionD() %></div>
                                            </td>
                                            <td>
                                                <span class="badge badge-success px-3 py-1 fs-sm">
                                                    Option <%= q.getCorrectOption() %>
                                                </span>
                                            </td>
                                            <td>
                                                <span class="badge badge-primary px-3 py-1 fs-sm">
                                                    <%= q.getMarks() %> mark<%= q.getMarks() == 1 ? "" : "s" %>
                                                </span>
                                            </td>
                                            <td>
                                                <div class="d-flex justify-content-end gap-1">
                                                    <a href="editQuestion?questionId=<%= q.getQuestionId() %>" class="btn btn-sm btn-outline-gray" title="Edit Question">
                                                        <i class="fa-solid fa-pen"></i>
                                                    </a>
                                                    <a href="admin-questions?action=delete&quizId=<%= quiz.getQuizId() %>&questionId=<%= q.getQuestionId() %>"
                                                       class="btn btn-sm btn-danger"
                                                       onclick="return confirm('Delete this question?');"
                                                       title="Delete Question">
                                                        <i class="fa-solid fa-trash-can"></i>
                                                    </a>
                                                </div>
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
