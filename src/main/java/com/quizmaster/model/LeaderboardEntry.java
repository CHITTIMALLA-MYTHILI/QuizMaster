package com.quizmaster.model;

import java.sql.Timestamp;

public class LeaderboardEntry {

    private int rank;
    private String studentName;
    private String studentEmail;
    private String department;
    private String quizTitle;
    private int score;
    private int totalMarks;
    private double percentage;
    private String grade;
    private Timestamp completedAt;

    public LeaderboardEntry() {
    }

    public LeaderboardEntry(int rank, String studentName, String studentEmail,
                            String department, String quizTitle, int score,
                            int totalMarks, double percentage, String grade,
                            Timestamp completedAt) {
        this.rank = rank;
        this.studentName = studentName;
        this.studentEmail = studentEmail;
        this.department = department;
        this.quizTitle = quizTitle;
        this.score = score;
        this.totalMarks = totalMarks;
        this.percentage = percentage;
        this.grade = grade;
        this.completedAt = completedAt;
    }

    public int getRank() {
        return rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getStudentEmail() {
        return studentEmail;
    }

    public void setStudentEmail(String studentEmail) {
        this.studentEmail = studentEmail;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getQuizTitle() {
        return quizTitle;
    }

    public void setQuizTitle(String quizTitle) {
        this.quizTitle = quizTitle;
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

    public Timestamp getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(Timestamp completedAt) {
        this.completedAt = completedAt;
    }
}
