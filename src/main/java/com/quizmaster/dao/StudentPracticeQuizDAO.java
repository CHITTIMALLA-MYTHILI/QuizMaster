package com.quizmaster.dao;

import com.quizmaster.model.StudentPracticeAttempt;
import com.quizmaster.model.StudentPracticeQuestion;
import com.quizmaster.model.StudentPracticeQuiz;
import com.quizmaster.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentPracticeQuizDAO {

    public int savePracticeQuiz(StudentPracticeQuiz quiz, List<StudentPracticeQuestion> questions) {
        String insertQuizSql = "INSERT INTO student_practice_quizzes (student_id, title, question_count, difficulty, question_type) VALUES (?, ?, ?, ?, ?)";
        String insertQSql = "INSERT INTO student_practice_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int quizId = -1;
            try (PreparedStatement psQuiz = conn.prepareStatement(insertQuizSql, Statement.RETURN_GENERATED_KEYS)) {
                psQuiz.setInt(1, quiz.getStudentId());
                psQuiz.setString(2, quiz.getTitle());
                psQuiz.setInt(3, questions.size());
                psQuiz.setString(4, quiz.getDifficulty());
                psQuiz.setString(5, quiz.getQuestionType());
                psQuiz.executeUpdate();

                try (ResultSet rs = psQuiz.getGeneratedKeys()) {
                    if (rs.next()) {
                        quizId = rs.getInt(1);
                    }
                }
            }

            if (quizId <= 0) {
                conn.rollback();
                return -1;
            }

            try (PreparedStatement psQ = conn.prepareStatement(insertQSql)) {
                for (StudentPracticeQuestion q : questions) {
                    psQ.setInt(1, quizId);
                    psQ.setString(2, q.getQuestionText());
                    psQ.setString(3, q.getOptionA());
                    psQ.setString(4, q.getOptionB());
                    psQ.setString(5, q.getOptionC());
                    psQ.setString(6, q.getOptionD());
                    psQ.setString(7, q.getCorrectOption());
                    psQ.setString(8, q.getExplanation());
                    psQ.addBatch();
                }
                psQ.executeBatch();
            }

            conn.commit();
            return quizId;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {}
            }
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {}
            }
        }
        return -1;
    }

    public StudentPracticeQuiz getQuizById(int quizId, int studentId) {
        String quizSql = "SELECT quiz_id, student_id, title, question_count, difficulty, question_type, created_at FROM student_practice_quizzes WHERE quiz_id = ? AND student_id = ?";
        String questionSql = "SELECT question_id, quiz_id, question_text, option_a, option_b, option_c, option_d, correct_option, explanation FROM student_practice_questions WHERE quiz_id = ? ORDER BY question_id ASC";

        try (Connection conn = DBConnection.getConnection()) {
            StudentPracticeQuiz quiz = null;
            try (PreparedStatement ps = conn.prepareStatement(quizSql)) {
                ps.setInt(1, quizId);
                ps.setInt(2, studentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        quiz = new StudentPracticeQuiz(
                                rs.getInt("quiz_id"),
                                rs.getInt("student_id"),
                                rs.getString("title"),
                                rs.getInt("question_count"),
                                rs.getString("difficulty"),
                                rs.getString("question_type"),
                                rs.getTimestamp("created_at")
                        );
                    }
                }
            }

            if (quiz != null) {
                List<StudentPracticeQuestion> questions = new ArrayList<>();
                try (PreparedStatement psQ = conn.prepareStatement(questionSql)) {
                    psQ.setInt(1, quizId);
                    try (ResultSet rsQ = psQ.executeQuery()) {
                        while (rsQ.next()) {
                            StudentPracticeQuestion q = new StudentPracticeQuestion(
                                    rsQ.getInt("question_id"),
                                    rsQ.getInt("quiz_id"),
                                    rsQ.getString("question_text"),
                                    rsQ.getString("option_a"),
                                    rsQ.getString("option_b"),
                                    rsQ.getString("option_c"),
                                    rsQ.getString("option_d"),
                                    rsQ.getString("correct_option"),
                                    rsQ.getString("explanation")
                            );
                            questions.add(q);
                        }
                    }
                }
                quiz.setQuestions(questions);
            }
            return quiz;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<StudentPracticeQuiz> getRecentQuizzesByStudentId(int studentId) {
        List<StudentPracticeQuiz> list = new ArrayList<>();
        String sql = "SELECT quiz_id, student_id, title, question_count, difficulty, question_type, created_at FROM student_practice_quizzes WHERE student_id = ? ORDER BY created_at DESC LIMIT 10";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentPracticeQuiz q = new StudentPracticeQuiz(
                            rs.getInt("quiz_id"),
                            rs.getInt("student_id"),
                            rs.getString("title"),
                            rs.getInt("question_count"),
                            rs.getString("difficulty"),
                            rs.getString("question_type"),
                            rs.getTimestamp("created_at")
                    );
                    list.add(q);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int saveAttempt(StudentPracticeAttempt attempt) {
        String sql = "INSERT INTO student_practice_attempts (quiz_id, student_id, score, total_marks, percentage, correct_count, incorrect_count, topics_to_revise) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, attempt.getQuizId());
            ps.setInt(2, attempt.getStudentId());
            ps.setInt(3, attempt.getScore());
            ps.setInt(4, attempt.getTotalMarks());
            ps.setDouble(5, attempt.getPercentage());
            ps.setInt(6, attempt.getCorrectCount());
            ps.setInt(7, attempt.getIncorrectCount());
            ps.setString(8, attempt.getTopicsToRevise());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    public StudentPracticeAttempt getAttemptById(int attemptId, int studentId) {
        String sql = "SELECT a.attempt_id, a.quiz_id, a.student_id, a.score, a.total_marks, a.percentage, a.correct_count, a.incorrect_count, a.topics_to_revise, a.completed_at, q.title as quiz_title " +
                     "FROM student_practice_attempts a " +
                     "JOIN student_practice_quizzes q ON a.quiz_id = q.quiz_id " +
                     "WHERE a.attempt_id = ? AND a.student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, attemptId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    StudentPracticeAttempt a = new StudentPracticeAttempt(
                            rs.getInt("attempt_id"),
                            rs.getInt("quiz_id"),
                            rs.getInt("student_id"),
                            rs.getInt("score"),
                            rs.getInt("total_marks"),
                            rs.getDouble("percentage"),
                            rs.getInt("correct_count"),
                            rs.getInt("incorrect_count"),
                            rs.getString("topics_to_revise"),
                            rs.getTimestamp("completed_at")
                    );
                    a.setQuizTitle(rs.getString("quiz_title"));
                    return a;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<StudentPracticeAttempt> getRecentAttemptsByStudentId(int studentId) {
        List<StudentPracticeAttempt> list = new ArrayList<>();
        String sql = "SELECT a.attempt_id, a.quiz_id, a.student_id, a.score, a.total_marks, a.percentage, a.correct_count, a.incorrect_count, a.topics_to_revise, a.completed_at, q.title as quiz_title " +
                     "FROM student_practice_attempts a " +
                     "JOIN student_practice_quizzes q ON a.quiz_id = q.quiz_id " +
                     "WHERE a.student_id = ? ORDER BY a.completed_at DESC LIMIT 10";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentPracticeAttempt a = new StudentPracticeAttempt(
                            rs.getInt("attempt_id"),
                            rs.getInt("quiz_id"),
                            rs.getInt("student_id"),
                            rs.getInt("score"),
                            rs.getInt("total_marks"),
                            rs.getDouble("percentage"),
                            rs.getInt("correct_count"),
                            rs.getInt("incorrect_count"),
                            rs.getString("topics_to_revise"),
                            rs.getTimestamp("completed_at")
                    );
                    a.setQuizTitle(rs.getString("quiz_title"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
