package com.quizmaster.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/quizmaster?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static final String DEFAULT_USER =
            "root";

    private static final String DEFAULT_PASSWORD =
            "root1234";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found in classpath!", e);
        }

        String url = System.getenv("DB_URL");
        if (url == null || url.trim().isEmpty()) {
            url = System.getProperty("quizmaster.db.url", DEFAULT_URL);
        }

        String user = System.getenv("DB_USER");
        if (user == null || user.trim().isEmpty()) {
            user = System.getProperty("quizmaster.db.user", DEFAULT_USER);
        }

        String password = System.getenv("DB_PASSWORD");
        if (password == null) {
            password = System.getProperty("quizmaster.db.password", DEFAULT_PASSWORD);
        }

        return DriverManager.getConnection(url, user, password);
    }
}