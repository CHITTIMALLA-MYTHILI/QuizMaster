package com.quizmaster.model;

import java.sql.Timestamp;

public class Attempt {

    private int attemptId;
    private int studentId;
    private int quizId;
    private Timestamp startTime;
    private Timestamp endTime;
    private int score;
    private String status = "IN_PROGRESS";

    public Attempt() {
    }

    public Attempt(int attemptId,
                   int studentId,
                   int quizId,
                   Timestamp startTime,
                   Timestamp endTime,
                   int score) {

        this.attemptId = attemptId;
        this.studentId = studentId;
        this.quizId = quizId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.score = score;
        this.status = "COMPLETED";
    }

    public Attempt(int attemptId,
                   int studentId,
                   int quizId,
                   Timestamp startTime,
                   Timestamp endTime,
                   int score,
                   String status) {

        this.attemptId = attemptId;
        this.studentId = studentId;
        this.quizId = quizId;
        this.startTime = startTime;
        this.endTime = endTime;
        this.score = score;
        this.status = status;
    }

    public int getAttemptId() {
        return attemptId;
    }

    public void setAttemptId(int attemptId) {
        this.attemptId = attemptId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public int getQuizId() {
        return quizId;
    }

    public void setQuizId(int quizId) {
        this.quizId = quizId;
    }

    public Timestamp getStartTime() {
        return startTime;
    }

    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }

    public Timestamp getEndTime() {
        return endTime;
    }

    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isCompleted() {
        return "COMPLETED".equalsIgnoreCase(status);
    }

    public boolean isInProgress() {
        return "IN_PROGRESS".equalsIgnoreCase(status);
    }
}