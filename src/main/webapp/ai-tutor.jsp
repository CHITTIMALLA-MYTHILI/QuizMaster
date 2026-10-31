<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.quizmaster.model.AITutorMessage" %>
<%@ page import="java.util.List" %>
<%
    if (session.getAttribute("studentId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    List<AITutorMessage> history = (List<AITutorMessage>) request.getAttribute("history");
    Boolean aiConfigured = (Boolean) request.getAttribute("aiConfigured");
    if (aiConfigured == null) aiConfigured = false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Study Tutor — QuizMaster</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2.0">
    <style>
        .chat-container {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius-xl);
            box-shadow: var(--shadow-card);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: calc(100vh - 220px);
            min-height: 500px;
        }
        .chat-messages {
            flex-grow: 1;
            padding: 24px;
            overflow-y: auto;
            background: #f8fafc;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .chat-bubble {
            max-width: 80%;
            padding: 14px 18px;
            border-radius: var(--radius-lg);
            font-size: 14px;
            line-height: 1.6;
        }
        .chat-bubble-user {
            align-self: flex-end;
            background: var(--primary);
            color: #ffffff;
            border-bottom-right-radius: 2px;
        }
        .chat-bubble-assistant {
            align-self: flex-start;
            background: #ffffff;
            color: var(--navy-text);
            border: 1px solid var(--border-color);
            border-bottom-left-radius: 2px;
            box-shadow: var(--shadow-sm);
        }
        .chat-input-bar {
            padding: 16px 20px;
            background: #ffffff;
            border-top: 1px solid var(--border-color);
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
            <a href="ai-study-assistant" class="qm-navbar-link"><i class="fa-solid fa-wand-magic-sparkles me-1 text-primary"></i> AI Study Assistant</a>
            <a href="ai-tutor" class="qm-navbar-link active"><i class="fa-solid fa-robot me-1 text-primary"></i> AI Study Tutor</a>
            <a href="leaderboard" class="qm-navbar-link"><i class="fa-solid fa-trophy me-1"></i> Leaderboard</a>
        </div>
        <div class="qm-navbar-user">
            <span class="username-display"><i class="fa-regular fa-user-circle me-1 text-primary"></i> <%= studentName %></span>
            <a href="logout" class="btn btn-outline-gray btn-sm text-danger"><i class="fa-solid fa-arrow-right-from-bracket me-1"></i> Logout</a>
        </div>
    </header>

    <div class="page-wrapper py-4">
        <div class="container" style="max-width: 960px;">
            <div class="page-header d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h1 class="page-title"><i class="fa-solid fa-graduation-cap text-primary me-2"></i> AI Study Tutor</h1>
                    <p class="page-subtitle">Ask questions, clarify concepts, and receive grounded explanations from your course materials.</p>
                </div>
                <div>
                    <a href="dashboard.jsp" class="btn btn-outline-gray btn-sm"><i class="fa-solid fa-arrow-left me-1"></i> Dashboard</a>
                </div>
            </div>

            <% if (!aiConfigured) { %>
                <div class="alert alert-warning mb-3">
                    <i class="fa-solid fa-circle-exclamation mt-1"></i>
                    <div>
                        <strong>Service Notice:</strong> The AI Study Tutor is currently in setup mode. An administrator must define <code>QUIZMASTER_AI_API_KEY</code> on the server to enable live replies.
                    </div>
                </div>
            <% } %>

            <!-- Chat Container (Section 3 specification) -->
            <div class="chat-container">
                <div class="chat-messages" id="chatWindow">
                    <!-- Welcome Initial Message -->
                    <div class="chat-bubble chat-bubble-assistant">
                        <div class="fw-bold mb-1 text-primary"><i class="fa-solid fa-robot me-1"></i> QuizMaster Tutor</div>
                        <div>
                            Hello <strong><%= studentName %></strong>! I am your AI Study Tutor. Ask me any question about your curriculum—such as:
                            <ul class="mb-0 mt-2 ps-3">
                                <li><em>"Explain Java Inheritance with an example"</em></li>
                                <li><em>"What is the difference between a process and a thread?"</em></li>
                                <li><em>"Can you give me practice questions on SQL joins?"</em></li>
                            </ul>
                        </div>
                    </div>

                    <% if (history != null) {
                        for (AITutorMessage m : history) {
                            boolean isUser = "user".equalsIgnoreCase(m.getRole());
                    %>
                        <div class="chat-bubble <%= isUser ? "chat-bubble-user" : "chat-bubble-assistant" %>">
                            <% if (!isUser) { %>
                                <div class="fw-bold mb-1 text-primary"><i class="fa-solid fa-robot me-1"></i> QuizMaster Tutor</div>
                            <% } %>
                            <div style="white-space: pre-wrap;"><%= m.getMessageText() %></div>
                            <% if (m.getSourcesCited() != null && !m.getSourcesCited().isEmpty()) { %>
                                <div class="mt-2 pt-2 border-top fs-sm text-muted">
                                    <i class="fa-solid fa-book-open me-1"></i> <strong>Grounded in:</strong> <%= m.getSourcesCited() %>
                                </div>
                            <% } %>
                        </div>
                    <%  }
                    } %>
                </div>

                <!-- Input Form -->
                <div class="chat-input-bar">
                    <form action="ai-tutor" method="post" class="d-flex gap-2">
                        <input type="text" name="query" class="form-control"
                               placeholder="Type your study question here..." required <%= !aiConfigured ? "disabled" : "" %>>
                        <button type="submit" class="btn btn-primary px-4" <%= !aiConfigured ? "disabled" : "" %>>
                            <i class="fa-solid fa-paper-plane me-1"></i> Send
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const chatWin = document.getElementById('chatWindow');
        if (chatWin) {
            chatWin.scrollTop = chatWin.scrollHeight;
        }
    </script>
</body>
</html>
