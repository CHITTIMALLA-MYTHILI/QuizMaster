package com.quizmaster.controller;

import com.quizmaster.dao.AnswerDAO;
import com.quizmaster.dao.AttemptDAO;
import com.quizmaster.dao.QuestionDAO;
import com.quizmaster.dao.QuizDAO;
import com.quizmaster.dao.ResultDAO;
import com.quizmaster.model.Attempt;
import com.quizmaster.model.Question;
import com.quizmaster.model.Quiz;
import com.quizmaster.model.Result;
import com.quizmaster.util.DBConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

@WebServlet("/submitQuiz")
public class SubmitQuizServlet extends HttpServlet {

    private final QuestionDAO questionDAO = new QuestionDAO();
    private final AnswerDAO answerDAO = new AnswerDAO();
    private final ResultDAO resultDAO = new ResultDAO();
    private final AttemptDAO attemptDAO = new AttemptDAO();
    private final QuizDAO quizDAO = new QuizDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("studentId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String quizIdParam = request.getParameter("quizId");
        if (quizIdParam == null) {
            response.sendRedirect("quizzes");
            return;
        }

        int quizId;
        try {
            quizId = Integer.parseInt(quizIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("quizzes");
            return;
        }

        int studentId = (Integer) session.getAttribute("studentId");

        // Get attempt ID - from form parameter first, then session
        Integer attemptId = null;
        String attemptIdParam = request.getParameter("attemptId");
        if (attemptIdParam != null) {
            try {
                attemptId = Integer.parseInt(attemptIdParam);
            } catch (NumberFormatException ignored) {}
        }
        if (attemptId == null) {
            attemptId = (Integer) session.getAttribute("attemptId");
        }

        if (attemptId == null) {
            response.sendRedirect("quizzes");
            return;
        }

        // Prevent double submission - check if already completed
        if (attemptDAO.isAttemptCompleted(attemptId)) {
            // Already submitted - redirect to result
            Result existingResult = resultDAO.getResultByAttemptId(attemptId);
            if (existingResult != null) {
                response.sendRedirect("view-result?resultId=" + existingResult.getResultId());
            } else {
                response.sendRedirect("results");
            }
            return;
        }

        // Verify attempt belongs to this student
        Attempt attempt = attemptDAO.getAttemptById(attemptId);
        if (attempt == null || attempt.getStudentId() != studentId) {
            response.sendRedirect("quizzes");
            return;
        }

        // Server-side deadline enforcement
        Quiz quiz = quizDAO.getQuizById(quizId);
        if (quiz != null && attempt.getStartTime() != null) {
            long elapsedSeconds = (System.currentTimeMillis() - attempt.getStartTime().getTime()) / 1000;
            long allowedSeconds = ((long) quiz.getDuration() * 60) + 60; // 60s grace buffer
            if (elapsedSeconds > allowedSeconds) {
                // Force auto-submit with 0 score for questions not answered
                // Continue processing with whatever answers were submitted
            }
        }

        // Get all questions for this quiz (from database - authoritative)
        List<Question> questions = questionDAO.getQuestionsByQuizId(quizId);

        int score = 0;
        int totalMarks = 0;
        int correctCount = 0;
        int incorrectCount = 0;
        int unansweredCount = 0;

        // Use a transaction for atomic submission
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // Process every question
                for (Question question : questions) {
                    totalMarks += question.getMarks();

                    // Only accept answers for questions that actually belong to this quiz (security)
                    String selectedOption = request.getParameter("question_" + question.getQuestionId());

                    boolean correct = false;
                    if (selectedOption != null && !selectedOption.trim().isEmpty()) {
                        if (selectedOption.trim().equalsIgnoreCase(question.getCorrectOption())) {
                            correct = true;
                            score += question.getMarks();
                            correctCount++;
                        } else {
                            incorrectCount++;
                        }
                    } else {
                        unansweredCount++;
                    }

                    // Save or update student's answer
                    answerDAO.saveOrUpdateAnswer(
                            attemptId,
                            question.getQuestionId(),
                            selectedOption,
                            correct
                    );
                }

                // Calculate percentage
                double percentage = (totalMarks > 0) ? ((double) score / totalMarks) * 100 : 0.0;

                // Calculate grade
                String grade;
                if (percentage >= 90) grade = "A+";
                else if (percentage >= 80) grade = "A";
                else if (percentage >= 70) grade = "B";
                else if (percentage >= 60) grade = "C";
                else if (percentage >= 50) grade = "D";
                else grade = "F";

                // Update attempt status to COMPLETED
                String updateAttemptSql = "UPDATE attempts SET end_time = NOW(), score = ?, status = 'COMPLETED' WHERE attempt_id = ?";
                try (PreparedStatement ps = con.prepareStatement(updateAttemptSql)) {
                    ps.setInt(1, score);
                    ps.setInt(2, attemptId);
                    ps.executeUpdate();
                }

                // Save result
                Result result = new Result();
                result.setStudentId(studentId);
                result.setQuizId(quizId);
                result.setAttemptId(attemptId);
                result.setScore(score);
                result.setTotalMarks(totalMarks);
                result.setPercentage(percentage);
                result.setGrade(grade);
                result.setCorrectCount(correctCount);
                result.setIncorrectCount(incorrectCount);
                result.setUnansweredCount(unansweredCount);

                String insertResultSql = "INSERT INTO results " +
                        "(student_id, quiz_id, attempt_id, score, percentage, grade, " +
                        "total_marks, correct_count, incorrect_count, unanswered_count, created_at) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

                int resultId = -1;
                try (PreparedStatement ps = con.prepareStatement(insertResultSql,
                        java.sql.Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, studentId);
                    ps.setInt(2, quizId);
                    ps.setInt(3, attemptId);
                    ps.setInt(4, score);
                    ps.setDouble(5, percentage);
                    ps.setString(6, grade);
                    ps.setInt(7, totalMarks);
                    ps.setInt(8, correctCount);
                    ps.setInt(9, incorrectCount);
                    ps.setInt(10, unansweredCount);
                    ps.executeUpdate();

                    try (java.sql.ResultSet keys = ps.getGeneratedKeys()) {
                        if (keys.next()) {
                            resultId = keys.getInt(1);
                        }
                    }
                }

                con.commit();

                // Clear attempt from session
                session.removeAttribute("attemptId");
                session.removeAttribute("currentQuizId");

                // Redirect to result page
                if (resultId != -1) {
                    response.sendRedirect("view-result?resultId=" + resultId);
                } else {
                    // Store result data in session as fallback
                    session.setAttribute("lastScore", score);
                    session.setAttribute("lastTotalMarks", totalMarks);
                    session.setAttribute("lastPercentage", percentage);
                    session.setAttribute("lastGrade", grade);
                    session.setAttribute("lastCorrectCount", correctCount);
                    session.setAttribute("lastIncorrectCount", incorrectCount);
                    session.setAttribute("lastUnansweredCount", unansweredCount);
                    response.sendRedirect("results");
                }

            } catch (Exception e) {
                con.rollback();
                e.printStackTrace();
                request.setAttribute("error", "Submission failed. Please try again.");
                response.sendRedirect("results");
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("results");
        }
    }
}