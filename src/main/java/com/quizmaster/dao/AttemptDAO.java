package com.quizmaster.dao;

import com.quizmaster.model.Attempt;
import com.quizmaster.model.Quiz;
import com.quizmaster.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class AttemptDAO {

    // ==========================================
    // CREATE A NEW ATTEMPT
    // ==========================================
    public int createAttempt(int studentId, int quizId) {
        String sql = "INSERT INTO attempts " +
                "(student_id, quiz_id, start_time, status) " +
                "VALUES (?, ?, NOW(), 'IN_PROGRESS')";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            statement.setInt(1, studentId);
            statement.setInt(2, quizId);

            int rows = statement.executeUpdate();
            if (rows > 0) {
                try (ResultSet keys = statement.getGeneratedKeys()) {
                    if (keys.next()) {
                        return keys.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ==========================================
    // GET ACTIVE (IN_PROGRESS) ATTEMPT OR CHECK EXPIRY
    // ==========================================
    public Attempt getActiveAttempt(int studentId, int quizId) {
        String sql = "SELECT attempt_id, student_id, quiz_id, start_time, end_time, score, status " +
                "FROM attempts " +
                "WHERE student_id = ? AND quiz_id = ? AND (status = 'IN_PROGRESS' OR status IS NULL) " +
                "ORDER BY attempt_id DESC LIMIT 1";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setInt(2, quizId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Attempt attempt = extractAttemptFromResultSet(rs);

                    // Check if time has already expired
                    QuizDAO quizDAO = new QuizDAO();
                    Quiz quiz = quizDAO.getQuizById(quizId);
                    if (quiz != null && attempt.getStartTime() != null) {
                        long elapsedSeconds = (System.currentTimeMillis() - attempt.getStartTime().getTime()) / 1000;
                        long allowedSeconds = ((long) quiz.getDuration() * 60) + 30; // 30 seconds buffer
                        if (elapsedSeconds > allowedSeconds) {
                            // Mark as expired
                            completeAttempt(attempt.getAttemptId(), 0, "EXPIRED");
                            return null;
                        }
                    }
                    return attempt;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ==========================================
    // GET ATTEMPT BY ID
    // ==========================================
    public Attempt getAttemptById(int attemptId) {
        String sql = "SELECT attempt_id, student_id, quiz_id, start_time, end_time, score, status " +
                "FROM attempts WHERE attempt_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, attemptId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractAttemptFromResultSet(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ==========================================
    // COMPLETE ATTEMPT
    // ==========================================
    public boolean completeAttempt(int attemptId, int score) {
        return completeAttempt(attemptId, score, "COMPLETED");
    }

    public boolean completeAttempt(int attemptId, int score, String status) {
        String sql = "UPDATE attempts " +
                "SET end_time = NOW(), score = ?, status = ? " +
                "WHERE attempt_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, score);
            statement.setString(2, status != null ? status : "COMPLETED");
            statement.setInt(3, attemptId);

            return statement.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // CHECK IF ATTEMPT IS COMPLETED
    // ==========================================
    public boolean isAttemptCompleted(int attemptId) {
        String sql = "SELECT status, end_time FROM attempts WHERE attempt_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, attemptId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    Timestamp endTime = rs.getTimestamp("end_time");
                    return "COMPLETED".equalsIgnoreCase(status) || "EXPIRED".equalsIgnoreCase(status) || endTime != null;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // GET ATTEMPTS BY STUDENT
    // ==========================================
    public List<Attempt> getAttemptsByStudentId(int studentId) {
        List<Attempt> attempts = new ArrayList<>();
        String sql = "SELECT attempt_id, student_id, quiz_id, start_time, end_time, score, status " +
                "FROM attempts WHERE student_id = ? ORDER BY attempt_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    attempts.add(extractAttemptFromResultSet(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return attempts;
    }

    // ==========================================
    // GET COUNT OF COMPLETED ATTEMPTS BY STUDENT
    // ==========================================
    public int getCompletedAttemptsCountByStudent(int studentId) {
        String sql = "SELECT COUNT(*) FROM attempts WHERE student_id = ? AND (status = 'COMPLETED' OR end_time IS NOT NULL)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Attempt extractAttemptFromResultSet(ResultSet rs) throws Exception {
        Attempt a = new Attempt();
        a.setAttemptId(rs.getInt("attempt_id"));
        a.setStudentId(rs.getInt("student_id"));
        a.setQuizId(rs.getInt("quiz_id"));
        a.setStartTime(rs.getTimestamp("start_time"));
        a.setEndTime(rs.getTimestamp("end_time"));
        a.setScore(rs.getInt("score"));

        try {
            a.setStatus(rs.getString("status"));
        } catch (Exception ignored) {
            a.setStatus("IN_PROGRESS");
        }
        return a;
    }
}