package com.quizmaster.model;

import java.sql.Timestamp;

public class Result {

    private int resultId;
    private int studentId;
    private int quizId;
    private int attemptId;
    private String quizTitle;
    private String studentName;
    private int score;
    private int totalMarks;
    private double percentage;
    private String grade;
    private int correctCount;
    private int incorrectCount;
    private int unansweredCount;
    private Timestamp createdAt;

    public Result() {
    }

    public Result(int resultId,
                  int studentId,
                  int quizId,
                  String quizTitle,
                  int score,
                  double percentage,
                  String grade) {

        this.resultId = resultId;
        this.studentId = studentId;
        this.quizId = quizId;
        this.quizTitle = quizTitle;
        this.score = score;
        this.percentage = percentage;
        this.grade = grade;
    }

    public Result(int resultId, int studentId, int quizId, int attemptId,
                  String quizTitle, String studentName, int score, int totalMarks,
                  double percentage, String grade, int correctCount, int incorrectCount,
                  int unansweredCount, Timestamp createdAt) {
        this.resultId = resultId;
        this.studentId = studentId;
        this.quizId = quizId;
        this.attemptId = attemptId;
        this.quizTitle = quizTitle;
        this.studentName = studentName;
        this.score = score;
        this.totalMarks = totalMarks;
        this.percentage = percentage;
        this.grade = grade;
        this.correctCount = correctCount;
        this.incorrectCount = incorrectCount;
        this.unansweredCount = unansweredCount;
        this.createdAt = createdAt;
    }

    public int getResultId() {
        return resultId;
    }

    public void setResultId(int resultId) {
        this.resultId = resultId;
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

    public int getAttemptId() {
        return attemptId;
    }

    public void setAttemptId(int attemptId) {
        this.attemptId = attemptId;
    }

    public String getQuizTitle() {
        return quizTitle;
    }

    public void setQuizTitle(String quizTitle) {
        this.quizTitle = quizTitle;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
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

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
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

    public int getUnansweredCount() {
        return unansweredCount;
    }

    public void setUnansweredCount(int unansweredCount) {
        this.unansweredCount = unansweredCount;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}