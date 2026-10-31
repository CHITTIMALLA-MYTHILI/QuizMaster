package com.quizmaster.util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * Utility for secure password hashing and verification.
 * Uses SHA-256 with backwards compatibility for existing plaintext passwords.
 */
public class PasswordUtil {

    /**
     * Hashes a plaintext password using SHA-256.
     *
     * @param plainPassword Plaintext password
     * @return Hexadecimal representation of the SHA-256 hash
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null) {
            return null;
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedHash = digest.digest(plainPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedHash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm not available", e);
        }
    }

    /**
     * Verifies a plaintext password against a stored password or hash.
     * Supports both SHA-256 hex hashes and legacy plaintext values.
     *
     * @param plainPassword Plaintext password provided by user
     * @param storedPassword Stored hash or legacy plaintext password from database
     * @return true if password matches, false otherwise
     */
    public static boolean verifyPassword(String plainPassword, String storedPassword) {
        if (plainPassword == null || storedPassword == null) {
            return false;
        }

        // Direct match with stored hash
        String computedHash = hashPassword(plainPassword);
        if (computedHash.equalsIgnoreCase(storedPassword)) {
            return true;
        }

        // Legacy match: plaintext in DB
        return storedPassword.equals(plainPassword);
    }

    /**
     * Checks if a stored password is in legacy plaintext format rather than SHA-256.
     */
    public static boolean isLegacyPlaintext(String storedPassword) {
        if (storedPassword == null) {
            return false;
        }
        return storedPassword.length() != 64;
    }
}
