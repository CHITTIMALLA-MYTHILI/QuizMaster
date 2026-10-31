package com.quizmaster.controller;

import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.QuestionDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.model.Attempt;
import com.quizmaster.model.Question;
import com.quizmaster.model.Quiz;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/exam")
public class ExamServlet extends HttpServlet {

    private final QuestionDAO questionDAO = new QuestionDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final QuizDAO quizDAO = new QuizDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String quizIdParam = request.getParameter("quizId");
        if (quizIdParam == null) {
            response.sendRedirect("quizzes");
            return;
        }

        int quizId;
        try {
            quizId = Integer.parseInt(quizIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("quizzes");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");

        Quiz quiz = quizDAO.getQuizById(quizId);
        if (quiz == null || !quiz.isPublished()) {
            response.sendRedirect("quizzes");
            return;
        }

        // Check if there is already an in-progress attempt (resume scenario)
        Attempt existingAttempt = attemptDAO.getActiveAttempt(studentId, quizId);

        int attemptId;
        if (existingAttempt != null) {
            // Resume existing attempt
            attemptId = existingAttempt.getAttemptId();
        } else {
            // Create new attempt
            attemptId = attemptDAO.createAttempt(studentId, quizId);
            if (attemptId == -1) {
                request.setAttribute("error", "Unable to start quiz. Please try again.");
                request.getRequestDispatcher("instructions.jsp?quizId=" + quizId).forward(request, response);
                return;
            }
        }

        // Store attempt ID in session
        session.setAttribute("attemptId", attemptId);
        session.setAttribute("currentQuizId", quizId);

        // Get quiz questions
        List<Question> questions = questionDAO.getQuestionsByQuizId(quizId);

        if (questions == null || questions.isEmpty()) {
            response.sendRedirect("quizzes");
            return;
        }

        // Calculate remaining time based on server start time
        Attempt attempt = attemptDAO.getAttemptById(attemptId);
        long startTimeMillis = (attempt != null && attempt.getStartTime() != null)
                ? attempt.getStartTime().getTime() : System.currentTimeMillis();
        long elapsedSeconds = (System.currentTimeMillis() - startTimeMillis) / 1000;
        long allowedSeconds = (long) quiz.getDuration() * 60;
        long remainingSeconds = Math.max(0, allowedSeconds - elapsedSeconds);

        request.setAttribute("questions", questions);
        request.setAttribute("quizId", quizId);
        request.setAttribute("quiz", quiz);
        request.setAttribute("attemptId", attemptId);
        request.setAttribute("remainingSeconds", remainingSeconds);
        request.setAttribute("startTimeMillis", startTimeMillis);

        request.getRequestDispatcher("exam.jsp").forward(request, response);
    }
}