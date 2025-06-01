package com.edutech.evaluationservice.service.impl;

import com.edutech.evaluationservice.dto.AnswerDTO;
import com.edutech.evaluationservice.dto.QuestionDTO;
import com.edutech.evaluationservice.exception.ResourceNotFoundException;
import com.edutech.evaluationservice.model.Answer;
import com.edutech.evaluationservice.model.Question;
import com.edutech.evaluationservice.model.Quiz;
import com.edutech.evaluationservice.repository.QuestionRepository;
import com.edutech.evaluationservice.repository.QuizRepository;
import com.edutech.evaluationservice.service.QuestionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
public class QuestionServiceImpl implements QuestionService {

    private final QuestionRepository questionRepository;
    private final QuizRepository quizRepository;

    @Autowired
    public QuestionServiceImpl(QuestionRepository questionRepository, QuizRepository quizRepository) {
        this.questionRepository = questionRepository;
        this.quizRepository = quizRepository;
    }

    @Override
    public List<QuestionDTO> getAllQuestions() {
        return questionRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public QuestionDTO getQuestionById(Long id) {
        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Pregunta", "id", id));
        return convertToDTO(question);
    }

    @Override
    public List<QuestionDTO> getQuestionsByQuiz(Long quizId) {
        // Verificar si el examen existe
        if (!quizRepository.existsById(quizId)) {
            throw new ResourceNotFoundException("Examen", "id", quizId);
        }

        return questionRepository.findByQuizIdOrderByOrderIndex(quizId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<QuestionDTO> getQuestionsByType(String questionType) {
        return questionRepository.findByQuestionType(questionType).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public QuestionDTO createQuestion(QuestionDTO questionDTO) {
        // Verificar si el examen existe
        Quiz quiz = quizRepository.findById(questionDTO.getQuizId())
                .orElseThrow(() -> new ResourceNotFoundException("Examen", "id", questionDTO.getQuizId()));

        Question question = new Question();
        question.setQuiz(quiz);
        updateQuestionFromDTO(question, questionDTO);

        // Si no se proporciona un orden, establecerlo al final
        if (question.getOrderIndex() == null) {
            int nextIndex = quiz.getQuestions().size();
            question.setOrderIndex(nextIndex);
        }

        Question savedQuestion = questionRepository.save(question);
        return convertToDTO(savedQuestion);
    }

    @Override
    @Transactional
    public QuestionDTO updateQuestion(Long id, QuestionDTO questionDTO) {
        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Pregunta", "id", id));

        updateQuestionFromDTO(question, questionDTO);

        Question updatedQuestion = questionRepository.save(question);
        return convertToDTO(updatedQuestion);
    }

    @Override
    @Transactional
    public void deleteQuestion(Long id) {
        Question question = questionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Pregunta", "id", id));

        questionRepository.delete(question);

        // Reordenar las preguntas restantes
        List<Question> remainingQuestions = questionRepository.findByQuizIdOrderByOrderIndex(question.getQuiz().getId());
        IntStream.range(0, remainingQuestions.size())
                .forEach(index -> {
                    Question q = remainingQuestions.get(index);
                    q.setOrderIndex(index);
                    questionRepository.save(q);
                });
    }

    @Override
    @Transactional
    public void reorderQuestions(Long quizId, List<Long> questionIds) {
        // Verificar si el examen existe
        if (!quizRepository.existsById(quizId)) {
            throw new ResourceNotFoundException("Examen", "id", quizId);
        }

        // Verificar si todas las preguntas existen y pertenecen al examen
        List<Question> questions = questionRepository.findAllById(questionIds);
        if (questions.size() != questionIds.size()) {
            throw new IllegalArgumentException("No se encontraron todas las preguntas especificadas");
        }

        for (Question question : questions) {
            if (!question.getQuiz().getId().equals(quizId)) {
                throw new IllegalArgumentException("Una o más preguntas no pertenecen al examen especificado");
            }
        }

        // Reordenar las preguntas
        for (int i = 0; i < questionIds.size(); i++) {
            Long questionId = questionIds.get(i);
            Question question = questionRepository.findById(questionId)
                    .orElseThrow(() -> new ResourceNotFoundException("Pregunta", "id", questionId));

            question.setOrderIndex(i);
            questionRepository.save(question);
        }
    }

    // Método auxiliar para actualizar una pregunta a partir de un DTO
    private void updateQuestionFromDTO(Question question, QuestionDTO questionDTO) {
        question.setQuestionText(questionDTO.getQuestionText());
        question.setOrderIndex(questionDTO.getOrderIndex());
        question.setQuestionType(questionDTO.getQuestionType());
        question.setExplanation(questionDTO.getExplanation());
        question.setPoints(questionDTO.getPoints());
        question.setDifficultyLevel(questionDTO.getDifficultyLevel());
    }

    // Método para convertir una entidad Question a DTO
    private QuestionDTO convertToDTO(Question question) {
        QuestionDTO questionDTO = new QuestionDTO();
        questionDTO.setId(question.getId());
        questionDTO.setQuestionText(question.getQuestionText());
        questionDTO.setOrderIndex(question.getOrderIndex());
        questionDTO.setQuestionType(question.getQuestionType());
        questionDTO.setExplanation(question.getExplanation());
        questionDTO.setPoints(question.getPoints());
        questionDTO.setDifficultyLevel(question.getDifficultyLevel());

        questionDTO.setQuizId(question.getQuiz().getId());
        questionDTO.setQuizTitle(question.getQuiz().getTitle());

        // Convertir las respuestas asociadas
        List<AnswerDTO> answerDTOs = question.getAnswers().stream()
                .map(this::convertAnswerToDTO)
                .collect(Collectors.toList());
        questionDTO.setAnswers(answerDTOs);

        return questionDTO;
    }

    // Método para convertir una entidad Answer a DTO
    private AnswerDTO convertAnswerToDTO(Answer answer) {
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
