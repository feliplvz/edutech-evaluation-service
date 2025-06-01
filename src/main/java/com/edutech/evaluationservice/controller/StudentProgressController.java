package com.edutech.evaluationservice.controller;

import com.edutech.evaluationservice.dto.StudentProgressDTO;
import com.edutech.evaluationservice.service.StudentProgressService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/progress")
public class StudentProgressController {

    private final StudentProgressService studentProgressService;

    @Autowired
    public StudentProgressController(StudentProgressService studentProgressService) {
        this.studentProgressService = studentProgressService;
    }

    @GetMapping
    public ResponseEntity<List<StudentProgressDTO>> getAllProgress() {
        return ResponseEntity.ok(studentProgressService.getAllProgress());
    }

    @GetMapping("/{id}")
    public ResponseEntity<StudentProgressDTO> getProgressById(@PathVariable Long id) {
        return ResponseEntity.ok(studentProgressService.getProgressById(id));
    }

    @GetMapping("/student/{studentId}/course/{courseId}")
    public ResponseEntity<StudentProgressDTO> getProgressByStudentAndCourse(
            @PathVariable Long studentId,
            @PathVariable Long courseId) {
        return ResponseEntity.ok(studentProgressService.getProgressByStudentAndCourse(studentId, courseId));
    }

    @GetMapping("/student/{studentId}")
    public ResponseEntity<List<StudentProgressDTO>> getProgressByStudent(@PathVariable Long studentId) {
        return ResponseEntity.ok(studentProgressService.getProgressByStudent(studentId));
    }

    @GetMapping("/course/{courseId}")
    public ResponseEntity<List<StudentProgressDTO>> getProgressByCourse(@PathVariable Long courseId) {
        return ResponseEntity.ok(studentProgressService.getProgressByCourse(courseId));
    }

    @PostMapping
    public ResponseEntity<StudentProgressDTO> createProgress(@Valid @RequestBody StudentProgressDTO progressDTO) {
        return new ResponseEntity<>(studentProgressService.createProgress(progressDTO), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<StudentProgressDTO> updateProgress(
            @PathVariable Long id,
            @Valid @RequestBody StudentProgressDTO progressDTO) {
        return ResponseEntity.ok(studentProgressService.updateProgress(id, progressDTO));
    }

    @PatchMapping("/student/{studentId}/course/{courseId}/lesson/{lessonId}/complete")
    public ResponseEntity<StudentProgressDTO> updateLessonCompletion(
            @PathVariable Long studentId,
            @PathVariable Long courseId,
            @PathVariable Long lessonId) {
        return ResponseEntity.ok(studentProgressService.updateLessonCompletion(studentId, courseId, lessonId));
    }

    @PatchMapping("/{progressId}/issue-certificate")
    public ResponseEntity<StudentProgressDTO> issueCertificate(
            @PathVariable Long progressId,
            @RequestBody Map<String, String> request) {
        String certificateUrl = request.get("certificateUrl");
        if (certificateUrl == null || certificateUrl.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(studentProgressService.issueCertificate(progressId, certificateUrl));
    }

    @GetMapping("/course/{courseId}/statistics/avg-completion")
    public ResponseEntity<Map<String, Double>> getAverageCompletionForCourse(@PathVariable Long courseId) {
        double avgCompletion = studentProgressService.getAverageCompletionForCourse(courseId);
        return ResponseEntity.ok(Map.of("averageCompletion", avgCompletion));
    }

    @GetMapping("/course/{courseId}/statistics/completion-count")
    public ResponseEntity<Map<String, Integer>> getCompletionCountForCourse(@PathVariable Long courseId) {
        int completionCount = studentProgressService.getCompletionCountForCourse(courseId);
        return ResponseEntity.ok(Map.of("completionCount", completionCount));
    }
}
