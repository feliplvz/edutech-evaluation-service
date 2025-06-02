@echo off
REM =============================================================================
REM EduTech - Script de Configuración del Microservicio de Evaluaciones (Windows)
REM =============================================================================
REM Descripción: Script profesional para configurar el entorno de desarrollo
REM              del Microservicio de Evaluaciones EduTech con validaciones completas
REM Autor: Equipo de Desarrollo EduTech
REM Versión: 2.0.0
REM Plataforma: Windows
REM Fecha: 1 de junio de 2025
REM =============================================================================

setlocal enabledelayedexpansion

REM Configuración
set SCRIPT_NAME=%~nx0
set SCRIPT_DIR=%~dp0
set PARENT_DIR=%SCRIPT_DIR%..\..\
set LOG_FILE=%PARENT_DIR%logs\configuracion.log
set TIMESTAMP=%date% %time%

REM Crear directorio de logs si no existe
if not exist "%PARENT_DIR%logs" mkdir "%PARENT_DIR%logs"

REM Cargar funciones del banner
call "%SCRIPT_DIR%..\banner.bat"

goto :main

REM =============================================================================
REM FUNCIONES DE LOGGING
REM =============================================================================

:escribir_log
    echo [%TIMESTAMP%] [%1] %2 >> "%LOG_FILE%"
    exit /b

:mostrar_y_log
    set "nivel=%1"
    set "mensaje=%~2"
    
    if "%nivel%"=="INFO" (
        echo %ESC%%CYAN%ℹ️  %mensaje%%ESC%%NC%
    ) else if "%nivel%"=="SUCCESS" (
        echo %ESC%%GREEN%✅ %mensaje%%ESC%%NC%
    ) else if "%nivel%"=="WARNING" (
        echo %ESC%%YELLOW%⚠️  %mensaje%%ESC%%NC%
    ) else if "%nivel%"=="ERROR" (
        echo %ESC%%RED%❌ %mensaje%%ESC%%NC%
    )
    
    call :escribir_log "%nivel%" "%mensaje%"
    exit /b

REM =============================================================================
REM FUNCIONES DE VERIFICACIÓN
REM =============================================================================

:verificar_java
    call :mostrar_y_log "INFO" "Verificando instalación de Java..."
    
    java -version >nul 2>&1
    if !errorlevel! neq 0 (
        call :mostrar_y_log "ERROR" "Java no está instalado o no está en PATH"
        call :mostrar_y_log "INFO" "Por favor instala Java 17 o superior desde: https://adoptium.net/"
        set "JAVA_OK=false"
    ) else (
        for /f "tokens=3" %%a in ('java -version 2^>^&1 ^| findstr "version"') do (
            set java_version=%%a
            set java_version=!java_version:"=!
            call :mostrar_y_log "SUCCESS" "Java encontrado: !java_version!"
            set "JAVA_OK=true"
        )
    )
    exit /b

:verificar_maven
    call :mostrar_y_log "INFO" "Verificando instalación de Maven..."
    
    mvn -version >nul 2>&1
    if !errorlevel! neq 0 (
        call :mostrar_y_log "ERROR" "Maven no está instalado o no está en PATH"
        call :mostrar_y_log "INFO" "Por favor instala Maven desde: https://maven.apache.org/download.cgi"
        set "MAVEN_OK=false"
    ) else (
        for /f "tokens=3" %%a in ('mvn -version 2^>nul ^| findstr "Apache Maven"') do (
            call :mostrar_y_log "SUCCESS" "Maven encontrado: %%a"
            set "MAVEN_OK=true"
        )
    )
    exit /b

:verificar_git
    call :mostrar_y_log "INFO" "Verificando instalación de Git..."
    
    git --version >nul 2>&1
    if !errorlevel! neq 0 (
        call :mostrar_y_log "WARNING" "Git no está instalado o no está en PATH"
        call :mostrar_y_log "INFO" "Se recomienda instalar Git desde: https://git-scm.com/"
        set "GIT_OK=false"
    ) else (
        for /f "tokens=3" %%a in ('git --version') do (
            call :mostrar_y_log "SUCCESS" "Git encontrado: %%a"
            set "GIT_OK=true"
        )
    )
    exit /b

:verificar_postgresql
    call :mostrar_y_log "INFO" "Verificando disponibilidad de PostgreSQL..."
    
    psql --version >nul 2>&1
    if !errorlevel! neq 0 (
        call :mostrar_y_log "WARNING" "PostgreSQL CLI no encontrado en PATH"
        call :mostrar_y_log "INFO" "Asegúrate de tener PostgreSQL instalado y accesible"
        set "POSTGRES_OK=false"
    ) else (
        for /f "tokens=3" %%a in ('psql --version') do (
            call :mostrar_y_log "SUCCESS" "PostgreSQL CLI encontrado: %%a"
            set "POSTGRES_OK=true"
        )
    )
    exit /b

REM =============================================================================
REM FUNCIONES DE CONFIGURACIÓN
REM =============================================================================

:crear_archivo_env
    call :mostrar_y_log "INFO" "Creando archivo de configuración de entorno..."
    cd /d "%PARENT_DIR%"
    
    if exist .env (
        call :mostrar_y_log "WARNING" "El archivo .env ya existe. Creando respaldo..."
        copy .env .env.backup.%date:~-4,4%%date:~-10,2%%date:~-7,2% >nul
    )
    
    (
        echo # =============================================================================
        echo # EduTech - Configuración del Microservicio de Evaluaciones
        echo # =============================================================================
        echo # Archivo de configuración de variables de entorno para desarrollo
        echo # Fecha de creación: %date% %time%
        echo # =============================================================================
        echo.
        echo # Configuración del Servidor
        echo SERVER_PORT=8083
        echo SPRING_PROFILES_ACTIVE=development
        echo.
        echo # Configuración de Base de Datos PostgreSQL
        echo DATABASE_URL=jdbc:postgresql://localhost:5432/edutech_evaluations
        echo DATABASE_USERNAME=edutech_user
        echo DATABASE_PASSWORD=edutech_password
        echo DATABASE_NAME=edutech_evaluations
        echo.
        echo # Configuración de JPA/Hibernate
        echo SPRING_JPA_HIBERNATE_DDL_AUTO=update
        echo SPRING_JPA_SHOW_SQL=true
        echo SPRING_JPA_PROPERTIES_HIBERNATE_FORMAT_SQL=true
        echo.
        echo # Configuración de Logging
        echo LOGGING_LEVEL_ROOT=INFO
        echo LOGGING_LEVEL_COM_EDUTECH=DEBUG
        echo LOGGING_FILE_NAME=logs/application.log
        echo.
        echo # Configuración de CORS
        echo CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
        echo CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
        echo.
        echo # Configuración de Actuator
        echo MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics,env
        echo MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS=always
        echo.
        echo # Configuración de Seguridad ^(si aplica^)
        echo # JWT_SECRET=tu_clave_secreta_super_segura_aqui
        echo # JWT_EXPIRATION=86400000
    ) > .env
    
    call :mostrar_y_log "SUCCESS" "Archivo .env creado exitosamente"
    exit /b

:crear_directorios
    call :mostrar_y_log "INFO" "Creando estructura de directorios..."
    cd /d "%PARENT_DIR%"
    
    if not exist logs mkdir logs
    call :mostrar_y_log "SUCCESS" "Directorio 'logs' creado/verificado"
    
    if not exist docs mkdir docs
    call :mostrar_y_log "SUCCESS" "Directorio 'docs' creado/verificado"
    
    if not exist postman mkdir postman
    call :mostrar_y_log "SUCCESS" "Directorio 'postman' creado/verificado"
    
    if not exist scripts\windows mkdir scripts\windows
    call :mostrar_y_log "SUCCESS" "Directorio 'scripts\windows' creado/verificado"
    
    if not exist scripts\mac mkdir scripts\mac
    call :mostrar_y_log "SUCCESS" "Directorio 'scripts\mac' creado/verificado"
    
    exit /b

:verificar_dependencias_maven
    call :mostrar_y_log "INFO" "Verificando dependencias de Maven..."
    cd /d "%PARENT_DIR%"
    
    if not exist pom.xml (
        call :mostrar_y_log "ERROR" "Archivo pom.xml no encontrado"
        exit /b
    )
    
    call :mostrar_y_log "INFO" "Descargando dependencias Maven..."
    mvn dependency:resolve >nul 2>&1
    if !errorlevel! equ 0 (
        call :mostrar_y_log "SUCCESS" "Dependencias Maven descargadas exitosamente"
    ) else (
        call :mostrar_y_log "ERROR" "Error al descargar dependencias Maven"
    )
    exit /b

:crear_resumen_proyecto
    call :mostrar_y_log "INFO" "Creando resumen del proyecto..."
    cd /d "%PARENT_DIR%"
    
    (
        echo # 🎓 EduTech - Microservicio de Evaluaciones
        echo.
        echo ## 📋 Información General
        echo - **Proyecto**: EduTech - Plataforma de Evaluaciones Estudiantiles
        echo - **Versión**: 2.0.0
        echo - **Fecha de Configuración**: %date% %time%
        echo - **Plataforma**: Windows
        echo.
        echo ## 🏗️ Arquitectura
        echo - **Framework**: Spring Boot 3.5.0
        echo - **Java**: 17+
        echo - **Base de Datos**: PostgreSQL
        echo - **Build Tool**: Maven
        echo - **API**: REST ^(43+ endpoints^)
        echo.
        echo ## 🚀 Configuración del Entorno
        echo.
        echo ### ✅ Herramientas Verificadas
        if "%JAVA_OK%"=="true" echo - ✅ Java instalado correctamente
        if "%JAVA_OK%"=="false" echo - ❌ Java no encontrado
        if "%MAVEN_OK%"=="true" echo - ✅ Maven instalado correctamente
        if "%MAVEN_OK%"=="false" echo - ❌ Maven no encontrado
        if "%GIT_OK%"=="true" echo - ✅ Git instalado correctamente
        if "%GIT_OK%"=="false" echo - ❌ Git no encontrado
        if "%POSTGRES_OK%"=="true" echo - ✅ PostgreSQL disponible
        if "%POSTGRES_OK%"=="false" echo - ❌ PostgreSQL no encontrado
        echo.
        echo ### 📁 Estructura de Directorios
        echo ```
        echo evaluation-service/
        echo ├── src/main/java/          # Código fuente Java
        echo ├── src/main/resources/     # Recursos de la aplicación
        echo ├── scripts/               # Scripts de automatización
        echo │   ├── windows/           # Scripts para Windows
        echo │   └── mac/               # Scripts para macOS/Linux
        echo ├── logs/                  # Archivos de log
        echo ├── docs/                  # Documentación
        echo ├── postman/               # Colecciones de Postman
        echo └── .env                   # Variables de entorno
        echo ```
        echo.
        echo ## 🛠️ Scripts Disponibles
        echo.
        echo ### Windows
        echo - `scripts\windows\controlador.bat` - Script maestro de control
        echo - `scripts\windows\configurar.bat` - Configuración del entorno
        echo - `scripts\windows\iniciar.bat` - Iniciar microservicio
        echo - `scripts\windows\detener.bat` - Detener microservicio
        echo - `scripts\windows\verificar-estado.bat` - Verificar estado
        echo.
        echo ### macOS/Linux
        echo - `scripts/mac/controlador.sh` - Script maestro de control
        echo - `scripts/mac/configurar.sh` - Configuración del entorno
        echo - `scripts/mac/iniciar.sh` - Iniciar microservicio
        echo - `scripts/mac/detener.sh` - Detener microservicio
        echo - `scripts/mac/verificar-estado.sh` - Verificar estado
        echo.
        echo ## 🔧 Configuración de Base de Datos
        echo.
        echo 1. **Crear Base de Datos**:
        echo    ```sql
        echo    CREATE DATABASE edutech_evaluations;
        echo    CREATE USER edutech_user WITH PASSWORD 'edutech_password';
        echo    GRANT ALL PRIVILEGES ON DATABASE edutech_evaluations TO edutech_user;
        echo    ```
        echo.
        echo 2. **Configurar Variables** ^(archivo .env^):
        echo    - `DATABASE_URL`: URL de conexión a PostgreSQL
        echo    - `DATABASE_USERNAME`: Usuario de la base de datos
        echo    - `DATABASE_PASSWORD`: Contraseña de la base de datos
        echo.
        echo ## 🚀 Inicio Rápido
        echo.
        echo 1. **Configurar Entorno**:
        echo    ```
        echo    scripts\windows\controlador.bat
        echo    # Seleccionar opción 1 ^(configurar^)
        echo    ```
        echo.
        echo 2. **Editar Variables de Entorno**:
        echo    ```
        echo    notepad .env
        echo    ```
        echo.
        echo 3. **Iniciar Microservicio**:
        echo    ```
        echo    scripts\windows\controlador.bat
        echo    # Seleccionar opción 3 ^(iniciar^)
        echo    ```
        echo.
        echo 4. **Verificar Estado**:
        echo    - API: http://localhost:8083
        echo    - Salud: http://localhost:8083/actuator/health
        echo    - Métricas: http://localhost:8083/actuator/metrics
        echo.
        echo ## 📚 Documentación Adicional
        echo.
        echo - **README.md**: Información general del proyecto
        echo - **SCRIPTS_GUIDE.md**: Guía detallada de scripts
        echo - **postman/**: Colecciones para probar la API
        echo - **docs/**: Documentación técnica adicional
        echo.
        echo ## 🤝 Soporte
        echo.
        echo Para obtener ayuda adicional:
        echo 1. Ejecuta `scripts\windows\controlador.bat` y selecciona "ayuda"
        echo 2. Revisa los logs en el directorio `logs/`
        echo 3. Consulta la documentación en el directorio `docs/`
        echo.
        echo ---
        echo **EduTech Development Team** - %date%
    ) > "RESUMEN_PROYECTO.md"
    
    call :mostrar_y_log "SUCCESS" "Archivo RESUMEN_PROYECTO.md creado exitosamente"
    exit /b

REM =============================================================================
REM FUNCIÓN PRINCIPAL
REM =============================================================================

:main
    call :show_edutech_banner
    call :mostrar_y_log "INFO" "=== Iniciando configuración del entorno de desarrollo EduTech ==="
    
    echo %ESC%%CYAN%🔧 Configurando entorno de desarrollo para EduTech Microservicio de Evaluaciones...%ESC%%NC%
    echo %ESC%%BLUE%📅 Fecha: %date% %time%%ESC%%NC%
    echo.
    
    REM Verificar herramientas del sistema
    echo %ESC%%PURPLE%🔍 VERIFICANDO HERRAMIENTAS DEL SISTEMA%ESC%%NC%
    echo ════════════════════════════════════════
    call :verificar_java
    call :verificar_maven
    call :verificar_git
    call :verificar_postgresql
    echo.
    
    REM Verificar si las herramientas esenciales están disponibles
    if "%JAVA_OK%"=="false" (
        echo %ESC%%RED%❌ CONFIGURACIÓN ABORTADA: Java es requerido%ESC%%NC%
        call :escribir_log "ERROR" "Configuración abortada: Java no encontrado"
        echo %ESC%%YELLOW%⏸️  Presiona cualquier tecla para salir...%ESC%%NC%
        pause >nul
        exit /b 1
    )
    
    if "%MAVEN_OK%"=="false" (
        echo %ESC%%RED%❌ CONFIGURACIÓN ABORTADA: Maven es requerido%ESC%%NC%
        call :escribir_log "ERROR" "Configuración abortada: Maven no encontrado"
        echo %ESC%%YELLOW%⏸️  Presiona cualquier tecla para salir...%ESC%%NC%
        pause >nul
        exit /b 1
    )
    
    REM Crear estructura de directorios
    echo %ESC%%PURPLE%📁 CREANDO ESTRUCTURA DE DIRECTORIOS%ESC%%NC%
    echo ══════════════════════════════════════════
    call :crear_directorios
    echo.
    
    REM Crear archivo de configuración
    echo %ESC%%PURPLE%⚙️ CONFIGURANDO VARIABLES DE ENTORNO%ESC%%NC%
    echo ════════════════════════════════════════════
    call :crear_archivo_env
    echo.
    
    REM Verificar dependencias Maven
    echo %ESC%%PURPLE%📦 VERIFICANDO DEPENDENCIAS MAVEN%ESC%%NC%
    echo ═══════════════════════════════════════════
    call :verificar_dependencias_maven
    echo.
    
    REM Crear resumen del proyecto
    echo %ESC%%PURPLE%📋 GENERANDO RESUMEN DEL PROYECTO%ESC%%NC%
    echo ════════════════════════════════════════════
    call :crear_resumen_proyecto
    echo.
    
    REM Resumen final
    echo %ESC%%GREEN%✅ CONFIGURACIÓN COMPLETADA EXITOSAMENTE%ESC%%NC%
    echo ═══════════════════════════════════════════════
    echo %ESC%%CYAN%🎉 El entorno de desarrollo EduTech está listo!%ESC%%NC%
    echo.
    echo %ESC%%YELLOW%📋 Próximos pasos:%ESC%%NC%
    echo   1. 📝 Edita el archivo .env con tus credenciales de base de datos
    echo   2. 🗄️  Crea la base de datos PostgreSQL ^(ver RESUMEN_PROYECTO.md^)
    echo   3. 🚀 Usa scripts\windows\controlador.bat para gestionar el microservicio
    echo   4. 📊 Verifica el estado con la opción 'estado' del controlador
    echo.
    echo %ESC%%BLUE%📂 Archivos creados:%ESC%%NC%
    echo   - .env ^(configuración de entorno^)
    echo   - RESUMEN_PROYECTO.md ^(documentación completa^)
    echo   - logs/ ^(directorio para logs^)
    echo.
    echo %ESC%%GREEN%🎯 Para iniciar el microservicio: scripts\windows\controlador.bat%ESC%%NC%
    
    call :mostrar_y_log "SUCCESS" "=== Configuración del entorno completada exitosamente ==="
    
    echo.
    echo %ESC%%YELLOW%⏸️  Presiona cualquier tecla para continuar...%ESC%%NC%
    pause >nul
    
    exit /b 0
