package com.quizmaster.dao;

import com.quizmaster.model.AITutorMessage;
import com.quizmaster.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class AITutorDAO {

    public void saveMessage(int studentId, String role, String messageText, String sourcesCited) {
        String sql = "INSERT INTO ai_tutor_messages (student_id, role, message_text, sources_cited) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setString(2, role);
            ps.setString(3, messageText);
            ps.setString(4, sourcesCited);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<AITutorMessage> getRecentMessages(int studentId, int limit) {
        List<AITutorMessage> list = new ArrayList<>();
        String sql = "SELECT * FROM ai_tutor_messages WHERE student_id = ? ORDER BY message_id DESC LIMIT ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, studentId);
            ps.setInt(2, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AITutorMessage m = new AITutorMessage(
                            rs.getInt("message_id"),
                            rs.getInt("student_id"),
                            rs.getString("role"),
                            rs.getString("message_text"),
                            rs.getString("sources_cited"),
                            rs.getTimestamp("created_at")
                    );
                    list.add(0, m); // Maintain chronological order
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
