# 🚀 EduTech Scripts - Guía Completa del Sistema Automatizado

<div align="center">

[![Scripts](https://img.shields.io/badge/Scripts-Automatizados-blue.svg)](scripts/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows-green.svg)](#🌐-compatibilidad-multiplataforma)
[![Version](https://img.shields.io/badge/Version-3.0.0-orange.svg)](scripts/)
[![Status](https://img.shields.io/badge/Status-✅%20Funcional-success.svg)](#✅-estado-de-los-scripts)

**🎯 Sistema de Automatización Empresarial para EduTech Evaluation Service**

*Conjunto completo de scripts para el ciclo de vida del microservicio*

</div>

## 🎯 Descripción General

Este proyecto incluye un **sistema de scripts** completamente automatizado, diseñado para proporcionar una experiencia de desarrollo de calidad y simplificar todas las operaciones del ciclo de vida del microservicio de evaluaciones EduTech.

### 📁 Estructura del Sistema de Scripts

```
scripts/
├── 🎨 banner.sh              # Sistema de banners para Mac/Linux
├── 🎨 banner.bat             # Sistema de banners para Windows
├── mac/                      # Scripts optimizados para macOS/Linux
│   ├── 🎮 controlador.sh     # Controlador maestro interactivo
│   ├── ⚙️ configurar.sh      # Configuración de entorno completa
│   ├── 🚀 iniciar.sh         # Inicio inteligente del microservicio
│   ├── 🛑 detener.sh         # Parada elegante del servicio
│   └── 🔍 verificar-estado.sh # Diagnóstico completo del sistema
└── windows/                  # Scripts equivalentes para Windows
    ├── 🎮 controlador.bat    # Controlador maestro interactivo
    ├── ⚙️ configurar.bat     # Configuración de entorno completa
    ├── 🚀 iniciar.bat        # Inicio inteligente del microservicio
    ├── 🛑 detener.bat        # Parada elegante del servicio
    └── 🔍 verificar-estado.bat # Diagnóstico completo del sistema
```

## 🚀 Scripts Disponibles

### 🎮 Controlador Maestro - El Cerebro del Sistema

**`scripts/mac/controlador.sh` / `scripts/windows/controlador.bat`** - Centro de comando unificado

```bash
# macOS/Linux
./scripts/mac/controlador.sh

# Windows
scripts\windows\controlador.bat
```

**🌟 Características Avanzadas:**
- 🎨 **Interfaz interactiva** con 19+ operaciones especializadas
- 🎯 **Menú intuitivo** con navegación por números o nombres
- 🔄 **Operaciones del ciclo completo** de desarrollo
- 📊 **Monitoreo en tiempo real** con reportes detallados
- 🛠️ **Herramientas DevOps** integradas
- 💡 **Sistema inteligente** de sugerencias y ayuda

#### 📋 **Menú Completo de Operaciones:**

```
🔧 CONFIGURACIÓN
 1) configurar      - 🛠️  Configurar entorno de desarrollo
 2) variables       - ⚙️  Gestionar variables de entorno

🚀 CICLO DE VIDA
 3) iniciar         - 🚀 Iniciar el microservicio
 4) detener         - 🛑 Detener el microservicio
 5) reiniciar       - 🔄 Reiniciar el microservicio
 6) estado          - 🔍 Verificar estado del servicio

🔨 COMPILACIÓN & PRUEBAS
 7) compilar        - 🔨 Compilar la aplicación
 8) pruebas         - 🧪 Ejecutar pruebas unitarias
 9) empaquetar      - 📦 Crear paquete desplegable
10) limpiar         - 🧹 Limpiar artefactos de compilación

📊 MONITOREO & LOGS
11) logs            - 📋 Ver logs de la aplicación
12) salud           - 🏥 Verificar endpoints de salud
13) metricas        - 📈 Ver métricas del sistema
14) bd              - 🗄️ Verificar conectividad de BD

🔧 HERRAMIENTAS DEV
15) dependencias    - 📦 Gestionar dependencias Maven
16) postman         - 📮 Operaciones con Postman
17) info            - ℹ️  Información del proyecto
18) ayuda           - ❓ Ayuda y documentación
```

### ⚙️ Configurador de Entorno - Setup Inteligente

**`scripts/mac/configurar.sh` / `scripts/windows/configurar.bat`** - Configuración automática del entorno

```bash
# macOS/Linux
./scripts/mac/configurar.sh

# Windows
scripts\windows\configurar.bat
```

**🔧 Funcionalidades Empresariales:**
- ✅ **Validación automática** de requisitos del sistema (Java 17+, Maven 3.6+, Git)
- ✅ **Configuración inteligente** de variables de entorno con plantillas
- ✅ **Gestión de permisos** automática para todos los scripts
- ✅ **Validación del proyecto** Maven con verificaciones de Spring Boot
- ✅ **Inicialización completa** de estructura de directorios
- ✅ **Generación de resumen** del proyecto en Markdown
- ✅ **Configuración de .gitignore** para proteger credenciales

### 🚀 Iniciador Inteligente - Smart Startup

**`scripts/mac/iniciar.sh` / `scripts/windows/iniciar.bat`** - Inicio avanzado del microservicio

```bash
# macOS/Linux
./scripts/mac/iniciar.sh

# Windows
scripts\windows\iniciar.bat
```

**🎯 Características Avanzadas:**
- ✅ **Pre-flight checks** completos del sistema
- ✅ **Gestión inteligente de puertos** con detección automática
- ✅ **Health monitoring** con timeouts configurables (120s)
- ✅ **Validación de build** y dependencias Maven
- ✅ **Gestión de procesos** con PID tracking
- ✅ **Logs en tiempo real** con colores y timestamps
- ✅ **Banner EduTech** con información del sistema

### 🛑 Terminador Elegante - Graceful Shutdown

**`scripts/mac/detener.sh` / `scripts/windows/detener.bat`** - Parada inteligente del servicio

```bash
# macOS/Linux
./scripts/mac/detener.sh

# Windows
scripts\windows\detener.bat
```

**🔒 Funcionalidades de Seguridad:**
- ✅ **Terminación graceful** con múltiples métodos (SIGTERM → SIGKILL)
- ✅ **Búsqueda automática** de procesos Java/Spring Boot/Maven
- ✅ **Cleanup completo** de archivos temporales y PIDs
- ✅ **Liberación de puertos** automática
- ✅ **Verificación de apagado** exitoso
- ✅ **Timeout configurable** para shutdown (30s default)

### 🔍 Diagnóstico Avanzado - System Health Check

**`scripts/mac/verificar-estado.sh` / `scripts/windows/verificar-estado.bat`** - Diagnóstico completo

```bash
# macOS/Linux
./scripts/mac/verificar-estado.sh

# Windows
scripts\windows\verificar-estado.bat
```

**📊 Capacidades de Diagnóstico:**
- ✅ **Health checks comprehensivos** de todos los endpoints
- ✅ **Validación completa** del proyecto Maven
- ✅ **Verificación de herramientas** (Java, Maven, Git, PostgreSQL)
- ✅ **Monitoreo de procesos** en tiempo real
- ✅ **Conectividad de BD** con pruebas automáticas
- ✅ **Compilación y pruebas** automáticas
- ✅ **Reporte ejecutivo** con métricas del sistema

### 🎨 Sistema de Banners - Visual Branding

**`scripts/banner.sh` / `scripts/banner.bat`** - Sistema visual profesional

**🎨 Características Visuales:**
- 🎯 **ASCII Art EduTech** con branding corporativo
- 🌈 **Soporte completo de colores** ANSI en ambas plataformas
- 📱 **Banners responsivos** para diferentes operaciones
- 💻 **Información dinámica** de sistema y versiones
- 🎭 **Marcos profesionales** con caracteres Unicode

## 🌟 Arquitectura del Sistema de Scripts

### 🏗️ Diseño Modular Empresarial

```
┌─────────────────────────────────────────────────────────────┐
│                    🎮 CONTROLADOR MAESTRO                   │
│              (Interfaz Unificada de Control)                │
└─────────────────────┬───────────────────────────────────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
    ┌────▼────┐  ┌────▼────┐  ┌────▼────┐
    │ ⚙️ CONFIG │  │ 🚀 START │  │ 🛑 STOP │
    │ Setup   │  │ Service │  │ Service │
    └────┬────┘  └────┬────┘  └────┬────┘
         │            │            │
         └────────────┼────────────┘
                      │
                 ┌────▼────┐
                 │ 🔍 CHECK │
                 │ Status  │
                 └─────────┘
```

### 🧠 Funcionalidades Inteligentes

#### 🔄 **Gestión de Estados Avanzada**
- **State Machine** para transiciones de servicio
- **Process Tracking** con archivos PID
- **Health Monitoring** continuo
- **Error Recovery** automático

#### 🛡️ **Sistema de Seguridad Integrado**
- **Validación de permisos** antes de ejecución
- **Sanitización de entrada** para prevenir inyecciones
- **Gestión segura de credenciales** con `.env`
- **Cleanup automático** de archivos sensibles

#### 📊 **Analytics y Telemetría**
- **Métricas de rendimiento** en tiempo real
- **Logs estructurados** con niveles (INFO, WARN, ERROR)
- **Timestamps precisos** para auditoría
- **Reporting ejecutivo** automático

### 🎨 Interfaz Visual Profesional

#### 🌈 **Sistema de Colores Inteligente**
```bash
🔴 RED    → Errores críticos y alertas
🟢 GREEN  → Operaciones exitosas
🟡 YELLOW → Advertencias y notas
🔵 BLUE   → Información general
🟣 PURPLE → Encabezados y títulos
🔵 CYAN   → Procesos en ejecución
```

#### 🎭 **Componentes Visuales**
- **Marcos Unicode** para secciones importantes
- **Progress Bars** ASCII para operaciones largas
- **Iconos contextuales** para cada tipo de operación
- **Banners dinámicos** con información del sistema

### 📝 Sistema de Logging Empresarial

#### 📁 **Estructura de Logs**
```
logs/
├── 📋 configuracion.log    # Setup y configuración inicial
├── 🚀 inicio.log          # Startup y arranque del servicio
├── 🛑 detencion.log       # Shutdown y parada del servicio
├── 🔍 verificacion.log    # Health checks y diagnósticos
└── 📊 application.log     # Logs del microservicio Spring Boot
```

#### 🏷️ **Formato de Log Profesional**
```log
[2025-06-01 21:08:39] [INFO] ✅ Java 17.0.2 detectado y validado
[2025-06-01 21:08:40] [WARN] ⚠️  Puerto 8083 en uso, intentando liberación
[2025-06-01 21:08:41] [ERROR] ❌ Conexión a BD falló: timeout después de 30s
[2025-06-01 21:08:42] [SUCCESS] 🎉 Microservicio iniciado exitosamente
```

### 🔍 Validaciones y Verificaciones Avanzadas

#### 🏥 **Health Checks Comprehensivos**

| Componente | Verificación | Timeout | Frecuencia |
|------------|-------------|---------|------------|
| **Sistema Base** | Java 17+, Maven 3.6+, Git | 10s | Startup |
| **Red y Puertos** | Puerto 8083, Conectividad | 30s | Startup |
| **Base de Datos** | PostgreSQL, Conexión activa | 60s | Cada 30s |
| **Aplicación** | `/actuator/health` endpoint | 120s | Cada 5s |
| **Compilación** | `mvn validate compile` | 180s | On-demand |

#### 🔒 **Validaciones de Seguridad**
- **Verificación de permisos** de archivos críticos
- **Validación de variables** de entorno obligatorias
- **Sanitización de entradas** de usuario
- **Verificación de integridad** de archivos de configuración

### 🌐 Compatibilidad Multiplataforma

| Característica | macOS/Linux (.sh) | Windows (.bat) | Estado |
|----------------|-------------------|----------------|--------|
| 🎨 **Colores ANSI** | ✅ Nativo | ✅ Windows 10+ | 100% |
| 🔧 **Gestión de Procesos** | ✅ bash/zsh | ✅ cmd/PowerShell | 100% |
| 📁 **Permisos de Archivos** | ✅ chmod | ✅ icacls | 100% |
| 🌐 **Health Checks HTTP** | ✅ curl | ✅ curl/PowerShell | 100% |
| ⚙️ **Variables de Entorno** | ✅ export/source | ✅ set/setx | 100% |
| 📊 **Logging Avanzado** | ✅ tee/tail | ✅ type/more | 100% |

### ⚙️ Configuración Avanzada del Sistema

#### 🔧 **Variables de Entorno Críticas**

```env
# =============================================================================
# EduTech - Variables de Entorno de Producción
# =============================================================================

# 🗄️ Configuración de Base de Datos PostgreSQL
DATABASE_URL=jdbc:postgresql://production-host:5432/edutech_evaluation
DATABASE_USERNAME=edutech_prod_user
DATABASE_PASSWORD=super_secure_password_2025!

# 🚀 Configuración de la Aplicación Spring Boot
SERVER_PORT=8083
SPRING_PROFILES_ACTIVE=production
SPRING_JPA_HIBERNATE_DDL_AUTO=validate

# 📊 Configuración de Logging
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_EDUTECH=DEBUG
LOGGING_FILE_NAME=logs/application.log

# 🏥 Configuración de Health Checks
HEALTH_CHECK_TIMEOUT=120
HEALTH_CHECK_INTERVAL=5
HEALTH_CHECK_RETRIES=3

# 🔒 Configuración de Seguridad
ALLOWED_ORIGINS=https://edutech.com,https://app.edutech.com
CORS_MAX_AGE=3600

# 📈 Configuración de Performance
JVM_OPTS=-Xmx2g -Xms1g -XX:+UseG1GC
MAVEN_OPTS=-Xmx1g -XX:+TieredCompilation
```

#### 🎯 **Configuración Específica por Entorno**

**🔧 Desarrollo (`dev`)**
```env
SPRING_PROFILES_ACTIVE=dev
LOGGING_LEVEL_ROOT=DEBUG
DATABASE_URL=jdbc:postgresql://localhost:5432/edutech_dev
HEALTH_CHECK_TIMEOUT=60
```

**🧪 Testing (`test`)**
```env
SPRING_PROFILES_ACTIVE=test
SPRING_JPA_HIBERNATE_DDL_AUTO=create-drop
DATABASE_URL=jdbc:h2:mem:testdb
HEALTH_CHECK_TIMEOUT=30
```

**🚀 Producción (`prod`)**
```env
SPRING_PROFILES_ACTIVE=production
LOGGING_LEVEL_ROOT=WARN
DATABASE_URL=jdbc:postgresql://prod-cluster:5432/edutech_prod
HEALTH_CHECK_TIMEOUT=120
```

## 🚀 Flujos de Trabajo

### 🆕 Onboarding

```bash
# 🎯 Paso 1: Configuración inicial del entorno
./scripts/mac/configurar.sh
# ✅ Valida Java 17+, Maven 3.6+, Git
# ✅ Crea archivo .env con plantillas
# ✅ Configura permisos de scripts
# ✅ Genera resumen del proyecto

# 🎮 Paso 2: Usar el controlador maestro
./scripts/mac/controlador.sh
# Seleccionar: 3) iniciar - para primer startup

# 🔍 Paso 3: Verificar que todo funciona
./scripts/mac/verificar-estado.sh
# ✅ Valida health endpoints
# ✅ Confirma conectividad de BD
# ✅ Verifica compilación exitosa
```

### 👨‍💻 Workflow de Desarrollo Diario

```bash
# 🌅 Inicio del día de desarrollo
./scripts/mac/controlador.sh
# → Opción 3: iniciar

# 🔍 Verificación rápida del sistema
./scripts/mac/verificar-estado.sh

# 📋 Monitoreo continuo de logs
tail -f logs/application.log

# 🌙 Final del día de trabajo
./scripts/mac/controlador.sh
# → Opción 4: detener
```

### 🔧 Workflow de Debug y Troubleshooting

```bash
# 🔍 Diagnóstico completo del sistema
./scripts/mac/verificar-estado.sh

# 🧹 Limpieza completa y reinicio
./scripts/mac/detener.sh
./scripts/mac/configurar.sh  # Reconfiguración
./scripts/mac/iniciar.sh

# 📊 Análisis de logs específicos
./scripts/mac/controlador.sh
# → Opción 11: logs (ver logs detallados)
# → Opción 12: salud (health checks)
# → Opción 13: metricas (system metrics)
```

### 🚀 Pipeline de Despliegue Automatizado

```bash
# 🎮 Usar controlador maestro para pipeline completo
./scripts/mac/controlador.sh

# 📝 Secuencia recomendada:
# 1. Opción 10: limpiar     - Clean build artifacts
# 2. Opción 7:  compilar    - Compile application  
# 3. Opción 8:  pruebas     - Run unit tests
# 4. Opción 9:  empaquetar  - Create deployable package
# 5. Opción 16: postman     - API integration tests
```

### 🔄 Workflow de Integración Continua

```bash
# 🤖 Script para CI/CD pipeline
#!/bin/bash
set -e

echo "🚀 EduTech CI/CD Pipeline iniciado..."

# Configurar entorno
./scripts/mac/configurar.sh

# Compilar y probar
./scripts/mac/controlador.sh
# → Automatizar: compilar → pruebas → empaquetar

# Verificar salud del sistema
./scripts/mac/verificar-estado.sh

echo "✅ Pipeline completado exitosamente"
```

## ✅ Estado de los Scripts

### 📊 Matriz de Funcionalidades

| Script | macOS/Linux | Windows | Funcionalidades | Estado |
|--------|-------------|---------|-----------------|--------|
| 🎮 **controlador** | ✅ | ✅ | 19 operaciones, menú interactivo | 🟢 100% |
| ⚙️ **configurar** | ✅ | ✅ | Setup completo, validaciones | 🟢 100% |
| 🚀 **iniciar** | ✅ | ✅ | Startup inteligente, health checks | 🟢 100% |
| 🛑 **detener** | ✅ | ✅ | Graceful shutdown, cleanup | 🟢 100% |
| 🔍 **verificar-estado** | ✅ | ✅ | Diagnóstico completo | 🟢 100% |
| 🎨 **banner** | ✅ | ✅ | Sistema visual | 🟢 100% |

### 🧪 Testing y Validación

**✅ Todos los scripts han sido probados y validados:**
- 🔧 **Sintaxis verificada** en ambas plataformas
- 🧪 **Funcionalidad probada** end-to-end
- 🔄 **Flujos de trabajo** validados
- 🛡️ **Casos de error** manejados correctamente
- 📊 **Logging y reportes** funcionando

## 🔒 Seguridad y Mejores Prácticas

### ✅ Mejores Prácticas Implementadas

- ✅ **Usar archivos `.env`** para todas las credenciales sensibles
- ✅ **Ejecutar `configurar.sh`** antes del primer uso
- ✅ **Revisar logs** en directorio `logs/` ante problemas
- ✅ **Usar `controlador.sh`** como punto de entrada principal
- ✅ **Mantener scripts actualizados** con `git pull`
- ✅ **Verificar permisos** de archivos ejecutables regularmente

### 🛡️ Medidas de Seguridad Implementadas

#### 🔐 **Protección de Credenciales**
```bash
# ✅ Correcto: usar variables de entorno
DATABASE_PASSWORD="${DATABASE_PASSWORD:-default_dev_password}"

# ❌ Incorrecto: hardcodear en script
DATABASE_PASSWORD="mi_password_super_secreto"
```

#### 🚫 **Sanitización de Entradas**
```bash
# ✅ Validación de entrada implementada
if [[ ! "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1024 ] || [ "$PORT" -gt 65535 ]; then
    print_error "Puerto inválido: $PORT"
    exit 1
fi
```

#### 🔍 **Auditoría y Logging**
```bash
# ✅ Logging detallado para auditoría
log "SECURITY" "Usuario: $USER ejecutó operación: $OPERATION"
log "SECURITY" "Archivo .env cargado desde: $ENV_FILE"
```

## 🆘 Troubleshooting Avanzado

### 🔧 Problemas Comunes y Soluciones

#### **🚫 Error: Permission denied**
```bash
# 🔧 Solución automática
./scripts/mac/configurar.sh  # Configura permisos automáticamente

# 🔧 Solución manual
chmod +x scripts/mac/*.sh
chmod +x scripts/banner.sh
```

#### **⚠️ Error: Port 8083 already in use**
```bash
# 🔧 Solución automática
./scripts/mac/detener.sh  # Libera puerto automáticamente

# 🔧 Solución manual
lsof -ti:8083 | xargs kill -9  # macOS/Linux
# o usar controlador: Opción 4 (detener)
```

#### **❌ Error: Database connection failed**
```bash
# 🔧 Diagnóstico completo
./scripts/mac/verificar-estado.sh

# 🔧 Reconfiguración completa
./scripts/mac/configurar.sh
# Editar archivo .env con credenciales correctas
```

#### **🔨 Error: Build compilation failed**
```bash
# 🔧 Limpieza y rebuild
./scripts/mac/controlador.sh
# → Opción 10: limpiar
# → Opción 7: compilar

# 🔧 Verificación de dependencias
./scripts/mac/controlador.sh
# → Opción 15: dependencias
```

#### 🆘 **Escalación de Problemas**

1. **🔍 Auto-diagnóstico**
   ```bash
   ./scripts/mac/verificar-estado.sh --detailed
   ```

2. **📋 Revisar logs específicos**
   ```bash
   # Log más reciente
   tail -50 logs/application.log
   
   # Logs de startup
   cat logs/inicio.log
   
   # Logs de configuración
   cat logs/configuracion.log
   ```

3. **🔄 Reset completo del entorno**
   ```bash
   ./scripts/mac/detener.sh
   ./scripts/mac/configurar.sh --force
   ./scripts/mac/iniciar.sh
   ```

## 📈 Métricas y Monitoreo

### 📊 Dashboard de Sistema

Los scripts proporcionan métricas detalladas del sistema:

```bash
# 📈 Métricas en tiempo real
./scripts/mac/controlador.sh
# → Opción 13: metricas

# Incluye:
# ├── 💻 CPU Usage
# ├── 🧠 Memory Usage  
# ├── 💾 Disk Space
# ├── 🌐 Network Status
# ├── 🗄️ Database Connections
# └── ⚡ Response Times
```

---

<div align="center">

## 🎉 ¡Sistema de Scripts EduTech Completamente Funcional!

**💡 ¿Necesitas ayuda? Ejecuta: `./scripts/mac/controlador.sh` → Opción 18 (ayuda)**

[![Desarrollado por](https://img.shields.io/badge/Desarrollado%20por-Felipe%20López-blue.svg)](https://github.com/feliplvz)
[![Repositorio](https://img.shields.io/badge/Repositorio-feliplvz-green.svg)](https://github.com/feliplvz/edutech-evaluation-service)
[![Última actualización](https://img.shields.io/badge/Actualizado-Dic%202024-orange.svg)](#)

---

*Sistema de scripts para EduTech Evaluation Service*

</div>