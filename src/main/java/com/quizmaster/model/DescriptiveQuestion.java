package com.quizmaster.model;

import java.sql.Timestamp;

public class DescriptiveQuestion {

    private int descQuestionId;
    private int quizId;
    private String questionText;
    private int maxMarks;
    private String referenceAnswer;
    private String rubric;
    private String expectedConcepts;
    private Timestamp createdAt;

    public DescriptiveQuestion() {
    }

    public DescriptiveQuestion(int descQuestionId, int quizId, String questionText, int maxMarks,
                               String referenceAnswer, String rubric, String expectedConcepts, Timestamp createdAt) {
        this.descQuestionId = descQuestionId;
        this.quizId = quizId;
        this.questionText = questionText;
        this.maxMarks = maxMarks;
        this.referenceAnswer = referenceAnswer;
        this.rubric = rubric;
        this.expectedConcepts = expectedConcepts;
        this.createdAt = createdAt;
    }

    public int getDescQuestionId() {
        return descQuestionId;
    }

    public void setDescQuestionId(int descQuestionId) {
        this.descQuestionId = descQuestionId;
    }

    public int getQuizId() {
        return quizId;
    }

    public void setQuizId(int quizId) {
        this.quizId = quizId;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public int getMaxMarks() {
        return maxMarks;
    }

    public void setMaxMarks(int maxMarks) {
        this.maxMarks = maxMarks;
    }

    public String getReferenceAnswer() {
        return referenceAnswer;
    }

    public void setReferenceAnswer(String referenceAnswer) {
        this.referenceAnswer = referenceAnswer;
    }

    public String getRubric() {
        return rubric;
    }

    public void setRubric(String rubric) {
        this.rubric = rubric;
    }

    public String getExpectedConcepts() {
        return expectedConcepts;
    }

    public void setExpectedConcepts(String expectedConcepts) {
        this.expectedConcepts = expectedConcepts;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
