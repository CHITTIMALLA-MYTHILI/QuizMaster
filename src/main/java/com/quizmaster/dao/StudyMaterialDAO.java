package com.quizmaster.dao;

import com.quizmaster.model.StudyMaterial;
import com.quizmaster.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class StudyMaterialDAO {

    public int addMaterial(String title, String category, String contentText, String fileName, int createdBy) {
        String sql = "INSERT INTO study_materials (title, category, content_text, file_name, created_by) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, title);
            ps.setString(2, category);
            ps.setString(3, contentText);
            ps.setString(4, fileName);
            ps.setInt(5, createdBy);

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int materialId = rs.getInt(1);
                        chunkAndStorePassages(con, materialId, contentText);
                        return materialId;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    private void chunkAndStorePassages(Connection con, int materialId, String contentText) {
        if (contentText == null || contentText.trim().isEmpty()) return;

        // Chunking strategy: roughly 400-500 words per passage with sentence boundary respect
        String[] paragraphs = contentText.split("\n\n+");
        String insertPassageSql = "INSERT INTO study_passages (material_id, passage_text, passage_index) VALUES (?, ?, ?)";

        try (PreparedStatement ps = con.prepareStatement(insertPassageSql)) {
            int index = 1;
            StringBuilder currentChunk = new StringBuilder();

            for (String p : paragraphs) {
                if (currentChunk.length() + p.length() > 1500 && currentChunk.length() > 0) {
                    ps.setInt(1, materialId);
                    ps.setString(2, currentChunk.toString().trim());
                    ps.setInt(3, index++);
                    ps.addBatch();
                    currentChunk.setLength(0);
                }
                currentChunk.append(p).append("\n\n");
            }

            if (currentChunk.length() > 0) {
                ps.setInt(1, materialId);
                ps.setString(2, currentChunk.toString().trim());
                ps.setInt(3, index);
                ps.addBatch();
            }

            ps.executeBatch();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<StudyMaterial> getAllMaterials() {
        List<StudyMaterial> list = new ArrayList<>();
        String sql = "SELECT material_id, title, category, content_text, file_name, created_by, created_at FROM study_materials ORDER BY material_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                StudyMaterial m = new StudyMaterial(
                        rs.getInt("material_id"),
                        rs.getString("title"),
                        rs.getString("category"),
                        rs.getString("content_text"),
                        rs.getString("file_name"),
                        rs.getInt("created_by"),
                        rs.getTimestamp("created_at")
                );
                list.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public StudyMaterial getMaterialById(int materialId) {
        String sql = "SELECT material_id, title, category, content_text, file_name, created_by, created_at FROM study_materials WHERE material_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, materialId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new StudyMaterial(
                            rs.getInt("material_id"),
                            rs.getString("title"),
                            rs.getString("category"),
                            rs.getString("content_text"),
                            rs.getString("file_name"),
                            rs.getInt("created_by"),
                            rs.getTimestamp("created_at")
                    );
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean deleteMaterial(int materialId) {
        String sql = "DELETE FROM study_materials WHERE material_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, materialId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<String> retrieveRelevantPassages(String query, int maxPassages) {
        List<String> results = new ArrayList<>();
        if (query == null || query.trim().isEmpty()) return results;

        String[] keywords = query.toLowerCase().replaceAll("[^a-zA-Z0-9 ]", "").split("\\s+");
        if (keywords.length == 0) return results;

        StringBuilder sql = new StringBuilder("SELECT p.passage_text, m.title FROM study_passages p JOIN study_materials m ON p.material_id = m.material_id WHERE ");
        List<String> conditions = new ArrayList<>();
        for (int i = 0; i < Math.min(keywords.length, 5); i++) {
            if (keywords[i].length() > 2) {
                conditions.add("LOWER(p.passage_text) LIKE ?");
            }
        }

        if (conditions.isEmpty()) {
            conditions.add("1=1");
        }

        sql.append(String.join(" OR ", conditions));
        sql.append(" LIMIT ?");

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            for (int i = 0; i < Math.min(keywords.length, 5); i++) {
                if (keywords[i].length() > 2) {
                    ps.setString(paramIndex++, "%" + keywords[i] + "%");
                }
            }
            ps.setInt(paramIndex, maxPassages);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String title = rs.getString("title");
                    String text = rs.getString("passage_text");
                    results.add("[Source: " + title + "]\n" + text);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return results;
    }
}
