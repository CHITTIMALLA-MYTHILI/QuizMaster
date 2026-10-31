package com.quizmaster.dao;

import com.quizmaster.model.LeaderboardEntry;
import com.quizmaster.model.Result;
import com.quizmaster.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class ResultDAO {

    public boolean saveResult(
            int studentId,
            int quizId,
            int attemptId,
            int score,
            double percentage,
            String grade) {

        Result r = new Result();
        r.setStudentId(studentId);
        r.setQuizId(quizId);
        r.setAttemptId(attemptId);
        r.setScore(score);
        r.setPercentage(percentage);
        r.setGrade(grade);
        return saveResult(r);
    }

    public boolean saveResult(Result result) {
        String sql = "INSERT INTO results " +
                "(student_id, quiz_id, attempt_id, score, percentage, grade, " +
                "total_marks, correct_count, incorrect_count, unanswered_count, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, result.getStudentId());
            statement.setInt(2, result.getQuizId());
            statement.setInt(3, result.getAttemptId());
            statement.setInt(4, result.getScore());
            statement.setDouble(5, result.getPercentage());
            statement.setString(6, result.getGrade());
            statement.setInt(7, result.getTotalMarks());
            statement.setInt(8, result.getCorrectCount());
            statement.setInt(9, result.getIncorrectCount());
            statement.setInt(10, result.getUnansweredCount());

            return statement.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public Result getResultByAttemptId(int attemptId) {
        String sql = "SELECT r.result_id, r.student_id, r.quiz_id, r.attempt_id, " +
                "q.title AS quiz_title, s.name AS student_name, " +
                "r.score, COALESCE(r.total_marks, q.total_marks) AS total_marks, " +
                "r.percentage, r.grade, r.correct_count, r.incorrect_count, r.unanswered_count, " +
                "COALESCE(r.created_at, NOW()) AS created_at " +
                "FROM results r " +
                "JOIN quizzes q ON r.quiz_id = q.quiz_id " +
                "JOIN students s ON r.student_id = s.student_id " +
                "WHERE r.attempt_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, attemptId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractResultFromResultSet(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Result getResultById(int resultId) {
        String sql = "SELECT r.result_id, r.student_id, r.quiz_id, r.attempt_id, " +
                "q.title AS quiz_title, s.name AS student_name, " +
                "r.score, COALESCE(r.total_marks, q.total_marks) AS total_marks, " +
                "r.percentage, r.grade, r.correct_count, r.incorrect_count, r.unanswered_count, " +
                "COALESCE(r.created_at, NOW()) AS created_at " +
                "FROM results r " +
                "JOIN quizzes q ON r.quiz_id = q.quiz_id " +
                "JOIN students s ON r.student_id = s.student_id " +
                "WHERE r.result_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, resultId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractResultFromResultSet(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Result> getResultsByStudentId(int studentId) {
        List<Result> results = new ArrayList<>();
        String sql = "SELECT r.result_id, r.student_id, r.quiz_id, r.attempt_id, " +
                "q.title AS quiz_title, s.name AS student_name, " +
                "r.score, COALESCE(r.total_marks, q.total_marks) AS total_marks, " +
                "r.percentage, r.grade, r.correct_count, r.incorrect_count, r.unanswered_count, " +
                "COALESCE(r.created_at, NOW()) AS created_at " +
                "FROM results r " +
                "JOIN quizzes q ON r.quiz_id = q.quiz_id " +
                "JOIN students s ON r.student_id = s.student_id " +
                "WHERE r.student_id = ? " +
                "ORDER BY r.result_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(extractResultFromResultSet(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return results;
    }

    public List<Result> getAllResults(Integer quizIdFilter) {
        List<Result> results = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT r.result_id, r.student_id, r.quiz_id, r.attempt_id, " +
                        "q.title AS quiz_title, s.name AS student_name, " +
                        "r.score, COALESCE(r.total_marks, q.total_marks) AS total_marks, " +
                        "r.percentage, r.grade, r.correct_count, r.incorrect_count, r.unanswered_count, " +
                        "COALESCE(r.created_at, NOW()) AS created_at " +
                        "FROM results r " +
                        "JOIN quizzes q ON r.quiz_id = q.quiz_id " +
                        "JOIN students s ON r.student_id = s.student_id "
        );

        if (quizIdFilter != null && quizIdFilter > 0) {
            sql.append("WHERE r.quiz_id = ? ");
        }
        sql.append("ORDER BY r.result_id DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            if (quizIdFilter != null && quizIdFilter > 0) {
                ps.setInt(1, quizIdFilter);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    results.add(extractResultFromResultSet(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return results;
    }

    public List<LeaderboardEntry> getLeaderboard(int limit) {
        List<LeaderboardEntry> list = new ArrayList<>();
        String sql = "SELECT s.name AS student_name, s.email AS student_email, s.department, " +
                "q.title AS quiz_title, r.score, COALESCE(r.total_marks, q.total_marks) AS total_marks, " +
                "r.percentage, r.grade, r.created_at " +
                "FROM results r " +
                "JOIN students s ON r.student_id = s.student_id " +
                "JOIN quizzes q ON r.quiz_id = q.quiz_id " +
                "ORDER BY r.percentage DESC, r.score DESC, r.result_id ASC " +
                "LIMIT ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, limit > 0 ? limit : 20);
            try (ResultSet rs = ps.executeQuery()) {
                int rank = 1;
                while (rs.next()) {
                    LeaderboardEntry entry = new LeaderboardEntry(
                            rank++,
                            rs.getString("student_name"),
                            rs.getString("student_email"),
                            rs.getString("department"),
                            rs.getString("quiz_title"),
                            rs.getInt("score"),
                            rs.getInt("total_marks"),
                            rs.getDouble("percentage"),
                            rs.getString("grade"),
                            rs.getTimestamp("created_at")
                    );
                    list.add(entry);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<LeaderboardEntry> getLeaderboardByQuiz(int quizId, int limit) {
        List<LeaderboardEntry> list = new ArrayList<>();
        String sql = "SELECT s.name AS student_name, s.email AS student_email, s.department, " +
                "q.title AS quiz_title, r.score, COALESCE(r.total_marks, q.total_marks) AS total_marks, " +
                "r.percentage, r.grade, r.created_at " +
                "FROM results r " +
                "JOIN students s ON r.student_id = s.student_id " +
                "JOIN quizzes q ON r.quiz_id = q.quiz_id " +
                "WHERE r.quiz_id = ? " +
                "ORDER BY r.percentage DESC, r.score DESC, r.result_id ASC " +
                "LIMIT ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, quizId);
            ps.setInt(2, limit > 0 ? limit : 20);
            try (ResultSet rs = ps.executeQuery()) {
                int rank = 1;
                while (rs.next()) {
                    LeaderboardEntry entry = new LeaderboardEntry(
                            rank++,
                            rs.getString("student_name"),
                            rs.getString("student_email"),
                            rs.getString("department"),
                            rs.getString("quiz_title"),
                            rs.getInt("score"),
                            rs.getInt("total_marks"),
                            rs.getDouble("percentage"),
                            rs.getString("grade"),
                            rs.getTimestamp("created_at")
                    );
                    list.add(entry);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    private Result extractResultFromResultSet(ResultSet rs) throws Exception {
        Result r = new Result();
        r.setResultId(rs.getInt("result_id"));
        r.setStudentId(rs.getInt("student_id"));
        r.setQuizId(rs.getInt("quiz_id"));
        r.setAttemptId(rs.getInt("attempt_id"));
        r.setQuizTitle(rs.getString("quiz_title"));
        r.setStudentName(rs.getString("student_name"));
        r.setScore(rs.getInt("score"));
        r.setTotalMarks(rs.getInt("total_marks"));
        r.setPercentage(rs.getDouble("percentage"));
        r.setGrade(rs.getString("grade"));

        try {
            r.setCorrectCount(rs.getInt("correct_count"));
            r.setIncorrectCount(rs.getInt("incorrect_count"));
            r.setUnansweredCount(rs.getInt("unanswered_count"));
            r.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (Exception ignored) {
        }

        return r;
    }
}