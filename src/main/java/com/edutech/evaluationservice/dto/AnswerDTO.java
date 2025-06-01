package com.edutech.evaluationservice.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AnswerDTO {

    private Long id;

    @NotBlank(message = "El texto de la respuesta es obligatorio")
    private String answerText;

    private boolean correct;

    private Integer orderIndex;

    private String feedback;

    private Long questionId;
}
