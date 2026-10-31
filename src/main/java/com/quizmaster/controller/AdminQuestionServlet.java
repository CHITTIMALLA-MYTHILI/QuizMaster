package com.quizmaster.controller;

import com.quizmaster.dao.QuestionDAO;
import com.quizmaster.dao.QuizDAO;
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

@WebServlet("/admin-questions")
public class AdminQuestionServlet extends HttpServlet {

    private final QuestionDAO questionDAO = new QuestionDAO();
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

            String action = request.getParameter("action");
            if ("delete".equalsIgnoreCase(action)) {
                String questionIdParam = request.getParameter("questionId");
                if (questionIdParam != null) {
                    int questionId = Integer.parseInt(questionIdParam);
                    boolean deleted = questionDAO.deleteQuestion(questionId);
                    if (deleted) {
                        // Check if quiz was published and total marks now mismatched
                        int marksSum = quizDAO.getQuestionMarksSum(quizId);
                        if (quiz.isPublished() && marksSum != quiz.getTotalMarks()) {
                            quizDAO.unpublishQuiz(quizId);
                            session.setAttribute("errorMessage",
                                    "Question deleted. Question marks sum (" + marksSum +
                                            ") no longer matches quiz total (" + quiz.getTotalMarks() +
                                            "). Quiz was reverted to Draft.");
                        } else {
                            session.setAttribute("successMessage", "Question deleted successfully.");
                        }
                    } else {
                        session.setAttribute("errorMessage", "Failed to delete question.");
                    }
                    response.sendRedirect("admin-questions?quizId=" + quizId);
                    return;
                }
            }

            List<Question> questions = questionDAO.getQuestionsByQuizId(quizId);
            int currentMarksSum = quizDAO.getQuestionMarksSum(quizId);

            request.setAttribute("quiz", quiz);
            request.setAttribute("questions", questions);
            request.setAttribute("currentMarksSum", currentMarksSum);

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

            request.getRequestDispatcher("admin-questions.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("admin-quizzes");
        }
    }
}
