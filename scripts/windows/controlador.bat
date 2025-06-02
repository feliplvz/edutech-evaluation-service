@echo off
REM =============================================================================
REM EduTech - Script Maestro de Control del Microservicio de Evaluaciones (Windows)
REM =============================================================================
REM Descripción: Script profesional para gestionar el ciclo completo de desarrollo
REM              del Microservicio de Evaluaciones EduTech
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
set VERSION=2.0.0

REM Cargar funciones del banner
call "%SCRIPT_DIR%..\banner.bat"

goto :main

REM =============================================================================
REM FUNCIONES DE INTERFAZ
REM =============================================================================

:mostrar_menu
    echo %ESC%%CYAN%📋 Operaciones Disponibles:%ESC%%NC%
    echo.
    echo %ESC%%GREEN%  🔧 CONFIGURACIÓN%ESC%%NC%
    echo     1^) %ESC%%YELLOW%configurar%ESC%%NC%       - 🛠️  Configurar entorno de desarrollo
    echo     2^) %ESC%%YELLOW%variables%ESC%%NC%        - ⚙️  Gestionar variables de entorno
    echo.
    echo %ESC%%GREEN%  🚀 CICLO DE VIDA%ESC%%NC%
    echo     3^) %ESC%%YELLOW%iniciar%ESC%%NC%          - 🚀 Iniciar el microservicio
    echo     4^) %ESC%%YELLOW%detener%ESC%%NC%          - 🛑 Detener el microservicio
    echo     5^) %ESC%%YELLOW%reiniciar%ESC%%NC%        - 🔄 Reiniciar el microservicio
    echo     6^) %ESC%%YELLOW%estado%ESC%%NC%           - 🔍 Verificar estado del servicio
    echo.
    echo %ESC%%GREEN%  🔨 COMPILACIÓN^&PRUEBAS%ESC%%NC%
    echo     7^) %ESC%%YELLOW%compilar%ESC%%NC%         - 🔨 Compilar la aplicación
    echo     8^) %ESC%%YELLOW%pruebas%ESC%%NC%          - 🧪 Ejecutar pruebas unitarias
    echo     9^) %ESC%%YELLOW%empaquetar%ESC%%NC%       - 📦 Crear paquete desplegable
    echo    10^) %ESC%%YELLOW%limpiar%ESC%%NC%          - 🧹 Limpiar artefactos de compilación
    echo.
    echo %ESC%%GREEN%  📊 MONITOREO^&LOGS%ESC%%NC%
    echo    11^) %ESC%%YELLOW%logs%ESC%%NC%             - 📋 Ver logs de la aplicación
    echo    12^) %ESC%%YELLOW%salud%ESC%%NC%            - 🏥 Verificar endpoints de salud
    echo    13^) %ESC%%YELLOW%metricas%ESC%%NC%         - 📊 Ver métricas de la aplicación
    echo.
    echo %ESC%%GREEN%  🛠️  HERRAMIENTAS%ESC%%NC%
    echo    14^) %ESC%%YELLOW%bd%ESC%%NC%               - 🗄️  Operaciones de base de datos
    echo    15^) %ESC%%YELLOW%dependencias%ESC%%NC%     - 🔍 Verificar dependencias Maven
    echo    16^) %ESC%%YELLOW%postman%ESC%%NC%          - 📮 Abrir colección de Postman
    echo.
    echo %ESC%%GREEN%  📖 INFORMACIÓN%ESC%%NC%
    echo    17^) %ESC%%YELLOW%info%ESC%%NC%             - 📊 Información del proyecto
    echo    18^) %ESC%%YELLOW%ayuda%ESC%%NC%            - 📖 Mostrar ayuda detallada
    echo    19^) %ESC%%YELLOW%version%ESC%%NC%          - 📋 Información de versión
    echo.
    echo %ESC%%RED%    0^) %ESC%%YELLOW%salir%ESC%%NC%           - 🚪 Salir del controlador maestro%ESC%%NC%
    echo.
    exit /b

REM =============================================================================
REM COMANDOS DE CONFIGURACIÓN
REM =============================================================================

:cmd_configurar
    call :show_operation_banner "🛠️  CONFIGURACIÓN" "Inicializando entorno de desarrollo..."
    cd /d "%PARENT_DIR%"
    if exist scripts\windows\configurar.bat (
        call scripts\windows\configurar.bat
    ) else (
        echo %ESC%%RED%❌ El script configurar.bat no fue encontrado%ESC%%NC%
    )
    exit /b

:cmd_variables
    call :show_operation_banner "⚙️  VARIABLES DE ENTORNO" "Abriendo configuración de variables..."
    cd /d "%PARENT_DIR%"
    if exist .env (
        notepad .env
    ) else (
        echo %ESC%%YELLOW%⚠️  Archivo .env no encontrado. Creando desde plantilla...%ESC%%NC%
        if exist .env.example (
            copy .env.example .env >nul
            notepad .env
        ) else (
            echo %ESC%%RED%❌ Archivo .env.example no encontrado%ESC%%NC%
        )
    )
    exit /b

REM =============================================================================
REM COMANDOS DE CICLO DE VIDA
REM =============================================================================

:cmd_iniciar
    call :show_operation_banner "🚀 INICIAR SERVICIO" "Iniciando microservicio de evaluaciones..."
    cd /d "%PARENT_DIR%"
    if exist scripts\windows\iniciar.bat (
        call scripts\windows\iniciar.bat
    ) else (
        echo %ESC%%RED%❌ El script iniciar.bat no fue encontrado%ESC%%NC%
    )
    exit /b

:cmd_detener
    call :show_operation_banner "🛑 DETENER SERVICIO" "Deteniendo microservicio de evaluaciones..."
    cd /d "%PARENT_DIR%"
    if exist scripts\windows\detener.bat (
        call scripts\windows\detener.bat
    ) else (
        echo %ESC%%RED%❌ El script detener.bat no fue encontrado%ESC%%NC%
    )
    exit /b

:cmd_reiniciar
    call :show_operation_banner "🔄 REINICIAR SERVICIO" "Reiniciando microservicio de evaluaciones..."
    call :cmd_detener
    timeout /t 2 >nul
    call :cmd_iniciar
    exit /b

:cmd_estado
    call :show_operation_banner "🔍 VERIFICAR ESTADO" "Verificando estado del microservicio..."
    cd /d "%PARENT_DIR%"
    if exist scripts\windows\verificar-estado.bat (
        call scripts\windows\verificar-estado.bat
    ) else (
        echo %ESC%%RED%❌ El script verificar-estado.bat no fue encontrado%ESC%%NC%
    )
    exit /b

REM =============================================================================
REM COMANDOS DE COMPILACIÓN Y PRUEBAS
REM =============================================================================

:cmd_compilar
    call :show_operation_banner "🔨 COMPILAR" "Compilando aplicación Spring Boot..."
    cd /d "%PARENT_DIR%"
    echo %ESC%%CYAN%📦 Ejecutando compilación Maven...%ESC%%NC%
    mvn clean compile
    if !errorlevel! equ 0 (
        echo %ESC%%GREEN%✅ Compilación completada exitosamente%ESC%%NC%
    ) else (
        echo %ESC%%RED%❌ Error en la compilación%ESC%%NC%
    )
    exit /b

:cmd_pruebas
    call :show_operation_banner "🧪 PRUEBAS UNITARIAS" "Ejecutando suite de pruebas..."
    cd /d "%PARENT_DIR%"
    echo %ESC%%CYAN%🧪 Ejecutando pruebas Maven...%ESC%%NC%
    mvn test
    if !errorlevel! equ 0 (
        echo %ESC%%GREEN%✅ Todas las pruebas pasaron exitosamente%ESC%%NC%
    ) else (
        echo %ESC%%RED%❌ Algunas pruebas fallaron%ESC%%NC%
    )
    exit /b

:cmd_empaquetar
    call :show_operation_banner "📦 EMPAQUETAR" "Creando paquete JAR desplegable..."
    cd /d "%PARENT_DIR%"
    echo %ESC%%CYAN%📦 Creando paquete Maven...%ESC%%NC%
    mvn clean package
    if !errorlevel! equ 0 (
        echo %ESC%%GREEN%✅ Paquete creado exitosamente%ESC%%NC%
        echo %ESC%%BLUE%📂 Ubicación: target\evaluation-service-*.jar%ESC%%NC%
    ) else (
        echo %ESC%%RED%❌ Error al crear el paquete%ESC%%NC%
    )
    exit /b

:cmd_limpiar
    call :show_operation_banner "🧹 LIMPIAR" "Limpiando artefactos de compilación..."
    cd /d "%PARENT_DIR%"
    echo %ESC%%CYAN%🧹 Limpiando proyecto Maven...%ESC%%NC%
    mvn clean
    if exist logs (
        echo %ESC%%CYAN%🗑️  Limpiando logs antiguos...%ESC%%NC%
        del logs\*.log >nul 2>&1
    )
    echo %ESC%%GREEN%✅ Limpieza completada%ESC%%NC%
    exit /b

REM =============================================================================
REM COMANDOS DE MONITOREO Y LOGS
REM =============================================================================

:cmd_logs
    call :show_operation_banner "📋 LOGS" "Mostrando logs de la aplicación..."
    cd /d "%PARENT_DIR%"
    if exist logs\application.log (
        echo %ESC%%CYAN%📋 Últimas 50 líneas del log:%ESC%%NC%
        powershell -Command "Get-Content logs\application.log -Tail 50"
    ) else (
        echo %ESC%%YELLOW%⚠️  No se encontraron logs de la aplicación%ESC%%NC%
    )
    exit /b

:cmd_salud
    call :show_operation_banner "🏥 VERIFICAR SALUD" "Verificando endpoints de salud..."
    cd /d "%PARENT_DIR%"
    
    REM Cargar puerto desde variables de entorno
    set "port=8083"
    if exist .env (
        for /f "usebackq tokens=1,2 delims==" %%a in (.env) do (
            if "%%a"=="SERVER_PORT" set "port=%%b"
        )
    )
    
    echo %ESC%%BLUE%🏥 Endpoint de Salud: http://localhost:!port!/actuator/health%ESC%%NC%
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:!port!/actuator/health' -UseBasicParsing; Write-Host '✅ Servicio funcionando correctamente'; $response.Content } catch { Write-Host '❌ Endpoint de salud no disponible' -ForegroundColor Red }"
    
    echo.
    echo %ESC%%BLUE%🗄️  Salud de Base de Datos: http://localhost:!port!/actuator/health/db%ESC%%NC%
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:!port!/actuator/health/db' -UseBasicParsing; Write-Host '✅ Base de datos funcionando correctamente'; $response.Content } catch { Write-Host '❌ Endpoint de base de datos no disponible' -ForegroundColor Red }"
    exit /b

:cmd_metricas
    call :show_operation_banner "📊 MÉTRICAS" "Consultando métricas de la aplicación..."
    cd /d "%PARENT_DIR%"
    
    set "port=8083"
    if exist .env (
        for /f "usebackq tokens=1,2 delims==" %%a in (.env) do (
            if "%%a"=="SERVER_PORT" set "port=%%b"
        )
    )
    
    echo %ESC%%BLUE%📊 Métricas: http://localhost:!port!/actuator/metrics%ESC%%NC%
    powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:!port!/actuator/metrics' -UseBasicParsing; Write-Host '✅ Métricas obtenidas exitosamente'; $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 3 } catch { Write-Host '❌ Endpoint de métricas no disponible' -ForegroundColor Red }"
    exit /b

REM =============================================================================
REM COMANDOS DE HERRAMIENTAS
REM =============================================================================

:cmd_bd
    call :show_operation_banner "🗄️  BASE DE DATOS" "Operaciones de base de datos..."
    echo.
    echo %ESC%%CYAN%Selecciona una operación:%ESC%%NC%
    echo.
    echo 1^) 📋 Mostrar información de conexión
    echo 2^) 🔌 Probar conexión a la base de datos
    echo 3^) 📊 Mostrar esquema de la base de datos
    echo 4^) 🔙 Volver al menú principal
    echo.
    set /p "db_choice=Selecciona opción [1-4]: "
    
    if "!db_choice!"=="1" (
        cd /d "%PARENT_DIR%"
        if exist .env (
            echo %ESC%%GREEN%📊 Información de Base de Datos:%ESC%%NC%
            for /f "usebackq tokens=1,2 delims==" %%a in (.env) do (
                if "%%a"=="DATABASE_URL" echo %ESC%%BLUE%🔗 URL: %%b%ESC%%NC%
                if "%%a"=="DATABASE_USERNAME" echo %ESC%%BLUE%👤 Usuario: %%b%ESC%%NC%
                if "%%a"=="DATABASE_NAME" echo %ESC%%BLUE%🗄️  Base de Datos: %%b%ESC%%NC%
            )
        ) else (
            echo %ESC%%RED%❌ Archivo .env no encontrado%ESC%%NC%
        )
    ) else if "!db_choice!"=="2" (
        echo %ESC%%CYAN%🔌 Probando conexión a la base de datos...%ESC%%NC%
        cd /d "%PARENT_DIR%"
        mvn spring-boot:run -Dspring-boot.run.arguments="--spring.jpa.hibernate.ddl-auto=validate" -Dspring-boot.run.fork=false
    ) else if "!db_choice!"=="3" (
        echo %ESC%%CYAN%📊 Información del esquema disponible en los logs de la aplicación%ESC%%NC%
    ) else if "!db_choice!"=="4" (
        exit /b
    ) else (
        echo %ESC%%RED%❌ Opción inválida%ESC%%NC%
    )
    exit /b

:cmd_dependencias
    call :show_operation_banner "🔍 DEPENDENCIAS" "Verificando dependencias Maven..."
    cd /d "%PARENT_DIR%"
    echo.
    echo %ESC%%BLUE%📦 Árbol de dependencias Maven:%ESC%%NC%
    mvn dependency:tree
    echo.
    echo %ESC%%BLUE%🔄 Dependencias desactualizadas:%ESC%%NC%
    mvn versions:display-dependency-updates
    exit /b

:cmd_postman
    call :show_operation_banner "📮 POSTMAN" "Abriendo colección de Postman..."
    cd /d "%PARENT_DIR%"
    if exist postman\EvaluationService-Complete.postman_collection.json (
        echo %ESC%%GREEN%📮 Abriendo colección de Postman...%ESC%%NC%
        echo %ESC%%BLUE%📂 Ubicación: postman\EvaluationService-Complete.postman_collection.json%ESC%%NC%
        start "" "postman\EvaluationService-Complete.postman_collection.json"
    ) else (
        echo %ESC%%RED%❌ Colección de Postman no encontrada%ESC%%NC%
    )
    exit /b

REM =============================================================================
REM COMANDOS DE INFORMACIÓN
REM =============================================================================

:cmd_info
    call :show_operation_banner "📊 INFORMACIÓN" "Información del proyecto EduTech..."
    cd /d "%PARENT_DIR%"
    echo.
    echo %ESC%%GREEN%🎓 Proyecto:%ESC%%NC% EduTech - Microservicio de Evaluaciones
    echo %ESC%%GREEN%📋 Versión:%ESC%%NC% %VERSION%
    echo %ESC%%GREEN%🖥️  Plataforma:%ESC%%NC% Windows
    echo %ESC%%GREEN%📅 Fecha:%ESC%%NC% 1 de junio de 2025
    
    if exist pom.xml (
        for /f "tokens=2 delims=<>" %%a in ('findstr "<spring-boot.version>" pom.xml 2^>nul') do (
            echo %ESC%%GREEN%🍃 Spring Boot:%ESC%%NC% %%a
        )
        for /f "tokens=2 delims=<>" %%a in ('findstr "<java.version>" pom.xml 2^>nul') do (
            echo %ESC%%GREEN%☕ Versión Java:%ESC%%NC% %%a
        )
    )
    
    echo.
    echo %ESC%%BLUE%🏗️  Arquitectura del Sistema:%ESC%%NC%
    echo    ├── 🌐 API REST con 43+ endpoints
    echo    ├── 🗄️  Integración con PostgreSQL
    echo    ├── 📊 Monitoreo con Spring Boot Actuator
    echo    ├── 📝 Documentación completa de API
    echo    └── 🚀 Scripts profesionales de despliegue
    
    echo.
    echo %ESC%%BLUE%📁 Estructura del Proyecto:%ESC%%NC%
    if exist src (
        for /f %%i in ('dir src\*.java /s /b 2^>nul ^| find /c /v ""') do echo    ├── 📄 Archivos Java: %%i
    )
    if exist src\main\java (
        for /f %%i in ('dir src\main\java\*Controller.java /s /b 2^>nul ^| find /c /v ""') do echo    ├── 🎛️  Controladores: %%i
        for /f %%i in ('dir src\main\java\*Service.java /s /b 2^>nul ^| find /c /v ""') do echo    ├── 🔧 Servicios: %%i
        for /f %%i in ('dir src\main\java\*Repository.java /s /b 2^>nul ^| find /c /v ""') do echo    └── 🗄️  Repositorios: %%i
    )
    exit /b

:cmd_ayuda
    call :show_operation_banner "📖 AYUDA" "Guía de uso del controlador maestro..."
    echo.
    echo %ESC%%GREEN%🚀 Inicio Rápido:%ESC%%NC%
    echo   1. Ejecuta 'configurar' para inicializar el entorno
    echo   2. Edita el archivo .env con tus credenciales de base de datos
    echo   3. Ejecuta 'iniciar' para lanzar la aplicación
    echo   4. Usa 'estado' para verificar que todo funciona correctamente
    echo.
    echo %ESC%%GREEN%🔄 Flujo de Desarrollo:%ESC%%NC%
    echo   • Usa 'compilar' antes de probar cambios
    echo   • Ejecuta 'pruebas' para ejecutar tests unitarios
    echo   • Usa 'logs' para monitorear el comportamiento
    echo   • Accede a 'postman' para documentación de API
    echo.
    echo %ESC%%GREEN%🚀 Despliegue en Producción:%ESC%%NC%
    echo   • Usa 'empaquetar' para crear el JAR desplegable
    echo   • Configura las variables de entorno de producción
    echo   • Usa endpoints de salud para monitoreo
    echo.
    echo %ESC%%GREEN%🔧 Solución de Problemas:%ESC%%NC%
    echo   • Verifica 'estado' para salud general
    echo   • Revisa 'logs' para detalles de errores
    echo   • Usa 'salud' para probar endpoints
    echo   • Ejecuta 'dependencias' para verificar dependencias
    exit /b

:cmd_version
    call :show_operation_banner "📋 VERSIÓN" "Información de versión del sistema..."
    echo.
    echo %ESC%%GREEN%🎛️  Script Maestro:%ESC%%NC% %VERSION%
    echo %ESC%%GREEN%📅 Fecha de Compilación:%ESC%%NC% %date% %time%
    echo.
    echo %ESC%%BLUE%💻 Información del Sistema:%ESC%%NC%
    echo %ESC%%GREEN%🖥️  Sistema Operativo:%ESC%%NC% Windows
    echo %ESC%%GREEN%🏗️  Arquitectura:%ESC%%NC% %PROCESSOR_ARCHITECTURE%
    
    java -version >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=3" %%a in ('java -version 2^>^&1 ^| findstr "version"') do (
            set java_ver=%%a
            set java_ver=!java_ver:"=!
            echo %ESC%%GREEN%☕ Java:%ESC%%NC% !java_ver!
        )
    )
    
    mvn -version >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=3" %%a in ('mvn -version 2^>nul ^| findstr "Apache Maven"') do (
            echo %ESC%%GREEN%📦 Maven:%ESC%%NC% %%a
        )
    )
    exit /b

REM =============================================================================
REM FUNCIÓN PRINCIPAL
REM =============================================================================

:main
    :menu_loop
    call :show_edutech_banner
    call :mostrar_menu
    
    echo %ESC%%PURPLE%🎯 Selecciona tu opción [0-19]: %ESC%%NC%
    set /p "choice="
    
    echo.
    if "!choice!"=="1" call :cmd_configurar
    if "!choice!"=="configurar" call :cmd_configurar
    if "!choice!"=="2" call :cmd_variables
    if "!choice!"=="variables" call :cmd_variables
    if "!choice!"=="3" call :cmd_iniciar
    if "!choice!"=="iniciar" call :cmd_iniciar
    if "!choice!"=="4" call :cmd_detener
    if "!choice!"=="detener" call :cmd_detener
    if "!choice!"=="5" call :cmd_reiniciar
    if "!choice!"=="reiniciar" call :cmd_reiniciar
    if "!choice!"=="6" call :cmd_estado
    if "!choice!"=="estado" call :cmd_estado
    if "!choice!"=="7" call :cmd_compilar
    if "!choice!"=="compilar" call :cmd_compilar
    if "!choice!"=="8" call :cmd_pruebas
    if "!choice!"=="pruebas" call :cmd_pruebas
    if "!choice!"=="9" call :cmd_empaquetar
    if "!choice!"=="empaquetar" call :cmd_empaquetar
    if "!choice!"=="10" call :cmd_limpiar
    if "!choice!"=="limpiar" call :cmd_limpiar
    if "!choice!"=="11" call :cmd_logs
    if "!choice!"=="logs" call :cmd_logs
    if "!choice!"=="12" call :cmd_salud
    if "!choice!"=="salud" call :cmd_salud
    if "!choice!"=="13" call :cmd_metricas
    if "!choice!"=="metricas" call :cmd_metricas
    if "!choice!"=="14" call :cmd_bd
    if "!choice!"=="bd" call :cmd_bd
    if "!choice!"=="15" call :cmd_dependencias
    if "!choice!"=="dependencias" call :cmd_dependencias
    if "!choice!"=="16" call :cmd_postman
    if "!choice!"=="postman" call :cmd_postman
    if "!choice!"=="17" call :cmd_info
    if "!choice!"=="info" call :cmd_info
    if "!choice!"=="18" call :cmd_ayuda
    if "!choice!"=="ayuda" call :cmd_ayuda
    if "!choice!"=="19" call :cmd_version
    if "!choice!"=="version" call :cmd_version
    if "!choice!"=="0" goto :salir_script
    if "!choice!"=="salir" goto :salir_script
    
    REM Opción inválida
    if not "!choice!"=="1" if not "!choice!"=="configurar" if not "!choice!"=="2" if not "!choice!"=="variables" if not "!choice!"=="3" if not "!choice!"=="iniciar" if not "!choice!"=="4" if not "!choice!"=="detener" if not "!choice!"=="5" if not "!choice!"=="reiniciar" if not "!choice!"=="6" if not "!choice!"=="estado" if not "!choice!"=="7" if not "!choice!"=="compilar" if not "!choice!"=="8" if not "!choice!"=="pruebas" if not "!choice!"=="9" if not "!choice!"=="empaquetar" if not "!choice!"=="10" if not "!choice!"=="limpiar" if not "!choice!"=="11" if not "!choice!"=="logs" if not "!choice!"=="12" if not "!choice!"=="salud" if not "!choice!"=="13" if not "!choice!"=="metricas" if not "!choice!"=="14" if not "!choice!"=="bd" if not "!choice!"=="15" if not "!choice!"=="dependencias" if not "!choice!"=="16" if not "!choice!"=="postman" if not "!choice!"=="17" if not "!choice!"=="info" if not "!choice!"=="18" if not "!choice!"=="ayuda" if not "!choice!"=="19" if not "!choice!"=="version" if not "!choice!"=="0" if not "!choice!"=="salir" (
        echo %ESC%%RED%❌ Opción inválida. Por favor intenta nuevamente.%ESC%%NC%
    )
    
    echo.
    echo %ESC%%YELLOW%⏸️  Presiona cualquier tecla para continuar...%ESC%%NC%
    pause >nul
    goto :menu_loop
    
    :salir_script
    echo %ESC%%GREEN%👋 ¡Hasta luego! ¡Feliz desarrollo con EduTech!%ESC%%NC%
    pause
    exit /b 0
