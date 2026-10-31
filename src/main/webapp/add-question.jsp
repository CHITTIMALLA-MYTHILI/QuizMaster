<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.dao.QuizDAO" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    String quizIdParam = request.getParameter("quizId");
    if (quizIdParam == null || quizIdParam.trim().isEmpty()) {
        response.sendRedirect("admin-quizzes");
        return;
    }

    int quizId;
    try {
        quizId = Integer.parseInt(quizIdParam.trim());
    } catch (NumberFormatException e) {
        response.sendRedirect("admin-quizzes");
        return;
    }

    QuizDAO quizDAO = new QuizDAO();
    Quiz quiz = quizDAO.getQuizById(quizId);
    if (quiz == null) {
        response.sendRedirect("admin-quizzes");
        return;
    }

    int currentCount = quizDAO.getQuestionCount(quizId);
    int currentMarksSum = quizDAO.getQuestionMarksSum(quizId);
    int totalMarks = quiz.getTotalMarks();
    int neededMarks = totalMarks - currentMarksSum;
    boolean marksMatch = (currentMarksSum == totalMarks);

    String successMessage = (String) session.getAttribute("questionSuccess");
    if (successMessage != null) {
        session.removeAttribute("questionSuccess");
    }
    String errorMessage = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Question — <%= quiz.getTitle() %> — QuizMaster</title>
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
            <div class="mb-3 d-flex justify-content-between align-items-center">
                <a href="admin-questions?quizId=<%= quizId %>" class="text-muted"><i class="fa-solid fa-arrow-left me-1"></i> Back to Questions List</a>
                <a href="admin-quizzes" class="text-muted fs-sm">Manage All Quizzes</a>
            </div>

            <!-- Quiz Status Card -->
            <div class="card mb-4 border-0 shadow-sm">
                <div class="card-body p-4 bg-light rounded">
                    <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                        <div>
                            <span class="badge badge-primary mb-1"><%= quiz.getCategory() %></span>
                            <h3 class="fw-bold text-primary mb-1"><%= quiz.getTitle() %></h3>
                            <p class="text-muted mb-0 fs-sm"><%= quiz.getDescription() != null ? quiz.getDescription() : "" %></p>
                        </div>
                        <div class="text-end">
                            <div class="fs-5 fw-bold <%= marksMatch ? "text-success" : "text-primary" %>">
                                <%= currentMarksSum %> / <%= totalMarks %> Marks
                            </div>
                            <span class="badge <%= marksMatch ? "badge-success" : "badge-draft" %>">
                                <%= marksMatch ? "Ready to Publish" : (neededMarks > 0 ? neededMarks + " Marks Needed" : (-neededMarks) + " Marks Excess") %>
                            </span>
                        </div>
                    </div>

                    <!-- Progress bar -->
                    <%
                        int percent = (totalMarks > 0) ? Math.min(100, (int) Math.round(((double) currentMarksSum / totalMarks) * 100)) : 0;
                    %>
                    <div class="progress mt-3" style="height: 8px;">
                        <div class="progress-bar <%= marksMatch ? "bg-success" : "bg-primary" %>"
                             role="progressbar" style="width: <%= percent %>%;"></div>
                    </div>
                    <div class="d-flex justify-content-between fs-sm text-muted mt-2">
                        <span><%= currentCount %> Questions Added</span>
                        <span>Configured Duration: <%= quiz.getDuration() %> mins</span>
                    </div>
                </div>
            </div>

            <% if (successMessage != null) { %>
                <div class="alert alert-success">
                    <i class="fa-solid fa-circle-check mt-1"></i>
                    <div><%= successMessage %></div>
                </div>
            <% } %>

            <% if (errorMessage != null) { %>
                <div class="alert alert-danger">
                    <i class="fa-solid fa-triangle-exclamation mt-1"></i>
                    <div><%= errorMessage %></div>
                </div>
            <% } %>

            <!-- Add Question Form -->
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom p-4">
                    <div class="d-flex justify-content-between align-items-center">
                        <h4 class="fw-bold mb-0 text-primary">
                            <i class="fa-solid fa-circle-plus me-2"></i> Add Question #<%= currentCount + 1 %>
                        </h4>
                        <span class="text-muted fs-sm">Support variable marks per question</span>
                    </div>
                </div>

                <div class="card-body p-4">
                    <form action="addQuestion" method="post">
                        <input type="hidden" name="quizId" value="<%= quizId %>">

                        <div class="form-group mb-3">
                            <label class="form-label" for="questionText">Question Text <span class="text-danger">*</span></label>
                            <textarea id="questionText" name="questionText" class="form-control" rows="3"
                                      placeholder="Type your question here..." required autofocus></textarea>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="optionA">Option A <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text fw-bold">A</span>
                                    <input type="text" id="optionA" name="optionA" class="form-control" placeholder="Answer option A" required>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="optionB">Option B <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text fw-bold">B</span>
                                    <input type="text" id="optionB" name="optionB" class="form-control" placeholder="Answer option B" required>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="optionC">Option C <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text fw-bold">C</span>
                                    <input type="text" id="optionC" name="optionC" class="form-control" placeholder="Answer option C" required>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="optionD">Option D <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text fw-bold">D</span>
                                    <input type="text" id="optionD" name="optionD" class="form-control" placeholder="Answer option D" required>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="correctOption">Correct Option <span class="text-danger">*</span></label>
                                <select id="correctOption" name="correctOption" class="form-control" required>
                                    <option value="">Select the correct option</option>
                                    <option value="A">Option A</option>
                                    <option value="B">Option B</option>
                                    <option value="C">Option C</option>
                                    <option value="D">Option D</option>
                                </select>
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label" for="marks">Question Marks <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <input type="number" id="marks" name="marks" class="form-control"
                                           min="1" max="100" value="<%= (neededMarks > 0) ? Math.min(neededMarks, 1) : 1 %>" required>
                                    <span class="input-group-text bg-light">marks</span>
                                </div>
                                <small class="text-muted">Assign any weight (e.g. 1, 2, 5 marks)</small>
                            </div>
                        </div>

                        <div class="form-group mb-4">
                            <label class="form-label" for="explanation">Explanation (Optional)</label>
                            <textarea id="explanation" name="explanation" class="form-control" rows="2"
                                      placeholder="Explain why this option is correct. Displayed to students in detailed result review."></textarea>
                        </div>

                        <div class="d-flex justify-content-between align-items-center pt-3 border-top flex-wrap gap-2">
                            <div class="d-flex gap-2">
                                <a href="admin-questions?quizId=<%= quizId %>" class="btn btn-outline-gray">
                                    View All Questions (<%= currentCount %>)
                                </a>
                                <% if (marksMatch) { %>
                                    <a href="admin-quizzes?action=publish&quizId=<%= quizId %>" class="btn btn-success">
                                        <i class="fa-solid fa-upload me-1"></i> Publish Quiz Now
                                    </a>
                                <% } %>
                            </div>

                            <button type="submit" class="btn btn-primary px-4">
                                <i class="fa-solid fa-plus me-1"></i> Save & Add Another
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