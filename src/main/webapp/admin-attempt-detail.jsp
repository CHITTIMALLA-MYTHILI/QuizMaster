<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Attempt" %>
<%@ page import="com.quizmaster.model.Student" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="com.quizmaster.model.Result" %>
<%@ page import="com.quizmaster.model.Question" %>
<%@ page import="com.quizmaster.model.Answer" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    Attempt attempt = (Attempt) request.getAttribute("attempt");
    if (attempt == null) {
        response.sendRedirect("admin-results");
        return;
    }

    Student student = (Student) request.getAttribute("student");
    Quiz quiz = (Quiz) request.getAttribute("quiz");
    Result result = (Result) request.getAttribute("result");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    Map<Integer, Answer> answerMap = (Map<Integer, Answer>) request.getAttribute("answerMap");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attempt Audit #<%= attempt.getAttemptId() %> — QuizMaster</title>
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
        <div class="container" style="max-width: 900px;">
            <div class="mb-3">
                <a href="admin-results" class="text-muted"><i class="fa-solid fa-arrow-left me-1"></i> Back to Results List</a>
            </div>

            <!-- Attempt Summary Card -->
            <div class="card mb-4 border-0 shadow-sm">
                <div class="card-header bg-white border-bottom p-4">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <span class="badge badge-primary mb-1">Attempt #<%= attempt.getAttemptId() %></span>
                            <h2 class="fw-bold mb-0 text-primary">Student Examination Audit</h2>
                        </div>
                        <% if (result != null) { %>
                            <span class="badge <%= "F".equalsIgnoreCase(result.getGrade()) ? "badge-danger" : "badge-success" %> fs-5 px-3 py-2">
                                Grade: <%= result.getGrade() %> (<%= String.format("%.1f", result.getPercentage()) %>%)
                            </span>
                        <% } %>
                    </div>
                </div>

                <div class="card-body p-4">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="p-3 bg-light rounded">
                                <div class="text-muted fs-sm">Student Details</div>
                                <div class="fw-bold fs-5"><%= student != null ? student.getName() : "ID: " + attempt.getStudentId() %></div>
                                <div class="text-muted fs-sm"><%= student != null ? student.getEmail() : "" %></div>
                                <div class="text-muted fs-sm">Dept: <%= student != null ? student.getDepartment() : "N/A" %> | Year: <%= student != null ? student.getYear() : "N/A" %></div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="p-3 bg-light rounded">
                                <div class="text-muted fs-sm">Quiz Details</div>
                                <div class="fw-bold fs-5"><%= quiz != null ? quiz.getTitle() : "ID: " + attempt.getQuizId() %></div>
                                <div class="text-muted fs-sm">Category: <%= quiz != null ? quiz.getCategory() : "N/A" %></div>
                                <div class="text-muted fs-sm">Duration: <%= quiz != null ? quiz.getDuration() : 0 %> mins | Total Marks: <%= quiz != null ? quiz.getTotalMarks() : 0 %></div>
                            </div>
                        </div>
                    </div>

                    <% if (result != null) { %>
                        <div class="row g-3 mt-2 text-center">
                            <div class="col-sm-3 col-6">
                                <div class="p-3 border rounded">
                                    <div class="fs-4 fw-bold text-primary"><%= result.getScore() %> / <%= result.getTotalMarks() %></div>
                                    <div class="text-muted fs-sm">Final Score</div>
                                </div>
                            </div>
                            <div class="col-sm-3 col-6">
                                <div class="p-3 border rounded">
                                    <div class="fs-4 fw-bold text-success"><%= result.getCorrectCount() %></div>
                                    <div class="text-muted fs-sm">Correct Answers</div>
                                </div>
                            </div>
                            <div class="col-sm-3 col-6">
                                <div class="p-3 border rounded">
                                    <div class="fs-4 fw-bold text-danger"><%= result.getIncorrectCount() %></div>
                                    <div class="text-muted fs-sm">Incorrect Answers</div>
                                </div>
                            </div>
                            <div class="col-sm-3 col-6">
                                <div class="p-3 border rounded">
                                    <div class="fs-4 fw-bold text-muted"><%= result.getUnansweredCount() %></div>
                                    <div class="text-muted fs-sm">Unanswered</div>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Per-Question Answers Breakdown -->
            <h4 class="fw-bold mb-3"><i class="fa-solid fa-list-check me-2 text-primary"></i> Detailed Question-by-Question Response Audit</h4>

            <%
                if (questions != null) {
                    int qNum = 1;
                    for (Question q : questions) {
                        Answer ans = (answerMap != null) ? answerMap.get(q.getQuestionId()) : null;
                        String selected = (ans != null) ? ans.getSelectedOption() : null;
                        boolean answered = (selected != null && !selected.trim().isEmpty());
                        boolean isCorrect = answered && selected.equalsIgnoreCase(q.getCorrectOption());
            %>
                <div class="card mb-3 border-0 shadow-sm <%= isCorrect ? "border-start border-success border-4" : (answered ? "border-start border-danger border-4" : "border-start border-secondary border-4") %>">
                    <div class="card-body p-4">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="badge <%= isCorrect ? "badge-success" : (answered ? "badge-danger" : "badge-gray") %> px-3 py-1">
                                <%= isCorrect ? "Correct (+ " + q.getMarks() + " marks)" : (answered ? "Incorrect (0 marks)" : "Unanswered (0 marks)") %>
                            </span>
                            <span class="text-muted fs-sm">Weight: <%= q.getMarks() %> mark<%= q.getMarks() == 1 ? "" : "s" %></span>
                        </div>

                        <h5 class="fw-bold mb-3">Q<%= qNum++ %>. <%= q.getQuestionText() %></h5>

                        <div class="row g-2 mb-3 fs-sm">
                            <div class="col-md-6">
                                <div class="p-2 rounded border <%= "A".equalsIgnoreCase(q.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %> <%= "A".equalsIgnoreCase(selected) && !isCorrect ? "bg-danger-subtle border-danger" : "" %>">
                                    <strong>A:</strong> <%= q.getOptionA() %>
                                    <% if ("A".equalsIgnoreCase(q.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1"></i> <% } %>
                                    <% if ("A".equalsIgnoreCase(selected) && !isCorrect) { %> <i class="fa-solid fa-xmark text-danger ms-1"></i> (Student's Choice) <% } %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-2 rounded border <%= "B".equalsIgnoreCase(q.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %> <%= "B".equalsIgnoreCase(selected) && !isCorrect ? "bg-danger-subtle border-danger" : "" %>">
                                    <strong>B:</strong> <%= q.getOptionB() %>
                                    <% if ("B".equalsIgnoreCase(q.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1"></i> <% } %>
                                    <% if ("B".equalsIgnoreCase(selected) && !isCorrect) { %> <i class="fa-solid fa-xmark text-danger ms-1"></i> (Student's Choice) <% } %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-2 rounded border <%= "C".equalsIgnoreCase(q.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %> <%= "C".equalsIgnoreCase(selected) && !isCorrect ? "bg-danger-subtle border-danger" : "" %>">
                                    <strong>C:</strong> <%= q.getOptionC() %>
                                    <% if ("C".equalsIgnoreCase(q.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1"></i> <% } %>
                                    <% if ("C".equalsIgnoreCase(selected) && !isCorrect) { %> <i class="fa-solid fa-xmark text-danger ms-1"></i> (Student's Choice) <% } %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-2 rounded border <%= "D".equalsIgnoreCase(q.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %> <%= "D".equalsIgnoreCase(selected) && !isCorrect ? "bg-danger-subtle border-danger" : "" %>">
                                    <strong>D:</strong> <%= q.getOptionD() %>
                                    <% if ("D".equalsIgnoreCase(q.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1"></i> <% } %>
                                    <% if ("D".equalsIgnoreCase(selected) && !isCorrect) { %> <i class="fa-solid fa-xmark text-danger ms-1"></i> (Student's Choice) <% } %>
                                </div>
                            </div>
                        </div>

                        <% if (q.getExplanation() != null && !q.getExplanation().trim().isEmpty()) { %>
                            <div class="alert alert-info py-2 px-3 mb-0 fs-sm">
                                <i class="fa-solid fa-lightbulb me-1"></i> <strong>Explanation:</strong> <%= q.getExplanation() %>
                            </div>
                        <% } %>
                    </div>
                </div>
            <%
                    }
                }
            %>

            <div class="text-center mt-4">
                <a href="admin-results" class="btn btn-outline-gray px-4">
                    <i class="fa-solid fa-arrow-left me-1"></i> Back to All Results
                </a>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
