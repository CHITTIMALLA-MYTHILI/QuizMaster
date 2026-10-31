<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.AIQuestionDraft" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="com.quizmaster.model.StudyMaterial" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    List<AIQuestionDraft> drafts = (List<AIQuestionDraft>) request.getAttribute("drafts");
    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    List<StudyMaterial> materials = (List<StudyMaterial>) request.getAttribute("materials");
    String batchId = (String) request.getAttribute("batchId");
    Boolean aiConfigured = (Boolean) request.getAttribute("aiConfigured");
    if (aiConfigured == null) aiConfigured = false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Quiz Generator — QuizMaster Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
</head>
<body>

    <!-- Header Navbar -->
    <header class="qm-navbar">
        <a class="qm-navbar-brand" href="admin-dashboard">
            <i class="fa-solid fa-graduation-cap"></i> QuizMaster <span class="badge badge-primary ms-1">Admin</span>
        </a>
        <div class="qm-navbar-user">
            <span><i class="fa-solid fa-user-shield text-primary me-1"></i> <%= session.getAttribute("adminUsername") %></span>
            <a href="adminLogout" class="btn btn-outline-gray btn-sm text-danger"><i class="fa-solid fa-arrow-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper">
        <div class="container" style="max-width: 1040px;">
            <div class="mb-3 d-flex justify-content-between align-items-center">
                <a href="admin-dashboard" class="text-muted"><i class="fa-solid fa-arrow-left me-1"></i> Back to Dashboard</a>
                <a href="study-materials" class="text-primary fs-sm fw-semibold"><i class="fa-solid fa-book-bookmark me-1"></i> Manage Study Materials</a>
            </div>

            <div class="page-header">
                <div class="d-flex align-items-center gap-2 mb-1">
                    <span class="badge badge-primary"><i class="fa-solid fa-wand-magic-sparkles me-1"></i> AI Powered</span>
                </div>
                <h1 class="page-title">AI Quiz Generator</h1>
                <p class="page-subtitle">Automatically generate multiple-choice questions from any topic or study material, review, edit, and approve into your quizzes.</p>
            </div>

            <% if (!aiConfigured) { %>
                <div class="alert alert-warning mb-4">
                    <i class="fa-solid fa-circle-exclamation mt-1"></i>
                    <div>
                        <strong>AI Key Notice:</strong> The environment variable <code>QUIZMASTER_AI_API_KEY</code> is not yet configured. Please set your key on the server to generate questions live.
                    </div>
                </div>
            <% } %>

            <!-- Generator Input Card -->
            <div class="card mb-4 border-0 shadow-sm">
                <div class="card-header bg-white p-4 border-bottom">
                    <h5 class="fw-bold mb-0 text-navy"><i class="fa-solid fa-sliders me-2 text-primary"></i> Generation Parameters</h5>
                </div>
                <div class="card-body p-4">
                    <form action="ai-quiz-generator" method="post">
                        <input type="hidden" name="action" value="generate">

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label" for="topic">Subject / Topic <span class="text-danger">*</span></label>
                                <input type="text" id="topic" name="topic" class="form-control"
                                       placeholder="e.g. Java Collections Framework, Binary Search Trees" required autofocus>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label" for="numQuestions">Question Count</label>
                                <select id="numQuestions" name="numQuestions" class="form-control">
                                    <option value="3">3 Questions</option>
                                    <option value="5" selected>5 Questions</option>
                                    <option value="10">10 Questions</option>
                                    <option value="15">15 Questions</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label" for="difficulty">Difficulty</label>
                                <select id="difficulty" name="difficulty" class="form-control">
                                    <option value="Easy">Easy</option>
                                    <option value="Medium" selected>Medium</option>
                                    <option value="Hard">Hard</option>
                                    <option value="Mixed">Mixed</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-group mb-3">
                            <label class="form-label" for="studyMaterial">Study Material Context (Optional)</label>
                            <textarea id="studyMaterial" name="studyMaterial" class="form-control" rows="3"
                                      placeholder="Paste lecture notes, syllabus text, or excerpts to base questions upon..."></textarea>
                        </div>

                        <div class="d-flex justify-content-between align-items-center pt-2">
                            <span class="text-muted fs-sm"><i class="fa-regular fa-lightbulb me-1"></i> Questions generated will be staged for administrator review before publication.</span>
                            <button type="submit" class="btn btn-primary px-4" <%= !aiConfigured ? "disabled" : "" %>>
                                <i class="fa-solid fa-wand-magic-sparkles me-2"></i> Generate Questions
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Staged Drafts for Review and Approval (Section 2 specification) -->
            <% if (drafts != null && !drafts.isEmpty()) { %>
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-header bg-white p-4 border-bottom d-flex justify-content-between align-items-center">
                        <div>
                            <h4 class="fw-bold mb-0 text-navy"><i class="fa-solid fa-list-check me-2 text-primary"></i> Staged AI Questions Review (<%= drafts.size() %>)</h4>
                            <small class="text-muted">Batch ID: <%= batchId %></small>
                        </div>
                    </div>
                    <div class="card-body p-4">
                        <%
                            int qIndex = 1;
                            for (AIQuestionDraft d : drafts) {
                        %>
                            <div class="card mb-4 border p-4 bg-white shadow-sm">
                                <div class="d-flex justify-content-between align-items-start mb-2">
                                    <span class="badge badge-primary fs-sm">Question <%= qIndex++ %></span>
                                    <span class="badge badge-gray fs-sm">Difficulty: <%= d.getDifficulty() %> | Weight: <%= d.getMarks() %> mark</span>
                                </div>

                                <h5 class="fw-bold mb-3 text-navy"><%= d.getQuestionText() %></h5>

                                <div class="row g-2 mb-3 fs-sm">
                                    <div class="col-md-6">
                                        <div class="p-2 border rounded <%= "A".equalsIgnoreCase(d.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %>">
                                            <strong>A:</strong> <%= d.getOptionA() %>
                                            <% if ("A".equalsIgnoreCase(d.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1"></i> <% } %>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="p-2 border rounded <%= "B".equalsIgnoreCase(d.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %>">
                                            <strong>B:</strong> <%= d.getOptionB() %>
                                            <% if ("B".equalsIgnoreCase(d.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1"></i> <% } %>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="p-2 border rounded <%= "C".equalsIgnoreCase(d.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %>">
                                            <strong>C:</strong> <%= d.getOptionC() %>
                                            <% if ("C".equalsIgnoreCase(d.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1"></i> <% } %>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="p-2 border rounded <%= "D".equalsIgnoreCase(d.getCorrectOption()) ? "bg-success-subtle border-success fw-bold" : "" %>">
                                            <strong>D:</strong> <%= d.getOptionD() %>
                                            <% if ("D".equalsIgnoreCase(d.getCorrectOption())) { %> <i class="fa-solid fa-check text-success ms-1"></i> <% } %>
                                        </div>
                                    </div>
                                </div>

                                <% if (d.getExplanation() != null && !d.getExplanation().isEmpty()) { %>
                                    <div class="alert alert-info py-2 px-3 mb-3 fs-sm">
                                        <i class="fa-solid fa-lightbulb me-1"></i> <strong>Explanation:</strong> <%= d.getExplanation() %>
                                    </div>
                                <% } %>

                                <!-- Approval & Target Quiz selection -->
                                <form action="ai-quiz-generator" method="post" class="d-flex align-items-center justify-content-between flex-wrap gap-2 pt-2 border-top">
                                    <input type="hidden" name="action" value="approve">
                                    <input type="hidden" name="draftId" value="<%= d.getDraftId() %>">
                                    <input type="hidden" name="batchId" value="<%= batchId %>">

                                    <div class="d-flex align-items-center gap-2">
                                        <label class="form-label mb-0 fs-sm text-nowrap fw-semibold">Add to Quiz:</label>
                                        <select name="targetQuizId" class="form-control form-control-sm" style="max-width: 260px;" required>
                                            <% if (quizzes != null) {
                                                for (Quiz q : quizzes) {
                                            %>
                                                <option value="<%= q.getQuizId() %>"><%= q.getTitle() %> (<%= q.getCategory() %>)</option>
                                            <%  }
                                            } %>
                                        </select>
                                    </div>

                                    <div class="d-flex gap-2">
                                        <button type="submit" class="btn btn-sm btn-success">
                                            <i class="fa-solid fa-check me-1"></i> Approve & Save
                                        </button>
                                        <a href="ai-quiz-generator?action=deleteDraft&draftId=<%= d.getDraftId() %>&batchId=<%= batchId %>"
                                           class="btn btn-sm btn-outline-gray text-danger"
                                           onclick="return confirm('Discard this question draft?');">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </a>
                                    </div>
                                </form>
                            </div>
                        <% } %>
                    </div>
                </div>
            <% } %>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
