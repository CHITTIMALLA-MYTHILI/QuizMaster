package com.quizmaster.controller;

import com.quizmaster.dao.QuizDAO;
import com.quizmaster.model.Quiz;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/editQuiz")
public class EditQuizServlet extends HttpServlet {

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
        if (quizIdParam == null) {
            response.sendRedirect("admin-quizzes");
            return;
        }

        try {
            int quizId = Integer.parseInt(quizIdParam);
            Quiz quiz = quizDAO.getQuizById(quizId);
            if (quiz == null) {
                response.sendRedirect("admin-quizzes");
                return;
            }

            request.setAttribute("quiz", quiz);
            request.setAttribute("categories", quizDAO.getAllCategories());
            request.setAttribute("currentMarksSum", quizDAO.getQuestionMarksSum(quizId));
            request.setAttribute("questionCount", quizDAO.getQuestionCount(quizId));
            request.getRequestDispatcher("edit-quiz.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("admin-quizzes");
        }
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

        String quizIdParam = request.getParameter("quizId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String durationParam = request.getParameter("duration");
        String totalMarksParam = request.getParameter("totalMarks");

        int quizId;
        int duration;
        int totalMarks;

        try {
            quizId = Integer.parseInt(quizIdParam);
            duration = Integer.parseInt(durationParam);
            totalMarks = Integer.parseInt(totalMarksParam);
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Invalid quiz form inputs.");
            response.sendRedirect("admin-quizzes");
            return;
        }

        if (title == null || title.trim().isEmpty() || duration <= 0 || totalMarks <= 0) {
            session.setAttribute("errorMessage", "Title, positive duration, and positive total marks are required.");
            response.sendRedirect("editQuiz?quizId=" + quizId);
            return;
        }

        Quiz existingQuiz = quizDAO.getQuizById(quizId);
        if (existingQuiz == null) {
            response.sendRedirect("admin-quizzes");
            return;
        }

        boolean updated = quizDAO.updateQuiz(quizId, title.trim(), description != null ? description.trim() : "",
                category != null ? category.trim() : "General", duration, totalMarks);

        if (updated) {
            // Check if marks sum still equals totalMarks
            int marksSum = quizDAO.getQuestionMarksSum(quizId);
            if (existingQuiz.isPublished() && marksSum != totalMarks) {
                // Revert to draft because totalMarks changed and doesn't match question marks
                quizDAO.unpublishQuiz(quizId);
                session.setAttribute("errorMessage",
                        "Quiz details updated. However, the questions total (" + marksSum +
                                " marks) does not match the new quiz total (" + totalMarks +
                                " marks). The quiz has been reverted to Draft until questions are adjusted.");
            } else {
                session.setAttribute("successMessage", "Quiz details updated successfully.");
            }
        } else {
            session.setAttribute("errorMessage", "Failed to update quiz in database.");
        }

        response.sendRedirect("admin-quizzes");
    }
}
