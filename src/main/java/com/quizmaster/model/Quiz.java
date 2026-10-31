package com.quizmaster.model;

import java.sql.Timestamp;

public class Quiz {

    private int quizId;
    private String title;
    private String description;
    private String category = "General";
    private int duration;
    private int numberOfQuestions;
    private int totalMarks;
    private String status = "DRAFT";
    private int createdBy = 1;
    private Timestamp createdAt;

    public Quiz() {
    }

    public Quiz(int quizId, String title, String description,
                int duration, int totalMarks) {
        this.quizId = quizId;
        this.title = title;
        this.description = description;
        this.duration = duration;
        this.numberOfQuestions = 0;
        this.totalMarks = totalMarks;
        this.status = "DRAFT";
    }

    public Quiz(int quizId, String title, String description,
                int duration, int numberOfQuestions, int totalMarks) {
        this.quizId = quizId;
        this.title = title;
        this.description = description;
        this.duration = duration;
        this.numberOfQuestions = numberOfQuestions;
        this.totalMarks = totalMarks;
        this.status = "DRAFT";
    }

    public int getQuizId() {
        return quizId;
    }

    public void setQuizId(int quizId) {
        this.quizId = quizId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public int getNumberOfQuestions() {
        return numberOfQuestions;
    }

    public void setNumberOfQuestions(int numberOfQuestions) {
        this.numberOfQuestions = numberOfQuestions;
    }

    public int getTotalMarks() {
        return totalMarks;
    }

    public void setTotalMarks(int totalMarks) {
        this.totalMarks = totalMarks;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isPublished() {
        return "PUBLISHED".equalsIgnoreCase(status);
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    /**
     * Backward-compatible fallback helper if equal distribution is queried.
     */
    public int getMarksPerQuestion() {
        if (numberOfQuestions <= 0) {
            return 1;
        }
        return totalMarks / numberOfQuestions;
    }
}