<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Result" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="com.quizmaster.model.Question" %>
<%@ page import="com.quizmaster.model.Answer" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Result result = (Result) request.getAttribute("result");
    if (result == null) {
        response.sendRedirect("results");
        return;
    }

    Quiz quiz = (Quiz) request.getAttribute("quiz");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    Map<Integer, Answer> answerMap = (Map<Integer, Answer>) request.getAttribute("answerMap");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examination Performance Review — QuizMaster</title>
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
            <a href="leaderboard" class="qm-navbar-link"><i class="fa-solid fa-trophy me-1"></i> Leaderboard</a>
        </div>
        <div class="qm-navbar-user">
            <span class="username-display"><i class="fa-solid fa-circle-user text-info me-1"></i> <%= session.getAttribute("studentName") %></span>
            <a href="logout" class="btn btn-danger btn-sm"><i class="fa-solid fa-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper">
        <div class="container" style="max-width: 880px;">
            <div class="mb-3 d-flex justify-content-between align-items-center">
                <a href="results" class="text-muted"><i class="fa-solid fa-arrow-left me-1"></i> Back to My Results</a>
                <a href="leaderboard?quizId=<%= result.getQuizId() %>" class="btn btn-sm btn-outline"><i class="fa-solid fa-trophy me-1"></i> View Leaderboard</a>
            </div>

            <!-- Score Hero Card -->
            <div class="result-score-box">
                <h4 class="fw-semibold mb-2" style="opacity: 0.9;"><%= quiz != null ? quiz.getTitle() : "Examination" %></h4>
                <div class="result-score-num"><%= result.getScore() %> <span class="result-score-denom">/ <%= result.getTotalMarks() %> Marks</span></div>
                <div class="fs-5 mt-2" style="opacity: 0.85;">Percentage: <%= String.format("%.2f", result.getPercentage()) %>%</div>
                <div>
                    <span class="result-grade-badge <%= "A+".equalsIgnoreCase(result.getGrade()) ? "grade-A-plus" : ("A".equalsIgnoreCase(result.getGrade()) ? "grade-A" : ("B".equalsIgnoreCase(result.getGrade()) ? "grade-B" : ("C".equalsIgnoreCase(result.getGrade()) ? "grade-C" : ("D".equalsIgnoreCase(result.getGrade()) ? "grade-D" : "grade-F")))) %>">
                        Grade <%= result.getGrade() %>
                    </span>
                </div>
            </div>

            <!-- Metrics Card -->
            <div class="row g-3 mb-4 text-center">
                <div class="col-sm-4">
                    <div class="card p-3 border-0 shadow-sm bg-white">
                        <div class="fs-3 fw-bold text-success"><%= result.getCorrectCount() %></div>
                        <div class="text-muted fs-sm">Correct Answers</div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="card p-3 border-0 shadow-sm bg-white">
                        <div class="fs-3 fw-bold text-danger"><%= result.getIncorrectCount() %></div>
                        <div class="text-muted fs-sm">Incorrect Answers</div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="card p-3 border-0 shadow-sm bg-white">
                        <div class="fs-3 fw-bold text-muted"><%= result.getUnansweredCount() %></div>
                        <div class="text-muted fs-sm">Unanswered</div>
                    </div>
                </div>
            </div>

            <!-- Detailed Question Breakdown -->
            <h4 class="fw-bold mb-3"><i class="fa-solid fa-list-check me-2 text-primary"></i> Question Review & Explanations</h4>

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
                            <span class="text-muted fs-sm">Question Weight: <%= q.getMarks() %> Mark<%= q.getMarks() == 1 ? "" : "s" %></span>
                        </div>

                        <h5 class="fw-bold mb-3">Q<%= qNum++ %>. <%= q.getQuestionText() %></h5>

                        <div class="row g-2 mb-3 fs-sm">
                            <div class="col-md-6">
                                <div class="p-2 rounded border <%= "A".equalsIgnoreCase(q.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %> <%= "A".equalsIgnoreCase(selected) && !isCorrect ? "bg-danger-subtle border-danger" : "" %>">
                                    <strong>A:</strong> <%= q.getOptionA() %>
                                    <% if ("A".equalsIgnoreCase(q.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1" title="Correct Answer"></i> <% } %>
                                    <% if ("A".equalsIgnoreCase(selected) && !isCorrect) { %> <i class="fa-solid fa-xmark text-danger ms-1" title="Your Choice"></i> (Your Choice) <% } %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-2 rounded border <%= "B".equalsIgnoreCase(q.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %> <%= "B".equalsIgnoreCase(selected) && !isCorrect ? "bg-danger-subtle border-danger" : "" %>">
                                    <strong>B:</strong> <%= q.getOptionB() %>
                                    <% if ("B".equalsIgnoreCase(q.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1" title="Correct Answer"></i> <% } %>
                                    <% if ("B".equalsIgnoreCase(selected) && !isCorrect) { %> <i class="fa-solid fa-xmark text-danger ms-1" title="Your Choice"></i> (Your Choice) <% } %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-2 rounded border <%= "C".equalsIgnoreCase(q.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %> <%= "C".equalsIgnoreCase(selected) && !isCorrect ? "bg-danger-subtle border-danger" : "" %>">
                                    <strong>C:</strong> <%= q.getOptionC() %>
                                    <% if ("C".equalsIgnoreCase(q.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1" title="Correct Answer"></i> <% } %>
                                    <% if ("C".equalsIgnoreCase(selected) && !isCorrect) { %> <i class="fa-solid fa-xmark text-danger ms-1" title="Your Choice"></i> (Your Choice) <% } %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="p-2 rounded border <%= "D".equalsIgnoreCase(q.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %> <%= "D".equalsIgnoreCase(selected) && !isCorrect ? "bg-danger-subtle border-danger" : "" %>">
                                    <strong>D:</strong> <%= q.getOptionD() %>
                                    <% if ("D".equalsIgnoreCase(q.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1" title="Correct Answer"></i> <% } %>
                                    <% if ("D".equalsIgnoreCase(selected) && !isCorrect) { %> <i class="fa-solid fa-xmark text-danger ms-1" title="Your Choice"></i> (Your Choice) <% } %>
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

            <div class="d-flex justify-content-center gap-3 mt-4">
                <a href="results" class="btn btn-outline-gray px-4">
                    <i class="fa-solid fa-arrow-left me-1"></i> All My Results
                </a>
                <a href="quizzes" class="btn btn-primary px-4">
                    <i class="fa-solid fa-play me-1"></i> Take Another Quiz
                </a>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
