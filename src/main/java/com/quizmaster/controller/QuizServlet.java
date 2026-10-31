package com.quizmaster.controller;

import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.ResultDAO;
import com.quizmaster.model.Attempt;
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

@WebServlet("/quizzes")
public class QuizServlet extends HttpServlet {

    private final QuizDAO quizDAO = new QuizDAO();
    private final ResultDAO resultDAO = new ResultDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String search = request.getParameter("search");
        String category = request.getParameter("category");

        List<com.quizmaster.model.Quiz> quizzes = quizDAO.searchPublishedQuizzes(search, category);
        List<String> categories = quizDAO.getAllCategories();

        // Get recent results for this student
        int studentId = (Integer) session.getAttribute("studentId");
        List<Result> recentResults = resultDAO.getResultsByStudentId(studentId);

        request.setAttribute("quizzes", quizzes);
        request.setAttribute("categories", categories);
        request.setAttribute("recentResults", recentResults);
        request.setAttribute("searchQuery", search);
        request.setAttribute("selectedCategory", category);

        request.getRequestDispatcher("quizzes.jsp").forward(request, response);
    }
}