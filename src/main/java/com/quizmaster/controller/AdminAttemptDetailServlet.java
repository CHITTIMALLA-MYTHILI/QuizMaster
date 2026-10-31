package com.quizmaster.controller;

import com.quizmaster.dao.AnswerDAO;
import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.QuestionDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.ResultDAO;
import com.quizmaster.dao.StudentDAO;
import com.quizmaster.model.Answer;
import com.quizmaster.model.Attempt;
import com.quizmaster.model.Question;
import com.quizmaster.model.Quiz;
import com.quizmaster.model.Result;
import com.quizmaster.model.Student;

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

@WebServlet("/admin-attempt-detail")
public class AdminAttemptDetailServlet extends HttpServlet {

    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final ResultDAO resultDAO = new ResultDAO();
    private final QuizDAO quizDAO = new QuizDAO();
    private final StudentDAO studentDAO = new StudentDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();
    private final AnswerDAO answerDAO = new AnswerDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminLoggedIn") == null) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        String attemptIdParam = request.getParameter("attemptId");
        if (attemptIdParam == null) {
            response.sendRedirect("admin-results");
            return;
        }

        try {
            int attemptId = Integer.parseInt(attemptIdParam);
            Attempt attempt = attemptDAO.getAttemptById(attemptId);
            if (attempt == null) {
                response.sendRedirect("admin-results");
                return;
            }

            Student student = studentDAO.getStudentById(attempt.getStudentId());
            Quiz quiz = quizDAO.getQuizById(attempt.getQuizId());
            Result result = resultDAO.getResultByAttemptId(attemptId);
            List<Question> questions = questionDAO.getQuestionsByQuizId(attempt.getQuizId());
            List<Answer> answers = answerDAO.getAnswersByAttemptId(attemptId);

            Map<Integer, Answer> answerMap = new HashMap<>();
            for (Answer a : answers) {
                answerMap.put(a.getQuestionId(), a);
            }

            request.setAttribute("attempt", attempt);
            request.setAttribute("student", student);
            request.setAttribute("quiz", quiz);
            request.setAttribute("result", result);
            request.setAttribute("questions", questions);
            request.setAttribute("answerMap", answerMap);

            request.getRequestDispatcher("admin-attempt-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("admin-results");
        }
    }
}
