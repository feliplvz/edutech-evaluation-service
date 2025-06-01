package com.edutech.evaluationservice.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "quiz_attempts")
public class QuizAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "student_id", nullable = false)
    private Long studentId;

    @Column(name = "quiz_id", nullable = false)
    private Long quizId;

    @Column(name = "score")
    private Double score;

    @Column(name = "max_score")
    private Double maxScore;

    @Column(name = "percentage")
    private Double percentage;

    @Column(name = "passed")
    private Boolean passed;

    @Column(name = "time_taken_seconds")
    private Integer timeTakenSeconds;

    @Column(name = "started_at")
    private LocalDateTime startedAt;

    @Column(name = "completed_at")
    private LocalDateTime completedAt;

    @Column(name = "attempt_number")
    private Integer attemptNumber;

    @Column(name = "status", nullable = false)
    private String status; // IN_PROGRESS, COMPLETED, TIMED_OUT

    @OneToMany(mappedBy = "quizAttempt", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<StudentAnswer> studentAnswers = new ArrayList<>();

    @PrePersist
    protected void onCreate() {
        startedAt = LocalDateTime.now();
        status = "IN_PROGRESS";
    }
}
