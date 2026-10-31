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

@WebServlet("/addQuestion")
public class AddQuestionServlet extends HttpServlet {

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

        request.getRequestDispatcher("add-question.jsp?quizId=" + quizIdParam).forward(request, response);
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
        if (quizIdParam == null || quizIdParam.trim().isEmpty()) {
            response.sendRedirect("admin-quizzes");
            return;
        }

        int quizId;
        try {
            quizId = Integer.parseInt(quizIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("admin-quizzes");
            return;
        }

        Quiz quiz = quizDAO.getQuizById(quizId);
        if (quiz == null) {
            response.sendRedirect("admin-quizzes");
            return;
        }

        String questionText = request.getParameter("questionText");
        String optionA = request.getParameter("optionA");
        String optionB = request.getParameter("optionB");
        String optionC = request.getParameter("optionC");
        String optionD = request.getParameter("optionD");
        String correctOption = request.getParameter("correctOption");
        String marksParam = request.getParameter("marks");
        String explanation = request.getParameter("explanation");

        // Server-side validation
        if (questionText == null || questionText.trim().isEmpty() ||
                optionA == null || optionA.trim().isEmpty() ||
                optionB == null || optionB.trim().isEmpty() ||
                optionC == null || optionC.trim().isEmpty() ||
                optionD == null || optionD.trim().isEmpty() ||
                correctOption == null || correctOption.trim().isEmpty()) {

            request.setAttribute("error", "All fields (Question, Options A-D, and Correct Option) are required.");
            request.getRequestDispatcher("add-question.jsp?quizId=" + quizId).forward(request, response);
            return;
        }

        correctOption = correctOption.trim().toUpperCase();
        if (!correctOption.matches("[ABCD]")) {
            request.setAttribute("error", "Correct Option must be one of A, B, C, or D.");
            request.getRequestDispatcher("add-question.jsp?quizId=" + quizId).forward(request, response);
            return;
        }

        int marks = 1;
        try {
            if (marksParam != null && !marksParam.trim().isEmpty()) {
                marks = Integer.parseInt(marksParam.trim());
            }
        } catch (NumberFormatException e) {
            marks = 1;
        }

        if (marks <= 0) {
            request.setAttribute("error", "Marks per question must be greater than zero.");
            request.getRequestDispatcher("add-question.jsp?quizId=" + quizId).forward(request, response);
            return;
        }

        Question question = new Question(
                0,
                quizId,
                questionText.trim(),
                optionA.trim(),
                optionB.trim(),
                optionC.trim(),
                optionD.trim(),
                correctOption,
                marks,
                explanation != null ? explanation.trim() : null
        );

        boolean success = questionDAO.addQuestion(question);

        if (success) {
            // Recalculate marks sum directly from database
            int newCount = quizDAO.getQuestionCount(quizId);
            int newMarksSum = quizDAO.getQuestionMarksSum(quizId);
            int totalMarks = quiz.getTotalMarks();

            String message;
            if (newMarksSum == totalMarks) {
                message = "Question added! Total questions: " + newCount + ". Total marks reached (" +
                        newMarksSum + "/" + totalMarks + " marks). Quiz is ready to be published!";
            } else if (newMarksSum < totalMarks) {
                int needed = totalMarks - newMarksSum;
                message = "Question added! Total questions: " + newCount + ". Current marks: " +
                        newMarksSum + "/" + totalMarks + " marks (" + needed + " more marks needed to publish).";
            } else {
                int excess = newMarksSum - totalMarks;
                message = "Question added! Total questions: " + newCount + ". Current marks: " +
                        newMarksSum + "/" + totalMarks + " marks (" + excess + " marks over configured total).";
            }

            session.setAttribute("questionSuccess", message);
            response.sendRedirect("add-question.jsp?quizId=" + quizId);

        } else {
            request.setAttribute("error", "Unable to save question to database. Please try again.");
            request.getRequestDispatcher("add-question.jsp?quizId=" + quizId).forward(request, response);
        }
    }
}