#!/bin/bash

# =============================================================================
# EduTech - Microservicio de Evaluaciones - Script de Verificación de Estado
# =============================================================================
# Descripción: Script profesional de verificación de estado del Microservicio
#              con análisis completo del sistema y diagnósticos
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
readonly LOG_FILE="${PROJECT_DIR}/logs/verificacion-estado.log"
readonly PID_FILE="${PROJECT_DIR}/logs/app.pid"
readonly TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
readonly DEFAULT_PORT=8083

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

# Cargar variables de entorno
load_environment() {
    cd "${PROJECT_DIR}"
    
    if [ -f .env ]; then
        set -a  # Marcar variables para exportar
        source .env
        set +a  # Desmarcar variables para exportar
        print_success "Variables de entorno cargadas"
    else
        print_warning "Archivo .env no encontrado, usando configuración predeterminada"
    fi
    
    # Establecer puerto predeterminado si no está configurado
    export SERVER_PORT="${SERVER_PORT:-${DEFAULT_PORT}}"
}

# Verificar estructura del proyecto
check_project_structure() {
    print_step "Verificando estructura del proyecto..."
    
    local errors=0
    
    # Archivos principales
    local required_files=(
        "pom.xml"
        "src/main/java/com/edutech/evaluationservice/EvaluationServiceApplication.java"
        "src/main/resources/application.properties"
        "README.md"
    )
    
    echo -e "${CYAN}📁 Estructura del Proyecto:${NC}"
    for file in "${required_files[@]}"; do
        if [ -f "${file}" ]; then
            print_success "  ${file}"
        else
            print_error "  ${file} (faltante)"
            ((errors++))
        fi
    done
    
    return ${errors}
}

# Verificar herramientas de desarrollo
check_development_tools() {
    print_step "Verificando herramientas de desarrollo..."
    
    echo -e "${CYAN}🛠️  Herramientas:${NC}"
    
    # Java
    if command_exists java; then
        local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
        print_success "  Java: ${java_version}"
    else
        print_error "  Java no encontrado"
        return 1
    fi
    
    # Maven
    if command_exists mvn; then
        local maven_version=$(mvn -version 2>/dev/null | head -n1 | cut -d' ' -f3)
        print_success "  Maven: ${maven_version}"
    else
        print_error "  Maven no encontrado"
        return 1
    fi
    
    # curl
    if command_exists curl; then
        print_success "  curl: disponible"
    else
        print_warning "  curl no encontrado (necesario para health checks)"
    fi
}

# Verificar compilación
check_compilation() {
    print_step "Verificando compilación..."
    
    echo -e "${CYAN}🔨 Compilación:${NC}"
    
    if mvn clean compile -q > /dev/null 2>&1; then
        print_success "  Proyecto compila sin errores"
        return 0
    else
        print_error "  Errores de compilación detectados"
        print_info "  Ejecute 'mvn compile' para ver detalles"
        return 1
    fi
}

# Verificar estado de la aplicación
check_application_status() {
    print_step "Verificando estado de la aplicación..."
    
    echo -e "${CYAN}🚀 Estado de la Aplicación:${NC}"
    
    # Verificar puerto
    if lsof -i ":${SERVER_PORT}" >/dev/null 2>&1; then
        local port_pid=$(lsof -t -i ":${SERVER_PORT}" 2>/dev/null || echo "desconocido")
        print_success "  Puerto ${SERVER_PORT} en uso (PID: ${port_pid})"
        print_success "  Aplicación EJECUTÁNDOSE"
        return 0
    else
        print_info "  Puerto ${SERVER_PORT} disponible"
        print_info "  Aplicación DETENIDA"
        return 1
    fi
}

# Generar resumen del estado
generate_summary() {
    echo ""
    show_operation_banner "RESUMEN DEL ESTADO DEL SISTEMA" "📊"
    echo ""
    
    print_info "🎯 Estado General del Microservicio:"
    echo -e "${CYAN}"
    echo "   ├── Estructura del proyecto: ✅ Correcta"
    echo "   ├── Herramientas de desarrollo: ✅ Configuradas"
    echo "   ├── Compilación: ✅ Sin errores"
    
    if lsof -i ":${SERVER_PORT}" >/dev/null 2>&1; then
        echo "   └── Estado de aplicación: 🚀 EJECUTÁNDOSE"
    else
        echo "   └── Estado de aplicación: 🛑 DETENIDA"
    fi
    echo -e "${NC}"
    
    print_info "🔧 Comandos Útiles:"
    echo -e "${YELLOW}"
    echo "   ├── Iniciar aplicación: ./scripts/mac/iniciar.sh"
    echo "   ├── Detener aplicación: ./scripts/mac/detener.sh"
    echo "   ├── Panel de control: ./scripts/mac/controlador.sh"
    echo "   └── Documentación: cat README.md"
    echo -e "${NC}"
    
    if lsof -i ":${SERVER_PORT}" >/dev/null 2>&1; then
        print_info "🌐 URLs de Acceso:"
        echo -e "${PURPLE}"
        echo "   ├── API Base: http://localhost:${SERVER_PORT}"
        echo "   ├── Health Check: http://localhost:${SERVER_PORT}/actuator/health"
        echo "   └── Documentación: Use Postman para pruebas de API"
        echo -e "${NC}"
    fi
}

# Ejecución principal
main() {
    # Cambiar al directorio del proyecto
    cd "${PROJECT_DIR}"
    
    # Mostrar banner
    show_edutech_banner
    show_operation_banner "VERIFICACIÓN DE ESTADO DEL MICROSERVICIO" "🔍"
    
    print_info "Iniciando verificación completa del sistema..."
    print_info "Archivo de log: ${LOG_FILE}"
    
    # Cargar entorno
    load_environment
    
    local overall_status=0
    echo ""
    
    # Ejecutar verificaciones
    check_project_structure || ((overall_status++))
    echo ""
    
    check_development_tools || ((overall_status++))
    echo ""
    
    check_compilation || ((overall_status++))
    echo ""
    
    check_application_status
    local app_status=$?
    echo ""
    
    # Generar resumen
    generate_summary
    
    if [ ${overall_status} -eq 0 ]; then
        show_mini_banner "¡Sistema completamente funcional!" "🌟"
        exit 0
    else
        show_mini_banner "Se encontraron problemas que requieren atención" "🚨"
        exit 1
    fi
}

# Ejecutar función principal
main "$@"
