package com.edutech.evaluationservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class QuestionDTO {

    private Long id;

    @NotBlank(message = "El texto de la pregunta es obligatorio")
    private String questionText;

    @PositiveOrZero
    private Integer orderIndex;

    private String questionType; // MULTIPLE_CHOICE, SINGLE_CHOICE, TRUE_FALSE, ESSAY

    private String explanation;

    private Integer points = 1;

    private String difficultyLevel;

    private Long quizId;

    private String quizTitle;

    private List<AnswerDTO> answers = new ArrayList<>();
}
