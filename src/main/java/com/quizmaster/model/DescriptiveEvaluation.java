package com.quizmaster.model;

import java.sql.Timestamp;

public class DescriptiveEvaluation {

    private int evaluationId;
    private int descQuestionId;
    private int studentId;
    private int attemptId;
    private String studentAnswer;
    private int awardedMarks;
    private String criterionFeedback;
    private String conceptsIdentified;
    private String missingConcepts;
    private String suggestions;
    private boolean isAdminOverridden;
    private String adminNotes;
    private Timestamp evaluatedAt;

    private String questionText;
    private int maxMarks;
    private String studentName;

    public DescriptiveEvaluation() {
    }

    public int getEvaluationId() {
        return evaluationId;
    }

    public void setEvaluationId(int evaluationId) {
        this.evaluationId = evaluationId;
    }

    public int getDescQuestionId() {
        return descQuestionId;
    }

    public void setDescQuestionId(int descQuestionId) {
        this.descQuestionId = descQuestionId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public int getAttemptId() {
        return attemptId;
    }

    public void setAttemptId(int attemptId) {
        this.attemptId = attemptId;
    }

    public String getStudentAnswer() {
        return studentAnswer;
    }

    public void setStudentAnswer(String studentAnswer) {
        this.studentAnswer = studentAnswer;
    }

    public int getAwardedMarks() {
        return awardedMarks;
    }

    public void setAwardedMarks(int awardedMarks) {
        this.awardedMarks = awardedMarks;
    }

    public String getCriterionFeedback() {
        return criterionFeedback;
    }

    public void setCriterionFeedback(String criterionFeedback) {
        this.criterionFeedback = criterionFeedback;
    }

    public String getConceptsIdentified() {
        return conceptsIdentified;
    }

    public void setConceptsIdentified(String conceptsIdentified) {
        this.conceptsIdentified = conceptsIdentified;
    }

    public String getMissingConcepts() {
        return missingConcepts;
    }

    public void setMissingConcepts(String missingConcepts) {
        this.missingConcepts = missingConcepts;
    }

    public String getSuggestions() {
        return suggestions;
    }

    public void setSuggestions(String suggestions) {
        this.suggestions = suggestions;
    }

    public boolean isAdminOverridden() {
        return isAdminOverridden;
    }

    public void setAdminOverridden(boolean adminOverridden) {
        isAdminOverridden = adminOverridden;
    }

    public String getAdminNotes() {
        return adminNotes;
    }

    public void setAdminNotes(String adminNotes) {
        this.adminNotes = adminNotes;
    }

    public Timestamp getEvaluatedAt() {
        return evaluatedAt;
    }

    public void setEvaluatedAt(Timestamp evaluatedAt) {
        this.evaluatedAt = evaluatedAt;
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

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }
}
