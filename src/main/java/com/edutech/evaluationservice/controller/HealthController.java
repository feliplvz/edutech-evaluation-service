package com.edutech.evaluationservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/health")
public class HealthController {

    @Autowired
    private DataSource dataSource;

    @GetMapping
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "evaluation-service");
        health.put("timestamp", LocalDateTime.now());
        health.put("port", 8083);
        health.put("description", "Microservicio de Evaluaciones y Seguimiento Estudiantil");
        
        return ResponseEntity.ok(health);
    }

    @GetMapping("/db")
    public ResponseEntity<Map<String, Object>> databaseHealth() {
        Map<String, Object> dbHealth = new HashMap<>();
        
        try (Connection connection = dataSource.getConnection()) {
            if (connection.isValid(2)) {
                dbHealth.put("status", "UP");
                dbHealth.put("database", "PostgreSQL");
                dbHealth.put("connection", "Activa");
                dbHealth.put("timestamp", LocalDateTime.now());
                return ResponseEntity.ok(dbHealth);
            } else {
                dbHealth.put("status", "DOWN");
                dbHealth.put("message", "Conexión a base de datos no válida");
                dbHealth.put("timestamp", LocalDateTime.now());
                return ResponseEntity.status(503).body(dbHealth);
            }
        } catch (SQLException e) {
            dbHealth.put("status", "DOWN");
            dbHealth.put("error", e.getMessage());
            dbHealth.put("timestamp", LocalDateTime.now());
            return ResponseEntity.status(503).body(dbHealth);
        }
    }
}
