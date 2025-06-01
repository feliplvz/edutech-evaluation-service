package com.edutech.evaluationservice.repository;

import com.edutech.evaluationservice.model.Quiz;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuizRepository extends JpaRepository<Quiz, Long> {

    List<Quiz> findByCourseId(Long courseId);

    List<Quiz> findByLessonId(Long lessonId);

    List<Quiz> findByCourseIdAndActiveTrue(Long courseId);
}
