package com.edutech.evaluationservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class QuizDTO {

    private Long id;

    @NotBlank(message = "El título del examen es obligatorio")
    @Size(min = 3, max = 100, message = "El título debe tener entre 3 y 100 caracteres")
    private String title;

    private String description;

    @NotNull(message = "El ID del curso es obligatorio")
    private Long courseId;

    private String courseName;

    private Long lessonId;

    private String lessonTitle;

    @PositiveOrZero
    private Integer passingScore = 60;

    @PositiveOrZero
    private Integer timeLimitMinutes;

    private boolean shuffleQuestions;

    private boolean showAnswers;

    private Integer maxAttempts;

    private boolean active = true;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    private int questionCount;

    private int totalPointsPossible;
}
