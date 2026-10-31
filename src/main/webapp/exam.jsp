<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Question" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Quiz quiz = (Quiz) request.getAttribute("quiz");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    Integer attemptId = (Integer) request.getAttribute("attemptId");
    Long remainingSeconds = (Long) request.getAttribute("remainingSeconds");

    if (quiz == null || questions == null || questions.isEmpty() || attemptId == null) {
        response.sendRedirect("quizzes");
        return;
    }

    if (remainingSeconds == null) {
        remainingSeconds = (long) quiz.getDuration() * 60;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Examination: <%= quiz.getTitle() %> — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
    <style>
        .exam-palette-btn {
            width: 38px;
            height: 38px;
            padding: 0;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            border: 2px solid var(--border);
            background: white;
            color: var(--text);
            transition: all 0.2s;
        }
        .exam-palette-btn:hover { border-color: var(--primary); }
        .exam-palette-btn.active { border-color: var(--primary); background: #dbeafe; color: var(--primary); }
        .exam-palette-btn.answered { background: var(--success); color: white; border-color: var(--success); }
        .exam-palette-btn.flagged { background: var(--warning); color: white; border-color: var(--warning); }
        .question-pane { display: none; }
        .question-pane.active { display: block; }
    </style>
</head>
<body style="background: #f8fafc;">

    <!-- Exam Navigation Bar -->
    <header class="exam-nav">
        <div class="d-flex align-items-center gap-2">
            <span class="navbar-brand text-white fw-bold fs-5">
                <i class="fa-solid fa-graduation-cap text-info me-1"></i> QuizMaster
            </span>
            <span class="badge badge-primary ms-2 d-none d-md-inline-block"><%= quiz.getTitle() %></span>
        </div>

        <div class="d-flex align-items-center gap-3">
            <div id="timerBadge" class="timer-badge">
                <i class="fa-solid fa-clock"></i>
                <span id="timerDisplay">--:--</span>
            </div>
            <button type="button" class="btn btn-danger btn-sm" onclick="confirmSubmit()">
                <i class="fa-solid fa-check me-1"></i> Submit Quiz
            </button>
        </div>
    </header>

    <div class="container py-4">
        <form id="examForm" action="submitQuiz" method="post">
            <input type="hidden" name="quizId" value="<%= quiz.getQuizId() %>">
            <input type="hidden" name="attemptId" value="<%= attemptId %>">

            <div class="row g-4">
                <!-- Main Question Display Area (Left Column) -->
                <div class="col-lg-8">
                    <%
                        for (int i = 0; i < questions.size(); i++) {
                            Question q = questions.get(i);
                            int qNum = i + 1;
                    %>
                        <div id="questionPane_<%= i %>" class="question-pane <%= (i == 0) ? "active" : "" %>">
                            <div class="card p-4 border-0 shadow-sm mb-3">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="badge badge-primary fs-sm">Question <%= qNum %> of <%= questions.size() %></span>
                                        <span class="badge badge-gray fs-sm"><%= q.getMarks() %> Mark<%= q.getMarks() == 1 ? "" : "s" %></span>
                                    </div>
                                    <button type="button" class="btn btn-sm btn-outline-gray" onclick="toggleFlag(<%= i %>)">
                                        <i class="fa-regular fa-flag me-1" id="flagIcon_<%= i %>"></i> <span id="flagText_<%= i %>">Mark for Review</span>
                                    </button>
                                </div>

                                <h4 class="fw-bold mb-4" style="color: var(--gray-800); line-height: 1.5;">
                                    <%= q.getQuestionText() %>
                                </h4>

                                <!-- Option A -->
                                <label class="option-label" onclick="handleOptionSelected(<%= i %>)">
                                    <input type="radio" name="question_<%= q.getQuestionId() %>" value="A" style="display: none;">
                                    <span class="option-key">A</span>
                                    <span><%= q.getOptionA() %></span>
                                </label>

                                <!-- Option B -->
                                <label class="option-label" onclick="handleOptionSelected(<%= i %>)">
                                    <input type="radio" name="question_<%= q.getQuestionId() %>" value="B" style="display: none;">
                                    <span class="option-key">B</span>
                                    <span><%= q.getOptionB() %></span>
                                </label>

                                <!-- Option C -->
                                <label class="option-label" onclick="handleOptionSelected(<%= i %>)">
                                    <input type="radio" name="question_<%= q.getQuestionId() %>" value="C" style="display: none;">
                                    <span class="option-key">C</span>
                                    <span><%= q.getOptionC() %></span>
                                </label>

                                <!-- Option D -->
                                <label class="option-label" onclick="handleOptionSelected(<%= i %>)">
                                    <input type="radio" name="question_<%= q.getQuestionId() %>" value="D" style="display: none;">
                                    <span class="option-key">D</span>
                                    <span><%= q.getOptionD() %></span>
                                </label>
                            </div>

                            <!-- Bottom Navigation Buttons -->
                            <div class="d-flex justify-content-between align-items-center">
                                <button type="button" class="btn btn-outline-gray" onclick="prevQuestion(<%= i %>)" <%= (i == 0) ? "disabled" : "" %>>
                                    <i class="fa-solid fa-arrow-left me-1"></i> Previous
                                </button>
                                <button type="button" class="btn btn-outline-gray text-danger" onclick="clearAnswer(<%= i %>, <%= q.getQuestionId() %>)">
                                    <i class="fa-solid fa-eraser me-1"></i> Clear Selection
                                </button>
                                <% if (i < questions.size() - 1) { %>
                                    <button type="button" class="btn btn-primary" onclick="nextQuestion(<%= i %>)">
                                        Next <i class="fa-solid fa-arrow-right ms-1"></i>
                                    </button>
                                <% } else { %>
                                    <button type="button" class="btn btn-success" onclick="confirmSubmit()">
                                        Submit Examination ✓
                                    </button>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>

                <!-- Question Palette & Summary Sidebar (Right Column) -->
                <div class="col-lg-4">
                    <div class="card p-4 border-0 shadow-sm sticky-top" style="top: 80px;">
                        <h5 class="fw-bold mb-3"><i class="fa-solid fa-grip me-2 text-primary"></i> Question Palette</h5>

                        <div class="d-flex flex-wrap gap-2 mb-4">
                            <% for (int i = 0; i < questions.size(); i++) { %>
                                <button type="button" id="paletteBtn_<%= i %>"
                                        class="exam-palette-btn <%= (i == 0) ? "active" : "" %>"
                                        onclick="goToQuestion(<%= i %>)">
                                    <%= i + 1 %>
                                </button>
                            <% } %>
                        </div>

                        <!-- Legend -->
                        <div class="border-top pt-3 fs-sm">
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <span class="d-inline-block rounded" style="width: 14px; height: 14px; background: var(--success);"></span>
                                <span>Answered (<span id="answeredCount">0</span>)</span>
                            </div>
                            <div class="d-flex align-items-center gap-2 mb-2">
                                <span class="d-inline-block rounded" style="width: 14px; height: 14px; background: var(--warning);"></span>
                                <span>Marked for Review (<span id="flaggedCount">0</span>)</span>
                            </div>
                            <div class="d-flex align-items-center gap-2">
                                <span class="d-inline-block rounded border" style="width: 14px; height: 14px; background: white;"></span>
                                <span>Unanswered (<span id="unansweredCount"><%= questions.size() %></span>)</span>
                            </div>
                        </div>

                        <div class="mt-4 pt-3 border-top">
                            <button type="button" class="btn btn-success btn-block btn-lg" onclick="confirmSubmit()">
                                <i class="fa-solid fa-check-double me-2"></i> Submit Examination
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>

    <!-- Confirmation Modal -->
    <div class="modal fade" id="submitModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-circle-question me-2"></i> Confirm Final Submission</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <p class="mb-3">Are you sure you want to finish and submit your examination?</p>
                    <div class="card bg-light p-3 border-0 mb-3 fs-sm">
                        <div class="d-flex justify-content-between mb-1">
                            <span>Answered:</span>
                            <strong id="modalAnswered" class="text-success">0</strong>
                        </div>
                        <div class="d-flex justify-content-between mb-1">
                            <span>Marked for Review:</span>
                            <strong id="modalFlagged" class="text-warning">0</strong>
                        </div>
                        <div class="d-flex justify-content-between">
                            <span>Unanswered:</span>
                            <strong id="modalUnanswered" class="text-danger">0</strong>
                        </div>
                    </div>
                    <small class="text-muted d-block">
                        <i class="fa-solid fa-triangle-exclamation text-warning me-1"></i> Once submitted, your answers cannot be altered.
                    </small>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-outline-gray" data-bs-dismiss="modal">Return to Exam</button>
                    <button type="button" class="btn btn-success px-4" onclick="document.getElementById('examForm').submit();">
                        Yes, Submit Exam
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="js/timer.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const totalQuestions = <%= questions.size() %>;
        let currentQuestion = 0;
        const flags = new Array(totalQuestions).fill(false);

        // Initialize Timer with server-remaining seconds
        window.onload = function() {
            initializeExamTimer(<%= remainingSeconds %>);
            updateSummaryCounts();
        };

        function goToQuestion(index) {
            if (index < 0 || index >= totalQuestions) return;
            document.querySelectorAll('.question-pane').forEach(el => el.classList.remove('active'));
            document.getElementById('questionPane_' + index).classList.add('active');

            // Update palette active states
            for (let i = 0; i < totalQuestions; i++) {
                const btn = document.getElementById('paletteBtn_' + i);
                if (i === index) {
                    btn.classList.add('active');
                } else {
                    btn.classList.remove('active');
                }
            }
            currentQuestion = index;
        }

        function nextQuestion(index) {
            goToQuestion(index + 1);
        }

        function prevQuestion(index) {
            goToQuestion(index - 1);
        }

        function handleOptionSelected(index) {
            setTimeout(() => {
                updatePaletteButton(index);
                updateSummaryCounts();
            }, 50);
        }

        function clearAnswer(index, questionId) {
            const radios = document.getElementsByName('question_' + questionId);
            for (let r of radios) {
                r.checked = false;
            }
            updatePaletteButton(index);
            updateSummaryCounts();
        }

        function toggleFlag(index) {
            flags[index] = !flags[index];
            const icon = document.getElementById('flagIcon_' + index);
            const text = document.getElementById('flagText_' + index);
            if (flags[index]) {
                icon.className = 'fa-solid fa-flag text-warning me-1';
                text.textContent = 'Remove Flag';
            } else {
                icon.className = 'fa-regular fa-flag me-1';
                text.textContent = 'Mark for Review';
            }
            updatePaletteButton(index);
            updateSummaryCounts();
        }

        function updatePaletteButton(index) {
            const btn = document.getElementById('paletteBtn_' + index);
            const pane = document.getElementById('questionPane_' + index);
            const hasChecked = pane.querySelector('input[type="radio"]:checked') !== null;

            btn.classList.remove('answered', 'flagged');
            if (flags[index]) {
                btn.classList.add('flagged');
            } else if (hasChecked) {
                btn.classList.add('answered');
            }
        }

        function updateSummaryCounts() {
            let answered = 0;
            let flagged = 0;
            for (let i = 0; i < totalQuestions; i++) {
                if (flags[i]) flagged++;
                const pane = document.getElementById('questionPane_' + i);
                if (pane.querySelector('input[type="radio"]:checked') !== null) {
                    answered++;
                }
            }
            const unanswered = totalQuestions - answered;
            document.getElementById('answeredCount').textContent = answered;
            document.getElementById('flaggedCount').textContent = flagged;
            document.getElementById('unansweredCount').textContent = unanswered;

            document.getElementById('modalAnswered').textContent = answered;
            document.getElementById('modalFlagged').textContent = flagged;
            document.getElementById('modalUnanswered').textContent = unanswered;
        }

        function confirmSubmit() {
            updateSummaryCounts();
            const modal = new bootstrap.Modal(document.getElementById('submitModal'));
            modal.show();
        }
    </script>
</body>
</html>