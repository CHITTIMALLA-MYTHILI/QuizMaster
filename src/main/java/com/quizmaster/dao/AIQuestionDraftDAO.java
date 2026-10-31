package com.quizmaster.dao;

import com.quizmaster.model.AIQuestionDraft;
import com.quizmaster.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AIQuestionDraftDAO {

    public boolean saveDraft(AIQuestionDraft draft) {
        String sql = "INSERT INTO ai_question_drafts " +
                "(batch_id, topic, question_text, option_a, option_b, option_c, option_d, correct_option, marks, difficulty, explanation, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, draft.getBatchId());
            ps.setString(2, draft.getTopic());
            ps.setString(3, draft.getQuestionText());
            ps.setString(4, draft.getOptionA());
            ps.setString(5, draft.getOptionB());
            ps.setString(6, draft.getOptionC());
            ps.setString(7, draft.getOptionD());
            ps.setString(8, draft.getCorrectOption());
            ps.setInt(9, draft.getMarks());
            ps.setString(10, draft.getDifficulty());
            ps.setString(11, draft.getExplanation());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        draft.setDraftId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<AIQuestionDraft> getDraftsByBatchId(String batchId) {
        List<AIQuestionDraft> list = new ArrayList<>();
        String sql = "SELECT * FROM ai_question_drafts WHERE batch_id = ? AND status = 'PENDING' ORDER BY draft_id ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, batchId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AIQuestionDraft d = new AIQuestionDraft(
                            rs.getInt("draft_id"),
                            rs.getString("batch_id"),
                            rs.getString("topic"),
                            rs.getString("question_text"),
                            rs.getString("option_a"),
                            rs.getString("option_b"),
                            rs.getString("option_c"),
                            rs.getString("option_d"),
                            rs.getString("correct_option"),
                            rs.getInt("marks"),
                            rs.getString("difficulty"),
                            rs.getString("explanation"),
                            rs.getString("status"),
                            rs.getTimestamp("created_at")
                    );
                    list.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public AIQuestionDraft getDraftById(int draftId) {
        String sql = "SELECT * FROM ai_question_drafts WHERE draft_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, draftId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new AIQuestionDraft(
                            rs.getInt("draft_id"),
                            rs.getString("batch_id"),
                            rs.getString("topic"),
                            rs.getString("question_text"),
                            rs.getString("option_a"),
                            rs.getString("option_b"),
                            rs.getString("option_c"),
                            rs.getString("option_d"),
                            rs.getString("correct_option"),
                            rs.getInt("marks"),
                            rs.getString("difficulty"),
                            rs.getString("explanation"),
                            rs.getString("status"),
                            rs.getTimestamp("created_at")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateDraft(AIQuestionDraft draft) {
        String sql = "UPDATE ai_question_drafts SET " +
                "question_text = ?, option_a = ?, option_b = ?, option_c = ?, option_d = ?, " +
                "correct_option = ?, marks = ?, difficulty = ?, explanation = ? " +
                "WHERE draft_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, draft.getQuestionText());
            ps.setString(2, draft.getOptionA());
            ps.setString(3, draft.getOptionB());
            ps.setString(4, draft.getOptionC());
            ps.setString(5, draft.getOptionD());
            ps.setString(6, draft.getCorrectOption());
            ps.setInt(7, draft.getMarks());
            ps.setString(8, draft.getDifficulty());
            ps.setString(9, draft.getExplanation());
            ps.setInt(10, draft.getDraftId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int draftId, String status) {
        String sql = "UPDATE ai_question_drafts SET status = ? WHERE draft_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, draftId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteDraft(int draftId) {
        String sql = "DELETE FROM ai_question_drafts WHERE draft_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, draftId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
