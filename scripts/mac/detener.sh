#!/bin/bash

# =============================================================================
# EduTech - Microservicio de Evaluaciones - Script de Detención Profesional
# =============================================================================
# Descripción: Script de detención empresarial para el Microservicio de Evaluaciones
#              con terminación elegante y procedimientos de limpieza
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
readonly LOG_FILE="${PROJECT_DIR}/logs/detencion.log"
readonly PID_FILE="${PROJECT_DIR}/logs/app.pid"
readonly TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
readonly DEFAULT_PORT=8083
readonly GRACEFUL_TIMEOUT=30

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

# Cargar variables de entorno
load_environment() {
    cd "${PROJECT_DIR}"
    
    if [ -f .env ]; then
        set -a  # Marcar variables para exportar
        source .env
        set +a  # Desmarcar variables para exportar
        print_success "Variables de entorno cargadas"
    fi
    
    # Establecer puerto predeterminado si no está configurado
    export SERVER_PORT="${SERVER_PORT:-${DEFAULT_PORT}}"
}

# Encontrar proceso por puerto
find_process_by_port() {
    local port="$1"
    lsof -t -i ":${port}" 2>/dev/null || true
}

# Encontrar procesos Spring Boot
find_spring_boot_processes() {
    pgrep -f "spring-boot:run" 2>/dev/null || true
}

# Encontrar procesos Maven
find_maven_processes() {
    pgrep -f "mvn.*spring-boot" 2>/dev/null || true
}

# Detención elegante
graceful_shutdown() {
    local pid="$1"
    local process_name="$2"
    
    print_step "Intentando detención elegante de ${process_name} (PID: ${pid})..."
    
    # Enviar SIGTERM para detención elegante
    if kill -TERM "${pid}" 2>/dev/null; then
        print_info "SIGTERM enviado al proceso ${pid}"
        
        # Esperar detención elegante
        local elapsed=0
        while [ ${elapsed} -lt ${GRACEFUL_TIMEOUT} ]; do
            if ! kill -0 "${pid}" 2>/dev/null; then
                print_success "Proceso ${pid} detenido elegantemente"
                return 0
            fi
            
            echo -ne "\r${CYAN}⏳ Esperando detención elegante... (${elapsed}s/${GRACEFUL_TIMEOUT}s)${NC}"
            sleep 2
            elapsed=$((elapsed + 2))
        done
        
        echo ""
        print_warning "Tiempo de espera de detención elegante alcanzado para proceso ${pid}"
        return 1
    else
        print_error "Falló enviar SIGTERM al proceso ${pid}"
        return 1
    fi
}

# Detención forzada
force_shutdown() {
    local pid="$1"
    local process_name="$2"
    
    print_step "Terminando forzadamente ${process_name} (PID: ${pid})..."
    
    if kill -9 "${pid}" 2>/dev/null; then
        sleep 2
        if ! kill -0 "${pid}" 2>/dev/null; then
            print_success "Proceso ${pid} terminado forzadamente"
            return 0
        else
            print_error "Falló terminar forzadamente proceso ${pid}"
            return 1
        fi
    else
        print_error "Falló enviar SIGKILL al proceso ${pid}"
        return 1
    fi
}

# Detener por archivo PID
stop_by_pid_file() {
    if [ -f "${PID_FILE}" ]; then
        local pid=$(cat "${PID_FILE}")
        
        if [ -n "${pid}" ] && kill -0 "${pid}" 2>/dev/null; then
            print_info "Proceso encontrado desde archivo PID: ${pid}"
            
            if graceful_shutdown "${pid}" "Aplicación"; then
                rm -f "${PID_FILE}"
                return 0
            else
                if force_shutdown "${pid}" "Aplicación"; then
                    rm -f "${PID_FILE}"
                    return 0
                else
                    return 1
                fi
            fi
        else
            print_warning "Archivo PID existe pero proceso no está ejecutándose"
            rm -f "${PID_FILE}"
        fi
    fi
    
    return 1
}

# Detener por puerto
stop_by_port() {
    local port="${SERVER_PORT}"
    local pids=$(find_process_by_port "${port}")
    
    if [ -n "${pids}" ]; then
        print_info "Procesos encontrados en puerto ${port}: ${pids}"
        
        for pid in ${pids}; do
            local process_info=$(ps -p "${pid}" -o comm= 2>/dev/null || echo "desconocido")
            
            if graceful_shutdown "${pid}" "Puerto ${port} (${process_info})"; then
                continue
            else
                force_shutdown "${pid}" "Puerto ${port} (${process_info})"
            fi
        done
        
        # Verificar que el puerto esté libre
        sleep 2
        local remaining_pids=$(find_process_by_port "${port}")
        if [ -z "${remaining_pids}" ]; then
            print_success "Puerto ${port} ahora está libre"
            return 0
        else
            print_error "Algunos procesos aún ejecutándose en puerto ${port}: ${remaining_pids}"
            return 1
        fi
    fi
    
    return 1
}

# Detener procesos Spring Boot
stop_spring_boot_processes() {
    local pids=$(find_spring_boot_processes)
    
    if [ -n "${pids}" ]; then
        print_info "Procesos Spring Boot encontrados: ${pids}"
        
        for pid in ${pids}; do
            if graceful_shutdown "${pid}" "Spring Boot"; then
                continue
            else
                force_shutdown "${pid}" "Spring Boot"
            fi
        done
        
        return 0
    fi
    
    return 1
}

# Detener procesos Maven
stop_maven_processes() {
    local pids=$(find_maven_processes)
    
    if [ -n "${pids}" ]; then
        print_info "Procesos Maven encontrados: ${pids}"
        
        for pid in ${pids}; do
            if graceful_shutdown "${pid}" "Maven"; then
                continue
            else
                force_shutdown "${pid}" "Maven"
            fi
        done
        
        return 0
    fi
    
    return 1
}

# Limpiar archivos temporales
cleanup_files() {
    print_step "Limpiando archivos temporales..."
    
    # Remover archivo PID si existe
    if [ -f "${PID_FILE}" ]; then
        rm -f "${PID_FILE}"
        print_success "Archivo PID removido"
    fi
    
    # Limpiar directorio target de Maven (opcional)
    if [ -d target ] && [ "$1" = "--clean" ]; then
        print_info "Limpiando directorio target de Maven..."
        rm -rf target
        print_success "Directorio target de Maven limpiado"
    fi
    
    # Rotar logs si son muy grandes
    if [ -f logs/application.log ]; then
        local log_size=$(stat -f%z logs/application.log 2>/dev/null || stat -c%s logs/application.log 2>/dev/null || echo 0)
        if [ "${log_size}" -gt 10485760 ]; then  # 10MB
            mv logs/application.log "logs/application.log.$(date +%Y%m%d_%H%M%S)"
            print_info "Archivo de log de aplicación grande rotado"
        fi
    fi
}

# Mostrar resumen de detención
display_summary() {
    echo ""
    show_operation_banner "DETENCIÓN COMPLETADA" "🛑"
    echo ""
    
    print_info "📊 Resumen de Detención:"
    echo -e "${CYAN}"
    echo "   ├── Aplicación detenida exitosamente"
    echo "   ├── Puerto ${SERVER_PORT} ahora está disponible"
    echo "   ├── Archivos temporales limpiados"
    echo "   └── Sistema listo para reinicio"
    echo -e "${NC}"
    
    print_info "🔄 Opciones de Reinicio:"
    echo -e "${YELLOW}"
    echo "   ├── Reinicio rápido: ./scripts/mac/iniciar.sh"
    echo "   ├── Configuración completa: ./scripts/mac/configurar.sh && ./scripts/mac/iniciar.sh"
    echo "   ├── Verificar estado: ./scripts/mac/verificar-estado.sh"
    echo "   └── Ver logs: tail -f logs/detencion.log"
    echo -e "${NC}"
}

# Ejecución principal
main() {
    # Cambiar al directorio del proyecto
    cd "${PROJECT_DIR}"
    
    # Mostrar banner
    show_edutech_banner
    show_operation_banner "DETENIENDO MICROSERVICIO DE EVALUACIONES" "🛑"
    
    print_info "Iniciando secuencia profesional de detención de aplicación..."
    print_info "Archivo de log: ${LOG_FILE}"
    
    # Cargar entorno
    load_environment
    
    local stopped=false
    
    # Intentar diferentes métodos de detención
    print_step "Intentando detener Servicio de Evaluaciones..."
    
    # Método 1: Detener por archivo PID
    if stop_by_pid_file; then
        print_success "Aplicación detenida usando archivo PID"
        stopped=true
    fi
    
    # Método 2: Detener por puerto
    if [ "${stopped}" = false ]; then
        if stop_by_port; then
            print_success "Aplicación detenida por búsqueda de puerto"
            stopped=true
        fi
    fi
    
    # Método 3: Detener procesos Spring Boot
    if [ "${stopped}" = false ]; then
        if stop_spring_boot_processes; then
            print_success "Procesos Spring Boot detenidos"
            stopped=true
        fi
    fi
    
    # Método 4: Detener procesos Maven
    if [ "${stopped}" = false ]; then
        if stop_maven_processes; then
            print_success "Procesos Maven detenidos"
            stopped=true
        fi
    fi
    
    if [ "${stopped}" = false ]; then
        print_warning "No se encontraron instancias de aplicación ejecutándose"
        print_info "La aplicación puede estar ya detenida"
    fi
    
    # Limpieza
    cleanup_files "$@"
    
    # Mostrar resumen
    display_summary
    
    show_mini_banner "¡Detención del Servicio de Evaluaciones completada!" "🌟"
}

# Ejecutar función principal
main "$@"
