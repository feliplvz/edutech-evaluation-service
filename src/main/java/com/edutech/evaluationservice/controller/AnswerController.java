package com.edutech.evaluationservice.controller;

import com.edutech.evaluationservice.dto.AnswerDTO;
import com.edutech.evaluationservice.service.AnswerService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/answers")
public class AnswerController {

    private final AnswerService answerService;

    @Autowired
    public AnswerController(AnswerService answerService) {
        this.answerService = answerService;
    }

    @GetMapping("/question/{questionId}")
    public ResponseEntity<List<AnswerDTO>> getAnswersByQuestion(@PathVariable Long questionId) {
        return ResponseEntity.ok(answerService.getAnswersByQuestion(questionId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<AnswerDTO> getAnswerById(@PathVariable Long id) {
        return ResponseEntity.ok(answerService.getAnswerById(id));
    }

    @PostMapping
    public ResponseEntity<AnswerDTO> createAnswer(@Valid @RequestBody AnswerDTO answerDTO) {
        return new ResponseEntity<>(answerService.createAnswer(answerDTO), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<AnswerDTO> updateAnswer(
            @PathVariable Long id,
            @Valid @RequestBody AnswerDTO answerDTO) {
        return ResponseEntity.ok(answerService.updateAnswer(id, answerDTO));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteAnswer(@PathVariable Long id) {
        answerService.deleteAnswer(id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/question/{questionId}/reorder")
    public ResponseEntity<Void> reorderAnswers(
            @PathVariable Long questionId,
            @RequestBody List<Long> answerIds) {
        answerService.reorderAnswers(questionId, answerIds);
        return ResponseEntity.noContent().build();
    }
}
