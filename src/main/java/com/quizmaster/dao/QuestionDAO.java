package com.quizmaster.dao;

import com.quizmaster.model.Question;
import com.quizmaster.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class QuestionDAO {

    private final QuizDAO quizDAO = new QuizDAO();

    // ==========================================
    // GET QUESTIONS BY QUIZ ID
    // ==========================================
    public List<Question> getQuestionsByQuizId(int quizId) {
        List<Question> questions = new ArrayList<>();
        String sql = "SELECT question_id, quiz_id, question_text, option_a, " +
                "option_b, option_c, option_d, correct_option, marks, explanation " +
                "FROM questions WHERE quiz_id = ? ORDER BY question_id ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Question q = extractQuestionFromResultSet(rs);
                    questions.add(q);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return questions;
    }

    // ==========================================
    // GET QUESTION BY ID
    // ==========================================
    public Question getQuestionById(int questionId) {
        String sql = "SELECT question_id, quiz_id, question_text, option_a, " +
                "option_b, option_c, option_d, correct_option, marks, explanation " +
                "FROM questions WHERE question_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractQuestionFromResultSet(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ==========================================
    // ADD QUESTION (SUPPORTS VARIABLE MARKS & EXPLANATION)
    // ==========================================
    public boolean addQuestion(
            int quizId,
            String questionText,
            String optionA,
            String optionB,
            String optionC,
            String optionD,
            String correctOption,
            int marks) {

        return addQuestion(new Question(
                0, quizId, questionText, optionA, optionB, optionC, optionD,
                correctOption, marks, null
        ));
    }

    public boolean addQuestion(Question question) {
        String sql = "INSERT INTO questions " +
                "(quiz_id, question_text, option_a, option_b, option_c, option_d, " +
                "correct_option, marks, explanation) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, question.getQuizId());
            ps.setString(2, question.getQuestionText() != null ? question.getQuestionText().trim() : "");
            ps.setString(3, question.getOptionA() != null ? question.getOptionA().trim() : "");
            ps.setString(4, question.getOptionB() != null ? question.getOptionB().trim() : "");
            ps.setString(5, question.getOptionC() != null ? question.getOptionC().trim() : "");
            ps.setString(6, question.getOptionD() != null ? question.getOptionD().trim() : "");
            ps.setString(7, question.getCorrectOption() != null ? question.getCorrectOption().trim().toUpperCase() : "A");
            ps.setInt(8, Math.max(1, question.getMarks()));
            ps.setString(9, question.getExplanation() != null ? question.getExplanation().trim() : null);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                // Synchronize question count in quizzes table
                quizDAO.syncQuizQuestionCount(question.getQuizId());
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // UPDATE QUESTION
    // ==========================================
    public boolean updateQuestion(Question question) {
        String sql = "UPDATE questions SET " +
                "question_text = ?, option_a = ?, option_b = ?, option_c = ?, " +
                "option_d = ?, correct_option = ?, marks = ?, explanation = ? " +
                "WHERE question_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, question.getQuestionText() != null ? question.getQuestionText().trim() : "");
            ps.setString(2, question.getOptionA() != null ? question.getOptionA().trim() : "");
            ps.setString(3, question.getOptionB() != null ? question.getOptionB().trim() : "");
            ps.setString(4, question.getOptionC() != null ? question.getOptionC().trim() : "");
            ps.setString(5, question.getOptionD() != null ? question.getOptionD().trim() : "");
            ps.setString(6, question.getCorrectOption() != null ? question.getCorrectOption().trim().toUpperCase() : "A");
            ps.setInt(7, Math.max(1, question.getMarks()));
            ps.setString(8, question.getExplanation() != null ? question.getExplanation().trim() : null);
            ps.setInt(9, question.getQuestionId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // DELETE QUESTION
    // ==========================================
    public boolean deleteQuestion(int questionId) {
        Question q = getQuestionById(questionId);
        if (q == null) {
            return false;
        }

        String sql = "DELETE FROM questions WHERE question_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, questionId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                quizDAO.syncQuizQuestionCount(q.getQuizId());
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // GET QUESTION COUNT BY QUIZ ID
    // ==========================================
    public int getQuestionCountByQuizId(int quizId) {
        return quizDAO.getQuestionCount(quizId);
    }

    // ==========================================
    // GET TOTAL MARKS FOR QUIZ
    // ==========================================
    public int getTotalMarksForQuiz(int quizId) {
        return quizDAO.getQuestionMarksSum(quizId);
    }

    private Question extractQuestionFromResultSet(ResultSet rs) throws Exception {
        Question q = new Question();
        q.setQuestionId(rs.getInt("question_id"));
        q.setQuizId(rs.getInt("quiz_id"));
        q.setQuestionText(rs.getString("question_text"));
        q.setOptionA(rs.getString("option_a"));
        q.setOptionB(rs.getString("option_b"));
        q.setOptionC(rs.getString("option_c"));
        q.setOptionD(rs.getString("option_d"));
        q.setCorrectOption(rs.getString("correct_option"));
        q.setMarks(rs.getInt("marks"));

        try {
            q.setExplanation(rs.getString("explanation"));
        } catch (Exception ignored) {
        }
        return q;
    }
}