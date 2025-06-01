package com.edutech.evaluationservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentProgressDTO {

    private Long id;

    private Long studentId;

    private String studentName;

    private Long courseId;

    private String courseName;

    private LocalDateTime enrollmentDate;

    private LocalDateTime lastActivityDate;

    private LocalDateTime completionDate;

    private Double completionPercentage;

    private Integer lessonsCompleted;

    private Integer totalLessons;

    private Integer quizzesCompleted;

    private Integer totalQuizzes;

    private Double averageScore;

    private Integer totalTimeSpentMinutes;

    private Boolean certificateIssued;

    private String certificateUrl;

    private Boolean isCompleted;
}
