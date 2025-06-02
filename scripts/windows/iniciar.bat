@echo off
REM =============================================================================
REM EduTech - Script de Inicio del Microservicio de Evaluaciones (Windows)
REM =============================================================================
REM Descripción: Script profesional para iniciar el Microservicio de Evaluaciones
REM              con monitoreo completo, validaciones y manejo de errores
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
set LOG_FILE=%PARENT_DIR%logs\inicio.log
set PID_FILE=%PARENT_DIR%logs\app.pid
set TIMESTAMP=%date% %time%
set DEFAULT_PORT=8083
set HEALTH_CHECK_TIMEOUT=120
set HEALTH_CHECK_INTERVAL=5

REM Crear directorio de logs si no existe
if not exist "%PARENT_DIR%logs" mkdir "%PARENT_DIR%logs"

REM Cargar funciones del banner
call "%SCRIPT_DIR%..\banner.bat"

goto :main

REM =============================================================================
REM FUNCIONES DE LOGGING
REM =============================================================================

:escribir_log
    echo [%date% %time%] [%1] %2 >> "%LOG_FILE%"
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
REM FUNCIONES DE VALIDACIÓN
REM =============================================================================

:cargar_variables_entorno
    call :mostrar_y_log "INFO" "Cargando variables de entorno..."
    cd /d "%PARENT_DIR%"
    
    if not exist .env (
        call :mostrar_y_log "ERROR" "Archivo .env no encontrado. Ejecuta el script de configuración primero."
        exit /b 1
    )
    
    REM Leer variables del archivo .env
    for /f "usebackq tokens=1,2 delims==" %%a in (.env) do (
        if not "%%a"=="" if not "%%a:~0,1%"=="#" (
            set "%%a=%%b"
        )
    )
    
    REM Establecer puerto por defecto si no está definido
    if not defined SERVER_PORT (
        set "SERVER_PORT=%DEFAULT_PORT%"
        call :mostrar_y_log "INFO" "Usando puerto por defecto: %DEFAULT_PORT%"
    )
    
    call :mostrar_y_log "SUCCESS" "Variables de entorno cargadas"
    call :mostrar_y_log "INFO" "Puerto del servidor: %SERVER_PORT%"
    exit /b 0

:verificar_puerto_disponible
    call :mostrar_y_log "INFO" "Verificando disponibilidad del puerto %SERVER_PORT%..."
    
    netstat -an | findstr ":%SERVER_PORT% " >nul
    if !errorlevel! equ 0 (
        call :mostrar_y_log "ERROR" "El puerto %SERVER_PORT% ya está en uso"
        call :mostrar_y_log "INFO" "Procesos usando el puerto:"
        netstat -ano | findstr ":%SERVER_PORT% "
        exit /b 1
    )
    
    call :mostrar_y_log "SUCCESS" "Puerto %SERVER_PORT% disponible"
    exit /b 0

:verificar_base_datos
    call :mostrar_y_log "INFO" "Verificando conectividad de base de datos..."
    
    if not defined DATABASE_URL (
        call :mostrar_y_log "WARNING" "DATABASE_URL no definida en .env"
        exit /b 1
    )
    
    call :mostrar_y_log "INFO" "Base de datos configurada: %DATABASE_URL%"
    
    REM Aquí podrías agregar una verificación de conectividad real si tienes psql
    psql "%DATABASE_URL%" -c "SELECT 1;" >nul 2>&1
    if !errorlevel! equ 0 (
        call :mostrar_y_log "SUCCESS" "Conexión a base de datos exitosa"
    ) else (
        call :mostrar_y_log "WARNING" "No se pudo verificar la conexión a la base de datos"
        call :mostrar_y_log "INFO" "El microservicio intentará conectarse al iniciar"
    )
    
    exit /b 0

:verificar_dependencias_maven
    call :mostrar_y_log "INFO" "Verificando dependencias Maven..."
    cd /d "%PARENT_DIR%"
    
    if not exist pom.xml (
        call :mostrar_y_log "ERROR" "Archivo pom.xml no encontrado"
        exit /b 1
    )
    
    mvn dependency:resolve -q >nul 2>&1
    if !errorlevel! neq 0 (
        call :mostrar_y_log "WARNING" "Problema con dependencias Maven, intentando resolverlas..."
        mvn dependency:resolve
    )
    
    call :mostrar_y_log "SUCCESS" "Dependencias Maven verificadas"
    exit /b 0

REM =============================================================================
REM FUNCIONES DE INICIO
REM =============================================================================

:compilar_aplicacion
    call :mostrar_y_log "INFO" "Compilando aplicación Spring Boot..."
    cd /d "%PARENT_DIR%"
    
    mvn clean compile -q
    if !errorlevel! neq 0 (
        call :mostrar_y_log "ERROR" "Error en la compilación"
        call :mostrar_y_log "INFO" "Ejecutando compilación detallada..."
        mvn clean compile
        exit /b 1
    )
    
    call :mostrar_y_log "SUCCESS" "Compilación completada exitosamente"
    exit /b 0

:iniciar_aplicacion
    call :mostrar_y_log "INFO" "Iniciando microservicio EduTech..."
    cd /d "%PARENT_DIR%"
    
    REM Eliminar archivo PID anterior si existe
    if exist "%PID_FILE%" del "%PID_FILE%"
    
    call :mostrar_y_log "INFO" "Ejecutando Spring Boot con perfil: %SPRING_PROFILES_ACTIVE%"
    
    REM Iniciar la aplicación en segundo plano
    start "EduTech-Evaluaciones" /min cmd /c "mvn spring-boot:run -Dspring-boot.run.jvmArguments=\"-Dserver.port=%SERVER_PORT%\" > logs\application.log 2>&1"
    
    REM Esperar un momento para que la aplicación inicie
    timeout /t 3 >nul
    
    call :mostrar_y_log "SUCCESS" "Proceso de inicio iniciado"
    exit /b 0

:verificar_salud_aplicacion
    call :mostrar_y_log "INFO" "Verificando estado de salud del microservicio..."
    
    set "health_url=http://localhost:%SERVER_PORT%/actuator/health"
    set /a intentos=0
    set /a max_intentos=%HEALTH_CHECK_TIMEOUT%/%HEALTH_CHECK_INTERVAL%
    
    :loop_salud
    set /a intentos+=1
    
    call :mostrar_y_log "INFO" "Intento %intentos%/%max_intentos% - Verificando %health_url%"
    
    powershell -Command "try { $response = Invoke-WebRequest -Uri '%health_url%' -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { exit 0 } else { exit 1 } } catch { exit 1 }" >nul 2>&1
    
    if !errorlevel! equ 0 (
        call :mostrar_y_log "SUCCESS" "Microservicio iniciado correctamente y respondiendo"
        call :mostrar_y_log "INFO" "Estado de salud: OK"
        goto :salud_ok
    )
    
    if %intentos% geq %max_intentos% (
        call :mostrar_y_log "ERROR" "Timeout: El microservicio no respondió después de %HEALTH_CHECK_TIMEOUT% segundos"
        call :mostrar_y_log "INFO" "Revisa los logs en: logs\application.log"
        exit /b 1
    )
    
    call :mostrar_y_log "INFO" "Esperando %HEALTH_CHECK_INTERVAL% segundos antes del siguiente intento..."
    timeout /t %HEALTH_CHECK_INTERVAL% >nul
    goto :loop_salud
    
    :salud_ok
    exit /b 0

:mostrar_informacion_startup
    echo.
    echo %ESC%%GREEN%🎉 ¡MICROSERVICIO EDUTECH INICIADO EXITOSAMENTE!%ESC%%NC%
    echo ════════════════════════════════════════════════════════
    echo.
    echo %ESC%%CYAN%📊 Información del Servicio:%ESC%%NC%
    echo   🌐 URL Principal: http://localhost:%SERVER_PORT%
    echo   🏥 Endpoint de Salud: http://localhost:%SERVER_PORT%/actuator/health
    echo   📊 Métricas: http://localhost:%SERVER_PORT%/actuator/metrics
    echo   📋 Info: http://localhost:%SERVER_PORT%/actuator/info
    echo.
    echo %ESC%%CYAN%📁 Archivos de Logs:%ESC%%NC%
    echo   📄 Aplicación: logs\application.log
    echo   🚀 Inicio: logs\inicio.log
    echo.
    echo %ESC%%CYAN%🛠️  Gestión del Servicio:%ESC%%NC%
    echo   🛑 Detener: scripts\windows\detener.bat
    echo   🔍 Estado: scripts\windows\verificar-estado.bat
    echo   🎛️  Control: scripts\windows\controlador.bat
    echo.
    echo %ESC%%YELLOW%💡 Consejo:%ESC%%NC% Usa Ctrl+C para detener este script, pero el microservicio seguirá ejecutándose
    echo.
    exit /b

REM =============================================================================
REM FUNCIÓN PRINCIPAL
REM =============================================================================

:main
    call :show_edutech_banner
    call :mostrar_y_log "INFO" "=== Iniciando EduTech Microservicio de Evaluaciones ==="
    
    echo %ESC%%CYAN%🚀 Iniciando microservicio EduTech de Evaluaciones...%ESC%%NC%
    echo %ESC%%BLUE%📅 Fecha: %date% %time%%ESC%%NC%
    echo.
    
    REM Paso 1: Cargar variables de entorno
    echo %ESC%%PURPLE%⚙️ PASO 1: CONFIGURACIÓN DE ENTORNO%ESC%%NC%
    echo ════════════════════════════════════════════
    call :cargar_variables_entorno
    if !errorlevel! neq 0 goto :error_exit
    echo.
    
    REM Paso 2: Verificar puerto disponible
    echo %ESC%%PURPLE%🔍 PASO 2: VERIFICACIÓN DE PUERTO%ESC%%NC%
    echo ══════════════════════════════════════════
    call :verificar_puerto_disponible
    if !errorlevel! neq 0 goto :error_exit
    echo.
    
    REM Paso 3: Verificar base de datos
    echo %ESC%%PURPLE%🗄️ PASO 3: VERIFICACIÓN DE BASE DE DATOS%ESC%%NC%
    echo ════════════════════════════════════════════════
    call :verificar_base_datos
    echo.
    
    REM Paso 4: Verificar dependencias Maven
    echo %ESC%%PURPLE%📦 PASO 4: VERIFICACIÓN DE DEPENDENCIAS%ESC%%NC%
    echo ═══════════════════════════════════════════════
    call :verificar_dependencias_maven
    if !errorlevel! neq 0 goto :error_exit
    echo.
    
    REM Paso 5: Compilar aplicación
    echo %ESC%%PURPLE%🔨 PASO 5: COMPILACIÓN DE LA APLICACIÓN%ESC%%NC%
    echo ═══════════════════════════════════════════════
    call :compilar_aplicacion
    if !errorlevel! neq 0 goto :error_exit
    echo.
    
    REM Paso 6: Iniciar aplicación
    echo %ESC%%PURPLE%🚀 PASO 6: INICIO DEL MICROSERVICIO%ESC%%NC%
    echo ═══════════════════════════════════════════
    call :iniciar_aplicacion
    if !errorlevel! neq 0 goto :error_exit
    echo.
    
    REM Paso 7: Verificar estado de salud
    echo %ESC%%PURPLE%🏥 PASO 7: VERIFICACIÓN DE ESTADO DE SALUD%ESC%%NC%
    echo ════════════════════════════════════════════════════
    call :verificar_salud_aplicacion
    if !errorlevel! neq 0 goto :error_exit
    echo.
    
    REM Mostrar información final
    call :mostrar_informacion_startup
    
    call :mostrar_y_log "SUCCESS" "=== Microservicio EduTech iniciado exitosamente ==="
    
    echo %ESC%%YELLOW%⏸️  Presiona cualquier tecla para finalizar este script...%ESC%%NC%
    pause >nul
    
    exit /b 0

:error_exit
    echo.
    echo %ESC%%RED%❌ ERROR: El microservicio no pudo iniciarse%ESC%%NC%
    echo ════════════════════════════════════════════════
    echo.
    echo %ESC%%YELLOW%🔧 Posibles soluciones:%ESC%%NC%
    echo   1. Ejecutar scripts\windows\configurar.bat
    echo   2. Verificar configuración en archivo .env
    echo   3. Asegurarse de que PostgreSQL esté ejecutándose
    echo   4. Revisar logs en logs\inicio.log
    echo.
    call :mostrar_y_log "ERROR" "=== Error al iniciar el microservicio ==="
    
    echo %ESC%%YELLOW%⏸️  Presiona cualquier tecla para salir...%ESC%%NC%
    pause >nul
    
    exit /b 1
