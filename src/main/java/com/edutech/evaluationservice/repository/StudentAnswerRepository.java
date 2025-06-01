package com.edutech.evaluationservice.repository;

import com.edutech.evaluationservice.model.StudentAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StudentAnswerRepository extends JpaRepository<StudentAnswer, Long> {

    List<StudentAnswer> findByQuizAttemptId(Long quizAttemptId);

    List<StudentAnswer> findByQuestionId(Long questionId);

    List<StudentAnswer> findByQuizAttemptIdAndQuestionId(Long quizAttemptId, Long questionId);
}
