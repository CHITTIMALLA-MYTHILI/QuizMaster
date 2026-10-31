package com.quizmaster.controller;

import com.quizmaster.ai.AIConfig;
import com.quizmaster.ai.AIStudyAssistantService;
import com.quizmaster.dao.StudentPracticeQuizDAO;
import com.quizmaster.dao.StudentSummaryDAO;
import com.quizmaster.model.StudentPracticeAttempt;
import com.quizmaster.model.StudentPracticeQuestion;
import com.quizmaster.model.StudentPracticeQuiz;
import com.quizmaster.model.StudentSummary;
import com.quizmaster.util.FileTextExtractor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/ai-study-assistant")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1 MB
        maxFileSize = 10 * 1024 * 1024,       // 10 MB
        maxRequestSize = 25 * 1024 * 1024     // 25 MB
)
public class AIStudyAssistantServlet extends HttpServlet {

    private final StudentSummaryDAO summaryDAO = new StudentSummaryDAO();
    private final StudentPracticeQuizDAO practiceQuizDAO = new StudentPracticeQuizDAO();
    private final AIStudyAssistantService aiService = new AIStudyAssistantService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");
        String action = request.getParameter("action");

        if ("viewSummary".equalsIgnoreCase(action)) {
            String summaryIdParam = request.getParameter("summaryId");
            if (summaryIdParam != null) {
                try {
                    int summaryId = Integer.parseInt(summaryIdParam);
                    StudentSummary summary = summaryDAO.getSummaryById(summaryId, studentId);
                    if (summary != null) {
                        request.setAttribute("currentSummary", summary);
                    }
                } catch (NumberFormatException ignored) {}
            }
        } else if ("deleteSummary".equalsIgnoreCase(action)) {
            String summaryIdParam = request.getParameter("summaryId");
            if (summaryIdParam != null) {
                try {
                    summaryDAO.deleteSummary(Integer.parseInt(summaryIdParam), studentId);
                    request.getSession().setAttribute("assistantSuccess", "Summary deleted successfully.");
                } catch (NumberFormatException ignored) {}
            }
            response.sendRedirect("ai-study-assistant");
            return;
        }

        loadHistoryAndForward(request, response, studentId);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            if (isJsonRequest(request)) {
                sendJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED, false, "Your session has expired. Please log in again.", null);
                return;
            }
            response.sendRedirect("login.jsp");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");
        String action = request.getParameter("action");
        boolean jsonRequested = isJsonRequest(request);

        // Check if API key is configured
        if (!AIConfig.isConfigured()) {
            String error = "The AI service is not configured on the server. Please ensure the QUIZMASTER_AI_API_KEY environment variable is defined.";
            if (jsonRequested) {
                sendJsonResponse(response, HttpServletResponse.SC_OK, false, error, null);
                return;
            }
            request.setAttribute("errorMessage", error);
            loadHistoryAndForward(request, response, studentId);
            return;
        }

        // Extract text from uploaded file or pasted textarea
        String extractedText = "";
        String sourceFileName = null;
        String sourceType = "Pasted Text";

        try {
            Part filePart = null;
            try {
                filePart = request.getPart("studyFile");
            } catch (Exception ignored) {}

            if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().trim().isEmpty()) {
                FileTextExtractor.ExtractionResult res = FileTextExtractor.extractText(filePart);
                extractedText = res.getText();
                sourceFileName = res.getFileName();
                sourceType = res.getFileType() + " Upload";
            }
        } catch (Exception e) {
            String errorMsg = "Document extraction failed: " + e.getMessage();
            if (jsonRequested) {
                sendJsonResponse(response, HttpServletResponse.SC_OK, false, errorMsg, null);
                return;
            }
            request.setAttribute("errorMessage", errorMsg);
            loadHistoryAndForward(request, response, studentId);
            return;
        }

        String pastedText = request.getParameter("pastedText");
        if ((extractedText == null || extractedText.trim().isEmpty()) && pastedText != null && !pastedText.trim().isEmpty()) {
            extractedText = pastedText.trim();
            sourceType = "Pasted Text";
        }

        if (extractedText == null || extractedText.trim().length() < 20) {
            String errorMsg = "Please upload a valid document (.pdf, .docx, .txt) or paste study material containing at least 20 characters.";
            if (jsonRequested) {
                sendJsonResponse(response, HttpServletResponse.SC_OK, false, errorMsg, null);
                return;
            }
            request.setAttribute("errorMessage", errorMsg);
            loadHistoryAndForward(request, response, studentId);
            return;
        }

        String title = request.getParameter("materialTitle");
        if (title == null || title.trim().isEmpty()) {
            if (sourceFileName != null && !sourceFileName.trim().isEmpty()) {
                title = sourceFileName.replaceFirst("[.][^.]+$", "");
            } else {
                title = "Study Notes - " + (extractedText.length() > 30 ? extractedText.substring(0, 30).trim() + "..." : extractedText.trim());
            }
        }

        // Action 1: Summarize Material
        if ("summarize".equalsIgnoreCase(action)) {
            String summaryType = request.getParameter("summaryType");
            if (summaryType == null || summaryType.trim().isEmpty()) {
                summaryType = "quick";
            }

            try {
                String aiSummary = aiService.generateSummary(extractedText, summaryType);

                StudentSummary summary = new StudentSummary();
                summary.setStudentId(studentId);
                summary.setTitle(title.trim());
                summary.setSummaryType(summaryType);
                summary.setSourceType(sourceType);
                summary.setFileName(sourceFileName);
                summary.setContentSummary(aiSummary);

                int savedId = summaryDAO.saveSummary(summary);
                summary.setSummaryId(savedId);

                if (jsonRequested) {
                    String extra = String.format("\"summaryId\":%d,\"title\":\"%s\",\"summaryType\":\"%s\",\"content\":%s",
                            savedId, escapeJson(title.trim()), escapeJson(summaryType), escapeJson(aiSummary));
                    sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Summary generated successfully!", extra);
                    return;
                }

                request.setAttribute("currentSummary", summary);
                request.setAttribute("successMessage", "Summary generated and saved successfully!");
            } catch (Exception e) {
                e.printStackTrace();
                String err = "AI Summarization Error: " + e.getMessage();
                if (jsonRequested) {
                    sendJsonResponse(response, HttpServletResponse.SC_OK, false, err, null);
                    return;
                }
                request.setAttribute("errorMessage", err);
            }

            loadHistoryAndForward(request, response, studentId);
            return;
        }

        // Action 2: Generate Practice Quiz
        if ("generateQuiz".equalsIgnoreCase(action)) {
            int numQuestions = 5;
            try {
                numQuestions = Integer.parseInt(request.getParameter("numQuestions"));
            } catch (Exception ignored) {}

            String difficulty = request.getParameter("difficulty");
            if (difficulty == null || difficulty.trim().isEmpty()) difficulty = "Medium";

            String questionType = request.getParameter("questionType");
            if (questionType == null || questionType.trim().isEmpty()) questionType = "MCQ";

            try {
                List<StudentPracticeQuestion> questions = aiService.generatePracticeQuiz(extractedText, numQuestions, difficulty, questionType);

                StudentPracticeQuiz quiz = new StudentPracticeQuiz();
                quiz.setStudentId(studentId);
                quiz.setTitle("Practice: " + title.trim());
                quiz.setQuestionCount(questions.size());
                quiz.setDifficulty(difficulty);
                quiz.setQuestionType(questionType);

                int generatedQuizId = practiceQuizDAO.savePracticeQuiz(quiz, questions);

                if (generatedQuizId > 0) {
                    String redirectUrl = "ai-practice-quiz?action=review&quizId=" + generatedQuizId;
                    if (jsonRequested) {
                        String extra = String.format("\"quizId\":%d,\"questionCount\":%d,\"redirectUrl\":\"%s\"",
                                generatedQuizId, questions.size(), redirectUrl);
                        sendJsonResponse(response, HttpServletResponse.SC_OK, true, "Practice quiz generated successfully!", extra);
                        return;
                    }
                    response.sendRedirect(redirectUrl);
                    return;
                } else {
                    String err = "Failed to save generated practice quiz to database.";
                    if (jsonRequested) {
                        sendJsonResponse(response, HttpServletResponse.SC_OK, false, err, null);
                        return;
                    }
                    request.setAttribute("errorMessage", err);
                }
            } catch (Exception e) {
                e.printStackTrace();
                String err = "AI Practice Quiz Generation Error: " + e.getMessage();
                if (jsonRequested) {
                    sendJsonResponse(response, HttpServletResponse.SC_OK, false, err, null);
                    return;
                }
                request.setAttribute("errorMessage", err);
            }

            loadHistoryAndForward(request, response, studentId);
            return;
        }

        loadHistoryAndForward(request, response, studentId);
    }

    private boolean isJsonRequest(HttpServletRequest request) {
        String accept = request.getHeader("Accept");
        String format = request.getParameter("format");
        String xReq = request.getHeader("X-Requested-With");
        return (accept != null && accept.contains("application/json")) ||
               "json".equalsIgnoreCase(format) ||
               "XMLHttpRequest".equalsIgnoreCase(xReq) ||
               xReq != null;
    }

    private void sendJsonResponse(HttpServletResponse response, int statusCode, boolean success, String message, String extraJsonFields) throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":").append(success).append(",");
        if (success) {
            json.append("\"message\":\"").append(escapeJson(message)).append("\"");
        } else {
            json.append("\"error\":\"").append(escapeJson(message)).append("\"");
        }

        if (extraJsonFields != null && !extraJsonFields.trim().isEmpty()) {
            json.append(",").append(extraJsonFields);
        }
        json.append("}");

        PrintWriter out = response.getWriter();
        out.print(json.toString());
        out.flush();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (char c : s.toCharArray()) {
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\b': sb.append("\\b"); break;
                case '\f': sb.append("\\f"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < ' ') {
                        String t = "000" + Integer.toHexString(c);
                        sb.append("\\u").append(t.substring(t.length() - 4));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.toString();
    }

    private void loadHistoryAndForward(HttpServletRequest request, HttpServletResponse response, int studentId)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String sessionSuccess = (String) session.getAttribute("assistantSuccess");
        if (sessionSuccess != null) {
            request.setAttribute("successMessage", sessionSuccess);
            session.removeAttribute("assistantSuccess");
        }

        List<StudentSummary> summaries = summaryDAO.getSummariesByStudentId(studentId);
        List<StudentPracticeAttempt> recentAttempts = practiceQuizDAO.getRecentAttemptsByStudentId(studentId);
        List<StudentPracticeQuiz> recentQuizzes = practiceQuizDAO.getRecentQuizzesByStudentId(studentId);

        request.setAttribute("summaries", summaries);
        request.setAttribute("recentAttempts", recentAttempts);
        request.setAttribute("recentQuizzes", recentQuizzes);

        request.getRequestDispatcher("ai-study-assistant.jsp").forward(request, response);
    }
}
