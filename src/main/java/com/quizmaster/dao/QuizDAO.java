package com.quizmaster.dao;

import com.quizmaster.model.Quiz;
import com.quizmaster.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class QuizDAO {

    // ==========================================
    // GET ALL QUIZZES (ADMIN)
    // ==========================================
    public List<Quiz> getAllQuizzes() {
        List<Quiz> quizzes = new ArrayList<>();
        String sql = "SELECT quiz_id, title, description, category, duration, " +
                "number_of_questions, total_marks, status, created_by, created_at " +
                "FROM quizzes ORDER BY quiz_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Quiz quiz = extractQuizFromResultSet(rs);
                quizzes.add(quiz);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return quizzes;
    }

    // ==========================================
    // GET PUBLISHED QUIZZES (STUDENTS)
    // ==========================================
    public List<Quiz> getPublishedQuizzes() {
        List<Quiz> quizzes = new ArrayList<>();
        String sql = "SELECT quiz_id, title, description, category, duration, " +
                "number_of_questions, total_marks, status, created_by, created_at " +
                "FROM quizzes WHERE status = 'PUBLISHED' ORDER BY quiz_id DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Quiz quiz = extractQuizFromResultSet(rs);
                quizzes.add(quiz);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return quizzes;
    }

    // ==========================================
    // SEARCH & FILTER PUBLISHED QUIZZES (STUDENTS)
    // ==========================================
    public List<Quiz> searchPublishedQuizzes(String query, String category) {
        List<Quiz> quizzes = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT quiz_id, title, description, category, duration, " +
                        "number_of_questions, total_marks, status, created_by, created_at " +
                        "FROM quizzes WHERE status = 'PUBLISHED' "
        );

        List<Object> params = new ArrayList<>();

        if (category != null && !category.trim().isEmpty() && !"ALL".equalsIgnoreCase(category)) {
            sql.append("AND category = ? ");
            params.add(category.trim());
        }

        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (LOWER(title) LIKE ? OR LOWER(description) LIKE ?) ");
            String searchPattern = "%" + query.trim().toLowerCase() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
        }

        sql.append("ORDER BY quiz_id DESC");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    quizzes.add(extractQuizFromResultSet(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return quizzes;
    }

    // ==========================================
    // GET ALL DISTINCT CATEGORIES
    // ==========================================
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM quizzes WHERE category IS NOT NULL AND category != '' ORDER BY category";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (categories.isEmpty()) {
            categories.add("Java");
            categories.add("Python");
            categories.add("Database");
            categories.add("General");
        }
        return categories;
    }

    // ==========================================
    // GET QUIZ BY ID
    // ==========================================
    public Quiz getQuizById(int quizId) {
        String sql = "SELECT quiz_id, title, description, category, duration, " +
                "number_of_questions, total_marks, status, created_by, created_at " +
                "FROM quizzes WHERE quiz_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, quizId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return extractQuizFromResultSet(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ==========================================
    // CREATE QUIZ - ADMIN (DEFAULTS TO DRAFT)
    // ==========================================
    public int createQuiz(String title,
                          String description,
                          int duration,
                          int totalMarks,
                          int createdBy) {
        return createQuiz(title, description, "General", duration, totalMarks, createdBy);
    }

    public int createQuiz(String title,
                          String description,
                          int duration,
                          int numberOfQuestions,
                          int totalMarks,
                          int createdBy) {
        return createQuiz(title, description, "General", duration, totalMarks, createdBy);
    }

    public int createQuiz(String title,
                          String description,
                          String category,
                          int duration,
                          int totalMarks,
                          int createdBy) {

        String sql = "INSERT INTO quizzes " +
                "(title, description, category, duration, number_of_questions, total_marks, status, created_by) " +
                "VALUES (?, ?, ?, ?, 0, ?, 'DRAFT', ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, title != null ? title.trim() : "");
            ps.setString(2, description != null ? description.trim() : "");
            ps.setString(3, (category != null && !category.trim().isEmpty()) ? category.trim() : "General");
            ps.setInt(4, duration);
            ps.setInt(5, totalMarks);
            ps.setInt(6, createdBy);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // ==========================================
    // UPDATE QUIZ DETAILS
    // ==========================================
    public boolean updateQuiz(int quizId, String title, String description,
                              String category, int duration, int totalMarks) {

        String sql = "UPDATE quizzes SET title = ?, description = ?, category = ?, " +
                "duration = ?, total_marks = ? WHERE quiz_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, title != null ? title.trim() : "");
            ps.setString(2, description != null ? description.trim() : "");
            ps.setString(3, (category != null && !category.trim().isEmpty()) ? category.trim() : "General");
            ps.setInt(4, duration);
            ps.setInt(5, totalMarks);
            ps.setInt(6, quizId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // UPDATE QUIZ STATUS
    // ==========================================
    public boolean updateQuizStatus(int quizId, String status) {
        String sql = "UPDATE quizzes SET status = ? WHERE quiz_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, quizId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // PUBLISH QUIZ WITH CRITICAL MARKS VALIDATION
    // Returns null on success, or an error message on failure
    // ==========================================
    public String publishQuiz(int quizId) {
        Quiz quiz = getQuizById(quizId);
        if (quiz == null) {
            return "Quiz not found.";
        }

        int questionCount = getQuestionCount(quizId);
        if (questionCount == 0) {
            return "Cannot publish quiz: No questions have been added yet. Add questions before publishing.";
        }

        int marksSum = getQuestionMarksSum(quizId);
        if (marksSum != quiz.getTotalMarks()) {
            return "Quiz total is " + quiz.getTotalMarks() + " marks, but the current questions total " +
                    marksSum + " marks (" + questionCount + " question" + (questionCount == 1 ? "" : "s") + "). " +
                    "Add or adjust questions before publishing.";
        }

        // Synchronize actual question count and publish
        syncQuizQuestionCount(quizId);
        boolean updated = updateQuizStatus(quizId, "PUBLISHED");
        if (updated) {
            return null; // Success!
        } else {
            return "Failed to update quiz status in database.";
        }
    }

    public boolean unpublishQuiz(int quizId) {
        return updateQuizStatus(quizId, "DRAFT");
    }

    // ==========================================
    // CHECK IF QUIZ HAS ATTEMPTS
    // ==========================================
    public boolean hasAttempts(int quizId) {
        String sql = "SELECT attempt_id FROM attempts WHERE quiz_id = ? LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // DELETE QUIZ (SAFE)
    // ==========================================
    public boolean deleteQuiz(int quizId) {
        // If there are student attempts, clean up answers, results, attempts, questions safely or refuse
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // Delete answers for attempts on this quiz
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE a FROM answers a JOIN attempts att ON a.attempt_id = att.attempt_id WHERE att.quiz_id = ?")) {
                    ps.setInt(1, quizId);
                    ps.executeUpdate();
                }

                // Delete results
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM results WHERE quiz_id = ?")) {
                    ps.setInt(1, quizId);
                    ps.executeUpdate();
                }

                // Delete attempts
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM attempts WHERE quiz_id = ?")) {
                    ps.setInt(1, quizId);
                    ps.executeUpdate();
                }

                // Delete questions
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM questions WHERE quiz_id = ?")) {
                    ps.setInt(1, quizId);
                    ps.executeUpdate();
                }

                // Delete quiz
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM quizzes WHERE quiz_id = ?")) {
                    ps.setInt(1, quizId);
                    ps.executeUpdate();
                }

                con.commit();
                return true;
            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // ==========================================
    // GET MARKS SUM FOR QUIZ
    // ==========================================
    public int getQuestionMarksSum(int quizId) {
        String sql = "SELECT COALESCE(SUM(marks), 0) FROM questions WHERE quiz_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quizId);
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

    // ==========================================
    // GET QUESTION COUNT FOR QUIZ
    // ==========================================
    public int getQuestionCount(int quizId) {
        String sql = "SELECT COUNT(*) FROM questions WHERE quiz_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quizId);
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

    // ==========================================
    // SYNCHRONIZE ACTUAL QUESTION COUNT
    // ==========================================
    public void syncQuizQuestionCount(int quizId) {
        String sql = "UPDATE quizzes SET number_of_questions = " +
                "(SELECT COUNT(*) FROM questions WHERE quiz_id = ?) WHERE quiz_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quizId);
            ps.setInt(2, quizId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private Quiz extractQuizFromResultSet(ResultSet rs) throws Exception {
        Quiz quiz = new Quiz();
        quiz.setQuizId(rs.getInt("quiz_id"));
        quiz.setTitle(rs.getString("title"));
        quiz.setDescription(rs.getString("description"));

        try {
            quiz.setCategory(rs.getString("category"));
        } catch (Exception ignored) {
            quiz.setCategory("General");
        }

        quiz.setDuration(rs.getInt("duration"));
        quiz.setNumberOfQuestions(rs.getInt("number_of_questions"));
        quiz.setTotalMarks(rs.getInt("total_marks"));

        try {
            quiz.setStatus(rs.getString("status"));
        } catch (Exception ignored) {
            quiz.setStatus("DRAFT");
        }

        try {
            quiz.setCreatedBy(rs.getInt("created_by"));
        } catch (Exception ignored) {
            quiz.setCreatedBy(1);
        }

        try {
            quiz.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (Exception ignored) {
        }

        return quiz;
    }
}