package com.quizmaster.dao;

import com.quizmaster.model.Admin;
import com.quizmaster.model.DashboardStats;
import com.quizmaster.util.DBConnection;
import com.quizmaster.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {

    public boolean validateAdmin(String username, String password) {
        if (username == null || password == null) {
            return false;
        }

        String sql = "SELECT admin_id, password FROM admins WHERE username = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int adminId = rs.getInt("admin_id");
                    String storedPassword = rs.getString("password");

                    if (PasswordUtil.verifyPassword(password, storedPassword)) {
                        // If it's stored in legacy plaintext, automatically upgrade to SHA-256
                        if (PasswordUtil.isLegacyPlaintext(storedPassword)) {
                            upgradeAdminPassword(adminId, password);
                        }
                        return true;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public Admin getAdminByUsername(String username) {
        String sql = "SELECT admin_id, username, password FROM admins WHERE username = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Admin admin = new Admin();
                    admin.setAdminId(rs.getInt("admin_id"));
                    admin.setUsername(rs.getString("username"));
                    admin.setPassword(rs.getString("password"));
                    return admin;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private void upgradeAdminPassword(int adminId, String plainPassword) {
        String updateSql = "UPDATE admins SET password = ? WHERE admin_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(updateSql)) {
            ps.setString(1, PasswordUtil.hashPassword(plainPassword));
            ps.setInt(2, adminId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public DashboardStats getDashboardStats() {
        DashboardStats stats = new DashboardStats();

        try (Connection con = DBConnection.getConnection()) {
            // Total Quizzes
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM quizzes");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setTotalQuizzes(rs.getInt(1));
                }
            }

            // Published Quizzes
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM quizzes WHERE status = 'PUBLISHED'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setPublishedQuizzes(rs.getInt(1));
                }
            }

            // Draft Quizzes
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM quizzes WHERE status = 'DRAFT' OR status IS NULL");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setDraftQuizzes(rs.getInt(1));
                }
            }

            // Total Students
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM students");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setTotalStudents(rs.getInt(1));
                }
            }

            // Total Attempts
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM attempts");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.setTotalAttempts(rs.getInt(1));
                }
            }

            // Recent Activities from attempts joined with results (if present)
            String recentSql = "SELECT a.attempt_id, s.name AS student_name, q.title AS quiz_title, " +
                    "COALESCE(r.score, a.score, 0) AS score, " +
                    "COALESCE(r.total_marks, q.total_marks, 0) AS total_marks, " +
                    "r.grade, " +
                    "a.status, " +
                    "COALESCE(r.created_at, a.end_time, a.start_time) AS activity_time " +
                    "FROM attempts a " +
                    "JOIN students s ON a.student_id = s.student_id " +
                    "JOIN quizzes q ON a.quiz_id = q.quiz_id " +
                    "LEFT JOIN results r ON a.attempt_id = r.attempt_id " +
                    "ORDER BY a.attempt_id DESC LIMIT 5";

            List<DashboardStats.RecentActivity> activities = new ArrayList<>();
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, HH:mm");

            try (PreparedStatement ps = con.prepareStatement(recentSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Timestamp ts = rs.getTimestamp("activity_time");
                    String formattedTime = ts != null ? sdf.format(ts) : "Just now";
                    int score = rs.getInt("score");
                    int totalMarks = rs.getInt("total_marks");
                    String grade = rs.getString("grade");

                    if (grade == null || grade.trim().isEmpty()) {
                        if (totalMarks > 0) {
                            double pct = ((double) score / totalMarks) * 100.0;
                            if (pct >= 90) grade = "A+";
                            else if (pct >= 80) grade = "A";
                            else if (pct >= 70) grade = "B";
                            else if (pct >= 60) grade = "C";
                            else if (pct >= 50) grade = "D";
                            else grade = "F";
                        } else {
                            grade = "N/A";
                        }
                    }

                    DashboardStats.RecentActivity activity = new DashboardStats.RecentActivity(
                            rs.getInt("attempt_id"),
                            rs.getString("student_name"),
                            rs.getString("quiz_title"),
                            score,
                            totalMarks,
                            grade,
                            rs.getString("status"),
                            formattedTime,
                            formattedTime
                    );
                    activities.add(activity);
                }
            }
            stats.setRecentActivities(activities);

        } catch (Exception e) {
            e.printStackTrace();
        }

        return stats;
    }
}