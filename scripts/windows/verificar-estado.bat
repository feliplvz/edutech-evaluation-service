@echo off
REM =============================================================================
REM EduTech - Script de Verificación de Estado del Microservicio (Windows)
REM =============================================================================
REM Descripción: Script profesional para verificar el estado del Microservicio 
REM              de Evaluaciones EduTech con monitoreo completo de salud
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
set LOG_FILE=%PARENT_DIR%logs\verificacion-estado.log
set TIMESTAMP=%date% %time%
set DEFAULT_PORT=8083

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
REM FUNCIONES DE VERIFICACIÓN
REM =============================================================================

:cargar_configuracion
    call :mostrar_y_log "INFO" "Cargando configuración del sistema..."
    cd /d "%PARENT_DIR%"
    
    REM Establecer puerto por defecto
    set "SERVER_PORT=%DEFAULT_PORT%"
    
    if exist .env (
        REM Leer variables del archivo .env
        for /f "usebackq tokens=1,2 delims==" %%a in (.env) do (
            if not "%%a"=="" if not "%%a:~0,1%"=="#" (
                if "%%a"=="SERVER_PORT" set "SERVER_PORT=%%b"
                if "%%a"=="DATABASE_URL" set "DATABASE_URL=%%b"
                if "%%a"=="SPRING_PROFILES_ACTIVE" set "SPRING_PROFILES_ACTIVE=%%b"
            )
        )
        call :mostrar_y_log "SUCCESS" "Configuración cargada desde .env"
    ) else (
        call :mostrar_y_log "WARNING" "Archivo .env no encontrado, usando configuración por defecto"
    )
    
    call :mostrar_y_log "INFO" "Puerto configurado: %SERVER_PORT%"
    exit /b 0

:verificar_procesos_sistema
    call :mostrar_y_log "INFO" "Verificando procesos del sistema..."
    
    set "procesos_encontrados=0"
    set "procesos_java=0"
    set "procesos_maven=0"
    
    REM Contar procesos Java
    for /f %%a in ('tasklist /fi "imagename eq java.exe" 2^>nul ^| find /c "java.exe"') do (
        set "procesos_java=%%a"
    )
    
    REM Buscar procesos específicos del microservicio
    for /f "tokens=2" %%a in ('tasklist /fi "imagename eq java.exe" /fo csv 2^>nul ^| findstr "java"') do (
        set "java_pid=%%a"
        set "java_pid=!java_pid:"=!"
        
        REM Verificar si es un proceso Spring Boot
        wmic process where "ProcessId=!java_pid!" get CommandLine /format:list 2>nul | findstr "spring-boot" >nul
        if !errorlevel! equ 0 (
            wmic process where "ProcessId=!java_pid!" get CommandLine /format:list 2>nul | findstr "evaluation" >nul
            if !errorlevel! equ 0 (
                set /a procesos_encontrados+=1
                call :mostrar_y_log "SUCCESS" "Proceso EduTech encontrado: PID !java_pid!"
                set "EDUTECH_PID=!java_pid!"
            ) else (
                set /a procesos_maven+=1
                call :mostrar_y_log "INFO" "Proceso Spring Boot (otro): PID !java_pid!"
            )
        )
    )
    
    echo %ESC%%BLUE%📊 Resumen de Procesos:%ESC%%NC%
    echo   ☕ Procesos Java totales: %procesos_java%
    echo   🎓 Procesos EduTech: %procesos_encontrados%
    echo   🔨 Otros procesos Maven: %procesos_maven%
    
    if %procesos_encontrados% gtr 0 (
        set "PROCESO_ACTIVO=true"
    ) else (
        set "PROCESO_ACTIVO=false"
    )
    
    exit /b 0

:verificar_puerto_red
    call :mostrar_y_log "INFO" "Verificando estado del puerto %SERVER_PORT%..."
    
    set "puerto_en_uso=false"
    
    netstat -an | findstr ":%SERVER_PORT% " >nul
    if !errorlevel! equ 0 (
        set "puerto_en_uso=true"
        call :mostrar_y_log "SUCCESS" "Puerto %SERVER_PORT% está en uso"
        
        REM Obtener detalles del proceso usando el puerto
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%SERVER_PORT% "') do (
            set "port_pid=%%a"
            if not "!port_pid!"=="" (
                for /f "tokens=1" %%b in ('tasklist /fi "pid eq !port_pid!" /fo csv /nh 2^>nul') do (
                    set "process_name=%%b"
                    set "process_name=!process_name:"=!"
                    call :mostrar_y_log "INFO" "Proceso usando puerto: !process_name! (PID: !port_pid!)"
                )
            )
        )
    ) else (
        call :mostrar_y_log "WARNING" "Puerto %SERVER_PORT% no está en uso"
    )
    
    exit /b 0

:verificar_endpoints_spring
    call :mostrar_y_log "INFO" "Verificando endpoints de Spring Boot Actuator..."
    
    set "base_url=http://localhost:%SERVER_PORT%"
    set "endpoints_ok=0"
    set "endpoints_total=4"
    
    REM Verificar endpoint de salud
    call :verificar_endpoint "%base_url%/actuator/health" "Salud"
    if !errorlevel! equ 0 set /a endpoints_ok+=1
    
    REM Verificar endpoint de información
    call :verificar_endpoint "%base_url%/actuator/info" "Información"
    if !errorlevel! equ 0 set /a endpoints_ok+=1
    
    REM Verificar endpoint de métricas
    call :verificar_endpoint "%base_url%/actuator/metrics" "Métricas"
    if !errorlevel! equ 0 set /a endpoints_ok+=1
    
    REM Verificar endpoint raíz de la aplicación
    call :verificar_endpoint "%base_url%" "Aplicación Principal"
    if !errorlevel! equ 0 set /a endpoints_ok+=1
    
    echo %ESC%%BLUE%📊 Resumen de Endpoints:%ESC%%NC%
    echo   ✅ Endpoints funcionando: %endpoints_ok%/%endpoints_total%
    
    if %endpoints_ok% geq 3 (
        set "ENDPOINTS_OK=true"
        call :mostrar_y_log "SUCCESS" "La mayoría de endpoints están funcionando"
    ) else (
        set "ENDPOINTS_OK=false"
        call :mostrar_y_log "WARNING" "Algunos endpoints no están respondiendo"
    )
    
    exit /b 0

:verificar_endpoint
    set "url=%1"
    set "nombre=%2"
    
    powershell -Command "try { $response = Invoke-WebRequest -Uri '%url%' -UseBasicParsing -TimeoutSec 5; if ($response.StatusCode -eq 200) { Write-Host '✅ %nombre%: OK (%url%)' -ForegroundColor Green; exit 0 } else { Write-Host '❌ %nombre%: HTTP ' + $response.StatusCode + ' (%url%)' -ForegroundColor Red; exit 1 } } catch { Write-Host '❌ %nombre%: No disponible (%url%)' -ForegroundColor Red; exit 1 }" 2>nul
    exit /b !errorlevel!

:verificar_salud_base_datos
    call :mostrar_y_log "INFO" "Verificando conexión a base de datos..."
    
    if not defined DATABASE_URL (
        call :mostrar_y_log "WARNING" "URL de base de datos no configurada"
        set "DB_HEALTH=unknown"
        exit /b 1
    )
    
    REM Verificar endpoint específico de salud de BD
    set "db_health_url=http://localhost:%SERVER_PORT%/actuator/health/db"
    
    powershell -Command "try { $response = Invoke-WebRequest -Uri '%db_health_url%' -UseBasicParsing -TimeoutSec 10; $content = $response.Content | ConvertFrom-Json; if ($content.status -eq 'UP') { Write-Host '✅ Base de datos: Conectada y funcionando' -ForegroundColor Green; exit 0 } else { Write-Host '❌ Base de datos: Estado ' + $content.status -ForegroundColor Red; exit 1 } } catch { Write-Host '⚠️ Base de datos: No se pudo verificar el estado' -ForegroundColor Yellow; exit 1 }" 2>nul
    
    if !errorlevel! equ 0 (
        set "DB_HEALTH=up"
        call :mostrar_y_log "SUCCESS" "Base de datos funcionando correctamente"
    ) else (
        set "DB_HEALTH=down"
        call :mostrar_y_log "WARNING" "Problema con la conexión de base de datos"
    )
    
    exit /b 0

:verificar_recursos_sistema
    call :mostrar_y_log "INFO" "Verificando recursos del sistema..."
    
    REM Obtener uso de memoria
    for /f "tokens=4" %%a in ('tasklist /fi "imagename eq java.exe" ^| findstr "java.exe" ^| head -n 1') do (
        set "memory_usage=%%a"
        call :mostrar_y_log "INFO" "Uso de memoria Java: !memory_usage!"
    )
    
    REM Verificar espacio en disco
    for /f "tokens=3" %%a in ('dir /-c ^| findstr "bytes free"') do (
        set "disk_free=%%a"
        call :mostrar_y_log "INFO" "Espacio libre en disco: !disk_free! bytes"
    )
    
    REM Verificar carga del sistema
    wmic cpu get loadpercentage /value | findstr "LoadPercentage" >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=2 delims==" %%a in ('wmic cpu get loadpercentage /value ^| findstr "LoadPercentage"') do (
            call :mostrar_y_log "INFO" "Carga de CPU: %%a%%"
        )
    )
    
    exit /b 0

:verificar_logs_aplicacion
    call :mostrar_y_log "INFO" "Verificando logs de la aplicación..."
    cd /d "%PARENT_DIR%"
    
    if exist logs\application.log (
        set "log_size=0"
        for %%a in (logs\application.log) do set "log_size=%%~za"
        
        call :mostrar_y_log "SUCCESS" "Log de aplicación encontrado (Tamaño: !log_size! bytes)"
        
        REM Buscar errores recientes
        powershell -Command "if (Test-Path 'logs\application.log') { $errors = Select-String -Path 'logs\application.log' -Pattern 'ERROR|FATAL' | Select-Object -Last 5; if ($errors) { Write-Host '⚠️ Errores recientes encontrados:' -ForegroundColor Yellow; $errors | ForEach-Object { Write-Host ('  ' + $_.Line) -ForegroundColor Red } } else { Write-Host '✅ No se encontraron errores recientes' -ForegroundColor Green } }"
        
        REM Mostrar líneas recientes
        echo %ESC%%BLUE%📋 Últimas 3 líneas del log:%ESC%%NC%
        powershell -Command "if (Test-Path 'logs\application.log') { Get-Content 'logs\application.log' -Tail 3 | ForEach-Object { Write-Host ('  ' + $_) -ForegroundColor Cyan } }"
    ) else (
        call :mostrar_y_log "WARNING" "Log de aplicación no encontrado"
    )
    
    exit /b 0

:generar_reporte_estado
    echo.
    echo %ESC%%PURPLE%📊 REPORTE COMPLETO DE ESTADO - EDUTECH MICROSERVICIO%ESC%%NC%
    echo ═══════════════════════════════════════════════════════════════
    echo %ESC%%BLUE%📅 Fecha del reporte: %date% %time%%ESC%%NC%
    echo %ESC%%BLUE%🖥️  Sistema: Windows%ESC%%NC%
    echo %ESC%%BLUE%🔧 Puerto configurado: %SERVER_PORT%%ESC%%NC%
    echo.
    
    REM Estado general
    if "%PROCESO_ACTIVO%"=="true" (
        if "%ENDPOINTS_OK%"=="true" (
            echo %ESC%%GREEN%🟢 ESTADO GENERAL: FUNCIONANDO CORRECTAMENTE%ESC%%NC%
            set "estado_general=FUNCIONANDO"
        ) else (
            echo %ESC%%YELLOW%🟡 ESTADO GENERAL: FUNCIONANDO CON PROBLEMAS%ESC%%NC%
            set "estado_general=PROBLEMAS"
        )
    ) else (
        echo %ESC%%RED%🔴 ESTADO GENERAL: DETENIDO O NO DISPONIBLE%ESC%%NC%
        set "estado_general=DETENIDO"
    )
    
    echo.
    echo %ESC%%CYAN%📋 Detalles del Estado:%ESC%%NC%
    
    if "%PROCESO_ACTIVO%"=="true" (
        echo   🔄 Proceso: %ESC%%GREEN%Ejecutándose%ESC%%NC% ^(PID: %EDUTECH_PID%^)
    ) else (
        echo   🔄 Proceso: %ESC%%RED%No encontrado%ESC%%NC%
    )
    
    if "%puerto_en_uso%"=="true" (
        echo   🌐 Puerto %SERVER_PORT%: %ESC%%GREEN%En uso%ESC%%NC%
    ) else (
        echo   🌐 Puerto %SERVER_PORT%: %ESC%%RED%Libre%ESC%%NC%
    )
    
    if "%ENDPOINTS_OK%"=="true" (
        echo   🏥 Endpoints: %ESC%%GREEN%Respondiendo%ESC%%NC%
    ) else (
        echo   🏥 Endpoints: %ESC%%RED%No respondiendo%ESC%%NC%
    )
    
    if "%DB_HEALTH%"=="up" (
        echo   🗄️  Base de Datos: %ESC%%GREEN%Conectada%ESC%%NC%
    ) else if "%DB_HEALTH%"=="down" (
        echo   🗄️  Base de Datos: %ESC%%RED%Desconectada%ESC%%NC%
    ) else (
        echo   🗄️  Base de Datos: %ESC%%YELLOW%Estado desconocido%ESC%%NC%
    )
    
    echo.
    echo %ESC%%CYAN%🔗 URLs de Acceso:%ESC%%NC%
    echo   🌐 Aplicación: http://localhost:%SERVER_PORT%
    echo   🏥 Salud: http://localhost:%SERVER_PORT%/actuator/health
    echo   📊 Métricas: http://localhost:%SERVER_PORT%/actuator/metrics
    echo   📋 Info: http://localhost:%SERVER_PORT%/actuator/info
    echo.
    
    if "%estado_general%"=="DETENIDO" (
        echo %ESC%%YELLOW%💡 Sugerencias:%ESC%%NC%
        echo   1. Ejecutar: scripts\windows\iniciar.bat
        echo   2. Verificar configuración en .env
        echo   3. Revisar logs en logs\
    ) else if "%estado_general%"=="PROBLEMAS" (
        echo %ESC%%YELLOW%💡 Sugerencias:%ESC%%NC%
        echo   1. Revisar logs de la aplicación
        echo   2. Verificar conexión a base de datos
        echo   3. Reiniciar el microservicio si es necesario
    ) else (
        echo %ESC%%GREEN%🎉 El microservicio está funcionando correctamente!%ESC%%NC%
    )
    
    exit /b 0

:verificar_herramientas_sistema
    call :mostrar_y_log "INFO" "Verificando herramientas del sistema..."
    
    set "herramientas_ok=true"
    
    REM Verificar Java
    java -version >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do (
            set "java_version=%%g"
            set "java_version=!java_version:"=!"
        )
        call :mostrar_y_log "SUCCESS" "Java encontrado: !java_version!"
    ) else (
        call :mostrar_y_log "ERROR" "Java no encontrado. Instale Java 17 o superior."
        set "herramientas_ok=false"
    )
    
    REM Verificar Maven
    mvn -version >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=3" %%g in ('mvn -version 2^>^&1 ^| findstr "Apache Maven"') do (
            set "maven_version=%%g"
        )
        call :mostrar_y_log "SUCCESS" "Maven encontrado: !maven_version!"
    ) else (
        call :mostrar_y_log "ERROR" "Maven no encontrado. Instale Apache Maven."
        set "herramientas_ok=false"
    )
    
    REM Verificar Git
    git --version >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=3" %%g in ('git --version') do (
            set "git_version=%%g"
        )
        call :mostrar_y_log "SUCCESS" "Git encontrado: !git_version!"
    ) else (
        call :mostrar_y_log "WARNING" "Git no encontrado. Funcionalidades de versión limitadas."
    )
    
    REM Verificar estructura del proyecto
    cd /d "%PARENT_DIR%"
    if exist pom.xml (
        call :mostrar_y_log "SUCCESS" "Estructura de proyecto Maven encontrada"
    ) else (
        call :mostrar_y_log "ERROR" "pom.xml no encontrado. No es un proyecto Maven válido."
        set "herramientas_ok=false"
    )
    
    if exist src\main\java (
        call :mostrar_y_log "SUCCESS" "Estructura de código Java encontrada"
    ) else (
        call :mostrar_y_log "WARNING" "Estructura src\main\java no encontrada"
    )
    
    if "%herramientas_ok%"=="false" (
        call :mostrar_y_log "ERROR" "Algunas herramientas críticas faltan. El sistema puede no funcionar correctamente."
        exit /b 1
    )
    
    exit /b 0

:verificar_compilacion_proyecto
    call :mostrar_y_log "INFO" "Verificando compilación del proyecto..."
    
    cd /d "%PARENT_DIR%"
    
    REM Limpiar y compilar
    call :mostrar_y_log "INFO" "Ejecutando mvn clean compile..."
    mvn clean compile -q >nul 2>&1
    if !errorlevel! equ 0 (
        call :mostrar_y_log "SUCCESS" "Compilación exitosa"
    ) else (
        call :mostrar_y_log "ERROR" "Error en la compilación. Revisar código fuente."
        exit /b 1
    )
    
    REM Verificar tests
    call :mostrar_y_log "INFO" "Ejecutando tests del proyecto..."
    mvn test -q >nul 2>&1
    if !errorlevel! equ 0 (
        call :mostrar_y_log "SUCCESS" "Tests ejecutados exitosamente"
    ) else (
        call :mostrar_y_log "WARNING" "Algunos tests fallaron o no se pudieron ejecutar"
    )
    
    exit /b 0

:generar_reporte_estado
    call :mostrar_y_log "INFO" "Generando reporte de estado del sistema..."
    
    set "reporte_file=%PARENT_DIR%\logs\reporte-estado.txt"
    
    echo === REPORTE DE ESTADO DEL MICROSERVICIO EDUTECH === > "%reporte_file%"
    echo Fecha: %date% %time% >> "%reporte_file%"
    echo. >> "%reporte_file%"
    
    echo [HERRAMIENTAS] >> "%reporte_file%"
    java -version 2>&1 | findstr "version" >> "%reporte_file%" 2>nul || echo Java: No encontrado >> "%reporte_file%"
    mvn -version 2>&1 | findstr "Apache Maven" >> "%reporte_file%" 2>nul || echo Maven: No encontrado >> "%reporte_file%"
    git --version >> "%reporte_file%" 2>nul || echo Git: No encontrado >> "%reporte_file%"
    echo. >> "%reporte_file%"
    
    echo [PROCESOS] >> "%reporte_file%"
    tasklist /fi "imagename eq java.exe" | findstr "java.exe" >> "%reporte_file%" 2>nul || echo No hay procesos Java >> "%reporte_file%"
    echo. >> "%reporte_file%"
    
    echo [PUERTOS] >> "%reporte_file%"
    netstat -an | findstr ":%SERVER_PORT%" >> "%reporte_file%" 2>nul || echo Puerto %SERVER_PORT%: No en uso >> "%reporte_file%"
    echo. >> "%reporte_file%"
    
    echo [ARCHIVOS] >> "%reporte_file%"
    if exist "%PARENT_DIR%\pom.xml" (echo pom.xml: OK >> "%reporte_file%") else (echo pom.xml: FALTANTE >> "%reporte_file%")
    if exist "%PARENT_DIR%\.env" (echo .env: OK >> "%reporte_file%") else (echo .env: FALTANTE >> "%reporte_file%")
    if exist "%PARENT_DIR%\target" (echo target\: OK >> "%reporte_file%") else (echo target\: FALTANTE >> "%reporte_file%")
    
    call :mostrar_y_log "SUCCESS" "Reporte generado en: logs\reporte-estado.txt"
    exit /b 0

REM =============================================================================
REM FUNCIÓN PRINCIPAL
REM =============================================================================

:main
    call :show_edutech_banner
    call :mostrar_y_log "INFO" "=== Verificando estado del microservicio EduTech ==="
    
    echo %ESC%%CYAN%🔍 Verificando estado del microservicio EduTech de Evaluaciones...%ESC%%NC%
    echo %ESC%%BLUE%📅 Fecha: %date% %time%%ESC%%NC%
    echo.
    
    REM Paso 1: Cargar configuración
    echo %ESC%%PURPLE%⚙️ PASO 1: CARGA DE CONFIGURACIÓN%ESC%%NC%
    echo ═══════════════════════════════════════════
    call :cargar_configuracion
    echo.
    
    REM Paso 2: Verificar herramientas del sistema
    echo %ESC%%PURPLE%🛠️ PASO 2: VERIFICACIÓN DE HERRAMIENTAS%ESC%%NC%
    echo ════════════════════════════════════════════════
    call :verificar_herramientas_sistema
    if !errorlevel! neq 0 goto :error_exit
    echo.
    
    REM Paso 3: Verificar compilación del proyecto
    echo %ESC%%PURPLE%🔨 PASO 3: VERIFICACIÓN DE COMPILACIÓN%ESC%%NC%
    echo ════════════════════════════════════════════════
    call :verificar_compilacion_proyecto
    echo.
    
    REM Paso 4: Verificar procesos del sistema
    echo %ESC%%PURPLE%🔄 PASO 4: VERIFICACIÓN DE PROCESOS%ESC%%NC%
    echo ═══════════════════════════════════════════
    call :verificar_procesos_sistema
    echo.
    
    REM Paso 5: Verificar puerto de red
    echo %ESC%%PURPLE%🌐 PASO 5: VERIFICACIÓN DE PUERTO DE RED%ESC%%NC%
    echo ════════════════════════════════════════════════
    call :verificar_puerto_red
    echo.
    
    REM Paso 6: Verificar endpoints Spring Boot
    echo %ESC%%PURPLE%🏥 PASO 6: VERIFICACIÓN DE ENDPOINTS%ESC%%NC%
    echo ══════════════════════════════════════════════
    call :verificar_endpoints_spring
    echo.
    
    REM Paso 7: Verificar salud de base de datos
    echo %ESC%%PURPLE%🗄️ PASO 7: VERIFICACIÓN DE BASE DE DATOS%ESC%%NC%
    echo ════════════════════════════════════════════════════
    call :verificar_salud_base_datos
    echo.
    
    REM Paso 8: Verificar recursos del sistema
    echo %ESC%%PURPLE%💻 PASO 8: VERIFICACIÓN DE RECURSOS%ESC%%NC%
    echo ═══════════════════════════════════════════════
    call :verificar_recursos_sistema
    echo.
    
    REM Paso 9: Verificar logs
    echo %ESC%%PURPLE%📋 PASO 9: VERIFICACIÓN DE LOGS%ESC%%NC%
    echo ══════════════════════════════════════════
    call :verificar_logs_aplicacion
    echo.
    
    REM Generar reporte final
    call :generar_reporte_estado
    
    call :mostrar_y_log "SUCCESS" "=== Verificación de estado completada ==="
    
    echo.
    echo %ESC%%YELLOW%⏸️  Presiona cualquier tecla para continuar...%ESC%%NC%
    pause >nul
    
    exit /b 0

:error_exit
    call :mostrar_y_log "ERROR" "=== Error crítico en la verificación ==="
    echo.
    echo %ESC%%RED%❌ Se encontraron problemas críticos que impiden continuar:%ESC%%NC%
    echo %ESC%%YELLOW%💡 Sugerencias para resolver:%ESC%%NC%
    echo   1. Instalar herramientas faltantes (Java, Maven)
    echo   2. Verificar configuración del proyecto
    echo   3. Revisar logs en logs\verificacion-estado.log
    echo   4. Ejecutar scripts\windows\configurar.bat
    echo.
    echo %ESC%%YELLOW%⏸️  Presiona cualquier tecla para salir...%ESC%%NC%
    pause >nul
    exit /b 1
