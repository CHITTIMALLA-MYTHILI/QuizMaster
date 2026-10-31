package com.quizmaster.controller;

import com.quizmaster.ai.AIConfig;
import com.quizmaster.ai.AIQuizGeneratorService;
import com.quizmaster.dao.AIQuestionDraftDAO;
import com.quizmaster.dao.QuestionDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.StudyMaterialDAO;
import com.quizmaster.model.AIQuestionDraft;
import com.quizmaster.model.Question;
import com.quizmaster.model.Quiz;
import com.quizmaster.model.StudyMaterial;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/ai-quiz-generator")
public class AIQuizGeneratorServlet extends HttpServlet {

    private final AIQuizGeneratorService generatorService = new AIQuizGeneratorService();
    private final AIQuestionDraftDAO draftDAO = new AIQuestionDraftDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();
    private final QuizDAO quizDAO = new QuizDAO();
    private final StudyMaterialDAO materialDAO = new StudyMaterialDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminLoggedIn") == null) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        String batchId = request.getParameter("batchId");
        if (batchId != null && !batchId.trim().isEmpty()) {
            List<AIQuestionDraft> drafts = draftDAO.getDraftsByBatchId(batchId.trim());
            request.setAttribute("drafts", drafts);
            request.setAttribute("batchId", batchId.trim());
        }

        List<Quiz> quizzes = quizDAO.getAllQuizzes();
        List<StudyMaterial> materials = materialDAO.getAllMaterials();

        request.setAttribute("quizzes", quizzes);
        request.setAttribute("materials", materials);
        request.setAttribute("aiConfigured", AIConfig.isConfigured());

        request.getRequestDispatcher("ai-quiz-generator.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminLoggedIn") == null) {
            response.sendRedirect("admin-login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("generate".equalsIgnoreCase(action)) {
            String topic = request.getParameter("topic");
            String studyMaterial = request.getParameter("studyMaterial");
            String numQuestionsParam = request.getParameter("numQuestions");
            String difficulty = request.getParameter("difficulty");
            String marksParam = request.getParameter("marksPerQuestion");

            int numQuestions = 5;
            int marksPerQuestion = 1;

            try {
                if (numQuestionsParam != null) numQuestions = Integer.parseInt(numQuestionsParam);
                if (marksParam != null) marksPerQuestion = Integer.parseInt(marksParam);
            } catch (Exception ignored) {}

            try {
                String batchId = generatorService.generateQuizDrafts(
                        topic != null ? topic.trim() : "General Knowledge",
                        studyMaterial,
                        numQuestions,
                        difficulty != null ? difficulty : "Medium",
                        marksPerQuestion
                );
                response.sendRedirect("ai-quiz-generator?batchId=" + batchId);
            } catch (Exception e) {
                request.setAttribute("error", "AI Generation Failed: " + e.getMessage());
                doGet(request, response);
            }

        } else if ("approve".equalsIgnoreCase(action)) {
            String draftIdParam = request.getParameter("draftId");
            String targetQuizIdParam = request.getParameter("targetQuizId");
            String batchId = request.getParameter("batchId");

            if (draftIdParam != null && targetQuizIdParam != null) {
                try {
                    int draftId = Integer.parseInt(draftIdParam);
                    int quizId = Integer.parseInt(targetQuizIdParam);

                    AIQuestionDraft draft = draftDAO.getDraftById(draftId);
                    if (draft != null) {
                        Question q = new Question(
                                0,
                                quizId,
                                draft.getQuestionText(),
                                draft.getOptionA(),
                                draft.getOptionB(),
                                draft.getOptionC(),
                                draft.getOptionD(),
                                draft.getCorrectOption(),
                                draft.getMarks(),
                                draft.getExplanation()
                        );
                        questionDAO.addQuestion(q);
                        draftDAO.updateStatus(draftId, "APPROVED");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect("ai-quiz-generator?batchId=" + (batchId != null ? batchId : ""));
        } else if ("deleteDraft".equalsIgnoreCase(action)) {
            String draftIdParam = request.getParameter("draftId");
            String batchId = request.getParameter("batchId");
            if (draftIdParam != null) {
                try {
                    draftDAO.deleteDraft(Integer.parseInt(draftIdParam));
                } catch (Exception ignored) {}
            }
            response.sendRedirect("ai-quiz-generator?batchId=" + (batchId != null ? batchId : ""));
        }
    }
}
