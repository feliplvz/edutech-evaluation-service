package com.edutech.evaluationservice.service.impl;

import com.edutech.evaluationservice.dto.QuizAttemptDTO;
import com.edutech.evaluationservice.dto.StudentAnswerDTO;
import com.edutech.evaluationservice.exception.ResourceNotFoundException;
import com.edutech.evaluationservice.model.*;
import com.edutech.evaluationservice.repository.*;
import com.edutech.evaluationservice.service.QuizAttemptService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class QuizAttemptServiceImpl implements QuizAttemptService {

    private final QuizAttemptRepository quizAttemptRepository;
    private final QuizRepository quizRepository;
    private final QuestionRepository questionRepository;
    private final AnswerRepository answerRepository;
    private final StudentAnswerRepository studentAnswerRepository;
    private final StudentProgressRepository studentProgressRepository;

    @Autowired
    public QuizAttemptServiceImpl(
            QuizAttemptRepository quizAttemptRepository,
            QuizRepository quizRepository,
            QuestionRepository questionRepository,
            AnswerRepository answerRepository,
            StudentAnswerRepository studentAnswerRepository,
            StudentProgressRepository studentProgressRepository) {
        this.quizAttemptRepository = quizAttemptRepository;
        this.quizRepository = quizRepository;
        this.questionRepository = questionRepository;
        this.answerRepository = answerRepository;
        this.studentAnswerRepository = studentAnswerRepository;
        this.studentProgressRepository = studentProgressRepository;
    }

    @Override
    public List<QuizAttemptDTO> getAttemptsByStudent(Long studentId) {
        return quizAttemptRepository.findByStudentId(studentId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<QuizAttemptDTO> getAttemptsByQuiz(Long quizId) {
        return quizAttemptRepository.findByQuizId(quizId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public QuizAttemptDTO getAttemptById(Long attemptId) {
        QuizAttempt attempt = quizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new ResourceNotFoundException("Intento de examen", "id", attemptId));
        return convertToDTO(attempt);
    }

    @Override
    public QuizAttemptDTO getLatestAttempt(Long studentId, Long quizId) {
        QuizAttempt attempt = quizAttemptRepository.findLatestAttempt(studentId, quizId)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "No se encontró ningún intento para el estudiante " + studentId + " en el examen " + quizId));
        return convertToDTO(attempt);
    }

    @Override
    public int getAttemptCount(Long studentId, Long quizId) {
        return quizAttemptRepository.countCompletedAttempts(studentId, quizId);
    }

    @Override
    @Transactional
    public QuizAttemptDTO startQuizAttempt(Long studentId, Long quizId) {
        // Verificar si el examen existe
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new ResourceNotFoundException("Examen", "id", quizId));

        // Verificar límites de intentos si corresponde
        if (quiz.getMaxAttempts() != null) {
            int attemptCount = quizAttemptRepository.countCompletedAttempts(studentId, quizId);
            if (attemptCount >= quiz.getMaxAttempts()) {
                throw new IllegalStateException(
                    "Se ha alcanzado el número máximo de intentos (" + quiz.getMaxAttempts() + ") para este examen.");
            }
        }

        // Verificar si hay un intento en progreso
        Optional<QuizAttempt> inProgressAttempt = quizAttemptRepository.findByStudentIdAndQuizId(studentId, quizId).stream()
                .filter(attempt -> "IN_PROGRESS".equals(attempt.getStatus()))
                .findFirst();

        if (inProgressAttempt.isPresent()) {
            return convertToDTO(inProgressAttempt.get());
        }

        // Crear un nuevo intento
        QuizAttempt newAttempt = new QuizAttempt();
        newAttempt.setStudentId(studentId);
        newAttempt.setQuizId(quizId);
        newAttempt.setStatus("IN_PROGRESS");

        // Calcular el número de intento
        int attemptNumber = quizAttemptRepository.findByStudentIdAndQuizId(studentId, quizId).size() + 1;
        newAttempt.setAttemptNumber(attemptNumber);

        return convertToDTO(quizAttemptRepository.save(newAttempt));
    }

    @Override
    @Transactional
    public QuizAttemptDTO submitAnswer(Long attemptId, StudentAnswerDTO answerDTO) {
        // Verificar si el intento existe y está en progreso
        QuizAttempt attempt = quizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new ResourceNotFoundException("Intento de examen", "id", attemptId));

        if (!"IN_PROGRESS".equals(attempt.getStatus())) {
            throw new IllegalStateException("Este intento de examen ya ha sido completado o cancelado.");
        }

        // Verificar si la pregunta existe
        Question question = questionRepository.findById(answerDTO.getQuestionId())
                .orElseThrow(() -> new ResourceNotFoundException("Pregunta", "id", answerDTO.getQuestionId()));

        // Crear la respuesta del estudiante
        StudentAnswer studentAnswer = new StudentAnswer();
        studentAnswer.setQuizAttempt(attempt);
        studentAnswer.setQuestionId(question.getId());

        // Manejar diferentes tipos de preguntas
        if ("ESSAY".equals(question.getQuestionType())) {
            // Para preguntas de ensayo, almacenamos el texto de la respuesta
            studentAnswer.setEssayAnswer(answerDTO.getEssayAnswer());
            studentAnswer.setIsCorrect(null); // La corrección debe ser manual
            studentAnswer.setPointsEarned(0.0); // Por defecto, hasta que sea calificado
        } else {
            // Para preguntas de opción
            if (answerDTO.getAnswerId() != null) {
                // Verificar si la respuesta existe
                Answer answer = answerRepository.findById(answerDTO.getAnswerId())
                        .orElseThrow(() -> new ResourceNotFoundException("Respuesta", "id", answerDTO.getAnswerId()));

                studentAnswer.setAnswerId(answer.getId());
                studentAnswer.setIsCorrect(answer.isCorrect());

                // Asignar puntos basados en la correctitud de la respuesta
                studentAnswer.setPointsEarned(answer.isCorrect() ? question.getPoints().doubleValue() : 0.0);
            } else {
                throw new IllegalArgumentException("Es necesario seleccionar una respuesta para este tipo de pregunta.");
            }
        }

        // Guardar la respuesta del estudiante
        studentAnswerRepository.save(studentAnswer);

        // Actualizar la última actividad en el progreso del estudiante
        updateStudentProgress(attempt.getStudentId(), attempt.getQuizId());

        return convertToDTO(attempt);
    }

    @Override
    @Transactional
    public QuizAttemptDTO completeQuizAttempt(Long attemptId) {
        // Verificar si el intento existe y está en progreso
        QuizAttempt attempt = quizAttemptRepository.findById(attemptId)
                .orElseThrow(() -> new ResourceNotFoundException("Intento de examen", "id", attemptId));

        if (!"IN_PROGRESS".equals(attempt.getStatus())) {
            throw new IllegalStateException("Este intento de examen ya ha sido completado o cancelado.");
        }

        // Obtener el examen
        Quiz quiz = quizRepository.findById(attempt.getQuizId())
                .orElseThrow(() -> new ResourceNotFoundException("Examen", "id", attempt.getQuizId()));

        // Calcular tiempo transcurrido
        LocalDateTime startTime = attempt.getStartedAt();
        LocalDateTime endTime = LocalDateTime.now();
        int secondsElapsed = (int) ChronoUnit.SECONDS.between(startTime, endTime);
        attempt.setTimeTakenSeconds(secondsElapsed);

        // Verificar límite de tiempo si aplica
        if (quiz.getTimeLimitMinutes() != null) {
            int timeLimit = quiz.getTimeLimitMinutes() * 60; // convertir a segundos
            if (secondsElapsed > timeLimit) {
                attempt.setStatus("TIMED_OUT");
            }
        }

        // Calcular puntuación
        List<StudentAnswer> answers = studentAnswerRepository.findByQuizAttemptId(attemptId);

        double totalEarnedPoints = answers.stream()
                .mapToDouble(a -> a.getPointsEarned() != null ? a.getPointsEarned() : 0)
                .sum();

        // Obtener el total de puntos posibles para el examen
        double totalPossiblePoints = questionRepository.findByQuizId(quiz.getId())
                .stream()
                .mapToInt(Question::getPoints)
                .sum();

        // Evitar división por cero
        double percentage = totalPossiblePoints > 0
                ? (totalEarnedPoints / totalPossiblePoints) * 100
                : 0;

        // Determinar si el intento es aprobado
        boolean passed = percentage >= quiz.getPassingScore();

        // Actualizar intento
        attempt.setScore(totalEarnedPoints);
        attempt.setMaxScore(totalPossiblePoints);
        attempt.setPercentage(percentage);
        attempt.setPassed(passed);
        attempt.setCompletedAt(endTime);

        // Si no fue marcado como TIMED_OUT, marcarlo como COMPLETED
        if (!"TIMED_OUT".equals(attempt.getStatus())) {
            attempt.setStatus("COMPLETED");
        }

        // Guardar el intento
        QuizAttempt completedAttempt = quizAttemptRepository.save(attempt);

        // Actualizar el progreso del estudiante
        updateStudentProgressAfterCompletion(attempt.getStudentId(), quiz.getCourseId(), passed);

        return convertToDTO(completedAttempt);
    }

    @Override
    public double getAverageScoreForQuiz(Long quizId) {
        Double avgScore = quizAttemptRepository.calculateAverageScore(quizId);
        return avgScore != null ? avgScore : 0;
    }

    @Override
    public int getPassRateForQuiz(Long quizId) {
        Integer passCount = quizAttemptRepository.countPassedAttempts(quizId);
        List<QuizAttempt> completedAttempts = quizAttemptRepository.findByQuizId(quizId).stream()
                .filter(a -> "COMPLETED".equals(a.getStatus()) || "TIMED_OUT".equals(a.getStatus()))
                .collect(Collectors.toList());

        int totalAttempts = completedAttempts.size();
        return totalAttempts > 0 ? (passCount * 100) / totalAttempts : 0;
    }

    // Método privado para actualizar el progreso del estudiante tras cada actividad
    private void updateStudentProgress(Long studentId, Long quizId) {
        // Obtener el examen para conocer el curso asociado
        Quiz quiz = quizRepository.findById(quizId)
                .orElseThrow(() -> new ResourceNotFoundException("Examen", "id", quizId));

        // Obtener o crear el registro de progreso del estudiante
        StudentProgress progress = studentProgressRepository
                .findByStudentIdAndCourseId(studentId, quiz.getCourseId())
                .orElseGet(() -> {
                    StudentProgress newProgress = new StudentProgress();
                    newProgress.setStudentId(studentId);
                    newProgress.setCourseId(quiz.getCourseId());
                    return newProgress;
                });

        // Actualizar la fecha de última actividad
        progress.updateLastActivity();

        // Guardar el progreso
        studentProgressRepository.save(progress);
    }

    // Método privado para actualizar el progreso del estudiante después de completar un examen
    private void updateStudentProgressAfterCompletion(Long studentId, Long courseId, boolean passed) {
        // Obtener o crear el registro de progreso del estudiante
        StudentProgress progress = studentProgressRepository
                .findByStudentIdAndCourseId(studentId, courseId)
                .orElseGet(() -> {
                    StudentProgress newProgress = new StudentProgress();
                    newProgress.setStudentId(studentId);
                    newProgress.setCourseId(courseId);
                    return newProgress;
                });

        // Actualizar la fecha de última actividad
        progress.updateLastActivity();

        // Incrementar contador de exámenes completados si fue aprobado
        if (passed) {
            Integer quizzesCompleted = progress.getQuizzesCompleted();
            progress.setQuizzesCompleted(quizzesCompleted != null ? quizzesCompleted + 1 : 1);

            // Recalcular porcentaje de finalización
            recalculateCompletionPercentage(progress);
        }

        // Guardar el progreso
        studentProgressRepository.save(progress);
    }

    // Método para recalcular el porcentaje de finalización de un curso
    private void recalculateCompletionPercentage(StudentProgress progress) {
        // Este es un ejemplo simple. En un caso real, consideraríamos lecciones y exámenes
        double quizzesWeight = 0.5;
        double lessonsWeight = 0.5;

        double quizzesPercentage = 0.0;
        if (progress.getTotalQuizzes() != null && progress.getTotalQuizzes() > 0) {
            quizzesPercentage = (double) progress.getQuizzesCompleted() / progress.getTotalQuizzes();
        }

        double lessonsPercentage = 0.0;
        if (progress.getTotalLessons() != null && progress.getTotalLessons() > 0) {
            lessonsPercentage = (double) progress.getLessonsCompleted() / progress.getTotalLessons();
        }

        double totalPercentage = (quizzesPercentage * quizzesWeight) + (lessonsPercentage * lessonsWeight);
        progress.setCompletionPercentage(totalPercentage * 100);

        // Marcar como completado si se alcanza el 100%
        if (progress.getCompletionPercentage() >= 100) {
            progress.setIsCompleted(true);
            progress.setCompletionDate(LocalDateTime.now());
        }
    }

    // Método para convertir un QuizAttempt a DTO
    private QuizAttemptDTO convertToDTO(QuizAttempt attempt) {
        QuizAttemptDTO dto = new QuizAttemptDTO();
        dto.setId(attempt.getId());
        dto.setStudentId(attempt.getStudentId());
        dto.setQuizId(attempt.getQuizId());
        dto.setScore(attempt.getScore());
        dto.setMaxScore(attempt.getMaxScore());
        dto.setPercentage(attempt.getPercentage());
        dto.setPassed(attempt.getPassed());
        dto.setTimeTakenSeconds(attempt.getTimeTakenSeconds());
        dto.setStartedAt(attempt.getStartedAt());
        dto.setCompletedAt(attempt.getCompletedAt());
        dto.setAttemptNumber(attempt.getAttemptNumber());
        dto.setStatus(attempt.getStatus());

        // Obtener nombre del examen si es posible
        quizRepository.findById(attempt.getQuizId()).ifPresent(quiz -> {
            dto.setQuizTitle(quiz.getTitle());
        });

        // Convertir respuestas del estudiante si hay datos en el objeto
        if (attempt.getStudentAnswers() != null && !attempt.getStudentAnswers().isEmpty()) {
            List<StudentAnswerDTO> answerDTOs = attempt.getStudentAnswers().stream()
                    .map(this::convertStudentAnswerToDTO)
                    .collect(Collectors.toList());
            dto.setStudentAnswers(answerDTOs);
        }

        return dto;
    }

    // Método para convertir un StudentAnswer a DTO
    private StudentAnswerDTO convertStudentAnswerToDTO(StudentAnswer answer) {
        StudentAnswerDTO dto = new StudentAnswerDTO();
        dto.setId(answer.getId());
        dto.setQuestionId(answer.getQuestionId());
        dto.setAnswerId(answer.getAnswerId());
        dto.setEssayAnswer(answer.getEssayAnswer());
        dto.setIsCorrect(answer.getIsCorrect());
        dto.setPointsEarned(answer.getPointsEarned());
        dto.setSubmittedAt(answer.getSubmittedAt());
        dto.setQuizAttemptId(answer.getQuizAttempt().getId());

        // Obtener texto de la pregunta si es posible
        questionRepository.findById(answer.getQuestionId()).ifPresent(question -> {
            dto.setQuestionText(question.getQuestionText());
        });

        // Obtener texto de la respuesta seleccionada si aplica
        if (answer.getAnswerId() != null) {
            answerRepository.findById(answer.getAnswerId()).ifPresent(answerEntity -> {
                dto.setAnswerText(answerEntity.getAnswerText());
            });
        }

        return dto;
    }
}
