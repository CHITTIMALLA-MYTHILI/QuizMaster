<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.dao.QuizDAO" %>
<%@ page import="com.quizmaster.dao.AttemptDAO" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="com.quizmaster.model.Attempt" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String quizIdParam = request.getParameter("quizId");
    if (quizIdParam == null || quizIdParam.trim().isEmpty()) {
        response.sendRedirect("quizzes");
        return;
    }

    int quizId;
    try {
        quizId = Integer.parseInt(quizIdParam.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("quizzes");
        return;
    }

    QuizDAO quizDAO = new QuizDAO();
    Quiz quiz = quizDAO.getQuizById(quizId);
    if (quiz == null || !quiz.isPublished()) {
        response.sendRedirect("quizzes");
        return;
    }

    int studentId = (Integer) session.getAttribute("studentId");
    AttemptDAO attemptDAO = new AttemptDAO();
    Attempt activeAttempt = attemptDAO.getActiveAttempt(studentId, quizId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instructions — <%= quiz.getTitle() %> — QuizMaster</title>
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
            <a href="leaderboard" class="qm-navbar-link"><i class="fa-solid fa-trophy me-1"></i> Leaderboard</a>
        </div>
        <div class="qm-navbar-user">
            <span class="username-display"><i class="fa-solid fa-circle-user text-info me-1"></i> <%= session.getAttribute("studentName") %></span>
            <a href="logout" class="btn btn-danger btn-sm"><i class="fa-solid fa-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper">
        <div class="container" style="max-width: 860px;">
            <div class="mb-3">
                <a href="quizzes" class="text-muted"><i class="fa-solid fa-arrow-left me-1"></i> Back to Browse Quizzes</a>
            </div>

            <div class="card shadow border-0 overflow-hidden">
                <div class="card-header bg-white border-bottom p-4">
                    <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                        <div>
                            <span class="badge badge-primary mb-2"><%= quiz.getCategory() %></span>
                            <h1 class="fw-bold mb-1" style="color: var(--primary);"><%= quiz.getTitle() %></h1>
                            <p class="text-muted mb-0"><%= quiz.getDescription() != null ? quiz.getDescription() : "Examination Portal" %></p>
                        </div>
                        <span class="badge badge-published fs-sm px-3 py-2">
                            <i class="fa-solid fa-circle-check me-1"></i> Verified Assessment
                        </span>
                    </div>
                </div>

                <div class="card-body p-4 p-md-5">
                    <% if (activeAttempt != null) { %>
                        <div class="alert alert-warning mb-4">
                            <i class="fa-solid fa-triangle-exclamation mt-1"></i>
                            <div>
                                <strong>Resume Existing Examination:</strong> You already have an ongoing attempt (#<%= activeAttempt.getAttemptId() %>) for this quiz. Clicking start will resume your examination with the remaining server time.
                            </div>
                        </div>
                    <% } %>

                    <!-- Quiz Meta Highlights -->
                    <div class="row g-3 mb-4 text-center">
                        <div class="col-sm-4">
                            <div class="p-3 bg-light rounded h-100">
                                <div class="stat-icon stat-icon-blue mx-auto mb-2" style="width: 48px; height: 48px;">
                                    <i class="fa-regular fa-clock text-primary fs-5"></i>
                                </div>
                                <h3 class="fw-bold mb-0 text-primary"><%= quiz.getDuration() %> Mins</h3>
                                <div class="text-muted fs-sm">Allotted Duration</div>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="p-3 bg-light rounded h-100">
                                <div class="stat-icon stat-icon-green mx-auto mb-2" style="width: 48px; height: 48px;">
                                    <i class="fa-solid fa-award text-success fs-5"></i>
                                </div>
                                <h3 class="fw-bold mb-0 text-success"><%= quiz.getTotalMarks() %> Marks</h3>
                                <div class="text-muted fs-sm">Total Examination Score</div>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="p-3 bg-light rounded h-100">
                                <div class="stat-icon stat-icon-purple mx-auto mb-2" style="width: 48px; height: 48px;">
                                    <i class="fa-solid fa-list-ol text-warning fs-5"></i>
                                </div>
                                <h3 class="fw-bold mb-0 text-dark"><%= quiz.getNumberOfQuestions() %> Questions</h3>
                                <div class="text-muted fs-sm">Multiple Choice Items</div>
                            </div>
                        </div>
                    </div>

                    <!-- Examination Rules -->
                    <h4 class="fw-bold mb-3"><i class="fa-solid fa-clipboard-list me-2 text-primary"></i> Examination Instructions & Honor Code</h4>
                    <div class="card bg-light border-0 p-3 mb-4">
                        <ul class="mb-0" style="padding-left: 20px; line-height: 1.8;">
                            <li><strong>Server-Enforced Timer:</strong> The timer begins immediately when you click <em>"Start Examination"</em>. Closing the window or refreshing the page will <u>not</u> pause the clock.</li>
                            <li><strong>Navigation:</strong> You can navigate between questions freely using the question palette and Previous / Next buttons.</li>
                            <li><strong>Review Flag:</strong> You can mark questions for review to revisit them before final submission.</li>
                            <li><strong>Unsaved Changes:</strong> Your answers are saved continuously as you move between questions.</li>
                            <li><strong>Automatic Submission:</strong> If the timer reaches 00:00, your current answers will be submitted automatically.</li>
                            <li><strong>Submission Finality:</strong> Once submitted, answers cannot be edited or modified under any circumstances.</li>
                        </ul>
                    </div>

                    <div class="d-flex justify-content-between align-items-center pt-3 border-top flex-wrap gap-2">
                        <a href="quizzes" class="btn btn-outline-gray">
                            <i class="fa-solid fa-arrow-left me-1"></i> Cancel & Return
                        </a>
                        <a href="exam?quizId=<%= quiz.getQuizId() %>" class="btn btn-primary btn-lg px-4 shadow">
                            <i class="fa-solid fa-play me-2"></i> <%= activeAttempt != null ? "Resume Examination" : "Start Examination" %>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>