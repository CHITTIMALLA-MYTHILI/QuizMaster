<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.StudentSummary" %>
<%@ page import="com.quizmaster.model.StudentPracticeQuiz" %>
<%@ page import="com.quizmaster.model.StudentPracticeAttempt" %>
<%@ page import="com.quizmaster.ai.AIConfig" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    StudentSummary currentSummary = (StudentSummary) request.getAttribute("currentSummary");
    List<StudentSummary> summaries = (List<StudentSummary>) request.getAttribute("summaries");
    List<StudentPracticeAttempt> recentAttempts = (List<StudentPracticeAttempt>) request.getAttribute("recentAttempts");
    List<StudentPracticeQuiz> recentQuizzes = (List<StudentPracticeQuiz>) request.getAttribute("recentQuizzes");

    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    boolean aiConfigured = AIConfig.isConfigured();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Study Assistant — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
    <style>
        .assistant-header-card {
            background: linear-gradient(135deg, #1e3a8a 0%, #1e40af 50%, #3b82f6 100%);
            color: #ffffff;
            border-radius: var(--radius-xl);
            padding: 32px 36px;
            margin-bottom: 28px;
            box-shadow: 0 10px 25px -5px rgba(30, 58, 138, 0.25);
        }
        .upload-dropzone {
            border: 2px dashed #cbd5e1;
            border-radius: var(--radius-lg);
            background: #f8fafc;
            padding: 28px 20px;
            text-align: center;
            cursor: pointer;
            transition: var(--transition);
        }
        .upload-dropzone:hover, .upload-dropzone.dragover {
            border-color: var(--primary);
            background: #eff6ff;
        }
        .file-pill {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            padding: 8px 14px;
            border-radius: var(--radius-md);
            font-size: 14px;
            box-shadow: var(--shadow-sm);
        }
        .summary-box {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-xl);
            padding: 32px;
            box-shadow: var(--shadow-card);
            line-height: 1.8;
            font-size: 15px;
            color: var(--navy-text);
        }
        .summary-box h1, .summary-box h2, .summary-box h3 {
            margin-top: 24px;
            margin-bottom: 12px;
            color: var(--navy-text);
            font-weight: 700;
        }
        .summary-box h2 { font-size: 20px; border-bottom: 2px solid #e2e8f0; padding-bottom: 6px; }
        .summary-box h3 { font-size: 17px; }
        .summary-box ul, .summary-box ol { padding-left: 24px; margin-bottom: 16px; }
        .summary-box li { margin-bottom: 6px; }
        .summary-box p { margin-bottom: 14px; }
        .action-nav-pills .nav-link {
            font-weight: 600;
            border-radius: var(--radius-md);
            padding: 10px 20px;
            color: var(--body-text);
            border: 1px solid transparent;
        }
        .action-nav-pills .nav-link.active {
            background-color: var(--primary);
            color: #ffffff;
        }
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(15, 23, 42, 0.75);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            backdrop-filter: blur(4px);
        }
        .loading-card {
            background: #ffffff;
            padding: 36px 40px;
            border-radius: var(--radius-xl);
            text-align: center;
            box-shadow: var(--shadow-float);
            max-width: 440px;
            width: 90%;
        }
    </style>
</head>
<body>

    <!-- Student Navbar -->
    <header class="qm-navbar">
        <a class="qm-navbar-brand" href="dashboard.jsp">
            <i class="fa-solid fa-graduation-cap"></i> QuizMaster
        </a>
        <div class="qm-navbar-links">
            <a href="dashboard.jsp" class="qm-navbar-link"><i class="fa-solid fa-gauge me-1"></i> Dashboard</a>
            <a href="quizzes" class="qm-navbar-link"><i class="fa-solid fa-book-open me-1"></i> Browse Quizzes</a>
            <a href="results" class="qm-navbar-link"><i class="fa-solid fa-square-poll-vertical me-1"></i> My Results</a>
            <a href="ai-study-assistant" class="qm-navbar-link active"><i class="fa-solid fa-wand-magic-sparkles me-1 text-primary"></i> AI Study Assistant</a>
            <a href="ai-tutor" class="qm-navbar-link"><i class="fa-solid fa-robot me-1 text-primary"></i> AI Tutor</a>
            <a href="leaderboard" class="qm-navbar-link"><i class="fa-solid fa-trophy me-1"></i> Leaderboard</a>
        </div>
        <div class="qm-navbar-user">
            <span class="username-display"><i class="fa-regular fa-user-circle me-1 text-primary"></i> <%= studentName %></span>
            <a href="logout" class="btn btn-outline-gray btn-sm text-danger"><i class="fa-solid fa-arrow-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper py-4">
        <div class="container">

            <!-- Hero Banner -->
            <div class="assistant-header-card d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <span class="badge bg-white text-primary fw-bold mb-2 px-3 py-2 fs-sm"><i class="fa-solid fa-brain me-1"></i> Powered by LLM Intelligence</span>
                    <h1 class="h2 text-white fw-bold mb-2">AI Study Assistant</h1>
                    <p class="text-white-50 mb-0" style="max-width: 620px;">
                        Upload lecture slides, chapters, or paste study material to synthesize revision summaries and take customized practice quizzes instantly.
                    </p>
                </div>
                <div class="d-flex gap-2">
                    <a href="dashboard.jsp" class="btn btn-outline-light"><i class="fa-solid fa-house me-1"></i> Dashboard</a>
                </div>
            </div>

            <!-- Feedback Alerts -->
            <% if (successMessage != null && !successMessage.isEmpty()) { %>
                <div class="alert alert-success d-flex align-items-center mb-4">
                    <i class="fa-solid fa-circle-check fs-5 me-2"></i>
                    <div><%= successMessage %></div>
                </div>
            <% } %>

            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger d-flex align-items-center mb-4">
                    <i class="fa-solid fa-circle-exclamation fs-5 me-2"></i>
                    <div><%= errorMessage %></div>
                </div>
            <% } %>

            <% if (!aiConfigured) { %>
                <div class="alert alert-warning mb-4">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i>
                    <strong>AI Service Notice:</strong> <code>QUIZMASTER_AI_API_KEY</code> is not configured in the server environment. Please set this variable to enable AI generation.
                </div>
            <% } %>

            <!-- Dynamic Alert Container for Asynchronous Operations -->
            <div id="dynamicAlertBox" class="mb-4"></div>

            <!-- Dynamic Generated Summary Box (Rendered via AJAX) -->
            <div id="dynamicSummaryBox" style="display: none;" class="summary-box mb-4 position-relative"></div>

            <!-- Generated Summary View (If Requested via Server Forward) -->
            <% if (currentSummary != null) { %>
                <div class="summary-box mb-4 position-relative" id="summaryViewCard">
                    <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3 pb-3 border-bottom">
                        <div>
                            <span class="badge badge-primary me-2"><%= currentSummary.getSummaryType().toUpperCase() %></span>
                            <span class="badge bg-light text-secondary border me-2"><i class="fa-solid fa-file-lines me-1"></i> <%= currentSummary.getSourceType() %></span>
                            <h2 class="h3 fw-bold mt-2 mb-1 text-navy"><%= currentSummary.getTitle() %></h2>
                            <small class="text-muted"><i class="fa-regular fa-clock me-1"></i> Generated on <%= currentSummary.getCreatedAt() %></small>
                        </div>
                        <div class="d-flex gap-2">
                            <button type="button" class="btn btn-outline-gray btn-sm" onclick="copySummaryText()">
                                <i class="fa-regular fa-copy me-1" id="copyIcon"></i> <span id="copyBtnText">Copy Notes</span>
                            </button>
                            <button type="button" class="btn btn-outline-gray btn-sm" onclick="window.print()">
                                <i class="fa-solid fa-print me-1"></i> Print
                            </button>
                            <a href="ai-study-assistant" class="btn btn-sm btn-outline-danger">
                                <i class="fa-solid fa-xmark"></i>
                            </a>
                        </div>
                    </div>

                    <div id="summaryContentText" class="mt-3">
                        <%= currentSummary.getContentSummary()
                                .replace("\n## ", "\n<h2>")
                                .replace("\n### ", "\n<h3>")
                                .replace("\n• ", "\n<li>")
                                .replace("\n- ", "\n<li>")
                                .replaceAll("(?m)^### (.*)$", "<h3>$1</h3>")
                                .replaceAll("(?m)^## (.*)$", "<h2>$1</h2>")
                                .replaceAll("\\*\\*(.*?)\\*\\*", "<strong>$1</strong>")
                                .replace("\n\n", "<br><br>")
                        %>
                    </div>
                </div>
            <% } %>

            <!-- Study Material Input Section -->
            <div class="row g-4 mb-5">
                <div class="col-lg-12">
                    <div class="card shadow-sm border-0">
                        <div class="card-header bg-white py-3 border-bottom">
                            <div class="d-flex justify-content-between align-items-center flex-wrap">
                                <h5 class="fw-bold mb-0 text-navy">
                                    <i class="fa-solid fa-file-circle-plus text-primary me-2"></i> Provide Study Material
                                </h5>
                                <span class="text-muted fs-sm">Supports PDF, DOCX, and TXT (up to 10MB) or direct text pasting</span>
                            </div>
                        </div>

                        <div class="card-body p-4">
                            <!-- Dual Form Tab Setup -->
                            <ul class="nav nav-pills action-nav-pills mb-4" id="assistantTabs" role="tablist">
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link active" id="summarize-tab" data-bs-toggle="pill" data-bs-target="#summarizePane" type="button" role="tab">
                                        <i class="fa-solid fa-file-contract me-2"></i> Summarize Material
                                    </button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link" id="quiz-tab" data-bs-toggle="pill" data-bs-target="#quizPane" type="button" role="tab">
                                        <i class="fa-solid fa-list-check me-2"></i> Generate Practice Quiz
                                    </button>
                                </li>
                            </ul>

                            <form id="assistantForm" action="ai-study-assistant" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="action" id="formAction" value="summarize">

                                <!-- Material Title -->
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Material Title / Subject <span class="text-muted fw-normal">(Optional)</span></label>
                                    <input type="text" name="materialTitle" id="materialTitle" class="form-control"
                                           placeholder="e.g., Computer Networks — OSI Layer Models">
                                </div>

                                <div class="row g-3 mb-4">
                                    <!-- Upload File Area -->
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Option A: Upload Document File</label>
                                        <div class="upload-dropzone" id="dropzone" onclick="document.getElementById('studyFile').click()">
                                            <i class="fa-solid fa-cloud-arrow-up fa-2x text-primary mb-2"></i>
                                            <p class="fw-semibold mb-1 text-navy">Click to browse or drop file here</p>
                                            <small class="text-muted d-block">PDF, DOCX, TXT (Max 10MB)</small>
                                            <input type="file" name="studyFile" id="studyFile" class="d-none" accept=".pdf,.docx,.txt" onchange="handleFileSelected(this)">
                                        </div>

                                        <!-- Selected File Preview Pill -->
                                        <div id="filePreviewPill" class="mt-2" style="display: none;">
                                            <div class="file-pill">
                                                <i class="fa-solid fa-file-lines text-primary" id="fileIcon"></i>
                                                <span class="fw-semibold" id="fileNameDisplay">document.pdf</span>
                                                <small class="text-muted" id="fileSizeDisplay">(2.4 MB)</small>
                                                <button type="button" class="btn btn-link text-danger p-0 ms-2" onclick="clearSelectedFile()" title="Remove file">
                                                    <i class="fa-solid fa-circle-xmark"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Paste Material Text Area -->
                                    <div class="col-md-6">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <label class="form-label fw-bold mb-0">Option B: Paste Study Content</label>
                                            <small class="text-muted" id="charCount">0 characters</small>
                                        </div>
                                        <textarea name="pastedText" id="pastedText" class="form-control" rows="6"
                                                  placeholder="Paste lecture notes, book excerpts, syllabus summaries, or syllabus questions here..."
                                                  oninput="updateCharCount(this)"></textarea>
                                    </div>
                                </div>

                                <!-- Tab Content Settings -->
                                <div class="tab-content" id="assistantTabsContent">

                                    <!-- PANE 1: Summarize Options -->
                                    <div class="tab-pane fade show active" id="summarizePane" role="tabpanel">
                                        <div class="p-3 bg-light rounded border mb-4">
                                            <h6 class="fw-bold text-navy mb-3"><i class="fa-solid fa-sliders me-2 text-primary"></i> Select Summary Format</h6>
                                            <div class="row g-3">
                                                <div class="col-md-4">
                                                    <div class="form-check p-3 bg-white rounded border">
                                                        <input class="form-check-input" type="radio" name="summaryType" id="typeQuick" value="quick" checked>
                                                        <label class="form-check-label ms-2" for="typeQuick">
                                                            <strong class="d-block text-navy">Quick Summary</strong>
                                                            <small class="text-muted">High-level overview & core bullet points</small>
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-check p-3 bg-white rounded border">
                                                        <input class="form-check-input" type="radio" name="summaryType" id="typeDetailed" value="detailed">
                                                        <label class="form-check-label ms-2" for="typeDetailed">
                                                            <strong class="d-block text-navy">Detailed Summary</strong>
                                                            <small class="text-muted">In-depth topic breakdown with context</small>
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-check p-3 bg-white rounded border">
                                                        <input class="form-check-input" type="radio" name="summaryType" id="typeRevision" value="revision">
                                                        <label class="form-check-label ms-2" for="typeRevision">
                                                            <strong class="d-block text-navy">Exam Revision Notes</strong>
                                                            <small class="text-muted">High-yield points & common pitfalls</small>
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-check p-3 bg-white rounded border">
                                                        <input class="form-check-input" type="radio" name="summaryType" id="typeConcepts" value="concepts">
                                                        <label class="form-check-label ms-2" for="typeConcepts">
                                                            <strong class="d-block text-navy">Key Concepts & Terms</strong>
                                                            <small class="text-muted">Glossary of terms & crisp definitions</small>
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-check p-3 bg-white rounded border">
                                                        <input class="form-check-input" type="radio" name="summaryType" id="typeFormulas" value="formulas">
                                                        <label class="form-check-label ms-2" for="typeFormulas">
                                                            <strong class="d-block text-navy">Formulas & Principles</strong>
                                                            <small class="text-muted">Key laws, formulas & algorithmic rules</small>
                                                        </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-4">
                                                    <div class="form-check p-3 bg-white rounded border">
                                                        <input class="form-check-input" type="radio" name="summaryType" id="typeChapters" value="chapters">
                                                        <label class="form-check-label ms-2" for="typeChapters">
                                                            <strong class="d-block text-navy">Topic / Chapter Outline</strong>
                                                            <small class="text-muted">Structured section-by-section breakdown</small>
                                                        </label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <button type="submit" id="summarizeSubmitBtn" class="btn btn-primary btn-lg shadow-sm w-100 py-3" onclick="setMode('summarize')">
                                            <i class="fa-solid fa-wand-magic-sparkles me-2"></i> Summarize Material Now
                                        </button>
                                    </div>

                                    <!-- PANE 2: Practice Quiz Options -->
                                    <div class="tab-pane fade" id="quizPane" role="tabpanel">
                                        <div class="p-3 bg-light rounded border mb-4">
                                            <h6 class="fw-bold text-navy mb-3"><i class="fa-solid fa-gear me-2 text-primary"></i> Practice Quiz Configuration</h6>
                                            <div class="row g-3">
                                                <div class="col-md-4">
                                                    <label class="form-label fw-bold">Number of Questions</label>
                                                    <select name="numQuestions" class="form-select">
                                                        <option value="5" selected>5 Questions (Quick Check)</option>
                                                        <option value="10">10 Questions (Standard Quiz)</option>
                                                        <option value="15">15 Questions (Comprehensive)</option>
                                                        <option value="20">20 Questions (Full Assessment)</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-4">
                                                    <label class="form-label fw-bold">Difficulty Level</label>
                                                    <select name="difficulty" class="form-select">
                                                        <option value="Easy">Easy (Foundational & Definitions)</option>
                                                        <option value="Medium" selected>Medium (Standard Conceptual)</option>
                                                        <option value="Hard">Hard (In-depth Application & Analysis)</option>
                                                    </select>
                                                </div>
                                                <div class="col-md-4">
                                                    <label class="form-label fw-bold">Question Format</label>
                                                    <select name="questionType" class="form-select">
                                                        <option value="MCQ" selected>Multiple Choice (4 Options)</option>
                                                        <option value="True/False">True / False</option>
                                                        <option value="Mixed">Mixed (MCQ + True/False)</option>
                                                    </select>
                                                </div>
                                            </div>
                                        </div>

                                        <button type="submit" id="quizSubmitBtn" class="btn btn-success btn-lg shadow-sm w-100 py-3" onclick="setMode('generateQuiz')">
                                            <i class="fa-solid fa-rocket me-2"></i> Generate Practice Quiz & Start Review
                                        </button>
                                    </div>

                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <!-- History Section -->
            <div class="row g-4">
                <!-- Saved Summaries -->
                <div class="col-lg-6">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                            <h5 class="fw-bold mb-0 text-navy"><i class="fa-solid fa-bookmark text-primary me-2"></i> Saved Summaries</h5>
                            <span class="badge badge-primary"><%= summaries != null ? summaries.size() : 0 %></span>
                        </div>
                        <div class="card-body p-0">
                            <% if (summaries == null || summaries.isEmpty()) { %>
                                <div class="empty-state py-5">
                                    <div class="empty-icon"><i class="fa-regular fa-file-lines text-muted"></i></div>
                                    <h5 class="empty-title">No Summaries Yet</h5>
                                    <p class="empty-desc">Summaries generated from your uploads will be stored here for revision.</p>
                                </div>
                            <% } else { %>
                                <div class="table-wrap">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Title / Format</th>
                                                <th>Source</th>
                                                <th>Date</th>
                                                <th class="text-end">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (StudentSummary s : summaries) { %>
                                                <tr>
                                                    <td>
                                                        <div class="fw-bold text-navy"><%= s.getTitle() %></div>
                                                        <span class="badge bg-light text-primary border"><%= s.getSummaryType() %></span>
                                                    </td>
                                                    <td>
                                                        <small class="text-muted"><%= s.getSourceType() %></small>
                                                    </td>
                                                    <td>
                                                        <small class="text-muted"><%= s.getCreatedAt().toString().substring(0, 16) %></small>
                                                    </td>
                                                    <td class="text-end">
                                                        <a href="ai-study-assistant?action=viewSummary&summaryId=<%= s.getSummaryId() %>" class="btn btn-sm btn-outline-primary me-1">
                                                            <i class="fa-regular fa-eye"></i> View
                                                        </a>
                                                        <a href="ai-study-assistant?action=deleteSummary&summaryId=<%= s.getSummaryId() %>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this saved summary?')">
                                                            <i class="fa-regular fa-trash-can"></i>
                                                        </a>
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

                <!-- Recent Practice Attempts -->
                <div class="col-lg-6">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-header bg-white py-3 border-bottom d-flex justify-content-between align-items-center">
                            <h5 class="fw-bold mb-0 text-navy"><i class="fa-solid fa-list-check text-success me-2"></i> AI Practice Attempts</h5>
                            <span class="badge badge-success"><%= recentAttempts != null ? recentAttempts.size() : 0 %></span>
                        </div>
                        <div class="card-body p-0">
                            <% if (recentAttempts == null || recentAttempts.isEmpty()) { %>
                                <div class="empty-state py-5">
                                    <div class="empty-icon"><i class="fa-solid fa-award text-muted"></i></div>
                                    <h5 class="empty-title">No Practice Attempts</h5>
                                    <p class="empty-desc">Generate a practice quiz above to practice and test your understanding.</p>
                                </div>
                            <% } else { %>
                                <div class="table-wrap">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Quiz Title</th>
                                                <th>Score</th>
                                                <th>Date</th>
                                                <th class="text-end">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (StudentPracticeAttempt att : recentAttempts) { %>
                                                <tr>
                                                    <td>
                                                        <div class="fw-bold text-navy"><%= att.getQuizTitle() != null ? att.getQuizTitle() : "Practice Quiz" %></div>
                                                        <small class="text-muted"><%= att.getCorrectCount() %> correct, <%= att.getIncorrectCount() %> wrong</small>
                                                    </td>
                                                    <td>
                                                        <span class="badge <%= att.getPercentage() >= 60.0 ? "badge-success" : "badge-danger" %>">
                                                            <%= att.getScore() %>/<%= att.getTotalMarks() %> (<%= att.getPercentage() %>%)
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <small class="text-muted"><%= att.getCompletedAt().toString().substring(0, 16) %></small>
                                                    </td>
                                                    <td class="text-end">
                                                        <a href="ai-practice-quiz?action=result&attemptId=<%= att.getAttemptId() %>" class="btn btn-sm btn-outline-gray">
                                                            Review Results →
                                                        </a>
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

        </div>
    </div>

    <!-- Loading Modal Overlay -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-card shadow-float">
            <div class="spinner-border text-primary mb-3" style="width: 3.5rem; height: 3.5rem;" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <h4 class="fw-bold text-navy mb-2" id="loadingTitle">AI is Processing...</h4>
            <p class="text-muted mb-3" id="loadingSubtitle">Extracting text, analyzing core concepts, and synthesizing your request with Large Language Model intelligence.</p>
            <button type="button" class="btn btn-outline-danger btn-sm px-3" onclick="cancelAIRequest()">
                <i class="fa-solid fa-xmark me-1"></i> Cancel Request
            </button>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentAbortController = null;
        let isSubmitting = false;

        function setMode(mode) {
            document.getElementById('formAction').value = mode;
        }

        function toggleSubmitButtons(disabled) {
            const btn1 = document.getElementById('summarizeSubmitBtn');
            const btn2 = document.getElementById('quizSubmitBtn');
            if (btn1) btn1.disabled = disabled;
            if (btn2) btn2.disabled = disabled;
        }

        function cancelAIRequest() {
            if (currentAbortController) {
                currentAbortController.abort();
            }
            const overlay = document.getElementById('loadingOverlay');
            if (overlay) overlay.style.display = 'none';
            isSubmitting = false;
            toggleSubmitButtons(false);
            showErrorAlert('Operation was cancelled by user.');
        }

        function clearDynamicAlert() {
            const box = document.getElementById('dynamicAlertBox');
            if (box) box.innerHTML = '';
        }

        function showErrorAlert(message) {
            const box = document.getElementById('dynamicAlertBox');
            if (!box) return;
            box.innerHTML = `
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center shadow-sm" role="alert">
                    <i class="fa-solid fa-circle-exclamation fs-5 me-2 flex-shrink-0"></i>
                    <div>\${escapeHtml(message)}</div>
                    <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            `;
            box.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }

        function showSuccessAlert(message) {
            const box = document.getElementById('dynamicAlertBox');
            if (!box) return;
            box.innerHTML = `
                <div class="alert alert-success alert-dismissible fade show d-flex align-items-center shadow-sm" role="alert">
                    <i class="fa-solid fa-circle-check fs-5 me-2 flex-shrink-0"></i>
                    <div>\${escapeHtml(message)}</div>
                    <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            `;
            box.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }

        function escapeHtml(text) {
            if (!text) return '';
            return text
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }

        function showDynamicSummary(data) {
            const sumBox = document.getElementById('dynamicSummaryBox');
            if (!sumBox) return;

            let formatted = escapeHtml(data.content || '')
                .replace(/\n## (.*)/g, '<h2 class="h4 fw-bold mt-4 mb-2 text-navy">$1</h2>')
                .replace(/\n### (.*)/g, '<h3 class="h5 fw-bold mt-3 mb-2 text-navy">$1</h3>')
                .replace(/\n• (.*)/g, '<li>$1</li>')
                .replace(/\n- (.*)/g, '<li>$1</li>')
                .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                .replace(/\n\n/g, '<br><br>');

            sumBox.innerHTML = `
                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3 pb-3 border-bottom">
                    <div>
                        <span class="badge badge-primary me-2">\${escapeHtml((data.summaryType || 'SUMMARY').toUpperCase())}</span>
                        <span class="badge bg-light text-secondary border me-2"><i class="fa-solid fa-file-lines me-1"></i> Generated</span>
                        <h2 class="h3 fw-bold mt-2 mb-1 text-navy">\${escapeHtml(data.title || 'Study Summary')}</h2>
                        <small class="text-muted"><i class="fa-regular fa-clock me-1"></i> Just now</small>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="button" class="btn btn-outline-gray btn-sm" onclick="copyDynamicSummaryText()">
                            <i class="fa-regular fa-copy me-1" id="dynCopyIcon"></i> <span id="dynCopyText">Copy Notes</span>
                        </button>
                        <button type="button" class="btn btn-outline-gray btn-sm" onclick="window.print()">
                            <i class="fa-solid fa-print me-1"></i> Print
                        </button>
                        <button type="button" class="btn btn-sm btn-outline-danger" onclick="document.getElementById('dynamicSummaryBox').style.display='none'">
                            <i class="fa-solid fa-xmark"></i>
                        </button>
                    </div>
                </div>
                <div id="dynamicSummaryContent" class="mt-3">
                    \${formatted}
                </div>
            `;
            sumBox.style.display = 'block';
            sumBox.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }

        function copyDynamicSummaryText() {
            const el = document.getElementById('dynamicSummaryContent');
            if (!el) return;
            const text = el.innerText || el.textContent;
            navigator.clipboard.writeText(text).then(() => {
                const btnText = document.getElementById('dynCopyText');
                const icon = document.getElementById('dynCopyIcon');
                if (btnText) btnText.textContent = 'Copied!';
                if (icon) icon.className = 'fa-solid fa-check text-success me-1';
                setTimeout(() => {
                    if (btnText) btnText.textContent = 'Copy Notes';
                    if (icon) icon.className = 'fa-regular fa-copy me-1';
                }, 2500);
            });
        }

        // File Selection and Validation
        function handleFileSelected(input) {
            if (!input.files || input.files.length === 0) return;
            const file = input.files[0];
            const maxBytes = 10 * 1024 * 1024; // 10MB

            if (file.size > maxBytes) {
                showErrorAlert('File size exceeds 10MB. Please upload a smaller file or paste text directly.');
                clearSelectedFile();
                return;
            }

            const name = file.name;
            const ext = name.split('.').pop().toLowerCase();
            if (['pdf', 'docx', 'txt'].indexOf(ext) === -1) {
                showErrorAlert('Only .pdf, .docx, and .txt files are supported.');
                clearSelectedFile();
                return;
            }

            document.getElementById('fileNameDisplay').textContent = name;
            document.getElementById('fileSizeDisplay').textContent = '(' + (file.size / (1024 * 1024)).toFixed(2) + ' MB)';
            
            const icon = document.getElementById('fileIcon');
            if (ext === 'pdf') {
                icon.className = 'fa-solid fa-file-pdf text-danger';
            } else if (ext === 'docx') {
                icon.className = 'fa-solid fa-file-word text-primary';
            } else {
                icon.className = 'fa-solid fa-file-lines text-secondary';
            }

            document.getElementById('filePreviewPill').style.display = 'block';

            const titleInput = document.getElementById('materialTitle');
            if (!titleInput.value) {
                titleInput.value = name.replace(/\.[^/.]+$/, "");
            }
        }

        function clearSelectedFile() {
            const input = document.getElementById('studyFile');
            if (input) input.value = '';
            document.getElementById('filePreviewPill').style.display = 'none';
        }

        function updateCharCount(textarea) {
            const count = textarea.value.length;
            document.getElementById('charCount').textContent = count + ' characters';
        }

        // Robust AJAX Form submission with finally-style cleanup
        document.getElementById('assistantForm').addEventListener('submit', async function(e) {
            e.preventDefault();

            if (isSubmitting) return;

            const fileInput = document.getElementById('studyFile');
            const hasFile = fileInput.files && fileInput.files.length > 0;
            const pasted = document.getElementById('pastedText').value.trim();

            if (!hasFile && pasted.length < 20) {
                showErrorAlert('Please upload a document (.pdf, .docx, .txt) or paste at least 20 characters of study material.');
                return false;
            }

            const action = document.getElementById('formAction').value;
            const overlay = document.getElementById('loadingOverlay');
            const title = document.getElementById('loadingTitle');
            const subtitle = document.getElementById('loadingSubtitle');

            if (action === 'generateQuiz') {
                title.textContent = 'Generating Practice Quiz...';
                subtitle.textContent = 'Synthesizing conceptual exam questions, 4 options, and grounded explanations from your material.';
            } else {
                title.textContent = 'Synthesizing AI Summary...';
                subtitle.textContent = 'Extracting key principles, exam formulas, definitions, and high-yield notes.';
            }

            clearDynamicAlert();
            isSubmitting = true;
            toggleSubmitButtons(true);
            overlay.style.display = 'flex';

            currentAbortController = new AbortController();
            const timeoutId = setTimeout(() => {
                if (currentAbortController) {
                    currentAbortController.abort();
                }
            }, 45000); // 45 seconds client timeout

            try {
                const formData = new FormData(this);
                formData.append('format', 'json');

                const response = await fetch('ai-study-assistant', {
                    method: 'POST',
                    body: formData,
                    headers: {
                        'Accept': 'application/json'
                    },
                    signal: currentAbortController.signal
                });

                clearTimeout(timeoutId);

                let data;
                const textResponse = await response.text();
                try {
                    data = JSON.parse(textResponse);
                } catch (jsonErr) {
                    throw new Error('Server returned an unparseable response.');
                }

                if (data.success) {
                    if (action === 'generateQuiz') {
                        if (data.redirectUrl) {
                            // Keep overlay while navigating to review screen
                            window.location.href = data.redirectUrl;
                            return;
                        } else {
                            showErrorAlert('Practice quiz was generated, but no navigation URL was returned.');
                        }
                    } else if (action === 'summarize') {
                        showDynamicSummary(data);
                        showSuccessAlert('Summary generated and saved successfully!');
                    }
                } else {
                    showErrorAlert(data.error || 'AI request was rejected. Please review your input.');
                }

            } catch (err) {
                clearTimeout(timeoutId);
                if (err.name === 'AbortError') {
                    showErrorAlert('The AI generation request timed out after 45 seconds. Please try with shorter material or fewer questions.');
                } else {
                    showErrorAlert('Request failed: ' + (err.message || 'Unknown network error.'));
                }
            } finally {
                // Ensure loading modal is ALWAYS removed
                overlay.style.display = 'none';
                isSubmitting = false;
                toggleSubmitButtons(false);
                currentAbortController = null;
            }
        });

        // Copy Server-Rendered Summary functionality
        function copySummaryText() {
            const textElem = document.getElementById('summaryContentText');
            if (!textElem) return;
            const textToCopy = textElem.innerText || textElem.textContent;

            navigator.clipboard.writeText(textToCopy).then(() => {
                const btnText = document.getElementById('copyBtnText');
                const icon = document.getElementById('copyIcon');
                if (btnText) btnText.textContent = 'Copied!';
                if (icon) icon.className = 'fa-solid fa-check text-success me-1';
                setTimeout(() => {
                    if (btnText) btnText.textContent = 'Copy Notes';
                    if (icon) icon.className = 'fa-regular fa-copy me-1';
                }, 2500);
            }).catch(err => {
                alert('Failed to copy: ' + err);
            });
        }
    </script>
</body>
</html>
