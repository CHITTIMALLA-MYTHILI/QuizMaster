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

@WebServlet("/editQuestion")
public class EditQuestionServlet extends HttpServlet {

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

        String questionIdParam = request.getParameter("questionId");
        if (questionIdParam == null) {
            response.sendRedirect("admin-quizzes");
            return;
        }

        try {
            int questionId = Integer.parseInt(questionIdParam);
            Question question = questionDAO.getQuestionById(questionId);
            if (question == null) {
                response.sendRedirect("admin-quizzes");
                return;
            }

            Quiz quiz = quizDAO.getQuizById(question.getQuizId());
            request.setAttribute("question", question);
            request.setAttribute("quiz", quiz);
            request.getRequestDispatcher("edit-question.jsp").forward(request, response);

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

        String questionIdParam = request.getParameter("questionId");
        String quizIdParam = request.getParameter("quizId");
        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctOption = request.getParameter("correctOption");
        String marksParam = request.getParameter("marks");
        String explanation = request.getParameter("explanation");

        int questionId;
        int quizId;
        int marks = 1;

        try {
            questionId = Integer.parseInt(questionIdParam);
            quizId = Integer.parseInt(quizIdParam);
            marks = Integer.parseInt(marksParam);
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Invalid inputs for question editing.");
            response.sendRedirect("admin-quizzes");
            return;
        }

        if (questionText == null || questionText.trim().isEmpty() ||
                optionA == null || optionA.trim().isEmpty() ||
                optionB == null || optionB.trim().isEmpty() ||
                optionC == null || optionC.trim().isEmpty() ||
                optionD == null || optionD.trim().isEmpty() ||
                correctOption == null || marks <= 0) {

            session.setAttribute("errorMessage", "All options and positive marks are required.");
            response.sendRedirect("editQuestion?questionId=" + questionId);
            return;
        }

        Question q = new Question(
                questionId,
                quizId,
                questionText.trim(),
                optionA.trim(),
                optionB.trim(),
                optionC.trim(),
                optionD.trim(),
                correctOption.trim().toUpperCase(),
                marks,
                explanation != null ? explanation.trim() : null
        );

        boolean updated = questionDAO.updateQuestion(q);
        if (updated) {
            Quiz quiz = quizDAO.getQuizById(quizId);
            int newMarksSum = quizDAO.getQuestionMarksSum(quizId);
            if (quiz != null && quiz.isPublished() && newMarksSum != quiz.getTotalMarks()) {
                quizDAO.unpublishQuiz(quizId);
                session.setAttribute("errorMessage",
                        "Question updated. However, the questions total (" + newMarksSum +
                                " marks) no longer matches quiz total (" + quiz.getTotalMarks() +
                                " marks). Quiz was reverted to Draft.");
            } else {
                session.setAttribute("successMessage", "Question updated successfully.");
            }
        } else {
            session.setAttribute("errorMessage", "Failed to update question.");
        }

        response.sendRedirect("admin-questions?quizId=" + quizId);
    }
}
