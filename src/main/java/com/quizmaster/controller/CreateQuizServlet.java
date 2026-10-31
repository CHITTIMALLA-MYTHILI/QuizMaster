package com.quizmaster.controller;

import com.quizmaster.dao.QuizDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/createQuiz")
public class CreateQuizServlet extends HttpServlet {

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

        request.setAttribute("categories", quizDAO.getAllCategories());
        request.getRequestDispatcher("create-quiz.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminLoggedIn") == null) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        Integer adminIdObj = (Integer) session.getAttribute("adminId");
        int createdBy = (adminIdObj != null) ? adminIdObj : 1;

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String durationParam = request.getParameter("duration");
        String totalMarksParam = request.getParameter("totalMarks");

        if (title == null || title.trim().isEmpty()) {
            request.setAttribute("error", "Quiz title is required.");
            request.setAttribute("categories", quizDAO.getAllCategories());
            request.getRequestDispatcher("create-quiz.jsp").forward(request, response);
            return;
        }

        int duration;
        int totalMarks;

        try {
            duration = Integer.parseInt(durationParam != null ? durationParam.trim() : "0");
            totalMarks = Integer.parseInt(totalMarksParam != null ? totalMarksParam.trim() : "0");
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Duration and total marks must be valid positive numbers.");
            request.setAttribute("categories", quizDAO.getAllCategories());
            request.getRequestDispatcher("create-quiz.jsp").forward(request, response);
            return;
        }

        if (duration <= 0 || totalMarks <= 0) {
            request.setAttribute("error", "Duration and total marks must be greater than zero.");
            request.setAttribute("categories", quizDAO.getAllCategories());
            request.getRequestDispatcher("create-quiz.jsp").forward(request, response);
            return;
        }

        if (category == null || category.trim().isEmpty()) {
            category = "General";
        }

        // Create quiz in DRAFT status
        int quizId = quizDAO.createQuiz(
                title.trim(),
                description != null ? description.trim() : "",
                category.trim(),
                duration,
                totalMarks,
                createdBy
        );

        if (quizId != -1) {
            session.setAttribute("questionSuccess",
                    "Quiz '" + title.trim() + "' created successfully in Draft mode! Now add questions to reach the " + totalMarks + " total marks.");
            response.sendRedirect("add-question.jsp?quizId=" + quizId + "&newQuiz=true");
        } else {
            request.setAttribute("error", "Unable to create quiz. Please check database connectivity and try again.");
            request.setAttribute("categories", quizDAO.getAllCategories());
            request.getRequestDispatcher("create-quiz.jsp").forward(request, response);
        }
    }
}