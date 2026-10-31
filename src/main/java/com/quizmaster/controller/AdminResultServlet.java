package com.quizmaster.controller;

import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.ResultDAO;
import com.quizmaster.model.Quiz;
import com.quizmaster.model.Result;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin-results")
public class AdminResultServlet extends HttpServlet {

    private final ResultDAO resultDAO = new ResultDAO();
    private final QuizDAO quizDAO = new QuizDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminLoggedIn") == null) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        String quizIdParam = request.getParameter("quizId");
        Integer quizIdFilter = null;
        if (quizIdParam != null && !quizIdParam.trim().isEmpty()) {
            try {
                quizIdFilter = Integer.parseInt(quizIdParam.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        List<Result> results = resultDAO.getAllResults(quizIdFilter);
        List<Quiz> quizzes = quizDAO.getAllQuizzes();

        request.setAttribute("results", results);
        request.setAttribute("quizzes", quizzes);
        request.setAttribute("selectedQuizId", quizIdFilter);

        request.getRequestDispatcher("admin-results.jsp").forward(request, response);
    }
}
