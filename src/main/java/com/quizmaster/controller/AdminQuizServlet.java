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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin-quizzes")
public class AdminQuizServlet extends HttpServlet {

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

        String action = request.getParameter("action");
        String quizIdParam = request.getParameter("quizId");

        if (action != null && quizIdParam != null) {
            try {
                int quizId = Integer.parseInt(quizIdParam);

                if ("publish".equalsIgnoreCase(action)) {
                    String publishError = quizDAO.publishQuiz(quizId);
                    if (publishError == null) {
                        request.getSession().setAttribute("successMessage",
                                "Quiz published successfully! It is now visible to students.");
                    } else {
                        request.getSession().setAttribute("errorMessage", publishError);
                    }
                    response.sendRedirect("admin-quizzes");
                    return;

                } else if ("unpublish".equalsIgnoreCase(action)) {
                    quizDAO.unpublishQuiz(quizId);
                    request.getSession().setAttribute("successMessage",
                            "Quiz unpublished and set to Draft mode.");
                    response.sendRedirect("admin-quizzes");
                    return;

                } else if ("delete".equalsIgnoreCase(action)) {
                    boolean deleted = quizDAO.deleteQuiz(quizId);
                    if (deleted) {
                        request.getSession().setAttribute("successMessage",
                                "Quiz and associated records deleted successfully.");
                    } else {
                        request.getSession().setAttribute("errorMessage",
                                "Unable to delete quiz.");
                    }
                    response.sendRedirect("admin-quizzes");
                    return;
                }
            } catch (NumberFormatException e) {
                // Ignore and show list
            }
        }

        // List all quizzes
        List<Quiz> quizzes = quizDAO.getAllQuizzes();

        // Calculate marks sum and real question count map
        Map<Integer, Integer> marksSumMap = new HashMap<>();
        Map<Integer, Integer> questionCountMap = new HashMap<>();
        for (Quiz q : quizzes) {
            marksSumMap.put(q.getQuizId(), quizDAO.getQuestionMarksSum(q.getQuizId()));
            questionCountMap.put(q.getQuizId(), quizDAO.getQuestionCount(q.getQuizId()));
        }

        request.setAttribute("quizzes", quizzes);
        request.setAttribute("marksSumMap", marksSumMap);
        request.setAttribute("questionCountMap", questionCountMap);

        // Flash messages
        String success = (String) session.getAttribute("successMessage");
        if (success != null) {
            request.setAttribute("successMessage", success);
            session.removeAttribute("successMessage");
        }
        String error = (String) session.getAttribute("errorMessage");
        if (error != null) {
            request.setAttribute("errorMessage", error);
            session.removeAttribute("errorMessage");
        }

        request.getRequestDispatcher("admin-quizzes.jsp").forward(request, response);
    }
}
