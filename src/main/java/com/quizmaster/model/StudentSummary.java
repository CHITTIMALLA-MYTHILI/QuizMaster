package com.quizmaster.model;

import java.sql.Timestamp;

public class StudentSummary {
    private int summaryId;
    private int studentId;
    private String title;
    private String summaryType;
    private String sourceType;
    private String fileName;
    private String contentSummary;
    private Timestamp createdAt;

    public StudentSummary() {}

    public StudentSummary(int summaryId, int studentId, String title, String summaryType,
                          String sourceType, String fileName, String contentSummary, Timestamp createdAt) {
        this.summaryId = summaryId;
        this.studentId = studentId;
        this.title = title;
        this.summaryType = summaryType;
        this.sourceType = sourceType;
        this.fileName = fileName;
        this.contentSummary = contentSummary;
        this.createdAt = createdAt;
    }

    public int getSummaryId() {
        return summaryId;
    }

    public void setSummaryId(int summaryId) {
        this.summaryId = summaryId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSummaryType() {
        return summaryType;
    }

    public void setSummaryType(String summaryType) {
        this.summaryType = summaryType;
    }

    public String getSourceType() {
        return sourceType;
    }

    public void setSourceType(String sourceType) {
        this.sourceType = sourceType;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getContentSummary() {
        return contentSummary;
    }

    public void setContentSummary(String contentSummary) {
        this.contentSummary = contentSummary;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
