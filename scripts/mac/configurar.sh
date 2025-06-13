#!/bin/bash

# =============================================================================
# EduTech - Script de Configuración Profesional (macOS/Linux)
# =============================================================================
# Descripción: Configuración empresarial del entorno de desarrollo para el
#              Microservicio de Evaluaciones EduTech con validación completa
# Autor: Equipo de Desarrollo EduTech
# Versión: 3.0.0
# Plataforma: macOS/Linux/Unix
# =============================================================================

set -euo pipefail  # Salir en error, variables indefinidas, fallos de pipe

# Importar banner
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
if [ -f "$ROOT_DIR/scripts/banner.sh" ]; then
    source "$ROOT_DIR/scripts/banner.sh"
fi

# Códigos de color para salida profesional
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # Sin Color

# Configuración
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="${ROOT_DIR}/logs/configuracion.log"
readonly TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Crear directorio de logs si no existe
mkdir -p "${ROOT_DIR}/logs"

# Función de logging
log() {
    local level="$1"
    shift
    local message="$*"
    echo -e "[${TIMESTAMP}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

# Funciones de impresión con colores
print_header() {
    show_edutech_banner
    show_operation_banner "🛠️  CONFIGURACIÓN DE ENTORNO" "Inicializando entorno de desarrollo profesional..."
}

print_step() {
    local step="$1"
    echo -e "${CYAN}🔄 ${step}...${NC}"
    log "PASO" "${step}..."
}

print_success() {
    local message="$1"
    echo -e "${GREEN}✅ ${message}${NC}"
    log "ÉXITO" "${message}"
}

print_warning() {
    local message="$1"
    echo -e "${YELLOW}⚠️  ${message}${NC}"
    log "ADVERTENCIA" "${message}"
}

print_error() {
    local message="$1"
    echo -e "${RED}❌ ${message}${NC}"
    log "ERROR" "${message}"
}

print_info() {
    local message="$1"
    echo -e "${BLUE}ℹ️  ${message}${NC}"
    log "INFO" "${message}"
}

# Verificar si comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validar requisitos del sistema
validate_requirements() {
    print_step "Validando requisitos del sistema"
    
    local requirements_met=true
    
    # Verificar Java
    if command_exists java; then
        local java_version=$(java -version 2>&1 | head -n1 | cut -d'"' -f2)
        print_success "Java encontrado: ${java_version}"
    else
        print_error "Java no encontrado. Por favor instale Java 17 o superior."
        requirements_met=false
    fi
    
    # Verificar Maven
    if command_exists mvn; then
        local maven_version=$(mvn -version 2>/dev/null | head -n1 | cut -d' ' -f3)
        print_success "Maven encontrado: ${maven_version}"
    else
        print_error "Maven no encontrado. Por favor instale Apache Maven."
        requirements_met=false
    fi
    
    # Verificar Git
    if command_exists git; then
        local git_version=$(git --version | cut -d' ' -f3)
        print_success "Git encontrado: ${git_version}"
    else
        print_warning "Git no encontrado. Las funciones de control de versiones serán limitadas."
    fi
    
    if [ "${requirements_met}" = false ]; then
        print_error "Los requisitos del sistema no se cumplen. Por favor instale las dependencias faltantes."
        exit 1
    fi
}

# Configurar entorno
setup_environment() {
    print_step "Configurando variables de entorno"
    
    cd "$ROOT_DIR"
    
    if [ ! -f .env ]; then
        # Crear archivo .env básico
        cat > .env << 'EOF'
# =============================================================================
# EduTech - Variables de Entorno de Desarrollo
# =============================================================================

# Configuración de Base de Datos PostgreSQL
DATABASE_URL=jdbc:postgresql://localhost:5432/evaluation_db
DATABASE_USERNAME=tu_usuario_aqui
DATABASE_PASSWORD=tu_password_aqui

# Configuración de la Aplicación
SERVER_PORT=8083
SPRING_PROFILES_ACTIVE=dev

# Configuración de Logging
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_EDUTECH=DEBUG

# Configuración de Health Checks
HEALTH_CHECK_TIMEOUT=120
HEALTH_CHECK_INTERVAL=5

# ⚠️  IMPORTANTE: 
# 1. Reemplace los valores de ejemplo con credenciales reales
# 2. NUNCA commita este archivo al control de versiones
# 3. Use contraseñas fuertes para producción
EOF
        print_success "Archivo .env creado con valores por defecto"
        print_warning "Por favor actualice el archivo .env con sus credenciales reales"
    else
        print_warning "Archivo de entorno ya existe. Omitiendo creación."
        
        # Validar .env existente
        if grep -q "tu_usuario_aqui\|your_database_url_here" .env; then
            print_warning "El archivo de entorno contiene valores de ejemplo. Por favor actualice con credenciales reales."
        fi
    fi
}

# Configurar permisos de scripts
setup_permissions() {
    print_step "Configurando permisos de scripts"
    
    cd "$ROOT_DIR"
    
    # Scripts en directorio raíz
    local root_scripts=("setup.sh" "start.sh" "check-status.sh" "stop.sh" "manage.sh")
    for script in "${root_scripts[@]}"; do
        if [ -f "${script}" ]; then
            chmod +x "${script}"
            print_success "Permisos ejecutables establecidos para ${script}"
        fi
    done
    
    # Scripts en directorio Mac
    if [ -d "scripts/mac" ]; then
        chmod +x scripts/mac/*.sh 2>/dev/null || true
        print_success "Permisos establecidos para scripts de Mac"
    fi
    
    # Script de banner
    if [ -f "scripts/banner.sh" ]; then
        chmod +x scripts/banner.sh
        print_success "Permisos establecidos para banner.sh"
    fi
}

# Inicializar estructura del proyecto
initialize_project() {
    print_step "Inicializando estructura del proyecto"
    
    cd "$ROOT_DIR"
    
    # Crear directorios necesarios
    local directories=("logs" "target" "docs/api" "scripts/mac" "scripts/windows")
    
    for dir in "${directories[@]}"; do
        if [ ! -d "${dir}" ]; then
            mkdir -p "${dir}"
            print_success "Directorio creado: ${dir}"
        fi
    done
    
    # Inicializar repositorio Git si no existe
    if [ ! -d .git ] && command_exists git; then
        git init
        print_success "Repositorio Git inicializado"
        
        # Agregar .env a .gitignore si no está presente
        if ! grep -q "\.env$" .gitignore 2>/dev/null; then
            echo -e "\n# Variables de entorno\n.env\n.env.local\n.env.*.local" >> .gitignore
            print_success ".env agregado a .gitignore"
        fi
    fi
}

# Validar proyecto Maven
validate_maven_project() {
    print_step "Validando estructura del proyecto Maven"
    
    cd "$ROOT_DIR"
    
    if [ ! -f pom.xml ]; then
        print_error "pom.xml no encontrado. Esto no parece ser un proyecto Maven."
        return 1
    fi
    
    # Verificar Spring Boot
    if grep -q "spring-boot" pom.xml; then
        print_success "Proyecto Spring Boot detectado"
    else
        print_warning "Dependencia de Spring Boot no encontrada en pom.xml"
    fi
    
    # Validar proyecto Maven
    if mvn validate &>/dev/null; then
        print_success "Validación del proyecto Maven exitosa"
    else
        print_error "Falló la validación del proyecto Maven"
        return 1
    fi
    
    # Verificar estructura de directorios Java
    if [ -d "src/main/java" ]; then
        print_success "Estructura de directorios Java encontrada"
    else
        print_warning "Estructura estándar de Maven no encontrada"
    fi
}

# Generar resumen del proyecto
generate_summary() {
    print_step "Generando resumen del proyecto"
    
    cd "$ROOT_DIR"
    
    local summary_file="RESUMEN_PROYECTO.md"
    
    cat > "${summary_file}" << EOF
# 📊 Resumen de Configuración del Proyecto EduTech

**Fecha de Configuración:** ${TIMESTAMP}  
**Versión del Script:** 3.0.0  
**Tipo de Proyecto:** Microservicio de Evaluaciones Spring Boot  

## 🖥️ Entorno de Desarrollo
- **Versión de Java:** $(java -version 2>&1 | head -n1 | cut -d'"' -f2)
- **Versión de Maven:** $(mvn -version 2>/dev/null | head -n1 | cut -d' ' -f3)
- **Sistema Operativo:** $(uname -s)
- **Arquitectura:** $(uname -m)

## 📁 Archivos de Configuración
- ✅ .env (Variables de entorno)
- ✅ .gitignore (Reglas de Git ignore)
- ✅ pom.xml (Configuración Maven)
- ✅ application.properties (Configuración Spring Boot)

## 🛠️ Scripts Disponibles
- \`./scripts/mac/controlador.sh\` - Control maestro del microservicio
- \`./scripts/mac/configurar.sh\` - Configuración del entorno de desarrollo
- \`./scripts/mac/iniciar.sh\` - Iniciar el microservicio
- \`./scripts/mac/verificar-estado.sh\` - Verificación de salud y estado

## 🚀 Próximos Pasos
1. 📝 Revisar y actualizar archivo .env con credenciales de base de datos
2. 🚀 Ejecutar \`./scripts/mac/iniciar.sh\` para iniciar el microservicio
3. 🔍 Usar \`./scripts/mac/verificar-estado.sh\` para verificar el servicio
4. 🌐 Acceder a la documentación API en http://localhost:8083/actuator

## 🏗️ Arquitectura del Proyecto
- 🌐 API REST con 20+ endpoints
- 🗄️ Integración con PostgreSQL
- 📊 Monitoreo con Spring Boot Actuator
- 🧪 Suite completa de pruebas
- 🚀 Scripts profesionales de despliegue

## 🔒 Notas de Seguridad
- ⚠️ NUNCA commitear archivo .env al control de versiones
- 🔒 Usar contraseñas fuertes para conexiones de base de datos
- 🛡️ Actualizar dependencias regularmente
- 🔐 Configurar variables de entorno en producción

## 📞 Soporte
Para problemas con la configuración:
1. Revisar logs en \`logs/configuracion.log\`
2. Ejecutar \`./scripts/mac/verificar-estado.sh\` para diagnósticos
3. Consultar documentación en README.md

---
*Generado por ${SCRIPT_NAME} el ${TIMESTAMP}*
EOF

    print_success "Resumen del proyecto generado: RESUMEN_PROYECTO.md"
}

# Función principal
main() {
    print_header
    
    print_info "Iniciando configuración profesional para EduTech Evaluation Service..."
    print_info "Archivo de log: ${LOG_FILE}"
    
    # Ejecutar pasos de configuración
    validate_requirements
    setup_environment
    setup_permissions
    initialize_project
    validate_maven_project
    generate_summary
    
    echo ""
    echo -e "${GREEN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          🎉 CONFIGURACIÓN COMPLETADA                         ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    print_info "📋 Próximos Pasos:"
    echo -e "${CYAN}"
    echo "   1. 📝 Editar archivo .env con credenciales de su base de datos"
    echo "   2. 🚀 Ejecutar ./scripts/mac/controlador.sh para usar el control maestro"
    echo "   3. 🔍 Usar opción 'iniciar' para lanzar el microservicio"
    echo "   4. 📖 Consultar RESUMEN_PROYECTO.md para información detallada"
    echo -e "${NC}"
    
    print_info "🔗 URLs Útiles:"
    echo -e "${BLUE}"
    echo "   ├── Health Check: http://localhost:8083/actuator/health"
    echo "   ├── Estado BD: http://localhost:8083/actuator/health/db"
    echo "   └── Métricas: http://localhost:8083/actuator/metrics"
    echo -e "${NC}"
    
    echo ""
    print_info "🔒 Recordatorio de Seguridad: ¡NUNCA commitear archivos .env al control de versiones!"
    echo ""
}

# Capturar errores y limpiar
trap 'print_error "Configuración falló en línea $LINENO. Revise ${LOG_FILE} para detalles."' ERR

# Ejecutar función principal
main "$@"
