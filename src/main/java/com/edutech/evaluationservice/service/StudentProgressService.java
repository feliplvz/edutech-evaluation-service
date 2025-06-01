package com.edutech.evaluationservice.service;

import com.edutech.evaluationservice.dto.StudentProgressDTO;

import java.util.List;

public interface StudentProgressService {

    List<StudentProgressDTO> getAllProgress();

    StudentProgressDTO getProgressById(Long id);

    StudentProgressDTO getProgressByStudentAndCourse(Long studentId, Long courseId);

    List<StudentProgressDTO> getProgressByStudent(Long studentId);

    List<StudentProgressDTO> getProgressByCourse(Long courseId);

    StudentProgressDTO createProgress(StudentProgressDTO progressDTO);

    StudentProgressDTO updateProgress(Long id, StudentProgressDTO progressDTO);

    StudentProgressDTO updateLessonCompletion(Long studentId, Long courseId, Long lessonId);

    StudentProgressDTO issueCertificate(Long progressId, String certificateUrl);

    double getAverageCompletionForCourse(Long courseId);

    int getCompletionCountForCourse(Long courseId);
}
