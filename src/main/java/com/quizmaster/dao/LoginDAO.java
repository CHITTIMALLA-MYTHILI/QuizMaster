package com.quizmaster.dao;

import com.quizmaster.model.Student;
import com.quizmaster.util.DBConnection;
import com.quizmaster.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LoginDAO {

    public Student login(String email, String password) {
        if (email == null || password == null) {
            return null;
        }

        String sql = "SELECT student_id, name, email, password, department, year FROM students " +
                "WHERE email = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, email.trim().toLowerCase());

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    int studentId = resultSet.getInt("student_id");
                    String storedPassword = resultSet.getString("password");

                    if (PasswordUtil.verifyPassword(password, storedPassword)) {
                        // Automatically upgrade legacy plaintext password to SHA-256 hash
                        if (PasswordUtil.isLegacyPlaintext(storedPassword)) {
                            upgradeStudentPassword(studentId, password);
                        }

                        return new Student(
                                studentId,
                                resultSet.getString("name"),
                                resultSet.getString("email"),
                                storedPassword,
                                resultSet.getString("department"),
                                resultSet.getInt("year")
                        );
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private void upgradeStudentPassword(int studentId, String plainPassword) {
        String updateSql = "UPDATE students SET password = ? WHERE student_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(updateSql)) {
            ps.setString(1, PasswordUtil.hashPassword(plainPassword));
            ps.setInt(2, studentId);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}