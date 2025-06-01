package com.edutech.evaluationservice.service.impl;

import com.edutech.evaluationservice.dto.AnswerDTO;
import com.edutech.evaluationservice.exception.ResourceNotFoundException;
import com.edutech.evaluationservice.model.Answer;
import com.edutech.evaluationservice.model.Question;
import com.edutech.evaluationservice.repository.AnswerRepository;
import com.edutech.evaluationservice.repository.QuestionRepository;
import com.edutech.evaluationservice.service.AnswerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class AnswerServiceImpl implements AnswerService {

    private final AnswerRepository answerRepository;
    private final QuestionRepository questionRepository;

    @Autowired
    public AnswerServiceImpl(AnswerRepository answerRepository, QuestionRepository questionRepository) {
        this.answerRepository = answerRepository;
        this.questionRepository = questionRepository;
    }

    @Override
    public List<AnswerDTO> getAnswersByQuestion(Long questionId) {
        // Verificar si la pregunta existe
        if (!questionRepository.existsById(questionId)) {
            throw new ResourceNotFoundException("Pregunta", "id", questionId);
        }

        return answerRepository.findByQuestionIdOrderByOrderIndex(questionId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public AnswerDTO getAnswerById(Long id) {
        Answer answer = answerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Respuesta", "id", id));
        return convertToDTO(answer);
    }

    @Override
    @Transactional
    public AnswerDTO createAnswer(AnswerDTO answerDTO) {
        // Verificar si la pregunta existe
        Question question = questionRepository.findById(answerDTO.getQuestionId())
                .orElseThrow(() -> new ResourceNotFoundException("Pregunta", "id", answerDTO.getQuestionId()));

        Answer answer = new Answer();
        answer.setQuestion(question);
        updateAnswerFromDTO(answer, answerDTO);

        // Si no se proporciona un orden, establecerlo al final
        if (answer.getOrderIndex() == null) {
            int nextIndex = question.getAnswers().size();
            answer.setOrderIndex(nextIndex);
        }

        Answer savedAnswer = answerRepository.save(answer);
        return convertToDTO(savedAnswer);
    }

    @Override
    @Transactional
    public AnswerDTO updateAnswer(Long id, AnswerDTO answerDTO) {
        Answer answer = answerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Respuesta", "id", id));

        updateAnswerFromDTO(answer, answerDTO);

        Answer updatedAnswer = answerRepository.save(answer);
        return convertToDTO(updatedAnswer);
    }

    @Override
    @Transactional
    public void deleteAnswer(Long id) {
        Answer answer = answerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Respuesta", "id", id));

        answerRepository.delete(answer);

        // Reordenar las respuestas restantes
        List<Answer> remainingAnswers = answerRepository.findByQuestionIdOrderByOrderIndex(answer.getQuestion().getId());
        for (int i = 0; i < remainingAnswers.size(); i++) {
            Answer a = remainingAnswers.get(i);
            a.setOrderIndex(i);
            answerRepository.save(a);
        }
    }

    @Override
    @Transactional
    public void reorderAnswers(Long questionId, List<Long> answerIds) {
        // Verificar si la pregunta existe
        if (!questionRepository.existsById(questionId)) {
            throw new ResourceNotFoundException("Pregunta", "id", questionId);
        }

        // Verificar si todas las respuestas existen y pertenecen a la pregunta
        List<Answer> answers = answerRepository.findAllById(answerIds);
        if (answers.size() != answerIds.size()) {
            throw new IllegalArgumentException("No se encontraron todas las respuestas especificadas");
        }

        for (Answer answer : answers) {
            if (!answer.getQuestion().getId().equals(questionId)) {
                throw new IllegalArgumentException("Una o más respuestas no pertenecen a la pregunta especificada");
            }
        }

        // Reordenar las respuestas
        for (int i = 0; i < answerIds.size(); i++) {
            Long answerId = answerIds.get(i);
            Answer answer = answerRepository.findById(answerId)
                    .orElseThrow(() -> new ResourceNotFoundException("Respuesta", "id", answerId));

            answer.setOrderIndex(i);
            answerRepository.save(answer);
        }
    }

    // Método auxiliar para actualizar una respuesta a partir de un DTO
    private void updateAnswerFromDTO(Answer answer, AnswerDTO answerDTO) {
        answer.setAnswerText(answerDTO.getAnswerText());
        answer.setCorrect(answerDTO.isCorrect());
        answer.setOrderIndex(answerDTO.getOrderIndex());
        answer.setFeedback(answerDTO.getFeedback());
    }

    // Método para convertir una entidad Answer a DTO
    private AnswerDTO convertToDTO(Answer answer) {
        AnswerDTO answerDTO = new AnswerDTO();
        answerDTO.setId(answer.getId());
        answerDTO.setAnswerText(answer.getAnswerText());
        answerDTO.setCorrect(answer.isCorrect());
        answerDTO.setOrderIndex(answer.getOrderIndex());
        answerDTO.setFeedback(answer.getFeedback());
        answerDTO.setQuestionId(answer.getQuestion().getId());
        return answerDTO;
    }
}
