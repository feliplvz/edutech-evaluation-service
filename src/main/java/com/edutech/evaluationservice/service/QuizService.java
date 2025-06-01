package com.edutech.evaluationservice.service;

import com.edutech.evaluationservice.dto.QuizDTO;

import java.util.List;

public interface QuizService {

    List<QuizDTO> getAllQuizzes();

    QuizDTO getQuizById(Long id);

    List<QuizDTO> getQuizzesByCourse(Long courseId);

    List<QuizDTO> getQuizzesByLesson(Long lessonId);

    QuizDTO createQuiz(QuizDTO quizDTO);

    QuizDTO updateQuiz(Long id, QuizDTO quizDTO);

    void deactivateQuiz(Long id);

    void activateQuiz(Long id);

    void deleteQuiz(Long id);
}
