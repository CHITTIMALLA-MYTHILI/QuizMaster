package com.quizmaster.controller;

import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.ResultDAO;
import com.quizmaster.model.LeaderboardEntry;
import com.quizmaster.model.Quiz;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/leaderboard")
public class LeaderboardServlet extends HttpServlet {

    private final ResultDAO resultDAO = new ResultDAO();
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
        Integer quizIdFilter = null;
        if (quizIdParam != null && !quizIdParam.trim().isEmpty()) {
            try {
                quizIdFilter = Integer.parseInt(quizIdParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        List<LeaderboardEntry> entries;
        if (quizIdFilter != null) {
            entries = resultDAO.getLeaderboardByQuiz(quizIdFilter, 20);
        } else {
            entries = resultDAO.getLeaderboard(20);
        }

        List<Quiz> quizzes = quizDAO.getPublishedQuizzes();

        request.setAttribute("entries", entries);
        request.setAttribute("quizzes", quizzes);
        request.setAttribute("selectedQuizId", quizIdFilter);

        request.getRequestDispatcher("leaderboard.jsp").forward(request, response);
    }
}
