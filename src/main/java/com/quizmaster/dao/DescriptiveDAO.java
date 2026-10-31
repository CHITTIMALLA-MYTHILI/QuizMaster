package com.quizmaster.dao;

import com.quizmaster.model.DescriptiveEvaluation;
import com.quizmaster.model.DescriptiveQuestion;
import com.quizmaster.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class DescriptiveDAO {

    public int addQuestion(int quizId, String questionText, int maxMarks, String referenceAnswer, String rubric, String expectedConcepts) {
        String sql = "INSERT INTO descriptive_questions (quiz_id, question_text, max_marks, reference_answer, rubric, expected_concepts) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, quizId);
            ps.setString(2, questionText);
            ps.setInt(3, maxMarks);
            ps.setString(4, referenceAnswer);
            ps.setString(5, rubric);
            ps.setString(6, expectedConcepts);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<DescriptiveQuestion> getQuestionsByQuizId(int quizId) {
        List<DescriptiveQuestion> list = new ArrayList<>();
        String sql = "SELECT * FROM descriptive_questions WHERE quiz_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DescriptiveQuestion q = new DescriptiveQuestion(
                            rs.getInt("desc_question_id"),
                            rs.getInt("quiz_id"),
                            rs.getString("question_text"),
                            rs.getInt("max_marks"),
                            rs.getString("reference_answer"),
                            rs.getString("rubric"),
                            rs.getString("expected_concepts"),
                            rs.getTimestamp("created_at")
                    );
                    list.add(q);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public DescriptiveQuestion getQuestionById(int descQuestionId) {
        String sql = "SELECT * FROM descriptive_questions WHERE desc_question_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, descQuestionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new DescriptiveQuestion(
                            rs.getInt("desc_question_id"),
                            rs.getInt("quiz_id"),
                            rs.getString("question_text"),
                            rs.getInt("max_marks"),
                            rs.getString("reference_answer"),
                            rs.getString("rubric"),
                            rs.getString("expected_concepts"),
                            rs.getTimestamp("created_at")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean saveEvaluation(DescriptiveEvaluation eval) {
        String sql = "INSERT INTO descriptive_evaluations " +
                "(desc_question_id, student_id, attempt_id, student_answer, awarded_marks, criterion_feedback, " +
                "concepts_identified, missing_concepts, suggestions, is_admin_overridden) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, eval.getDescQuestionId());
            ps.setInt(2, eval.getStudentId());
            ps.setInt(3, eval.getAttemptId());
            ps.setString(4, eval.getStudentAnswer());
            ps.setInt(5, eval.getAwardedMarks());
            ps.setString(6, eval.getCriterionFeedback());
            ps.setString(7, eval.getConceptsIdentified());
            ps.setString(8, eval.getMissingConcepts());
            ps.setString(9, eval.getSuggestions());
            ps.setBoolean(10, eval.isAdminOverridden());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<DescriptiveEvaluation> getAllEvaluations() {
        List<DescriptiveEvaluation> list = new ArrayList<>();
        String sql = "SELECT e.*, dq.question_text, dq.max_marks, s.name AS student_name " +
                "FROM descriptive_evaluations e " +
                "JOIN descriptive_questions dq ON e.desc_question_id = dq.desc_question_id " +
                "JOIN students s ON e.student_id = s.student_id " +
                "ORDER BY e.evaluation_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                DescriptiveEvaluation eval = new DescriptiveEvaluation();
                eval.setEvaluationId(rs.getInt("evaluation_id"));
                eval.setDescQuestionId(rs.getInt("desc_question_id"));
                eval.setStudentId(rs.getInt("student_id"));
                eval.setAttemptId(rs.getInt("attempt_id"));
                eval.setStudentAnswer(rs.getString("student_answer"));
                eval.setAwardedMarks(rs.getInt("awarded_marks"));
                eval.setCriterionFeedback(rs.getString("criterion_feedback"));
                eval.setConceptsIdentified(rs.getString("concepts_identified"));
                eval.setMissingConcepts(rs.getString("missing_concepts"));
                eval.setSuggestions(rs.getString("suggestions"));
                eval.setAdminOverridden(rs.getBoolean("is_admin_overridden"));
                eval.setAdminNotes(rs.getString("admin_notes"));
                eval.setEvaluatedAt(rs.getTimestamp("evaluated_at"));
                eval.setQuestionText(rs.getString("question_text"));
                eval.setMaxMarks(rs.getInt("max_marks"));
                eval.setStudentName(rs.getString("student_name"));
                list.add(eval);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean overrideEvaluation(int evaluationId, int newMarks, String adminNotes) {
        String sql = "UPDATE descriptive_evaluations SET awarded_marks = ?, is_admin_overridden = TRUE, admin_notes = ? WHERE evaluation_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, newMarks);
            ps.setString(2, adminNotes);
            ps.setInt(3, evaluationId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
