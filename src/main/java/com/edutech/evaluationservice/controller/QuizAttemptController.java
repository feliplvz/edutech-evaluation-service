package com.edutech.evaluationservice.controller;

import com.edutech.evaluationservice.dto.QuizAttemptDTO;
import com.edutech.evaluationservice.dto.StudentAnswerDTO;
import com.edutech.evaluationservice.service.QuizAttemptService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/quiz-attempts")
public class QuizAttemptController {

    private final QuizAttemptService quizAttemptService;

    @Autowired
    public QuizAttemptController(QuizAttemptService quizAttemptService) {
        this.quizAttemptService = quizAttemptService;
    }

    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<QuizAttemptDTO>> getAttemptsByStudent(@PathVariable Long studentId) {
        return ResponseEntity.ok(quizAttemptService.getAttemptsByStudent(studentId));
    }

    @GetMapping("/quiz/{quizId}")
    public ResponseEntity<List<QuizAttemptDTO>> getAttemptsByQuiz(@PathVariable Long quizId) {
        return ResponseEntity.ok(quizAttemptService.getAttemptsByQuiz(quizId));
    }

    @GetMapping("/{attemptId}")
    public ResponseEntity<QuizAttemptDTO> getAttemptById(@PathVariable Long attemptId) {
        return ResponseEntity.ok(quizAttemptService.getAttemptById(attemptId));
    }

    @GetMapping("/student/{studentId}/quiz/{quizId}/latest")
    public ResponseEntity<QuizAttemptDTO> getLatestAttempt(
            @PathVariable Long studentId,
            @PathVariable Long quizId) {
        return ResponseEntity.ok(quizAttemptService.getLatestAttempt(studentId, quizId));
    }

    @GetMapping("/student/{studentId}/quiz/{quizId}/count")
    public ResponseEntity<Map<String, Integer>> getAttemptCount(
            @PathVariable Long studentId,
            @PathVariable Long quizId) {
        int count = quizAttemptService.getAttemptCount(studentId, quizId);
        return ResponseEntity.ok(Map.of("attemptCount", count));
    }

    @PostMapping("/student/{studentId}/quiz/{quizId}/start")
    public ResponseEntity<QuizAttemptDTO> startQuizAttempt(
            @PathVariable Long studentId,
            @PathVariable Long quizId) {
        return new ResponseEntity<>(quizAttemptService.startQuizAttempt(studentId, quizId), HttpStatus.CREATED);
    }

    @PostMapping("/{attemptId}/submit-answer")
    public ResponseEntity<QuizAttemptDTO> submitAnswer(
            @PathVariable Long attemptId,
            @Valid @RequestBody StudentAnswerDTO answerDTO) {
        return ResponseEntity.ok(quizAttemptService.submitAnswer(attemptId, answerDTO));
    }

    @PostMapping("/{attemptId}/complete")
    public ResponseEntity<QuizAttemptDTO> completeQuizAttempt(@PathVariable Long attemptId) {
        return ResponseEntity.ok(quizAttemptService.completeQuizAttempt(attemptId));
    }

    @GetMapping("/quiz/{quizId}/statistics/avg-score")
    public ResponseEntity<Map<String, Double>> getAverageScoreForQuiz(@PathVariable Long quizId) {
        double avgScore = quizAttemptService.getAverageScoreForQuiz(quizId);
        return ResponseEntity.ok(Map.of("averageScore", avgScore));
    }

    @GetMapping("/quiz/{quizId}/statistics/pass-rate")
    public ResponseEntity<Map<String, Integer>> getPassRateForQuiz(@PathVariable Long quizId) {
        int passRate = quizAttemptService.getPassRateForQuiz(quizId);
        return ResponseEntity.ok(Map.of("passRate", passRate));
    }
}
