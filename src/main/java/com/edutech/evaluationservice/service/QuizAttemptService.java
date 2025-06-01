package com.edutech.evaluationservice.service;

import com.edutech.evaluationservice.dto.QuizAttemptDTO;
import com.edutech.evaluationservice.dto.StudentAnswerDTO;

import java.util.List;

public interface QuizAttemptService {

    List<QuizAttemptDTO> getAttemptsByStudent(Long studentId);

    List<QuizAttemptDTO> getAttemptsByQuiz(Long quizId);

    QuizAttemptDTO getAttemptById(Long attemptId);

    QuizAttemptDTO getLatestAttempt(Long studentId, Long quizId);

    int getAttemptCount(Long studentId, Long quizId);

    QuizAttemptDTO startQuizAttempt(Long studentId, Long quizId);

    QuizAttemptDTO submitAnswer(Long attemptId, StudentAnswerDTO answerDTO);

    QuizAttemptDTO completeQuizAttempt(Long attemptId);

    double getAverageScoreForQuiz(Long quizId);

    int getPassRateForQuiz(Long quizId);
}
