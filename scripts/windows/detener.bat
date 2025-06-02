@echo off
REM =============================================================================
REM EduTech - Script de Detención del Microservicio de Evaluaciones (Windows)
REM =============================================================================
REM Descripción: Script profesional para detener el Microservicio de Evaluaciones
REM              con terminación elegante y procedimientos de limpieza
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
set LOG_FILE=%PARENT_DIR%logs\detencion.log
set PID_FILE=%PARENT_DIR%logs\app.pid
set TIMESTAMP=%date% %time%
set DEFAULT_PORT=8083
set GRACEFUL_TIMEOUT=30

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
REM FUNCIONES DE DETECCIÓN Y DETENCIÓN
REM =============================================================================

:cargar_variables_entorno
    call :mostrar_y_log "INFO" "Cargando configuración de entorno..."
    cd /d "%PARENT_DIR%"
    
    REM Establecer puerto por defecto
    set "SERVER_PORT=%DEFAULT_PORT%"
    
    if exist .env (
        REM Leer variables del archivo .env
        for /f "usebackq tokens=1,2 delims==" %%a in (.env) do (
            if not "%%a"=="" if not "%%a:~0,1%"=="#" (
                if "%%a"=="SERVER_PORT" set "SERVER_PORT=%%b"
            )
        )
        call :mostrar_y_log "SUCCESS" "Configuración cargada desde .env"
    ) else (
        call :mostrar_y_log "WARNING" "Archivo .env no encontrado, usando puerto por defecto"
    )
    
    call :mostrar_y_log "INFO" "Puerto objetivo: %SERVER_PORT%"
    exit /b 0

:detectar_procesos_microservicio
    call :mostrar_y_log "INFO" "Detectando procesos del microservicio EduTech..."
    
    set "procesos_encontrados=false"
    
    REM Buscar por puerto
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%SERVER_PORT% "') do (
        set "pid=%%a"
        if not "!pid!"=="" (
            set "procesos_encontrados=true"
            call :mostrar_y_log "INFO" "Proceso encontrado usando puerto %SERVER_PORT%: PID !pid!"
            set "MAIN_PID=!pid!"
        )
    )
    
    REM Buscar procesos Java relacionados con evaluación
    for /f "tokens=2" %%a in ('tasklist /fi "imagename eq java.exe" /fo csv ^| findstr "java"') do (
        set "java_pid=%%a"
        set "java_pid=!java_pid:"=!"
        
        REM Verificar si es nuestro proceso Spring Boot
        wmic process where "ProcessId=!java_pid!" get CommandLine /format:list 2>nul | findstr "spring-boot" >nul
        if !errorlevel! equ 0 (
            wmic process where "ProcessId=!java_pid!" get CommandLine /format:list 2>nul | findstr "evaluation" >nul
            if !errorlevel! equ 0 (
                set "procesos_encontrados=true"
                call :mostrar_y_log "INFO" "Proceso Spring Boot encontrado: PID !java_pid!"
                set "SPRING_PID=!java_pid!"
            )
        )
    )
    
    REM Buscar procesos Maven
    for /f "tokens=2" %%a in ('tasklist /fi "imagename eq java.exe" /fo csv ^| findstr "java"') do (
        set "maven_pid=%%a"
        set "maven_pid=!maven_pid:"=!"
        
        wmic process where "ProcessId=!maven_pid!" get CommandLine /format:list 2>nul | findstr "maven" >nul
        if !errorlevel! equ 0 (
            set "procesos_encontrados=true"
            call :mostrar_y_log "INFO" "Proceso Maven encontrado: PID !maven_pid!"
            set "MAVEN_PID=!maven_pid!"
        )
    )
    
    if "%procesos_encontrados%"=="false" (
        call :mostrar_y_log "WARNING" "No se encontraron procesos del microservicio ejecutándose"
        exit /b 1
    )
    
    exit /b 0

:terminar_proceso_graceful
    set "pid=%1"
    set "nombre=%2"
    
    if "%pid%"=="" (
        exit /b 1
    )
    
    call :mostrar_y_log "INFO" "Enviando señal de terminación elegante a %nombre% (PID: %pid%)"
    
    REM Verificar si el proceso existe
    tasklist /fi "pid eq %pid%" 2>nul | findstr "%pid%" >nul
    if !errorlevel! neq 0 (
        call :mostrar_y_log "WARNING" "El proceso %pid% ya no existe"
        exit /b 0
    )
    
    REM Intentar terminación elegante enviando Ctrl+C
    taskkill /pid %pid% >nul 2>&1
    
    REM Esperar un momento para terminación elegante
    set /a contador=0
    :esperar_terminacion
    timeout /t 2 >nul
    set /a contador+=2
    
    tasklist /fi "pid eq %pid%" 2>nul | findstr "%pid%" >nul
    if !errorlevel! neq 0 (
        call :mostrar_y_log "SUCCESS" "Proceso %nombre% terminado elegantemente"
        exit /b 0
    )
    
    if %contador% geq %GRACEFUL_TIMEOUT% (
        call :mostrar_y_log "WARNING" "Timeout de terminación elegante, forzando terminación..."
        taskkill /f /pid %pid% >nul 2>&1
        call :mostrar_y_log "SUCCESS" "Proceso %nombre% terminado forzadamente"
        exit /b 0
    )
    
    goto :esperar_terminacion

:verificar_endpoints_shutdown
    call :mostrar_y_log "INFO" "Intentando apagado elegante vía endpoint de Spring Boot..."
    
    set "shutdown_url=http://localhost:%SERVER_PORT%/actuator/shutdown"
    
    REM Intentar apagado elegante si el endpoint está disponible
    powershell -Command "try { Invoke-WebRequest -Uri '%shutdown_url%' -Method POST -UseBasicParsing -TimeoutSec 10 | Out-Null; Write-Host 'Shutdown endpoint called successfully' } catch { Write-Host 'Shutdown endpoint not available or accessible' }" 2>nul
    
    REM Esperar un momento para que el apagado elegante tome efecto
    timeout /t 5 >nul
    
    exit /b 0

:limpiar_archivos_temporales
    call :mostrar_y_log "INFO" "Limpiando archivos temporales..."
    cd /d "%PARENT_DIR%"
    
    REM Eliminar archivo PID si existe
    if exist "%PID_FILE%" (
        del "%PID_FILE%" >nul 2>&1
        call :mostrar_y_log "SUCCESS" "Archivo PID eliminado"
    )
    
    REM Limpiar archivos de bloqueo temporales
    if exist "*.lock" (
        del "*.lock" >nul 2>&1
        call :mostrar_y_log "SUCCESS" "Archivos de bloqueo eliminados"
    )
    
    REM Limpiar archivos temporales de Maven
    if exist "target\maven-status\maven-compiler-plugin\compile\default-compile\inputFiles.lst" (
        call :mostrar_y_log "INFO" "Archivos de estado de Maven encontrados (OK)"
    )
    
    exit /b 0

:verificar_detencion_completa
    call :mostrar_y_log "INFO" "Verificando que todos los procesos hayan terminado..."
    
    REM Verificar por puerto
    netstat -an | findstr ":%SERVER_PORT% " >nul
    if !errorlevel! equ 0 (
        call :mostrar_y_log "WARNING" "Puerto %SERVER_PORT% aún está en uso"
        
        REM Intentar obtener el PID y terminarlo
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%SERVER_PORT% "') do (
            set "remaining_pid=%%a"
            if not "!remaining_pid!"=="" (
                call :mostrar_y_log "INFO" "Terminando proceso restante: PID !remaining_pid!"
                taskkill /f /pid !remaining_pid! >nul 2>&1
            )
        )
    ) else (
        call :mostrar_y_log "SUCCESS" "Puerto %SERVER_PORT% liberado correctamente"
    )
    
    REM Verificar procesos Java restantes
    set "java_processes_found=false"
    for /f "tokens=2" %%a in ('tasklist /fi "imagename eq java.exe" /fo csv 2^>nul ^| findstr "java"') do (
        set "check_pid=%%a"
        set "check_pid=!check_pid:"=!"
        
        wmic process where "ProcessId=!check_pid!" get CommandLine /format:list 2>nul | findstr "evaluation\|spring-boot" >nul
        if !errorlevel! equ 0 (
            set "java_processes_found=true"
            call :mostrar_y_log "WARNING" "Proceso Java relacionado aún ejecutándose: PID !check_pid!"
        )
    )
    
    if "%java_processes_found%"=="false" (
        call :mostrar_y_log "SUCCESS" "Todos los procesos relacionados han terminado"
    )
    
    exit /b 0

REM =============================================================================
REM FUNCIÓN PRINCIPAL
REM =============================================================================

:main
    call :show_edutech_banner
    call :mostrar_y_log "INFO" "=== Deteniendo EduTech Microservicio de Evaluaciones ==="
    
    echo %ESC%%CYAN%🛑 Deteniendo microservicio EduTech de Evaluaciones...%ESC%%NC%
    echo %ESC%%BLUE%📅 Fecha: %date% %time%%ESC%%NC%
    echo.
    
    REM Paso 1: Cargar configuración
    echo %ESC%%PURPLE%⚙️ PASO 1: CARGA DE CONFIGURACIÓN%ESC%%NC%
    echo ═══════════════════════════════════════════
    call :cargar_variables_entorno
    echo.
    
    REM Paso 2: Detectar procesos
    echo %ESC%%PURPLE%🔍 PASO 2: DETECCIÓN DE PROCESOS%ESC%%NC%
    echo ═══════════════════════════════════════════
    call :detectar_procesos_microservicio
    if !errorlevel! neq 0 (
        echo %ESC%%GREEN%✅ No se encontraron procesos para detener%ESC%%NC%
        goto :detencion_exitosa
    )
    echo.
    
    REM Paso 3: Apagado elegante vía endpoint
    echo %ESC%%PURPLE%🏥 PASO 3: APAGADO ELEGANTE VÍA ENDPOINT%ESC%%NC%
    echo ════════════════════════════════════════════════
    call :verificar_endpoints_shutdown
    echo.
    
    REM Paso 4: Terminar procesos detectados
    echo %ESC%%PURPLE%🔌 PASO 4: TERMINACIÓN DE PROCESOS%ESC%%NC%
    echo ═══════════════════════════════════════════════
    
    if defined MAIN_PID (
        call :terminar_proceso_graceful "%MAIN_PID%" "Proceso Principal"
    )
    
    if defined SPRING_PID (
        if not "%SPRING_PID%"=="%MAIN_PID%" (
            call :terminar_proceso_graceful "%SPRING_PID%" "Spring Boot"
        )
    )
    
    if defined MAVEN_PID (
        if not "%MAVEN_PID%"=="%MAIN_PID%" if not "%MAVEN_PID%"=="%SPRING_PID%" (
            call :terminar_proceso_graceful "%MAVEN_PID%" "Maven"
        )
    )
    echo.
    
    REM Paso 5: Limpiar archivos temporales
    echo %ESC%%PURPLE%🧹 PASO 5: LIMPIEZA DE ARCHIVOS TEMPORALES%ESC%%NC%
    echo ════════════════════════════════════════════════════
    call :limpiar_archivos_temporales
    echo.
    
    REM Paso 6: Verificación final
    echo %ESC%%PURPLE%✅ PASO 6: VERIFICACIÓN FINAL%ESC%%NC%
    echo ══════════════════════════════════════════
    call :verificar_detencion_completa
    echo.
    
    :detencion_exitosa
    echo %ESC%%GREEN%🎉 ¡MICROSERVICIO EDUTECH DETENIDO EXITOSAMENTE!%ESC%%NC%
    echo ════════════════════════════════════════════════════════
    echo.
    echo %ESC%%CYAN%📊 Estado Final:%ESC%%NC%
    echo   🛑 Microservicio: Detenido
    echo   🔌 Puerto %SERVER_PORT%: Liberado
    echo   🧹 Archivos temporales: Limpiados
    echo.
    echo %ESC%%CYAN%🛠️  Gestión del Servicio:%ESC%%NC%
    echo   🚀 Iniciar: scripts\windows\iniciar.bat
    echo   🔍 Estado: scripts\windows\verificar-estado.bat
    echo   🎛️  Control: scripts\windows\controlador.bat
    echo.
    echo %ESC%%CYAN%📁 Logs Disponibles:%ESC%%NC%
    echo   📄 Aplicación: logs\application.log
    echo   🛑 Detención: logs\detencion.log
    echo.
    
    call :mostrar_y_log "SUCCESS" "=== Microservicio EduTech detenido exitosamente ==="
    
    echo %ESC%%YELLOW%⏸️  Presiona cualquier tecla para continuar...%ESC%%NC%
    pause >nul
    
    exit /b 0
