package com.edutech.evaluationservice.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "student_progress")
public class StudentProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_id", nullable = false)
    private Long studentId;

    @Column(name = "course_id", nullable = false)
    private Long courseId;

    @Column(name = "enrollment_date", nullable = false)
    private LocalDateTime enrollmentDate;

    @Column(name = "last_activity_date")
    private LocalDateTime lastActivityDate;

    @Column(name = "completion_date")
    private LocalDateTime completionDate;

    @Column(name = "completion_percentage", nullable = false)
    private Double completionPercentage = 0.0;

    @Column(name = "lessons_completed", nullable = false)
    private Integer lessonsCompleted = 0;

    @Column(name = "total_lessons")
    private Integer totalLessons;

    @Column(name = "quizzes_completed", nullable = false)
    private Integer quizzesCompleted = 0;

    @Column(name = "total_quizzes")
    private Integer totalQuizzes;

    @Column(name = "average_score")
    private Double averageScore;

    @Column(name = "total_time_spent_minutes")
    private Integer totalTimeSpentMinutes = 0;

    @Column(name = "certificate_issued")
    private Boolean certificateIssued = false;

    @Column(name = "certificate_url")
    private String certificateUrl;

    @Column(name = "is_completed", nullable = false)
    private Boolean isCompleted = false;

    @PrePersist
    protected void onCreate() {
        enrollmentDate = LocalDateTime.now();
        lastActivityDate = LocalDateTime.now();
    }

    public void updateLastActivity() {
        lastActivityDate = LocalDateTime.now();
    }

    public void incrementTimeSpent(Integer minutes) {
        if (totalTimeSpentMinutes == null) {
            totalTimeSpentMinutes = 0;
        }
        totalTimeSpentMinutes += minutes;
    }
}
