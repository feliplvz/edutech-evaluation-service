package com.edutech.evaluationservice.service.impl;

import com.edutech.evaluationservice.dto.StudentProgressDTO;
import com.edutech.evaluationservice.exception.ResourceNotFoundException;
import com.edutech.evaluationservice.model.StudentProgress;
import com.edutech.evaluationservice.repository.StudentProgressRepository;
import com.edutech.evaluationservice.service.StudentProgressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class StudentProgressServiceImpl implements StudentProgressService {

    private final StudentProgressRepository studentProgressRepository;

    @Autowired
    public StudentProgressServiceImpl(StudentProgressRepository studentProgressRepository) {
        this.studentProgressRepository = studentProgressRepository;
    }

    @Override
    public List<StudentProgressDTO> getAllProgress() {
        return studentProgressRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public StudentProgressDTO getProgressById(Long id) {
        StudentProgress progress = studentProgressRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Progreso del estudiante", "id", id));
        return convertToDTO(progress);
    }

    @Override
    public StudentProgressDTO getProgressByStudentAndCourse(Long studentId, Long courseId) {
        StudentProgress progress = studentProgressRepository.findByStudentIdAndCourseId(studentId, courseId)
                .orElseThrow(() -> new ResourceNotFoundException(
                    "No se encontró progreso para el estudiante " + studentId + " en el curso " + courseId));
        return convertToDTO(progress);
    }

    @Override
    public List<StudentProgressDTO> getProgressByStudent(Long studentId) {
        return studentProgressRepository.findByStudentId(studentId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public List<StudentProgressDTO> getProgressByCourse(Long courseId) {
        return studentProgressRepository.findByCourseId(courseId).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional
    public StudentProgressDTO createProgress(StudentProgressDTO progressDTO) {
        // Verificar si ya existe un registro para este estudiante y curso
        if (studentProgressRepository.findByStudentIdAndCourseId(
                progressDTO.getStudentId(), progressDTO.getCourseId()).isPresent()) {
            throw new IllegalStateException(
                "Ya existe un registro de progreso para este estudiante en este curso");
        }

        StudentProgress progress = new StudentProgress();
        updateProgressFromDTO(progress, progressDTO);

        StudentProgress savedProgress = studentProgressRepository.save(progress);
        return convertToDTO(savedProgress);
    }

    @Override
    @Transactional
    public StudentProgressDTO updateProgress(Long id, StudentProgressDTO progressDTO) {
        StudentProgress progress = studentProgressRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Progreso del estudiante", "id", id));

        updateProgressFromDTO(progress, progressDTO);

        StudentProgress updatedProgress = studentProgressRepository.save(progress);
        return convertToDTO(updatedProgress);
    }

    @Override
    @Transactional
    public StudentProgressDTO updateLessonCompletion(Long studentId, Long courseId, Long lessonId) {
        // Obtener o crear el registro de progreso
        StudentProgress progress = studentProgressRepository.findByStudentIdAndCourseId(studentId, courseId)
                .orElseGet(() -> {
                    StudentProgress newProgress = new StudentProgress();
                    newProgress.setStudentId(studentId);
                    newProgress.setCourseId(courseId);
                    newProgress.setLessonsCompleted(0);
                    return newProgress;
                });

        // Incrementar contador de lecciones completadas
        progress.setLessonsCompleted(progress.getLessonsCompleted() + 1);

        // Actualizar fecha de última actividad
        progress.updateLastActivity();

        // Recalcular porcentaje de finalización
        if (progress.getTotalLessons() != null && progress.getTotalLessons() > 0) {
            double percentage = ((double) progress.getLessonsCompleted() / progress.getTotalLessons()) * 100;
            progress.setCompletionPercentage(percentage);

            // Marcar como completado si se alcanza el 100%
            if (percentage >= 100) {
                progress.setIsCompleted(true);
                progress.setCompletionDate(LocalDateTime.now());
            }
        }

        StudentProgress updatedProgress = studentProgressRepository.save(progress);
        return convertToDTO(updatedProgress);
    }

    @Override
    @Transactional
    public StudentProgressDTO issueCertificate(Long progressId, String certificateUrl) {
        StudentProgress progress = studentProgressRepository.findById(progressId)
                .orElseThrow(() -> new ResourceNotFoundException("Progreso del estudiante", "id", progressId));

        // Verificar si el curso está completado
        if (!progress.getIsCompleted()) {
            throw new IllegalStateException("No se puede emitir un certificado para un curso que no está completado.");
        }

        progress.setCertificateIssued(true);
        progress.setCertificateUrl(certificateUrl);

        StudentProgress updatedProgress = studentProgressRepository.save(progress);
        return convertToDTO(updatedProgress);
    }

    @Override
    public double getAverageCompletionForCourse(Long courseId) {
        Double avgCompletion = studentProgressRepository.getAverageCompletionPercentage(courseId);
        return avgCompletion != null ? avgCompletion : 0;
    }

    @Override
    public int getCompletionCountForCourse(Long courseId) {
        Integer completionCount = studentProgressRepository.countCompletedCourses(courseId);
        return completionCount != null ? completionCount : 0;
    }

    // Método privado para actualizar una entidad StudentProgress a partir de un DTO
    private void updateProgressFromDTO(StudentProgress progress, StudentProgressDTO dto) {
        progress.setStudentId(dto.getStudentId());
        progress.setCourseId(dto.getCourseId());

        // Estos campos solo se actualizan si están presentes en el DTO
        if (dto.getLessonsCompleted() != null) {
            progress.setLessonsCompleted(dto.getLessonsCompleted());
        }

        if (dto.getTotalLessons() != null) {
            progress.setTotalLessons(dto.getTotalLessons());
        }

        if (dto.getQuizzesCompleted() != null) {
            progress.setQuizzesCompleted(dto.getQuizzesCompleted());
        }

        if (dto.getTotalQuizzes() != null) {
            progress.setTotalQuizzes(dto.getTotalQuizzes());
        }

        if (dto.getAverageScore() != null) {
            progress.setAverageScore(dto.getAverageScore());
        }

        if (dto.getTotalTimeSpentMinutes() != null) {
            progress.setTotalTimeSpentMinutes(dto.getTotalTimeSpentMinutes());
        }

        // Actualizar porcentaje de finalización si hay datos suficientes
        if (progress.getTotalLessons() != null && progress.getTotalLessons() > 0 &&
                progress.getTotalQuizzes() != null && progress.getTotalQuizzes() > 0) {
            // Porcentaje por lecciones completadas
            double lessonPercentage = (double) progress.getLessonsCompleted() / progress.getTotalLessons();

            // Porcentaje por exámenes completados
            double quizPercentage = (double) progress.getQuizzesCompleted() / progress.getTotalQuizzes();

            // Promedio ponderado (50% lecciones, 50% exámenes)
            double totalPercentage = (lessonPercentage * 0.5) + (quizPercentage * 0.5);
            progress.setCompletionPercentage(totalPercentage * 100);

            // Marcar como completado si se alcanza el 100%
            if (progress.getCompletionPercentage() >= 100) {
                progress.setIsCompleted(true);
                if (progress.getCompletionDate() == null) {
                    progress.setCompletionDate(LocalDateTime.now());
                }
            }
        }

        // Actualizar fecha de última actividad
        progress.updateLastActivity();
    }

    // Método para convertir una entidad StudentProgress a DTO
    private StudentProgressDTO convertToDTO(StudentProgress progress) {
        StudentProgressDTO dto = new StudentProgressDTO();
        dto.setId(progress.getId());
        dto.setStudentId(progress.getStudentId());
        dto.setCourseId(progress.getCourseId());
        dto.setEnrollmentDate(progress.getEnrollmentDate());
        dto.setLastActivityDate(progress.getLastActivityDate());
        dto.setCompletionDate(progress.getCompletionDate());
        dto.setCompletionPercentage(progress.getCompletionPercentage());
        dto.setLessonsCompleted(progress.getLessonsCompleted());
        dto.setTotalLessons(progress.getTotalLessons());
        dto.setQuizzesCompleted(progress.getQuizzesCompleted());
        dto.setTotalQuizzes(progress.getTotalQuizzes());
        dto.setAverageScore(progress.getAverageScore());
        dto.setTotalTimeSpentMinutes(progress.getTotalTimeSpentMinutes());
        dto.setCertificateIssued(progress.getCertificateIssued());
        dto.setCertificateUrl(progress.getCertificateUrl());
        dto.setIsCompleted(progress.getIsCompleted());

        return dto;
    }
}
