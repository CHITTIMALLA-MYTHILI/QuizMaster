<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.StudentPracticeQuiz" %>
<%@ page import="com.quizmaster.model.StudentPracticeQuestion" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    StudentPracticeQuiz quiz = (StudentPracticeQuiz) request.getAttribute("quiz");
    String viewMode = (String) request.getAttribute("viewMode");
    if (viewMode == null) viewMode = "review";

    if (quiz == null) {
        response.sendRedirect("ai-study-assistant");
        return;
    }

    List<StudentPracticeQuestion> questions = quiz.getQuestions();
    int totalQuestions = questions != null ? questions.size() : 0;
    int durationMinutes = Math.max(5, (int) Math.ceil(totalQuestions * 1.5));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= "take".equals(viewMode) ? "Taking Practice Quiz" : "Practice Quiz Review" %> — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
    <style>
        .quiz-timer-pill {
            background: #eff6ff;
            color: var(--primary);
            font-weight: 700;
            padding: 8px 16px;
            border-radius: var(--radius-xl);
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: 1px solid #bfdbfe;
            font-size: 15px;
        }
        .timer-warning {
            background: #fef2f2 !important;
            color: #dc2626 !important;
            border-color: #fecaca !important;
            animation: pulse 1s infinite;
        }
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.7; }
            100% { opacity: 1; }
        }
        .option-choice-card {
            display: block;
            position: relative;
            cursor: pointer;
            border: 1px solid var(--border-color);
            background: #ffffff;
            border-radius: var(--radius-md);
            padding: 16px 20px;
            margin-bottom: 12px;
            transition: var(--transition);
        }
        .option-choice-card:hover {
            border-color: var(--primary);
            background: #f8fafc;
        }
        .option-choice-card input[type="radio"] {
            margin-right: 12px;
            accent-color: var(--primary);
            transform: scale(1.15);
        }
        .option-choice-card.selected {
            border-color: var(--primary);
            background: #eff6ff;
            box-shadow: 0 0 0 1px var(--primary);
        }
        .palette-btn {
            width: 38px;
            height: 38px;
            font-weight: 600;
            font-size: 13px;
            border-radius: var(--radius-sm);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--border-color);
            background: #ffffff;
            color: var(--body-text);
            cursor: pointer;
            transition: var(--transition);
        }
        .palette-btn.answered {
            background: var(--primary);
            color: #ffffff;
            border-color: var(--primary);
        }
        .palette-btn.active {
            box-shadow: 0 0 0 2px #3b82f6;
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
        </div>
        <div class="qm-navbar-user">
            <span class="username-display"><i class="fa-regular fa-user-circle me-1 text-primary"></i> <%= studentName %></span>
        </div>
    </header>

    <div class="page-wrapper py-4">
        <div class="container">

            <% if ("review".equalsIgnoreCase(viewMode)) { %>
                <!-- MODE 1: REVIEW BEFORE QUIZ STARTS -->
                <div class="row justify-content-center">
                    <div class="col-lg-8">
                        <div class="card shadow-sm border-0">
                            <div class="card-header bg-white py-4 border-bottom text-center">
                                <span class="badge badge-primary px-3 py-2 mb-2 fs-sm"><i class="fa-solid fa-robot me-1"></i> AI Generated Assessment</span>
                                <h2 class="h3 fw-bold text-navy mb-1"><%= quiz.getTitle() %></h2>
                                <p class="text-muted mb-0">Review the examination parameters below before beginning.</p>
                            </div>
                            <div class="card-body p-4 p-md-5">
                                <div class="row g-3 mb-4">
                                    <div class="col-sm-4 text-center p-3 bg-light rounded border">
                                        <div class="text-muted fs-sm mb-1"><i class="fa-solid fa-list-ol me-1"></i> Questions</div>
                                        <div class="h4 fw-bold text-navy mb-0"><%= totalQuestions %></div>
                                    </div>
                                    <div class="col-sm-4 text-center p-3 bg-light rounded border">
                                        <div class="text-muted fs-sm mb-1"><i class="fa-solid fa-stopwatch me-1"></i> Recommended Time</div>
                                        <div class="h4 fw-bold text-navy mb-0"><%= durationMinutes %> Mins</div>
                                    </div>
                                    <div class="col-sm-4 text-center p-3 bg-light rounded border">
                                        <div class="text-muted fs-sm mb-1"><i class="fa-solid fa-signal me-1"></i> Difficulty</div>
                                        <div class="h4 fw-bold text-primary mb-0"><%= quiz.getDifficulty() %></div>
                                    </div>
                                </div>

                                <h5 class="fw-bold text-navy mb-3"><i class="fa-solid fa-circle-info text-primary me-2"></i> Important Instructions</h5>
                                <ul class="list-unstyled d-flex flex-column gap-2 mb-4">
                                    <li class="d-flex align-items-start gap-2">
                                        <i class="fa-solid fa-check-circle text-success mt-1"></i>
                                        <span>Each question is synthesized directly from your supplied study material.</span>
                                    </li>
                                    <li class="d-flex align-items-start gap-2">
                                        <i class="fa-solid fa-check-circle text-success mt-1"></i>
                                        <span>You can move between questions freely using the question navigation controls.</span>
                                    </li>
                                    <li class="d-flex align-items-start gap-2">
                                        <i class="fa-solid fa-check-circle text-success mt-1"></i>
                                        <span>A countdown timer will help you pace yourself. When time expires, answers are submitted automatically.</span>
                                    </li>
                                    <li class="d-flex align-items-start gap-2">
                                        <i class="fa-solid fa-check-circle text-success mt-1"></i>
                                        <span>Instant feedback, answer keys, explanations, and custom revision topics are generated upon submission.</span>
                                    </li>
                                </ul>

                                <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 pt-3 border-top">
                                    <a href="ai-study-assistant" class="btn btn-outline-gray">
                                        <i class="fa-solid fa-arrow-left me-1"></i> Back to Assistant
                                    </a>
                                    <a href="ai-practice-quiz?action=take&quizId=<%= quiz.getQuizId() %>" class="btn btn-primary btn-lg px-4 shadow-sm">
                                        <i class="fa-solid fa-play me-2"></i> Start Practice Quiz Now
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            <% } else { %>
                <!-- MODE 2: INTERACTIVE PRACTICE QUIZ TAKING -->
                <form id="quizExamForm" action="ai-practice-quiz" method="post">
                    <input type="hidden" name="quizId" value="<%= quiz.getQuizId() %>">

                    <!-- Top Sticky Control Bar -->
                    <div class="card shadow-sm border-0 mb-4 sticky-top" style="top: 15px; z-index: 100;">
                        <div class="card-body py-3 px-4 d-flex justify-content-between align-items-center flex-wrap gap-3 bg-white rounded">
                            <div>
                                <h5 class="fw-bold text-navy mb-0"><%= quiz.getTitle() %></h5>
                                <small class="text-muted">Total Questions: <%= totalQuestions %> | Mode: Practice Simulation</small>
                            </div>
                            <div class="d-flex align-items-center gap-3">
                                <div class="quiz-timer-pill" id="timerBadge">
                                    <i class="fa-regular fa-clock"></i>
                                    <span id="timerText"><%= durationMinutes %>:00</span>
                                </div>
                                <button type="button" class="btn btn-primary btn-sm px-3 shadow-sm" onclick="confirmFinishQuiz()">
                                    <i class="fa-solid fa-circle-check me-1"></i> Submit Quiz
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4">
                        <!-- Questions Container -->
                        <div class="col-lg-8">
                            <%
                                int qIndex = 0;
                                for (StudentPracticeQuestion q : questions) {
                                    qIndex++;
                            %>
                                <div class="card shadow-sm border-0 mb-4 question-card" id="qcard-<%= qIndex %>" style="<%= qIndex == 1 ? "" : "display: none;" %>">
                                    <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                                        <span class="badge badge-primary px-3 py-2">Question <%= qIndex %> of <%= totalQuestions %></span>
                                        <span class="text-muted fs-sm">Practice MCQ</span>
                                    </div>
                                    <div class="card-body p-4">
                                        <h5 class="fw-bold text-navy mb-4" style="line-height: 1.6;"><%= q.getQuestionText() %></h5>

                                        <!-- Options -->
                                        <div class="options-group">
                                            <label class="option-choice-card" id="lbl-<%= q.getQuestionId() %>-A" onclick="markAnswered(<%= qIndex %>, '<%= q.getQuestionId() %>', 'A')">
                                                <input type="radio" name="answer_<%= q.getQuestionId() %>" value="A">
                                                <strong>A.</strong> <%= q.getOptionA() %>
                                            </label>

                                            <label class="option-choice-card" id="lbl-<%= q.getQuestionId() %>-B" onclick="markAnswered(<%= qIndex %>, '<%= q.getQuestionId() %>', 'B')">
                                                <input type="radio" name="answer_<%= q.getQuestionId() %>" value="B">
                                                <strong>B.</strong> <%= q.getOptionB() %>
                                            </label>

                                            <% if (q.getOptionC() != null && !q.getOptionC().trim().isEmpty() && !"-".equals(q.getOptionC().trim())) { %>
                                                <label class="option-choice-card" id="lbl-<%= q.getQuestionId() %>-C" onclick="markAnswered(<%= qIndex %>, '<%= q.getQuestionId() %>', 'C')">
                                                    <input type="radio" name="answer_<%= q.getQuestionId() %>" value="C">
                                                    <strong>C.</strong> <%= q.getOptionC() %>
                                                </label>
                                            <% } %>

                                            <% if (q.getOptionD() != null && !q.getOptionD().trim().isEmpty() && !"-".equals(q.getOptionD().trim())) { %>
                                                <label class="option-choice-card" id="lbl-<%= q.getQuestionId() %>-D" onclick="markAnswered(<%= qIndex %>, '<%= q.getQuestionId() %>', 'D')">
                                                    <input type="radio" name="answer_<%= q.getQuestionId() %>" value="D">
                                                    <strong>D.</strong> <%= q.getOptionD() %>
                                                </label>
                                            <% } %>
                                        </div>

                                        <!-- Bottom Question Nav -->
                                        <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
                                            <button type="button" class="btn btn-outline-gray btn-sm" onclick="goToQuestion(<%= qIndex - 1 %>)" <%= qIndex == 1 ? "disabled" : "" %>>
                                                <i class="fa-solid fa-chevron-left me-1"></i> Previous
                                            </button>
                                            <button type="button" class="btn btn-link text-muted btn-sm" onclick="clearAnswer('<%= q.getQuestionId() %>', <%= qIndex %>)">
                                                Clear Selection
                                            </button>
                                            <% if (qIndex < totalQuestions) { %>
                                                <button type="button" class="btn btn-primary btn-sm" onclick="goToQuestion(<%= qIndex + 1 %>)">
                                                    Next <i class="fa-solid fa-chevron-right ms-1"></i>
                                                </button>
                                            <% } else { %>
                                                <button type="button" class="btn btn-success btn-sm" onclick="confirmFinishQuiz()">
                                                    Finish & Submit <i class="fa-solid fa-check ms-1"></i>
                                                </button>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>

                        <!-- Sidebar Navigation Palette -->
                        <div class="col-lg-4">
                            <div class="card shadow-sm border-0 sticky-top" style="top: 90px;">
                                <div class="card-header bg-white py-3 border-bottom">
                                    <h6 class="fw-bold text-navy mb-0"><i class="fa-solid fa-table-cells me-2 text-primary"></i> Question Palette</h6>
                                </div>
                                <div class="card-body p-3">
                                    <div class="d-flex flex-wrap gap-2 mb-3">
                                        <% for (int i = 1; i <= totalQuestions; i++) { %>
                                            <button type="button" class="palette-btn <%= i == 1 ? "active" : "" %>" id="pal-btn-<%= i %>" onclick="goToQuestion(<%= i %>)">
                                                <%= i %>
                                            </button>
                                        <% } %>
                                    </div>
                                    <div class="border-top pt-3 d-flex justify-content-between text-muted fs-sm">
                                        <div><span class="badge bg-primary me-1">&nbsp;</span> Answered: <strong id="answeredCount">0</strong></div>
                                        <div><span class="badge bg-light text-dark border me-1">&nbsp;</span> Unanswered: <strong id="unansweredCount"><%= totalQuestions %></strong></div>
                                    </div>
                                    <div class="mt-4">
                                        <button type="button" class="btn btn-success w-100 py-2" onclick="confirmFinishQuiz()">
                                            <i class="fa-solid fa-paper-plane me-2"></i> Submit Practice Quiz
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>

                <script>
                    let currentQ = 1;
                    const totalQ = <%= totalQuestions %>;
                    const answeredMap = {};

                    function goToQuestion(idx) {
                        if (idx < 1 || idx > totalQ) return;
                        document.getElementById('qcard-' + currentQ).style.display = 'none';
                        document.getElementById('pal-btn-' + currentQ).classList.remove('active');

                        currentQ = idx;
                        document.getElementById('qcard-' + currentQ).style.display = 'block';
                        document.getElementById('pal-btn-' + currentQ).classList.add('active');
                    }

                    function markAnswered(qIdx, qId, opt) {
                        // Clear existing selection styles for this question
                        ['A', 'B', 'C', 'D'].forEach(o => {
                            const lbl = document.getElementById('lbl-' + qId + '-' + o);
                            if (lbl) lbl.classList.remove('selected');
                        });
                        const selectedLbl = document.getElementById('lbl-' + qId + '-' + opt);
                        if (selectedLbl) selectedLbl.classList.add('selected');

                        answeredMap[qIdx] = true;
                        document.getElementById('pal-btn-' + qIdx).classList.add('answered');
                        updateStats();
                    }

                    function clearAnswer(qId, qIdx) {
                        const radios = document.getElementsByName('answer_' + qId);
                        for (let r of radios) r.checked = false;
                        ['A', 'B', 'C', 'D'].forEach(o => {
                            const lbl = document.getElementById('lbl-' + qId + '-' + o);
                            if (lbl) lbl.classList.remove('selected');
                        });
                        delete answeredMap[qIdx];
                        document.getElementById('pal-btn-' + qIdx).classList.remove('answered');
                        updateStats();
                    }

                    function updateStats() {
                        const count = Object.keys(answeredMap).length;
                        document.getElementById('answeredCount').textContent = count;
                        document.getElementById('unansweredCount').textContent = totalQ - count;
                    }

                    function confirmFinishQuiz() {
                        const count = Object.keys(answeredMap).length;
                        const msg = `You have answered ${count} of ${totalQ} questions.\n\nDo you want to submit and view your detailed performance report?`;
                        if (confirm(msg)) {
                            document.getElementById('quizExamForm').submit();
                        }
                    }

                    // Timer Countdown
                    let timeLeft = <%= durationMinutes * 60 %>;
                    const timerText = document.getElementById('timerText');
                    const timerBadge = document.getElementById('timerBadge');

                    const timerInterval = setInterval(() => {
                        timeLeft--;
                        if (timeLeft <= 0) {
                            clearInterval(timerInterval);
                            alert("Time has expired! Submitting your answers automatically.");
                            document.getElementById('quizExamForm').submit();
                            return;
                        }

                        const mins = Math.floor(timeLeft / 60);
                        const secs = timeLeft % 60;
                        timerText.textContent = mins + ":" + (secs < 10 ? "0" : "") + secs;

                        if (timeLeft <= 120) { // last 2 minutes
                            timerBadge.classList.add('timer-warning');
                        }
                    }, 1000);
                </script>
            <% } %>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
