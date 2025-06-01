package com.edutech.evaluationservice.repository;

import com.edutech.evaluationservice.model.StudentProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentProgressRepository extends JpaRepository<StudentProgress, Long> {

    Optional<StudentProgress> findByStudentIdAndCourseId(Long studentId, Long courseId);

    List<StudentProgress> findByStudentId(Long studentId);

    List<StudentProgress> findByCourseId(Long courseId);

    List<StudentProgress> findByIsCompletedTrue();

    @Query("SELECT AVG(sp.completionPercentage) FROM StudentProgress sp WHERE sp.courseId = :courseId")
    Double getAverageCompletionPercentage(@Param("courseId") Long courseId);

    @Query("SELECT COUNT(sp) FROM StudentProgress sp WHERE sp.courseId = :courseId AND sp.isCompleted = TRUE")
    Integer countCompletedCourses(@Param("courseId") Long courseId);

    @Query("SELECT sp FROM StudentProgress sp WHERE sp.studentId = :studentId ORDER BY sp.lastActivityDate DESC")
    List<StudentProgress> findRecentActivityByStudent(@Param("studentId") Long studentId);
}
