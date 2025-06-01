package com.edutech.evaluationservice.service;

import com.edutech.evaluationservice.dto.AnswerDTO;

import java.util.List;

public interface AnswerService {

    List<AnswerDTO> getAnswersByQuestion(Long questionId);

    AnswerDTO getAnswerById(Long id);

    AnswerDTO createAnswer(AnswerDTO answerDTO);

    AnswerDTO updateAnswer(Long id, AnswerDTO answerDTO);

    void deleteAnswer(Long id);

    void reorderAnswers(Long questionId, List<Long> answerIds);
}
