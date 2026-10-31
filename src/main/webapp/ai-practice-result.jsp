<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.StudentPracticeAttempt" %>
<%@ page import="com.quizmaster.model.StudentPracticeQuiz" %>
<%@ page import="com.quizmaster.model.StudentPracticeQuestion" %>
<%@ page import="java.util.Map" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    StudentPracticeAttempt attempt = (StudentPracticeAttempt) request.getAttribute("attempt");
    StudentPracticeQuiz quiz = (StudentPracticeQuiz) request.getAttribute("quiz");
    @SuppressWarnings("unchecked")
    Map<Integer, String> userAnswers = (Map<Integer, String>) request.getAttribute("userAnswers");

    if (attempt == null || quiz == null) {
        response.sendRedirect("ai-study-assistant");
        return;
    }

    double pct = attempt.getPercentage();
    String performanceBadge;
    String badgeClass;
    if (pct >= 85.0) {
        performanceBadge = "Mastered (Excellent Understanding)";
        badgeClass = "bg-success";
    } else if (pct >= 60.0) {
        performanceBadge = "Proficient (Good Foundation)";
        badgeClass = "bg-primary";
    } else {
        performanceBadge = "Needs Revision (Target Weak Spots)";
        badgeClass = "bg-danger";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Practice Quiz Results — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
    <style>
        .result-banner {
            background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%);
            color: #ffffff;
            border-radius: var(--radius-xl);
            padding: 36px 40px;
            margin-bottom: 30px;
            box-shadow: var(--shadow-card);
        }
        .score-circle {
            width: 110px;
            height: 110px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            border: 4px solid #60a5fa;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            font-weight: 800;
        }
        .review-question-card {
            border: 1px solid var(--border-color);
            background: #ffffff;
            border-radius: var(--radius-lg);
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: var(--shadow-sm);
        }
        .option-review-row {
            padding: 12px 16px;
            border-radius: var(--radius-md);
            margin-bottom: 8px;
            border: 1px solid #e2e8f0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .option-review-row.is-correct {
            background: #ecfdf5;
            border-color: #a7f3d0;
            color: #065f46;
            font-weight: 600;
        }
        .option-review-row.is-incorrect-choice {
            background: #fef2f2;
            border-color: #fecaca;
            color: #991b1b;
        }
        .explanation-callout {
            background: #f0fdf4;
            border-left: 4px solid var(--success);
            padding: 14px 18px;
            border-radius: 0 var(--radius-md) var(--radius-md) 0;
            font-size: 14px;
            margin-top: 14px;
        }
        .revision-sheet {
            background: #fffbeb;
            border: 1px solid #fde68a;
            border-radius: var(--radius-xl);
            padding: 24px 28px;
            margin-bottom: 30px;
        }
    </style>
</head>
<body class="bg-page">

    <!-- Header -->
    <header class="qm-navbar">
        <a class="qm-navbar-brand" href="dashboard.jsp">
            <i class="fa-solid fa-graduation-cap"></i> QuizMaster
        </a>
        <div class="qm-navbar-links">
            <a href="dashboard.jsp" class="qm-navbar-link"><i class="fa-solid fa-gauge me-1"></i> Dashboard</a>
            <a href="ai-study-assistant" class="qm-navbar-link active"><i class="fa-solid fa-wand-magic-sparkles me-1 text-primary"></i> AI Study Assistant</a>
            <a href="results" class="qm-navbar-link"><i class="fa-solid fa-square-poll-vertical me-1"></i> My Results</a>
        </div>
        <div class="qm-navbar-user">
            <span class="username-display"><i class="fa-regular fa-user-circle me-1 text-primary"></i> <%= studentName %></span>
        </div>
    </header>

    <div class="page-wrapper py-4">
        <div class="container" style="max-width: 980px;">

            <!-- Results Banner -->
            <div class="result-banner d-flex justify-content-between align-items-center flex-wrap gap-4">
                <div>
                    <span class="badge <%= badgeClass %> px-3 py-2 fs-sm mb-2"><%= performanceBadge %></span>
                    <h1 class="h2 text-white fw-bold mb-2"><%= quiz.getTitle() %></h1>
                    <p class="text-white-50 mb-0">
                        Completed on <%= attempt.getCompletedAt() %> &bull; Practice Assessment Report
                    </p>
                </div>
                <div class="d-flex align-items-center gap-4">
                    <div class="score-circle">
                        <span><%= attempt.getScore() %>/<%= attempt.getTotalMarks() %></span>
                        <small style="font-size: 12px; font-weight: normal;"><%= attempt.getPercentage() %>%</small>
                    </div>
                </div>
            </div>

            <!-- Quick Metrics Grid -->
            <div class="row g-3 mb-4">
                <div class="col-sm-4">
                    <div class="card p-3 text-center border-0 shadow-sm">
                        <small class="text-muted"><i class="fa-solid fa-check-circle text-success me-1"></i> Correct Answers</small>
                        <h3 class="fw-bold text-success mb-0 mt-1"><%= attempt.getCorrectCount() %></h3>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="card p-3 text-center border-0 shadow-sm">
                        <small class="text-muted"><i class="fa-solid fa-circle-xmark text-danger me-1"></i> Incorrect Answers</small>
                        <h3 class="fw-bold text-danger mb-0 mt-1"><%= attempt.getIncorrectCount() %></h3>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="card p-3 text-center border-0 shadow-sm">
                        <small class="text-muted"><i class="fa-solid fa-chart-pie text-primary me-1"></i> Success Rate</small>
                        <h3 class="fw-bold text-primary mb-0 mt-1"><%= attempt.getPercentage() %>%</h3>
                    </div>
                </div>
            </div>

            <!-- Topics to Revise Diagnostic Sheet -->
            <div class="revision-sheet shadow-sm">
                <div class="d-flex align-items-center gap-2 mb-2">
                    <i class="fa-solid fa-lightbulb text-warning fa-lg"></i>
                    <h5 class="fw-bold text-navy mb-0">Target Revision Recommendations</h5>
                </div>
                <p class="text-muted fs-sm mb-3">AI diagnostic analysis based on your questions and responses:</p>
                <div class="p-3 bg-white rounded border" style="white-space: pre-line; line-height: 1.7; font-size: 14px;">
                    <%= attempt.getTopicsToRevise() %>
                </div>
            </div>

            <!-- Question Review Breakdown -->
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="fw-bold text-navy mb-0"><i class="fa-solid fa-list-check text-primary me-2"></i> Question Breakdown & Explanations</h4>
                <div class="d-flex gap-2">
                    <a href="ai-practice-quiz?action=take&quizId=<%= quiz.getQuizId() %>" class="btn btn-outline-primary btn-sm">
                        <i class="fa-solid fa-rotate-right me-1"></i> Retake Quiz
                    </a>
                    <a href="ai-study-assistant" class="btn btn-primary btn-sm">
                        <i class="fa-solid fa-arrow-left me-1"></i> Back to Study Assistant
                    </a>
                </div>
            </div>

            <%
                int qNum = 0;
                for (StudentPracticeQuestion q : quiz.getQuestions()) {
                    qNum++;
                    String chosen = userAnswers != null ? userAnswers.get(q.getQuestionId()) : null;
                    if (chosen == null) chosen = "";
                    boolean isCorrect = q.getCorrectOption() != null && q.getCorrectOption().equalsIgnoreCase(chosen);
            %>
                <div class="review-question-card">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <span class="badge <%= isCorrect ? "badge-success" : "badge-danger" %> px-3 py-1">
                            <i class="fa-solid <%= isCorrect ? "fa-check" : "fa-xmark" %> me-1"></i> Question <%= qNum %>: <%= isCorrect ? "Correct" : "Incorrect" %>
                        </span>
                        <span class="text-muted fs-sm">Correct Option: <strong><%= q.getCorrectOption() %></strong></span>
                    </div>

                    <h5 class="fw-bold text-navy mb-3"><%= q.getQuestionText() %></h5>

                    <!-- Option A -->
                    <div class="option-review-row <%= "A".equalsIgnoreCase(q.getCorrectOption()) ? "is-correct" : ("A".equalsIgnoreCase(chosen) ? "is-incorrect-choice" : "") %>">
                        <div>
                            <strong>A.</strong> <%= q.getOptionA() %>
                        </div>
                        <div>
                            <% if ("A".equalsIgnoreCase(q.getCorrectOption())) { %>
                                <span class="badge bg-success"><i class="fa-solid fa-check"></i> Correct Answer</span>
                            <% } else if ("A".equalsIgnoreCase(chosen)) { %>
                                <span class="badge bg-danger"><i class="fa-solid fa-xmark"></i> Your Choice</span>
                            <% } %>
                        </div>
                    </div>

                    <!-- Option B -->
                    <div class="option-review-row <%= "B".equalsIgnoreCase(q.getCorrectOption()) ? "is-correct" : ("B".equalsIgnoreCase(chosen) ? "is-incorrect-choice" : "") %>">
                        <div>
                            <strong>B.</strong> <%= q.getOptionB() %>
                        </div>
                        <div>
                            <% if ("B".equalsIgnoreCase(q.getCorrectOption())) { %>
                                <span class="badge bg-success"><i class="fa-solid fa-check"></i> Correct Answer</span>
                            <% } else if ("B".equalsIgnoreCase(chosen)) { %>
                                <span class="badge bg-danger"><i class="fa-solid fa-xmark"></i> Your Choice</span>
                            <% } %>
                        </div>
                    </div>

                    <!-- Option C -->
                    <% if (q.getOptionC() != null && !q.getOptionC().trim().isEmpty() && !"-".equals(q.getOptionC().trim())) { %>
                        <div class="option-review-row <%= "C".equalsIgnoreCase(q.getCorrectOption()) ? "is-correct" : ("C".equalsIgnoreCase(chosen) ? "is-incorrect-choice" : "") %>">
                            <div>
                                <strong>C.</strong> <%= q.getOptionC() %>
                            </div>
                            <div>
                                <% if ("C".equalsIgnoreCase(q.getCorrectOption())) { %>
                                    <span class="badge bg-success"><i class="fa-solid fa-check"></i> Correct Answer</span>
                                <% } else if ("C".equalsIgnoreCase(chosen)) { %>
                                    <span class="badge bg-danger"><i class="fa-solid fa-xmark"></i> Your Choice</span>
                                <% } %>
                            </div>
                        </div>
                    <% } %>

                    <!-- Option D -->
                    <% if (q.getOptionD() != null && !q.getOptionD().trim().isEmpty() && !"-".equals(q.getOptionD().trim())) { %>
                        <div class="option-review-row <%= "D".equalsIgnoreCase(q.getCorrectOption()) ? "is-correct" : ("D".equalsIgnoreCase(chosen) ? "is-incorrect-choice" : "") %>">
                            <div>
                                <strong>D.</strong> <%= q.getOptionD() %>
                            </div>
                            <div>
                                <% if ("D".equalsIgnoreCase(q.getCorrectOption())) { %>
                                    <span class="badge bg-success"><i class="fa-solid fa-check"></i> Correct Answer</span>
                                <% } else if ("D".equalsIgnoreCase(chosen)) { %>
                                    <span class="badge bg-danger"><i class="fa-solid fa-xmark"></i> Your Choice</span>
                                <% } %>
                            </div>
                        </div>
                    <% } %>

                    <!-- AI Explanation Callout -->
                    <div class="explanation-callout">
                        <strong class="text-navy d-block mb-1"><i class="fa-solid fa-circle-info text-success me-1"></i> Grounded Explanation:</strong>
                        <span class="text-body"><%= q.getExplanation() != null ? q.getExplanation() : "Refer to course study material for deeper context." %></span>
                    </div>
                </div>
            <% } %>

            <!-- Bottom Actions -->
            <div class="text-center mt-5 mb-4">
                <a href="ai-study-assistant" class="btn btn-primary btn-lg px-4 shadow-sm me-2">
                    <i class="fa-solid fa-wand-magic-sparkles me-2"></i> Return to AI Study Assistant
                </a>
                <a href="quizzes" class="btn btn-outline-gray btn-lg px-4 shadow-sm">
                    <i class="fa-solid fa-book-open me-2"></i> Browse All Examinations
                </a>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
