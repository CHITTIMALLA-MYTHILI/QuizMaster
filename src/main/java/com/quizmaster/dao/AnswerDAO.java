package com.quizmaster.dao;

import com.quizmaster.model.Answer;
import com.quizmaster.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AnswerDAO {

    public boolean saveAnswer(
            int attemptId,
            int questionId,
            String selectedOption,
            boolean correct) {

        return saveOrUpdateAnswer(attemptId, questionId, selectedOption, correct);
    }

    public boolean saveOrUpdateAnswer(
            int attemptId,
            int questionId,
            String selectedOption,
            boolean correct) {

        String checkSql = "SELECT answer_id FROM answers WHERE attempt_id = ? AND question_id = ?";
        String updateSql = "UPDATE answers SET selected_option = ?, is_correct = ? WHERE attempt_id = ? AND question_id = ?";
        String insertSql = "INSERT INTO answers (attempt_id, question_id, selected_option, is_correct) VALUES (?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection()) {
            boolean exists = false;
            try (PreparedStatement checkPs = con.prepareStatement(checkSql)) {
                checkPs.setInt(1, attemptId);
                checkPs.setInt(2, questionId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                try (PreparedStatement updatePs = con.prepareStatement(updateSql)) {
                    updatePs.setString(1, selectedOption);
                    updatePs.setBoolean(2, correct);
                    updatePs.setInt(3, attemptId);
                    updatePs.setInt(4, questionId);
                    return updatePs.executeUpdate() > 0;
                }
            } else {
                try (PreparedStatement insertPs = con.prepareStatement(insertSql)) {
                    insertPs.setInt(1, attemptId);
                    insertPs.setInt(2, questionId);
                    insertPs.setString(3, selectedOption);
                    insertPs.setBoolean(4, correct);
                    return insertPs.executeUpdate() > 0;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public List<Answer> getAnswersByAttemptId(int attemptId) {
        List<Answer> answers = new ArrayList<>();
        String sql = "SELECT answer_id, attempt_id, question_id, selected_option, is_correct FROM answers WHERE attempt_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, attemptId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Answer a = new Answer();
                    a.setAnswerId(rs.getInt("answer_id"));
                    a.setAttemptId(rs.getInt("attempt_id"));
                    a.setQuestionId(rs.getInt("question_id"));
                    a.setSelectedOption(rs.getString("selected_option"));
                    a.setCorrect(rs.getBoolean("is_correct"));
                    answers.add(a);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return answers;
    }

    public Answer getAnswer(int attemptId, int questionId) {
        String sql = "SELECT answer_id, attempt_id, question_id, selected_option, is_correct FROM answers WHERE attempt_id = ? AND question_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, attemptId);
            ps.setInt(2, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Answer a = new Answer();
                    a.setAnswerId(rs.getInt("answer_id"));
                    a.setAttemptId(rs.getInt("attempt_id"));
                    a.setQuestionId(rs.getInt("question_id"));
                    a.setSelectedOption(rs.getString("selected_option"));
                    a.setCorrect(rs.getBoolean("is_correct"));
                    return a;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}