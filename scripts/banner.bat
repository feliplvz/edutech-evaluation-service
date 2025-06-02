REM =============================================================================
REM EduTech Banner - Banner profesional para scripts Windows
REM =============================================================================

setlocal enabledelayedexpansion

REM Códigos de color ANSI
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "PURPLE=[35m"
set "CYAN=[36m"
set "WHITE=[37m"
set "BOLD=[1m"
set "NC=[0m"

REM Habilitar colores ANSI en Windows 10+
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION_NUM=%%i.%%j
if "%VERSION_NUM%" geq "10.0" (
    for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
) else (
    set "ESC="
    set "RED="
    set "GREEN="
    set "YELLOW="
    set "BLUE="
    set "PURPLE="
    set "CYAN="
    set "WHITE="
    set "BOLD="
    set "NC="
)

goto :eof

:show_edutech_banner
    cls
    echo %ESC%%PURPLE%%BOLD%
    echo ╔══════════════════════════════════════════════════════════════════════════════╗
    echo ║                                                                              ║
    echo ║   ███████╗██████╗ ██╗   ██╗████████╗███████╗ ██████╗██╗  ██╗                ║
    echo ║   ██╔════╝██╔══██╗██║   ██║╚══██╔══╝██╔════╝██╔════╝██║  ██║                ║
    echo ║   █████╗  ██║  ██║██║   ██║   ██║   █████╗  ██║     ███████║                ║
    echo ║   ██╔══╝  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║     ██╔══██║                ║
    echo ║   ███████╗██████╔╝╚██████╔╝   ██║   ███████╗╚██████╗██║  ██║                ║
    echo ║   ╚══════╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝                ║
    echo ║                                                                              ║
    echo ║              🎓 PLATAFORMA DE EVALUACIONES ESTUDIANTILES 🎓                  ║
    echo ║                                                                              ║
    echo ╚══════════════════════════════════════════════════════════════════════════════╝
    echo %ESC%%NC%
    echo %ESC%%CYAN%%BOLD%                    🚀 Microservicio de Evaluaciones v2.0.0
    echo                       Desarrollado con Spring Boot 3.5.0%ESC%%NC%
    echo.
    exit /b

:show_mini_banner
    echo %ESC%%PURPLE%%BOLD%
    echo ╔═══════════════════════════════════════════════════════════════╗
    echo ║   🎓 EduTech - Plataforma de Evaluaciones Estudiantiles 🎓   ║
    echo ╚═══════════════════════════════════════════════════════════════╝
    echo %ESC%%NC%
    exit /b

:show_operation_banner
    set "operation=%~1"
    set "description=%~2"
    echo %ESC%%BLUE%%BOLD%
    echo ╔═══════════════════════════════════════════════════════════════╗
    echo ║  %operation%
    echo ║  %description%
    echo ╚═══════════════════════════════════════════════════════════════╝
    echo %ESC%%NC%
    exit /b
