package com.edutech.evaluationservice.repository;

import com.edutech.evaluationservice.model.QuizAttempt;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuizAttemptRepository extends JpaRepository<QuizAttempt, Long> {

    List<QuizAttempt> findByStudentIdAndQuizId(Long studentId, Long quizId);

    List<QuizAttempt> findByStudentId(Long studentId);

    List<QuizAttempt> findByQuizId(Long quizId);

    Page<QuizAttempt> findByStudentId(Long studentId, Pageable pageable);

    @Query("SELECT qa FROM QuizAttempt qa WHERE qa.studentId = :studentId AND qa.quizId = :quizId AND qa.attemptNumber = (SELECT MAX(qa2.attemptNumber) FROM QuizAttempt qa2 WHERE qa2.studentId = :studentId AND qa2.quizId = :quizId)")
    Optional<QuizAttempt> findLatestAttempt(@Param("studentId") Long studentId, @Param("quizId") Long quizId);

    @Query("SELECT COUNT(qa) FROM QuizAttempt qa WHERE qa.studentId = :studentId AND qa.quizId = :quizId AND qa.status = 'COMPLETED'")
    Integer countCompletedAttempts(@Param("studentId") Long studentId, @Param("quizId") Long quizId);

    @Query("SELECT AVG(qa.percentage) FROM QuizAttempt qa WHERE qa.quizId = :quizId AND qa.status = 'COMPLETED'")
    Double calculateAverageScore(@Param("quizId") Long quizId);

    @Query("SELECT COUNT(qa) FROM QuizAttempt qa WHERE qa.quizId = :quizId AND qa.passed = TRUE AND qa.status = 'COMPLETED'")
    Integer countPassedAttempts(@Param("quizId") Long quizId);
}
