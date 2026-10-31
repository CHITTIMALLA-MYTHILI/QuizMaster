package com.quizmaster.controller;

import com.quizmaster.ai.AIConfig;
import com.quizmaster.ai.LLMClient;
import com.quizmaster.dao.AITutorDAO;
import com.quizmaster.dao.StudyMaterialDAO;
import com.quizmaster.model.AITutorMessage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/ai-tutor")
public class AITutorServlet extends HttpServlet {

    private final AITutorDAO tutorDAO = new AITutorDAO();
    private final StudyMaterialDAO materialDAO = new StudyMaterialDAO();
    private final LLMClient llmClient = new LLMClient();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");
        List<AITutorMessage> history = tutorDAO.getRecentMessages(studentId, 20);

        request.setAttribute("history", history);
        request.setAttribute("aiConfigured", AIConfig.isConfigured());
        request.getRequestDispatcher("ai-tutor.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");
        String userQuery = request.getParameter("query");

        if (userQuery != null && !userQuery.trim().isEmpty()) {
            userQuery = userQuery.trim();

            if (!AIConfig.isConfigured()) {
                request.setAttribute("error", "The AI Study Tutor service is currently unavailable. Please ask your administrator to configure QUIZMASTER_AI_API_KEY.");
                doGet(request, response);
                return;
            }

            // Retrieve relevant passages for Grounded RAG
            List<String> relevantPassages = materialDAO.retrieveRelevantPassages(userQuery, 3);
            StringBuilder contextBuilder = new StringBuilder();
            if (!relevantPassages.isEmpty()) {
                contextBuilder.append("Relevant course study materials:\n");
                for (String p : relevantPassages) {
                    contextBuilder.append("---\n").append(p).append("\n");
                }
            }

            String systemPrompt = "You are QuizMaster AI Study Tutor. Help students learn, solve exam doubts, and understand core concepts.\n" +
                    "Explain concepts clearly with code examples where applicable.\n" +
                    "If study material is provided below, prefer grounding your explanation in it and cite the [Source: Title].\n" +
                    "Do not make up fake citations. If unsure, admit it and explain fundamentals clearly.";

            String combinedPrompt = contextBuilder.toString() + "\nStudent Question: " + userQuery;

            try {
                // Save user question
                tutorDAO.saveMessage(studentId, "user", userQuery, null);

                // Call LLM
                String aiReply = llmClient.generateCompletion(systemPrompt, combinedPrompt);

                // Save assistant answer
                String sources = relevantPassages.isEmpty() ? null : String.join(", ", relevantPassages);
                tutorDAO.saveMessage(studentId, "assistant", aiReply, sources);

            } catch (Exception e) {
                request.setAttribute("error", "AI Service Error: " + e.getMessage());
            }
        }

        response.sendRedirect("ai-tutor");
    }
}
