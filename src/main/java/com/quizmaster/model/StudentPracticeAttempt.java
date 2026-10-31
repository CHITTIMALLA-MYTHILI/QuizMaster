package com.quizmaster.model;

import java.sql.Timestamp;

public class StudentPracticeAttempt {
    private int attemptId;
    private int quizId;
    private int studentId;
    private int score;
    private int totalMarks;
    private double percentage;
    private int correctCount;
    private int incorrectCount;
    private String topicsToRevise;
    private Timestamp completedAt;

    // Optional transient fields for display
    private String quizTitle;

    public StudentPracticeAttempt() {}

    public StudentPracticeAttempt(int attemptId, int quizId, int studentId, int score,
                                  int totalMarks, double percentage, int correctCount,
                                  int incorrectCount, String topicsToRevise, Timestamp completedAt) {
        this.attemptId = attemptId;
        this.quizId = quizId;
        this.studentId = studentId;
        this.score = score;
        this.totalMarks = totalMarks;
        this.percentage = percentage;
        this.correctCount = correctCount;
        this.incorrectCount = incorrectCount;
        this.topicsToRevise = topicsToRevise;
        this.completedAt = completedAt;
    }

    public int getAttemptId() {
        return attemptId;
    }

    public void setAttemptId(int attemptId) {
        this.attemptId = attemptId;
    }

    public int getQuizId() {
        return quizId;
    }

    public void setQuizId(int quizId) {
        this.quizId = quizId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public int getTotalMarks() {
        return totalMarks;
    }

    public void setTotalMarks(int totalMarks) {
        this.totalMarks = totalMarks;
    }

    public double getPercentage() {
        return percentage;
    }

    public void setPercentage(double percentage) {
        this.percentage = percentage;
    }

    public int getCorrectCount() {
        return correctCount;
    }

    public void setCorrectCount(int correctCount) {
        this.correctCount = correctCount;
    }

    public int getIncorrectCount() {
        return incorrectCount;
    }

    public void setIncorrectCount(int incorrectCount) {
        this.incorrectCount = incorrectCount;
    }

    public String getTopicsToRevise() {
        return topicsToRevise;
    }

    public void setTopicsToRevise(String topicsToRevise) {
        this.topicsToRevise = topicsToRevise;
    }

    public Timestamp getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(Timestamp completedAt) {
        this.completedAt = completedAt;
    }

    public String getQuizTitle() {
        return quizTitle;
    }

    public void setQuizTitle(String quizTitle) {
        this.quizTitle = quizTitle;
    }
}
