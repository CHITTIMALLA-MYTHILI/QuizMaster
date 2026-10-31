package com.quizmaster.model;

import java.util.ArrayList;
import java.util.List;

public class DashboardStats {

    private int totalQuizzes;
    private int publishedQuizzes;
    private int draftQuizzes;
    private int totalStudents;
    private int totalAttempts;
    private List<RecentActivity> recentActivities = new ArrayList<>();

    public DashboardStats() {
    }

    public int getTotalQuizzes() {
        return totalQuizzes;
    }

    public void setTotalQuizzes(int totalQuizzes) {
        this.totalQuizzes = totalQuizzes;
    }

    public int getPublishedQuizzes() {
        return publishedQuizzes;
    }

    public void setPublishedQuizzes(int publishedQuizzes) {
        this.publishedQuizzes = publishedQuizzes;
    }

    public int getDraftQuizzes() {
        return draftQuizzes;
    }

    public void setDraftQuizzes(int draftQuizzes) {
        this.draftQuizzes = draftQuizzes;
    }

    public int getTotalStudents() {
        return totalStudents;
    }

    public void setTotalStudents(int totalStudents) {
        this.totalStudents = totalStudents;
    }

    public int getTotalAttempts() {
        return totalAttempts;
    }

    public void setTotalAttempts(int totalAttempts) {
        this.totalAttempts = totalAttempts;
    }

    public List<RecentActivity> getRecentActivities() {
        return recentActivities;
    }

    public void setRecentActivities(List<RecentActivity> recentActivities) {
        this.recentActivities = recentActivities;
    }

    public static class RecentActivity {
        private int attemptId;
        private String studentName;
        private String quizTitle;
        private int score;
        private int totalMarks;
        private String grade;
        private String status;
        private String completedAt;
        private String formattedTime;

        public RecentActivity() {
        }

        public RecentActivity(int attemptId, String studentName, String quizTitle,
                              int score, int totalMarks, String grade, String status,
                              String completedAt, String formattedTime) {
            this.attemptId = attemptId;
            this.studentName = studentName;
            this.quizTitle = quizTitle;
            this.score = score;
            this.totalMarks = totalMarks;
            this.grade = grade;
            this.status = status;
            this.completedAt = completedAt;
            this.formattedTime = formattedTime;
        }

        public int getAttemptId() {
            return attemptId;
        }

        public void setAttemptId(int attemptId) {
            this.attemptId = attemptId;
        }

        public String getStudentName() {
            return studentName;
        }

        public void setStudentName(String studentName) {
            this.studentName = studentName;
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

        public String getGrade() {
            if (grade != null && !grade.trim().isEmpty()) {
                return grade;
            }
            if (totalMarks > 0) {
                double pct = ((double) score / totalMarks) * 100.0;
                if (pct >= 90) return "A+";
                if (pct >= 80) return "A";
                if (pct >= 70) return "B";
                if (pct >= 60) return "C";
                if (pct >= 50) return "D";
                return "F";
            }
            return "N/A";
        }

        public void setGrade(String grade) {
            this.grade = grade;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getCompletedAt() {
            if (completedAt != null && !completedAt.trim().isEmpty()) {
                return completedAt;
            }
            return formattedTime != null ? formattedTime : "N/A";
        }

        public void setCompletedAt(String completedAt) {
            this.completedAt = completedAt;
        }

        public String getFormattedTime() {
            return formattedTime;
        }

        public void setFormattedTime(String formattedTime) {
            this.formattedTime = formattedTime;
        }
    }
}
