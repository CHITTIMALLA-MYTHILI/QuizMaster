package com.quizmaster.controller;

import com.quizmaster.dao.AnswerDAO;
import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.QuestionDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.ResultDAO;
import com.quizmaster.model.Answer;
import com.quizmaster.model.Attempt;
import com.quizmaster.model.Question;
import com.quizmaster.model.Quiz;
import com.quizmaster.model.Result;

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

@WebServlet("/view-result")
public class ViewResultServlet extends HttpServlet {

    private final ResultDAO resultDAO = new ResultDAO();
    private final QuizDAO quizDAO = new QuizDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();
    private final AnswerDAO answerDAO = new AnswerDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String resultIdParam = request.getParameter("resultId");
        if (resultIdParam == null) {
            response.sendRedirect("results");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");

        try {
            int resultId = Integer.parseInt(resultIdParam);
            Result result = resultDAO.getResultById(resultId);

            if (result == null) {
                response.sendRedirect("results");
                return;
            }

            // Security: only the student who took this attempt can view it
            if (result.getStudentId() != studentId) {
                response.sendRedirect("results");
                return;
            }

            Quiz quiz = quizDAO.getQuizById(result.getQuizId());
            List<Question> questions = questionDAO.getQuestionsByQuizId(result.getQuizId());
            List<Answer> answers = answerDAO.getAnswersByAttemptId(result.getAttemptId());

            Map<Integer, Answer> answerMap = new HashMap<>();
            for (Answer a : answers) {
                answerMap.put(a.getQuestionId(), a);
            }

            request.setAttribute("result", result);
            request.setAttribute("quiz", quiz);
            request.setAttribute("questions", questions);
            request.setAttribute("answerMap", answerMap);

            request.getRequestDispatcher("view-result.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect("results");
        }
    }
}
