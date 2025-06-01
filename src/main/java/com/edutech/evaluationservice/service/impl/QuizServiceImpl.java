package com.edutech.evaluationservice.service.impl;

import com.edutech.evaluationservice.dto.QuizDTO;
import com.edutech.evaluationservice.exception.ResourceNotFoundException;
import com.edutech.evaluationservice.model.Question;
import com.edutech.evaluationservice.model.Quiz;
import com.edutech.evaluationservice.repository.QuizRepository;
import com.edutech.evaluationservice.service.QuizService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class QuizServiceImpl implements QuizService {

    private final QuizRepository quizRepository;

    @Autowired
    public QuizServiceImpl(QuizRepository quizRepository) {
        this.quizRepository = quizRepository;
    }

    @Override
    public List<QuizDTO> getAllQuizzes() {
        return quizRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public QuizDTO getQuizById(Long id) {
        Quiz quiz = quizRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Examen", "id", id));
        return convertToDTO(quiz);
    }

    @Override
    public List<QuizDTO> getQuizzesByCourse(Long courseId) {
        return quizRepository.findByCourseId(courseId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<QuizDTO> getQuizzesByLesson(Long lessonId) {
        return quizRepository.findByLessonId(lessonId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public QuizDTO createQuiz(QuizDTO quizDTO) {
        Quiz quiz = new Quiz();
        updateQuizFromDTO(quiz, quizDTO);

        Quiz savedQuiz = quizRepository.save(quiz);
        return convertToDTO(savedQuiz);
    }

    @Override
    @Transactional
    public QuizDTO updateQuiz(Long id, QuizDTO quizDTO) {
        Quiz quiz = quizRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Examen", "id", id));

        updateQuizFromDTO(quiz, quizDTO);

        Quiz updatedQuiz = quizRepository.save(quiz);
        return convertToDTO(updatedQuiz);
    }

    @Override
    @Transactional
    public void deactivateQuiz(Long id) {
        Quiz quiz = quizRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Examen", "id", id));

        quiz.setActive(false);
        quizRepository.save(quiz);
    }

    @Override
    @Transactional
    public void activateQuiz(Long id) {
        Quiz quiz = quizRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Examen", "id", id));

        quiz.setActive(true);
        quizRepository.save(quiz);
    }

    @Override
    @Transactional
    public void deleteQuiz(Long id) {
        Quiz quiz = quizRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Examen", "id", id));

        quizRepository.delete(quiz);
    }

    // Método auxiliar para actualizar una entidad Quiz a partir de un DTO
    private void updateQuizFromDTO(Quiz quiz, QuizDTO quizDTO) {
        quiz.setTitle(quizDTO.getTitle());
        quiz.setDescription(quizDTO.getDescription());
        quiz.setCourseId(quizDTO.getCourseId());
        quiz.setLessonId(quizDTO.getLessonId());
        quiz.setPassingScore(quizDTO.getPassingScore());
        quiz.setTimeLimitMinutes(quizDTO.getTimeLimitMinutes());
        quiz.setShuffleQuestions(quizDTO.isShuffleQuestions());
        quiz.setShowAnswers(quizDTO.isShowAnswers());
        quiz.setMaxAttempts(quizDTO.getMaxAttempts());
        quiz.setActive(quizDTO.isActive());
    }

    // Método para convertir una entidad Quiz a DTO
    private QuizDTO convertToDTO(Quiz quiz) {
        QuizDTO quizDTO = new QuizDTO();
        quizDTO.setId(quiz.getId());
        quizDTO.setTitle(quiz.getTitle());
        quizDTO.setDescription(quiz.getDescription());
        quizDTO.setCourseId(quiz.getCourseId());
        quizDTO.setLessonId(quiz.getLessonId());
        quizDTO.setPassingScore(quiz.getPassingScore());
        quizDTO.setTimeLimitMinutes(quiz.getTimeLimitMinutes());
        quizDTO.setShuffleQuestions(quiz.isShuffleQuestions());
        quizDTO.setShowAnswers(quiz.isShowAnswers());
        quizDTO.setMaxAttempts(quiz.getMaxAttempts());
        quizDTO.setActive(quiz.isActive());
        quizDTO.setCreatedAt(quiz.getCreatedAt());
        quizDTO.setUpdatedAt(quiz.getUpdatedAt());

        // Contar preguntas y puntos totales
        quizDTO.setQuestionCount(quiz.getQuestions().size());
        quizDTO.setTotalPointsPossible(
            quiz.getQuestions().stream()
                .mapToInt(Question::getPoints)
                .sum()
        );

        return quizDTO;
    }
}
