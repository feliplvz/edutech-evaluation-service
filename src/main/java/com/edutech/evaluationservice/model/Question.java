package com.edutech.evaluationservice.model;

import jakarta.persistence.*;
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
@Entity
@Table(name = "questions")
public class Question {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El texto de la pregunta es obligatorio")
    @Column(name = "question_text", nullable = false, columnDefinition = "TEXT")
    private String questionText;

    @PositiveOrZero
    @Column(name = "order_index")
    private Integer orderIndex;

    @Column(name = "question_type", nullable = false)
    private String questionType; // MULTIPLE_CHOICE, SINGLE_CHOICE, TRUE_FALSE, ESSAY

    @Column(columnDefinition = "TEXT")
    private String explanation; // Explicación que aparece después de responder

    @Column(name = "points", nullable = false)
    private Integer points = 1; // Puntos que vale la pregunta

    @Column(name = "difficulty_level")
    private String difficultyLevel; // EASY, MEDIUM, HARD

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", nullable = false)
    private Quiz quiz;

    @OneToMany(mappedBy = "question", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Answer> answers = new ArrayList<>();
}
