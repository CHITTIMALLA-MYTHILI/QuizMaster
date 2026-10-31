package com.quizmaster.controller;

import com.quizmaster.dao.StudentPracticeQuizDAO;
import com.quizmaster.model.StudentPracticeAttempt;
import com.quizmaster.model.StudentPracticeQuestion;
import com.quizmaster.model.StudentPracticeQuiz;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/ai-practice-quiz")
public class AIPracticeQuizServlet extends HttpServlet {

    private final StudentPracticeQuizDAO practiceQuizDAO = new StudentPracticeQuizDAO();

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
        if (action == null || action.trim().isEmpty()) {
            action = "review";
        }

        if ("result".equalsIgnoreCase(action)) {
            String attemptIdParam = request.getParameter("attemptId");
            if (attemptIdParam == null) {
                response.sendRedirect("ai-study-assistant");
                return;
            }

            try {
                int attemptId = Integer.parseInt(attemptIdParam);
                StudentPracticeAttempt attempt = practiceQuizDAO.getAttemptById(attemptId, studentId);
                if (attempt == null) {
                    response.sendRedirect("ai-study-assistant");
                    return;
                }

                StudentPracticeQuiz quiz = practiceQuizDAO.getQuizById(attempt.getQuizId(), studentId);
                request.setAttribute("attempt", attempt);
                request.setAttribute("quiz", quiz);

                // Fetch submitted answers from session if available
                @SuppressWarnings("unchecked")
                Map<Integer, String> userAnswers = (Map<Integer, String>) session.getAttribute("lastPracticeAnswers_" + attemptId);
                request.setAttribute("userAnswers", userAnswers);

                request.getRequestDispatcher("ai-practice-result.jsp").forward(request, response);
                return;
            } catch (NumberFormatException e) {
                response.sendRedirect("ai-study-assistant");
                return;
            }
        }

        // Review or Take
        String quizIdParam = request.getParameter("quizId");
        if (quizIdParam == null) {
            response.sendRedirect("ai-study-assistant");
            return;
        }

        try {
            int quizId = Integer.parseInt(quizIdParam);
            StudentPracticeQuiz quiz = practiceQuizDAO.getQuizById(quizId, studentId);

            if (quiz == null) {
                response.sendRedirect("ai-study-assistant");
                return;
            }

            request.setAttribute("quiz", quiz);
            request.setAttribute("viewMode", action); // "review" or "take"
            request.getRequestDispatcher("ai-practice-quiz.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect("ai-study-assistant");
        }
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
        String quizIdParam = request.getParameter("quizId");

        if (quizIdParam == null) {
            response.sendRedirect("ai-study-assistant");
            return;
        }

        try {
            int quizId = Integer.parseInt(quizIdParam);
            StudentPracticeQuiz quiz = practiceQuizDAO.getQuizById(quizId, studentId);
            if (quiz == null) {
                response.sendRedirect("ai-study-assistant");
                return;
            }

            List<StudentPracticeQuestion> questions = quiz.getQuestions();
            int totalMarks = questions.size();
            int score = 0;
            int correctCount = 0;
            int incorrectCount = 0;

            Map<Integer, String> userAnswers = new HashMap<>();
            StringBuilder topicsToRevise = new StringBuilder();

            for (StudentPracticeQuestion q : questions) {
                String chosen = request.getParameter("answer_" + q.getQuestionId());
                if (chosen != null) {
                    chosen = chosen.trim().toUpperCase();
                } else {
                    chosen = "";
                }
                userAnswers.put(q.getQuestionId(), chosen);

                if (q.getCorrectOption() != null && q.getCorrectOption().equalsIgnoreCase(chosen)) {
                    score++;
                    correctCount++;
                } else {
                    incorrectCount++;
                    // Build topic to revise note from question explanation
                    if (topicsToRevise.length() > 0) topicsToRevise.append("\n");
                    String note = "• " + q.getQuestionText() + " — Concept: " + (q.getExplanation() != null ? q.getExplanation() : "Review source material.");
                    topicsToRevise.append(note);
                }
            }

            double percentage = totalMarks > 0 ? ((double) score / totalMarks) * 100.0 : 0.0;
            percentage = Math.round(percentage * 10.0) / 10.0;

            String revisionNotes = topicsToRevise.toString();
            if (revisionNotes.isEmpty()) {
                revisionNotes = "Outstanding job! You answered all questions correctly. Keep up the great work!";
            }

            StudentPracticeAttempt attempt = new StudentPracticeAttempt();
            attempt.setQuizId(quizId);
            attempt.setStudentId(studentId);
            attempt.setScore(score);
            attempt.setTotalMarks(totalMarks);
            attempt.setPercentage(percentage);
            attempt.setCorrectCount(correctCount);
            attempt.setIncorrectCount(incorrectCount);
            attempt.setTopicsToRevise(revisionNotes);

            int attemptId = practiceQuizDAO.saveAttempt(attempt);

            if (attemptId > 0) {
                session.setAttribute("lastPracticeAnswers_" + attemptId, userAnswers);
                response.sendRedirect("ai-practice-quiz?action=result&attemptId=" + attemptId);
            } else {
                response.sendRedirect("ai-study-assistant");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("ai-study-assistant");
        }
    }
}
