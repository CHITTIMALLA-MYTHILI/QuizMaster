package com.quizmaster.controller;

import com.quizmaster.ai.AIDescriptiveEvaluatorService;
import com.quizmaster.dao.DescriptiveDAO;
import com.quizmaster.model.DescriptiveEvaluation;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/ai-evaluation-review")
public class AIEvaluationReviewServlet extends HttpServlet {

    private final DescriptiveDAO descriptiveDAO = new DescriptiveDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminLoggedIn") == null) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        List<DescriptiveEvaluation> evaluations = descriptiveDAO.getAllEvaluations();
        request.setAttribute("evaluations", evaluations);
        request.getRequestDispatcher("ai-evaluation-review.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminLoggedIn") == null) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        String evalIdParam = request.getParameter("evaluationId");
        String newMarksParam = request.getParameter("newMarks");
        String adminNotes = request.getParameter("adminNotes");

        if (evalIdParam != null && newMarksParam != null) {
            try {
                int evalId = Integer.parseInt(evalIdParam);
                int newMarks = Integer.parseInt(newMarksParam);
                descriptiveDAO.overrideEvaluation(evalId, newMarks, adminNotes != null ? adminNotes.trim() : "Approved by administrator");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("ai-evaluation-review");
    }
}
