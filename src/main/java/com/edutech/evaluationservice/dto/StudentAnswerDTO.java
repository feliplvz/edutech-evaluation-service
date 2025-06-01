package com.edutech.evaluationservice.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentAnswerDTO {

    private Long id;

    private Long questionId;

    private String questionText;

    private Long answerId;

    private String answerText;

    private String essayAnswer;

    private Boolean isCorrect;

    private Double pointsEarned;

    private LocalDateTime submittedAt;

    private Long quizAttemptId;
}
