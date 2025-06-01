package com.edutech.evaluationservice.service;

import com.edutech.evaluationservice.dto.QuestionDTO;

import java.util.List;

public interface QuestionService {

    List<QuestionDTO> getAllQuestions();

    QuestionDTO getQuestionById(Long id);

    List<QuestionDTO> getQuestionsByQuiz(Long quizId);

    List<QuestionDTO> getQuestionsByType(String questionType);

    QuestionDTO createQuestion(QuestionDTO questionDTO);

    QuestionDTO updateQuestion(Long id, QuestionDTO questionDTO);

    void deleteQuestion(Long id);

    void reorderQuestions(Long quizId, List<Long> questionIds);
}
