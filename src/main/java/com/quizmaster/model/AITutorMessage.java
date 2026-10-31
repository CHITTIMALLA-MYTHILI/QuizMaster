package com.quizmaster.model;

import java.sql.Timestamp;

public class AITutorMessage {

    private int messageId;
    private int studentId;
    private String role; // user or assistant
    private String messageText;
    private String sourcesCited;
    private Timestamp createdAt;

    public AITutorMessage() {
    }

    public AITutorMessage(int messageId, int studentId, String role, String messageText, String sourcesCited, Timestamp createdAt) {
        this.messageId = messageId;
        this.studentId = studentId;
        this.role = role;
        this.messageText = messageText;
        this.sourcesCited = sourcesCited;
        this.createdAt = createdAt;
    }

    public int getMessageId() {
        return messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getMessageText() {
        return messageText;
    }

    public void setMessageText(String messageText) {
        this.messageText = messageText;
    }

    public String getSourcesCited() {
        return sourcesCited;
    }

    public void setSourcesCited(String sourcesCited) {
        this.sourcesCited = sourcesCited;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
