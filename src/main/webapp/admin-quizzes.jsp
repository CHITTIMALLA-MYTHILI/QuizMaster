<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.Quiz" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    List<Quiz> quizzes = (List<Quiz>) request.getAttribute("quizzes");
    if (quizzes == null) {
        response.sendRedirect("admin-quizzes");
        return;
    }

    Map<Integer, Integer> marksSumMap = (Map<Integer, Integer>) request.getAttribute("marksSumMap");
    Map<Integer, Integer> questionCountMap = (Map<Integer, Integer>) request.getAttribute("questionCountMap");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Quizzes — Admin — QuizMaster</title>
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
            <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h1 class="page-title">Quiz Management</h1>
                    <p class="page-subtitle">Create, configure, publish, and manage online examinations.</p>
                </div>
                <div>
                    <a href="createQuiz" class="btn btn-primary"><i class="fa-solid fa-plus me-1"></i> Create New Quiz</a>
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

            <div class="card">
                <div class="card-body p-0">
                    <%
                        if (quizzes.isEmpty()) {
                    %>
                        <div class="empty-state">
                            <div class="empty-icon"><i class="fa-solid fa-folder-open text-muted"></i></div>
                            <h4 class="empty-title">No Quizzes Found</h4>
                            <p class="empty-desc">You haven't created any quizzes yet. Get started by creating your first quiz.</p>
                            <a href="createQuiz" class="btn btn-primary"><i class="fa-solid fa-plus me-1"></i> Create Quiz</a>
                        </div>
                    <%
                        } else {
                    %>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Quiz Title & Category</th>
                                        <th>Duration</th>
                                        <th>Questions</th>
                                        <th>Marks Status</th>
                                        <th>Status</th>
                                        <th class="text-end">Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for (Quiz q : quizzes) {
                                            int qCount = (questionCountMap != null && questionCountMap.containsKey(q.getQuizId()))
                                                    ? questionCountMap.get(q.getQuizId()) : 0;
                                            int marksSum = (marksSumMap != null && marksSumMap.containsKey(q.getQuizId()))
                                                    ? marksSumMap.get(q.getQuizId()) : 0;
                                            boolean marksMatch = (marksSum == q.getTotalMarks());
                                            boolean isPublished = q.isPublished();
                                    %>
                                        <tr>
                                            <td class="text-muted fw-bold">#<%= q.getQuizId() %></td>
                                            <td>
                                                <div class="fw-bold fs-6"><%= q.getTitle() %></div>
                                                <span class="badge badge-primary fs-sm"><%= q.getCategory() %></span>
                                            </td>
                                            <td><i class="fa-regular fa-clock me-1 text-muted"></i> <%= q.getDuration() %> mins</td>
                                            <td>
                                                <a href="admin-questions?quizId=<%= q.getQuizId() %>" class="fw-semibold">
                                                    <%= qCount %> question<%= qCount == 1 ? "" : "s" %>
                                                </a>
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <span class="fw-bold <%= marksMatch ? "text-success" : "text-danger" %>">
                                                        <%= marksSum %> / <%= q.getTotalMarks() %>
                                                    </span>
                                                    <% if (marksMatch) { %>
                                                        <i class="fa-solid fa-circle-check text-success" title="Marks match configured total"></i>
                                                    <% } else { %>
                                                        <i class="fa-solid fa-circle-exclamation text-danger" title="Questions sum does not equal configured total marks"></i>
                                                    <% } %>
                                                </div>
                                                <small class="text-muted"><%= marksMatch ? "Ready for publishing" : (q.getTotalMarks() - marksSum) + " marks needed" %></small>
                                            </td>
                                            <td>
                                                <% if (isPublished) { %>
                                                    <span class="badge badge-published"><i class="fa-solid fa-globe me-1"></i> Published</span>
                                                <% } else { %>
                                                    <span class="badge badge-draft"><i class="fa-solid fa-pen-ruler me-1"></i> Draft</span>
                                                <% } %>
                                            </td>
                                            <td>
                                                <div class="d-flex justify-content-end gap-1 flex-wrap">
                                                    <!-- Questions management -->
                                                    <a href="admin-questions?quizId=<%= q.getQuizId() %>" class="btn btn-sm btn-outline" title="Manage Questions">
                                                        <i class="fa-solid fa-list-ol me-1"></i> Questions
                                                    </a>

                                                    <!-- Edit -->
                                                    <a href="editQuiz?quizId=<%= q.getQuizId() %>" class="btn btn-sm btn-outline-gray" title="Edit Quiz Details">
                                                        <i class="fa-solid fa-pen"></i>
                                                    </a>

                                                    <!-- Publish / Unpublish -->
                                                    <% if (!isPublished) { %>
                                                        <a href="admin-quizzes?action=publish&quizId=<%= q.getQuizId() %>"
                                                           class="btn btn-sm btn-success"
                                                           title="Publish Quiz to Students">
                                                            <i class="fa-solid fa-upload me-1"></i> Publish
                                                        </a>
                                                    <% } else { %>
                                                        <a href="admin-quizzes?action=unpublish&quizId=<%= q.getQuizId() %>"
                                                           class="btn btn-sm btn-warning"
                                                           title="Revert to Draft">
                                                            <i class="fa-solid fa-eye-slash me-1"></i> Unpublish
                                                        </a>
                                                    <% } %>

                                                    <!-- Delete -->
                                                    <a href="admin-quizzes?action=delete&quizId=<%= q.getQuizId() %>"
                                                       class="btn btn-sm btn-danger"
                                                       onclick="return confirm('Are you sure you want to delete \'<%= q.getTitle().replace("'", "\\'") %>\'? This will remove all questions, attempts, and results.');"
                                                       title="Delete Quiz">
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
