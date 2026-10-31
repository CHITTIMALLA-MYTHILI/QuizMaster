package com.quizmaster.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class StudentPracticeQuiz {
    private int quizId;
    private int studentId;
    private String title;
    private int questionCount;
    private String difficulty;
    private String questionType;
    private Timestamp createdAt;
    private List<StudentPracticeQuestion> questions = new ArrayList<>();

    public StudentPracticeQuiz() {}

    public StudentPracticeQuiz(int quizId, int studentId, String title, int questionCount,
                               String difficulty, String questionType, Timestamp createdAt) {
        this.quizId = quizId;
        this.studentId = studentId;
        this.title = title;
        this.questionCount = questionCount;
        this.difficulty = difficulty;
        this.questionType = questionType;
        this.createdAt = createdAt;
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

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getQuestionCount() {
        return questionCount;
    }

    public void setQuestionCount(int questionCount) {
        this.questionCount = questionCount;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }

    public String getQuestionType() {
        return questionType;
    }

    public void setQuestionType(String questionType) {
        this.questionType = questionType;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<StudentPracticeQuestion> getQuestions() {
        return questions;
    }

    public void setQuestions(List<StudentPracticeQuestion> questions) {
        this.questions = questions;
    }
}
