<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.StudyMaterial" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("adminLoggedIn") == null) {
        response.sendRedirect("admin-login.jsp");
        return;
    }

    List<StudyMaterial> materials = (List<StudyMaterial>) request.getAttribute("materials");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Study Materials — QuizMaster Admin</title>
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
                <a href="ai-quiz-generator" class="text-primary fs-sm fw-semibold"><i class="fa-solid fa-wand-magic-sparkles me-1"></i> AI Quiz Generator</a>
            </div>

            <div class="page-header d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h1 class="page-title">Course Study Materials</h1>
                    <p class="page-subtitle">Add reference texts, lecture notes, and study material. These are indexed for AI Quiz Generation and Grounded Tutor Retrieval.</p>
                </div>
            </div>

            <div class="row g-4">
                <!-- Ingestion Form (Left Column) -->
                <div class="col-lg-5">
                    <div class="card border-0 shadow-sm">
                        <div class="card-header bg-white p-4 border-bottom">
                            <h5 class="fw-bold mb-0 text-navy"><i class="fa-solid fa-file-circle-plus me-2 text-primary"></i> Add Study Material</h5>
                        </div>
                        <div class="card-body p-4">
                            <form action="study-materials" method="post">
                                <div class="form-group mb-3">
                                    <label class="form-label" for="title">Document Title <span class="text-danger">*</span></label>
                                    <input type="text" id="title" name="title" class="form-control"
                                           placeholder="e.g. Chapter 4: SQL Joins & Subqueries" required>
                                </div>

                                <div class="form-group mb-3">
                                    <label class="form-label" for="category">Subject Category</label>
                                    <select id="category" name="category" class="form-control">
                                        <option value="Programming">Programming</option>
                                        <option value="Database">Database</option>
                                        <option value="Web Development">Web Development</option>
                                        <option value="Mathematics">Mathematics</option>
                                        <option value="General Science">General Science</option>
                                        <option value="General" selected>General</option>
                                    </select>
                                </div>

                                <div class="form-group mb-4">
                                    <label class="form-label" for="contentText">Document Text Content <span class="text-danger">*</span></label>
                                    <textarea id="contentText" name="contentText" class="form-control" rows="8"
                                              placeholder="Paste chapter text, key definitions, or syllabus content here..." required></textarea>
                                    <small class="text-muted d-block mt-1"><i class="fa-solid fa-circle-nodes me-1"></i> Text is automatically segmented into passages for search retrieval.</small>
                                </div>

                                <button type="submit" class="btn btn-primary btn-block">
                                    <i class="fa-solid fa-plus me-1"></i> Save & Index Material
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Material List (Right Column) -->
                <div class="col-lg-7">
                    <div class="card border-0 shadow-sm h-100">
                        <div class="card-header bg-white p-4 border-bottom">
                            <h5 class="fw-bold mb-0 text-navy"><i class="fa-solid fa-book-bookmark me-2 text-primary"></i> Indexed Materials (<%= materials != null ? materials.size() : 0 %>)</h5>
                        </div>
                        <div class="card-body p-0">
                            <% if (materials == null || materials.isEmpty()) { %>
                                <div class="empty-state py-5">
                                    <div class="empty-icon"><i class="fa-solid fa-folder-open text-muted"></i></div>
                                    <h5 class="empty-title">No Study Materials Added</h5>
                                    <p class="empty-desc">Add reference notes using the form on the left to enable AI-grounded tutoring and quiz generation.</p>
                                </div>
                            <% } else { %>
                                <div class="table-wrap">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Title</th>
                                                <th>Category</th>
                                                <th>Length</th>
                                                <th>Added</th>
                                                <th class="text-end">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (StudyMaterial m : materials) { %>
                                                <tr>
                                                    <td>
                                                        <div class="fw-bold"><%= m.getTitle() %></div>
                                                    </td>
                                                    <td><span class="badge badge-primary"><%= m.getCategory() %></span></td>
                                                    <td class="text-muted fs-sm"><%= m.getContentText().length() %> chars</td>
                                                    <td class="text-muted fs-sm"><%= m.getCreatedAt() != null ? m.getCreatedAt().toString().substring(0, 10) : "" %></td>
                                                    <td class="text-end">
                                                        <a href="study-materials?action=delete&materialId=<%= m.getMaterialId() %>"
                                                           class="btn btn-sm btn-outline-gray text-danger"
                                                           onclick="return confirm('Delete this study material and all indexed passages?');">
                                                            <i class="fa-solid fa-trash-can"></i>
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

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
