<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.DashboardStats" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    DashboardStats stats = (DashboardStats) request.getAttribute("stats");
    if (stats == null) {
        response.sendRedirect("admin-dashboard");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — QuizMaster Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
    <style>
        .admin-sidebar {
            background: #ffffff;
            border-right: 1px solid var(--border-color);
            min-height: calc(100vh - 64px);
            padding: 24px 16px;
        }
        .admin-sidebar-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 14px;
            border-radius: var(--radius-md);
            color: var(--body-text);
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 4px;
            transition: var(--transition);
        }
        .admin-sidebar-link:hover {
            color: var(--primary);
            background: var(--primary-light);
        }
        .admin-sidebar-link.active {
            color: var(--primary);
            background: var(--primary-light);
            font-weight: 700;
        }
        .admin-sidebar-heading {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: var(--muted-text);
            padding: 12px 14px 6px;
        }
    </style>
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

    <div class="container-fluid p-0">
        <div class="row g-0">
            <!-- Sidebar (Section 7 specification) -->
            <div class="col-md-3 col-lg-2 d-none d-md-block admin-sidebar">
                <div class="admin-sidebar-heading">Management</div>
                <a href="admin-dashboard" class="admin-sidebar-link active">
                    <i class="fa-solid fa-gauge text-primary"></i> Dashboard
                </a>
                <a href="admin-quizzes" class="admin-sidebar-link">
                    <i class="fa-solid fa-book-open"></i> Manage Quizzes
                </a>
                <a href="createQuiz" class="admin-sidebar-link">
                    <i class="fa-solid fa-circle-plus text-success"></i> Create Quiz
                </a>

                <div class="admin-sidebar-heading mt-3">AI Intelligence</div>
                <a href="ai-quiz-generator" class="admin-sidebar-link">
                    <i class="fa-solid fa-wand-magic-sparkles text-primary"></i> AI Quiz Generator
                </a>
                <a href="study-materials" class="admin-sidebar-link">
                    <i class="fa-solid fa-book-bookmark text-info"></i> Study Materials
                </a>
                <a href="ai-evaluation-review" class="admin-sidebar-link">
                    <i class="fa-solid fa-signature text-warning"></i> AI Evaluation Review
                </a>
                
                <div class="admin-sidebar-heading mt-3">Examinations & Students</div>
                <a href="admin-results" class="admin-sidebar-link">
                    <i class="fa-solid fa-square-poll-vertical text-info"></i> Student Results
                </a>
                <a href="leaderboard" class="admin-sidebar-link">
                    <i class="fa-solid fa-trophy text-warning"></i> Leaderboard
                </a>
                
                <div class="admin-sidebar-heading mt-3">Account</div>
                <a href="adminLogout" class="admin-sidebar-link text-danger">
                    <i class="fa-solid fa-right-from-bracket"></i> Logout
                </a>
            </div>

            <!-- Main Content Area -->
            <div class="col-md-9 col-lg-10 p-4 p-md-5" style="background: var(--bg-page);">
                <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                    <div>
                        <h1 class="page-title">Administrator Dashboard</h1>
                        <p class="page-subtitle">Welcome back! Real-time examination platform statistics and recent student activities.</p>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="createQuiz" class="btn btn-primary"><i class="fa-solid fa-plus me-1"></i> Create New Quiz</a>
                        <a href="admin-quizzes" class="btn btn-outline-gray"><i class="fa-solid fa-list-check me-1"></i> Manage Quizzes</a>
                    </div>
                </div>

                <!-- 5 Real Database Statistics Cards (Section 7 specification) -->
                <div class="grid grid-4 section-gap" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
                    <div class="stat-card">
                        <div class="stat-icon stat-icon-blue">
                            <i class="fa-solid fa-book-open"></i>
                        </div>
                        <div>
                            <div class="stat-value"><%= stats.getTotalQuizzes() %></div>
                            <div class="stat-label">Total Quizzes</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon stat-icon-green">
                            <i class="fa-solid fa-globe"></i>
                        </div>
                        <div>
                            <div class="stat-value"><%= stats.getPublishedQuizzes() %></div>
                            <div class="stat-label">Published Quizzes</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon stat-icon-orange">
                            <i class="fa-solid fa-file-pen"></i>
                        </div>
                        <div>
                            <div class="stat-value"><%= stats.getDraftQuizzes() %></div>
                            <div class="stat-label">Draft Quizzes</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon stat-icon-cyan">
                            <i class="fa-solid fa-user-graduate"></i>
                        </div>
                        <div>
                            <div class="stat-value"><%= stats.getTotalStudents() %></div>
                            <div class="stat-label">Registered Students</div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon stat-icon-purple">
                            <i class="fa-solid fa-clipboard-check"></i>
                        </div>
                        <div>
                            <div class="stat-value"><%= stats.getTotalAttempts() %></div>
                            <div class="stat-label">Total Attempts</div>
                        </div>
                    </div>
                </div>

                <!-- Recent Activity & Quick Shortcuts -->
                <div class="row g-4">
                    <div class="col-lg-8">
                        <div class="card h-100">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h5 class="fw-bold mb-0"><i class="fa-solid fa-clock-rotate-left me-2 text-primary"></i> Recent Examination Activity</h5>
                                <a href="admin-results" class="btn btn-sm btn-outline">View All Results</a>
                            </div>
                            <div class="card-body p-0">
                                <%
                                    List<DashboardStats.RecentActivity> activities = stats.getRecentActivities();
                                    if (activities == null || activities.isEmpty()) {
                                %>
                                    <div class="empty-state">
                                        <div class="empty-icon"><i class="fa-solid fa-inbox text-muted"></i></div>
                                        <h5 class="empty-title">No Recent Activity</h5>
                                        <p class="empty-desc">Completed student examination attempts will be listed here automatically.</p>
                                    </div>
                                <%
                                    } else {
                                %>
                                    <div class="table-wrap">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>Student</th>
                                                    <th>Quiz</th>
                                                    <th>Score / Total</th>
                                                    <th>Grade</th>
                                                    <th>Completed At</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <% for (DashboardStats.RecentActivity a : activities) { %>
                                                    <tr>
                                                        <td class="fw-bold"><%= a.getStudentName() %></td>
                                                        <td><%= a.getQuizTitle() %></td>
                                                        <td><span class="badge badge-primary"><%= a.getScore() %> / <%= a.getTotalMarks() %></span></td>
                                                        <td>
                                                            <span class="badge <%= "F".equalsIgnoreCase(a.getGrade()) ? "badge-danger" : "badge-success" %>">
                                                                <%= a.getGrade() %>
                                                            </span>
                                                        </td>
                                                        <td class="text-muted fs-sm"><%= a.getCompletedAt() %></td>
                                                    </tr>
                                                <% } %>
                                            </tbody>
                                        </table>
                                    </div>
                                <%
                                    }
                                %>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="card h-100">
                            <div class="card-header">
                                <h5 class="fw-bold mb-0"><i class="fa-solid fa-bolt me-2 text-warning"></i> Quick Operations</h5>
                            </div>
                            <div class="card-body d-flex flex-column gap-3 p-4">
                                <a href="createQuiz" class="btn btn-primary btn-block text-start py-3">
                                    <i class="fa-solid fa-circle-plus fs-5 me-2"></i>
                                    <div>
                                        <div class="fw-bold">Create New Quiz</div>
                                        <small class="opacity-75">Title, subject, duration & marks</small>
                                    </div>
                                </a>

                                <a href="admin-quizzes" class="btn btn-outline-gray btn-block text-start py-3">
                                    <i class="fa-solid fa-book-open fs-5 me-2 text-primary"></i>
                                    <div>
                                        <div class="fw-bold">Manage Quizzes</div>
                                        <small class="text-muted">Publish, edit or add questions</small>
                                    </div>
                                </a>

                                <a href="admin-results" class="btn btn-outline-gray btn-block text-start py-3">
                                    <i class="fa-solid fa-square-poll-vertical fs-5 me-2 text-info"></i>
                                    <div>
                                        <div class="fw-bold">Inspect Attempts</div>
                                        <small class="text-muted">Per-question answer evaluation audit</small>
                                    </div>
                                </a>

                                <div class="alert alert-info mt-auto mb-0 fs-sm">
                                    <i class="fa-solid fa-circle-info me-2"></i>
                                    <strong>Publishing Rule:</strong> Quiz total marks must strictly equal the sum of assigned question marks before publishing to students.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>