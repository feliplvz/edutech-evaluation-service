package com.edutech.evaluationservice.repository;

import com.edutech.evaluationservice.model.Answer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AnswerRepository extends JpaRepository<Answer, Long> {

    List<Answer> findByQuestionId(Long questionId);

    List<Answer> findByQuestionIdOrderByOrderIndex(Long questionId);

    List<Answer> findByQuestionIdAndCorrectTrue(Long questionId);
}
