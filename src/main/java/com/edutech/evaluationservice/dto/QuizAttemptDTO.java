package com.edutech.evaluationservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class QuizAttemptDTO {

    private Long id;

    private Long studentId;

    private String studentName;

    private Long quizId;

    private String quizTitle;

    private Double score;

    private Double maxScore;

    private Double percentage;

    private Boolean passed;

    private Integer timeTakenSeconds;

    private LocalDateTime startedAt;

    private LocalDateTime completedAt;

    private Integer attemptNumber;

    private String status;

    private List<StudentAnswerDTO> studentAnswers = new ArrayList<>();
}
