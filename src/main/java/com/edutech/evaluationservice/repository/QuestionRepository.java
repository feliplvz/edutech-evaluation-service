package com.edutech.evaluationservice.repository;

import com.edutech.evaluationservice.model.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {

    List<Question> findByQuizId(Long quizId);

    List<Question> findByQuizIdOrderByOrderIndex(Long quizId);

    List<Question> findByQuestionType(String questionType);

    List<Question> findByDifficultyLevel(String difficultyLevel);
}
