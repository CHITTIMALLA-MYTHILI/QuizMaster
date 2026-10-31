package com.quizmaster.dao;

import com.quizmaster.model.StudentSummary;
import com.quizmaster.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentSummaryDAO {

    public int saveSummary(StudentSummary summary) {
        String sql = "INSERT INTO student_summaries (student_id, title, summary_type, source_type, file_name, content_summary) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, summary.getStudentId());
            ps.setString(2, summary.getTitle());
            ps.setString(3, summary.getSummaryType());
            ps.setString(4, summary.getSourceType());
            ps.setString(5, summary.getFileName());
            ps.setString(6, summary.getContentSummary());

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

    public List<StudentSummary> getSummariesByStudentId(int studentId) {
        List<StudentSummary> list = new ArrayList<>();
        String sql = "SELECT summary_id, student_id, title, summary_type, source_type, file_name, content_summary, created_at FROM student_summaries WHERE student_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    StudentSummary s = new StudentSummary(
                            rs.getInt("summary_id"),
                            rs.getInt("student_id"),
                            rs.getString("title"),
                            rs.getString("summary_type"),
                            rs.getString("source_type"),
                            rs.getString("file_name"),
                            rs.getString("content_summary"),
                            rs.getTimestamp("created_at")
                    );
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public StudentSummary getSummaryById(int summaryId, int studentId) {
        String sql = "SELECT summary_id, student_id, title, summary_type, source_type, file_name, content_summary, created_at FROM student_summaries WHERE summary_id = ? AND student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, summaryId);
            ps.setInt(2, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new StudentSummary(
                            rs.getInt("summary_id"),
                            rs.getInt("student_id"),
                            rs.getString("title"),
                            rs.getString("summary_type"),
                            rs.getString("source_type"),
                            rs.getString("file_name"),
                            rs.getString("content_summary"),
                            rs.getTimestamp("created_at")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean deleteSummary(int summaryId, int studentId) {
        String sql = "DELETE FROM student_summaries WHERE summary_id = ? AND student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, summaryId);
            ps.setInt(2, studentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
