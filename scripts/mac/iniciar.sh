#!/bin/bash

# =============================================================================
# EduTech - Microservicio de Evaluaciones - Script de Inicio Profesional
# =============================================================================
# Descripción: Script de inicio empresarial para el Microservicio de Evaluaciones
#              con monitoreo integral, validación y manejo de errores
# Autor: Equipo de Desarrollo EduTech
# Versión: 3.0.0
# Plataforma: Unix/Linux/macOS
# =============================================================================

set -euo pipefail  # Salir en error, variables indefinidas, fallos de pipe

# Obtener la ruta del directorio de scripts
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Cargar funciones del banner
source "${SCRIPT_DIR}/../banner.sh"

# Configuración
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="${PROJECT_DIR}/logs/inicio.log"
readonly PID_FILE="${PROJECT_DIR}/logs/app.pid"
readonly TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
readonly DEFAULT_PORT=8083
readonly HEALTH_CHECK_TIMEOUT=120
readonly HEALTH_CHECK_INTERVAL=5

# Crear directorio de logs si no existe
mkdir -p "${PROJECT_DIR}/logs"

# Función de logging
log() {
    local level="$1"
    shift
    local message="$*"
    echo -e "[${TIMESTAMP}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

# Funciones de impresión con colores
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    log "SUCCESS" "$1"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    log "ERROR" "$1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log "WARNING" "$1"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
    log "INFO" "$1"
}

print_step() {
    echo -e "${CYAN}🔄 $1${NC}"
    log "STEP" "$1"
}

# Verificar si comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar si el puerto está disponible
check_port() {
    local port="$1"
    if lsof -i ":${port}" >/dev/null 2>&1; then
        return 1
    else
        return 0
    fi
}

# Terminar proceso en puerto
kill_process_on_port() {
    local port="$1"
    local pid=$(lsof -t -i ":${port}" 2>/dev/null || true)
    
    if [ -n "${pid}" ]; then
        print_warning "Proceso encontrado en puerto ${port} (PID: ${pid}). Terminando..."
        kill "${pid}" 2>/dev/null || true
        sleep 2
        
        # Forzar terminación si aún está ejecutándose
        if kill -0 "${pid}" 2>/dev/null; then
            print_warning "Forzando terminación del proceso ${pid}..."
            kill -9 "${pid}" 2>/dev/null || true
        fi
        
        print_success "Puerto ${port} ahora está disponible"
    fi
}

# Validar entorno
validate_environment() {
    print_step "Validando entorno..."
    
    # Cambiar al directorio del proyecto
    cd "${PROJECT_DIR}"
    
    # Verificar archivo .env
    if [ -f .env ]; then
        print_success "Archivo de entorno encontrado"
        
        # Cargar variables de entorno
        set -a  # Marcar variables para exportar
        source .env
        set +a  # Desmarcar variables para exportar
        
        # Validar variables críticas
        if [[ "${DATABASE_URL:-}" == *"your_database_url_here"* ]] || [ -z "${DATABASE_URL:-}" ]; then
            print_error "DATABASE_URL no configurada en archivo .env"
            print_info "Por favor edite .env con sus credenciales reales de base de datos"
            return 1
        fi
        
        print_success "Variables de entorno cargadas"
    else
        print_warning "No se encontró archivo .env. Usando configuración predeterminada"
        print_info "Cree .env desde .env.example para configuración personalizada"
    fi
    
    # Establecer puerto predeterminado si no está configurado
    export SERVER_PORT="${SERVER_PORT:-${DEFAULT_PORT}}"
    
    # Verificar si el puerto está disponible
    if ! check_port "${SERVER_PORT}"; then
        print_warning "Puerto ${SERVER_PORT} ya está en uso"
        read -p "¿Desea terminar el proceso existente? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[SsYy]$ ]]; then
            kill_process_on_port "${SERVER_PORT}"
        else
            print_error "No se puede iniciar la aplicación. Puerto ${SERVER_PORT} ocupado."
            return 1
        fi
    fi
}

# Verificaciones previas al vuelo
preflight_checks() {
    print_step "Ejecutando verificaciones previas..."
    
    # Verificar Java
    if ! command_exists java; then
        print_error "Java no encontrado. Por favor instale Java 17 o superior."
        return 1
    fi
    
    local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
    print_success "Versión de Java: ${java_version}"
    
    # Verificar Maven
    if ! command_exists mvn; then
        print_error "Maven no encontrado. Por favor instale Apache Maven."
        return 1
    fi
    
    local maven_version=$(mvn -version 2>/dev/null | head -n1 | cut -d' ' -f3)
    print_success "Versión de Maven: ${maven_version}"
    
    # Verificar pom.xml
    if [ ! -f pom.xml ]; then
        print_error "pom.xml no encontrado. Esto no parece ser un proyecto Maven."
        return 1
    fi
    
    print_success "Estructura del proyecto Maven validada"
}

# Compilar aplicación
build_application() {
    print_step "Compilando aplicación..."
    
    print_info "Limpiando compilaciones anteriores..."
    if mvn clean >/dev/null 2>&1; then
        print_success "Compilaciones anteriores limpiadas"
    else
        print_warning "La operación de limpieza tuvo problemas, continuando..."
    fi
    
    print_info "Compilando código fuente..."
    if mvn compile -q; then
        print_success "Compilación exitosa"
    else
        print_error "Falló la compilación"
        print_info "Revise la salida de Maven arriba para detalles"
        return 1
    fi
    
    print_info "Ejecutando tests..."
    if mvn test -q; then
        print_success "Todos los tests pasaron"
    else
        print_warning "Algunos tests fallaron, pero continuando con el inicio..."
    fi
}

# Función de verificación de salud
wait_for_health() {
    print_step "Esperando a que la aplicación esté lista..."
    
    local url="http://localhost:${SERVER_PORT}/actuator/health"
    local elapsed=0
    
    while [ ${elapsed} -lt ${HEALTH_CHECK_TIMEOUT} ]; do
        if curl -s "${url}" >/dev/null 2>&1; then
            print_success "¡La aplicación está lista y saludable!"
            return 0
        fi
        
        echo -ne "\r${CYAN}⏳ Esperando inicio... (${elapsed}s/${HEALTH_CHECK_TIMEOUT}s)${NC}"
        sleep ${HEALTH_CHECK_INTERVAL}
        elapsed=$((elapsed + HEALTH_CHECK_INTERVAL))
    done
    
    echo ""
    print_warning "Tiempo de espera de verificación de salud alcanzado. La aplicación puede estar aún iniciando..."
    return 1
}

# Iniciar aplicación
start_application() {
    print_step "Iniciando aplicación Spring Boot..."
    
    print_info "📊 Configuración de la Aplicación:"
    echo -e "${BLUE}"
    echo "   ├── Puerto: ${SERVER_PORT}"
    echo "   ├── Perfil: ${SPRING_PROFILES_ACTIVE:-default}"
    echo "   ├── Base de Datos: ${DATABASE_URL:-localhost (predeterminado)}"
    echo "   └── Nivel de Log: ${LOGGING_LEVEL:-INFO}"
    echo -e "${NC}"
    
    # Iniciar aplicación en segundo plano y capturar PID
    print_info "Lanzando aplicación..."
    nohup mvn spring-boot:run \
        -Dspring-boot.run.jvmArguments="-Dserver.port=${SERVER_PORT}" \
        > "${PROJECT_DIR}/logs/application.log" 2>&1 &
    
    local app_pid=$!
    echo ${app_pid} > "${PID_FILE}"
    
    print_success "Aplicación iniciada con PID: ${app_pid}"
    print_info "Logs disponibles en: ${PROJECT_DIR}/logs/application.log"
    
    # Esperar a que la aplicación esté lista
    if wait_for_health; then
        display_success_info
    else
        print_warning "Aplicación iniciada pero verificación de salud falló"
        print_info "Revise logs en: ${PROJECT_DIR}/logs/application.log"
    fi
}

# Mostrar información de éxito
display_success_info() {
    echo ""
    show_operation_banner "APLICACIÓN INICIADA EXITOSAMENTE" "🎉"
    echo ""
    
    print_info "🔗 URLs de la Aplicación:"
    echo -e "${CYAN}"
    echo "   ├── URL Base API: http://localhost:${SERVER_PORT}"
    echo "   ├── Verificación de Salud: http://localhost:${SERVER_PORT}/actuator/health"
    echo "   ├── Estado BD: http://localhost:${SERVER_PORT}/actuator/health/db"
    echo "   ├── Info Aplicación: http://localhost:${SERVER_PORT}/actuator/info"
    echo "   └── Documentación API: Use Postman para pruebas"
    echo -e "${NC}"
    
    print_info "📊 Comandos de Gestión:"
    echo -e "${YELLOW}"
    echo "   ├── Verificar Estado: ./scripts/mac/verificar-estado.sh"
    echo "   ├── Ver Logs: tail -f logs/application.log"
    echo "   ├── Detener Aplicación: ./scripts/mac/detener.sh"
    echo "   └── Reiniciar: ./scripts/mac/iniciar.sh"
    echo -e "${NC}"
    
    print_info "🔧 Tips de Desarrollo:"
    echo -e "${PURPLE}"
    echo "   ├── Recarga en caliente: Use spring-boot-devtools"
    echo "   ├── Modo debug: Agregue -Ddebug=true a args JVM"
    echo "   ├── Cambio de perfil: Configure SPRING_PROFILES_ACTIVE en .env"
    echo "   └── Admin BD: Use pgAdmin o herramienta similar"
    echo -e "${NC}"
}

# Función de limpieza
cleanup() {
    print_info "Limpiando..."
    # Remover archivo PID si existe
    [ -f "${PID_FILE}" ] && rm -f "${PID_FILE}"
}

# Ejecución principal
main() {
    # Cambiar al directorio del proyecto
    cd "${PROJECT_DIR}"
    
    # Mostrar banner
    show_edutech_banner
    show_operation_banner "INICIANDO MICROSERVICIO DE EVALUACIONES" "🚀"
    
    print_info "Iniciando secuencia profesional de inicio de aplicación..."
    print_info "Archivo de log: ${LOG_FILE}"
    
    # Ejecutar pasos de inicio
    validate_environment
    preflight_checks
    build_application
    start_application
    
    show_mini_banner "¡Servicio de Evaluaciones EduTech está funcionando!" "🌟"
    print_info "Presione Ctrl+C para ver logs, o use ./scripts/mac/verificar-estado.sh para monitoreo"
}

# Configurar traps para limpieza
trap cleanup EXIT
trap 'print_error "Inicio interrumpido"; exit 1' INT TERM

# Ejecutar función principal
main "$@"
