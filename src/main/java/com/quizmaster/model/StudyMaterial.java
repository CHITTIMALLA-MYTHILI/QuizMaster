package com.quizmaster.model;

import java.sql.Timestamp;

public class StudyMaterial {

    private int materialId;
    private String title;
    private String category;
    private String contentText;
    private String fileName;
    private Integer createdBy;
    private Timestamp createdAt;

    public StudyMaterial() {
    }

    public StudyMaterial(int materialId, String title, String category, String contentText, String fileName, Integer createdBy, Timestamp createdAt) {
        this.materialId = materialId;
        this.title = title;
        this.category = category;
        this.contentText = contentText;
        this.fileName = fileName;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    public int getMaterialId() {
        return materialId;
    }

    public void setMaterialId(int materialId) {
        this.materialId = materialId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getContentText() {
        return contentText;
    }

    public void setContentText(String contentText) {
        this.contentText = contentText;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
