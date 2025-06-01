# 🚀 Postman Collection - EduTech Evaluation Service

Esta carpeta contiene la colección completa de Postman para probar todos los endpoints del **Microservicio de Evaluaciones y Seguimiento Estudiantil**.

## 📁 Archivos Incluidos

- `EvaluationService-Complete.postman_collection.json` - Colección completa con 20+ requests
- `EvaluationService.postman_environment.json` - Variables de entorno
- `README.md` - Esta guía de uso

## 🚀 Cómo Importar en Postman

### 1. Importar la Colección
1. Abre Postman
2. Clic en **Import** (esquina superior izquierda)
3. Arrastra el archivo `EvaluationService-Complete.postman_collection.json`
4. Clic en **Import**

### 2. Importar el Environment
1. Clic en **Import** nuevamente
2. Arrastra el archivo `EvaluationService.postman_environment.json`
3. Clic en **Import**
4. Selecciona el environment "🎯 EduTech Evaluation Service Environment" en la esquina superior derecha

## 🧪 Ejecución de Pruebas

### ⚡ Ejecución Rápida (Runner)
```bash
1. Clic en la colección "🎯 EduTech - Evaluation Service API Complete"
2. Clic en "Run" (botón azul)
3. Seleccionar todas las carpetas/requests
4. Clic en "Run EduTech - Evaluation Service API Complete"
```

### 📋 Orden de Ejecución Recomendado
1. **🏥 Health & System** - Verificar que el servicio esté activo
2. **📝 Quizzes Management** - CRUD completo de quizzes
3. **❓ Questions Management** - CRUD de preguntas
4. **✅ Answers Management** - CRUD de respuestas
5. **🎯 Quiz Attempts** - Simulación completa de examen
6. **📊 Student Progress** - Gestión de progreso estudiantil
7. **🗑️ Cleanup Tests** - Limpieza de datos de prueba

## 📊 Qué Prueba Cada Sección

### 🏥 Health & System
- ✅ Conectividad del microservicio
- ✅ Estado del sistema
- ✅ Verificación de base de datos PostgreSQL
- ✅ Tiempo de respuesta

### 📝 Quizzes Management
- ✅ Listar todos los quizzes
- ✅ Crear nuevo quiz
- ✅ Obtener quiz por ID
- ✅ Actualizar quiz existente
- ✅ Validación de campos requeridos

### ❓ Questions Management
- ✅ Listar todas las preguntas
- ✅ Crear nueva pregunta
- ✅ Obtener preguntas por quiz
- ✅ Validación de relaciones

### ✅ Answers Management
- ✅ Crear opciones de respuesta (correcta e incorrecta)
- ✅ Obtener respuestas por pregunta
- ✅ Validación de tipo de respuesta
- ✅ **CORREGIDO**: Eliminado endpoint inexistente `GET /api/answers`

### 🎯 Quiz Attempts
- ✅ Iniciar intento de quiz
- ✅ Enviar respuesta a pregunta
- ✅ Completar intento de quiz
- ✅ Obtener resultados y calificación
- ✅ Validación del flujo completo de examen

### 📊 Student Progress
- ✅ Listar progreso de estudiantes
- ✅ Obtener progreso por estudiante
- ✅ Actualizar progreso
- ✅ Validación de métricas

### 🗑️ Cleanup Tests
- ✅ Eliminación de datos de prueba
- ✅ Validación de limpieza

## 🎯 Tests Automáticos Incluidos

Cada request incluye tests automáticos que verifican:

- **Status Codes** - Códigos de respuesta correctos
- **Response Structure** - Estructura JSON esperada
- **Data Validation** - Validación de tipos de datos
- **Business Logic** - Lógica de negocio específica
- **Relationships** - Relaciones entre entidades
- **Performance** - Tiempos de respuesta aceptables

## 📈 Métricas de Testing

La colección incluye **30+ tests automáticos** que verifican:

- ✅ **100% Coverage** de endpoints principales
- ✅ **CRUD Completo** para todas las entidades
- ✅ **Flujo End-to-End** de examen completo
- ✅ **Validación de Datos** en todas las operaciones
- ✅ **Gestión de Errores** y casos edge
- ✅ **Performance Testing** básico
- ✅ **Endpoints Corregidos** - Sin endpoints inexistentes

## 🔧 Configuración Requerida

### Prerequisitos
1. **Microservicio ejecutándose** en `http://localhost:8083`
2. **Base de datos conectada** (Railway PostgreSQL)
3. **Postman** versión 9.0+ instalado

### Variables de Entorno
Las siguientes variables se configuran automáticamente durante la ejecución:
- `baseUrl` - URL base del microservicio
- `quizId` - ID del quiz creado para pruebas
- `questionId` - ID de la pregunta creada
- `answerId` - ID de respuesta creada
- `attemptId` - ID del intento de quiz

## 🚨 Notas Importantes

### ⚠️ Datos de Prueba
- La colección crea datos de prueba temporales
- Al final, ejecuta limpieza automática
- Los datos existentes NO se modifican

### 🔄 Reutilización
- Puedes ejecutar la colección múltiples veces
- Las variables se actualizan automáticamente
- No hay conflictos entre ejecuciones

### 📊 Reportes
- Postman genera reportes automáticos
- Puedes exportar resultados en JSON/HTML
- Integración con CI/CD disponible

## 🆘 Solución de Problemas

### Error: "Could not get response"
```bash
# Verificar que el microservicio esté ejecutándose
curl http://localhost:8083/health

# Si no responde, ejecutar:
cd /ruta/del/proyecto
./start.sh
```

### Error: "Environment not selected"
```bash
1. Verificar que el environment esté importado
2. Seleccionar "🎯 EduTech Evaluation Service Environment" 
3. en la esquina superior derecha de Postman
```

### Error: "Variable not found"
```bash
1. Ejecutar los requests en orden
2. Verificar que el environment esté seleccionado
3. Revisar que las pruebas anteriores hayan pasado
```

---

## 🎉 ¡Listo para Probar!

Tu microservicio está completamente probado con esta colección. Ejecuta todas las pruebas y verifica que el **100% de los tests pasen** para confirmar que todo funciona correctamente.

**¡Happy Testing!** 🚀✅
