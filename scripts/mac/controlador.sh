#!/bin/bash

# =============================================================================
# EduTech - Script Maestro de Control (macOS/Linux)
# =============================================================================
# Descripción: Script empresarial para gestionar el ciclo completo de desarrollo
#              del Microservicio de Evaluaciones EduTech
# Autor: Equipo de Desarrollo EduTech
# Versión: 3.0.0 - Edición Española
# Plataforma: macOS/Linux/Unix
# =============================================================================

set -euo pipefail

# Configuración
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly VERSION="3.0.0"

# Importar banner
if [ -f "$ROOT_DIR/scripts/banner.sh" ]; then
    source "$ROOT_DIR/scripts/banner.sh"
fi

# Funciones de utilidad
log() {
    local level="$1"
    shift
    local message="$*"
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] [${level}] ${message}"
}

print_menu() {
    echo -e "${CYAN}${BOLD}📋 Operaciones Disponibles:${NC}"
    echo ""
    echo -e "${GREEN}  🔧 CONFIGURACIÓN E INICIALIZACIÓN${NC}"
    echo -e "     1) ${YELLOW}configurar${NC}    - 🛠️  Configurar entorno de desarrollo"
    echo -e "     2) ${YELLOW}variables${NC}     - ⚙️  Gestionar variables de entorno"
    echo ""
    echo -e "${GREEN}  🚀 CICLO DE VIDA DE LA APLICACIÓN${NC}"
    echo -e "     3) ${YELLOW}iniciar${NC}       - 🚀 Iniciar el microservicio"
    echo -e "     4) ${YELLOW}detener${NC}       - 🛑 Detener el microservicio"
    echo -e "     5) ${YELLOW}reiniciar${NC}     - 🔄 Reiniciar el microservicio"
    echo -e "     6) ${YELLOW}estado${NC}        - 🔍 Verificar estado de la aplicación"
    echo ""
    echo -e "${GREEN}  🔨 COMPILACIÓN Y PRUEBAS${NC}"
    echo -e "     7) ${YELLOW}compilar${NC}      - 🔨 Compilar la aplicación"
    echo -e "     8) ${YELLOW}probar${NC}        - 🧪 Ejecutar pruebas unitarias"
    echo -e "     9) ${YELLOW}empaquetar${NC}    - 📦 Crear paquete desplegable"
    echo -e "    10) ${YELLOW}limpiar${NC}       - 🧹 Limpiar archivos de compilación"
    echo ""
    echo -e "${GREEN}  📊 MONITOREO Y REGISTROS${NC}"
    echo -e "    11) ${YELLOW}logs${NC}          - 📋 Ver registros de la aplicación"
    echo -e "    12) ${YELLOW}salud${NC}         - 🏥 Verificar endpoints de salud"
    echo -e "    13) ${YELLOW}metricas${NC}      - 📊 Ver métricas de la aplicación"
    echo ""
    echo -e "${GREEN}  🛠️  HERRAMIENTAS DE DESARROLLO${NC}"
    echo -e "    14) ${YELLOW}bd${NC}            - 🗄️  Operaciones de base de datos"
    echo -e "    15) ${YELLOW}dependencias${NC}  - 🔍 Verificar dependencias"
    echo -e "    16) ${YELLOW}documentar${NC}    - 📖 Generar documentación"
    echo ""
    echo -e "${GREEN}  📖 INFORMACIÓN Y AYUDA${NC}"
    echo -e "    17) ${YELLOW}info${NC}          - 📊 Información del proyecto"
    echo -e "    18) ${YELLOW}ayuda${NC}         - 💡 Mostrar ayuda detallada"
    echo -e "    19) ${YELLOW}version${NC}       - 📋 Información de versión"
    echo ""
    echo -e "${RED}     0) ${YELLOW}salir${NC}         - 👋 Salir del control maestro${NC}"
    echo ""
}

# Comandos principales
cmd_configurar() {
    show_operation_banner "🛠️  CONFIGURANDO ENTORNO" "Inicializando entorno de desarrollo EduTech..."
    if [ -f "$ROOT_DIR/scripts/mac/configurar.sh" ]; then
        "$ROOT_DIR/scripts/mac/configurar.sh"
    else
        echo -e "${RED}❌ Script de configuración no encontrado${NC}"
    fi
}

cmd_variables() {
    show_operation_banner "⚙️  GESTIÓN DE VARIABLES" "Configurando variables de entorno..."
    if [ -f "$ROOT_DIR/.env" ]; then
        ${EDITOR:-nano} "$ROOT_DIR/.env"
    else
        echo -e "${YELLOW}⚠️  Archivo .env no encontrado. Creando desde plantilla...${NC}"
        if [ -f "$ROOT_DIR/.env.example" ]; then
            cp "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
            ${EDITOR:-nano} "$ROOT_DIR/.env"
        else
            echo -e "${RED}❌ Plantilla .env.example no encontrada${NC}"
        fi
    fi
}

cmd_iniciar() {
    show_operation_banner "🚀 INICIANDO APLICACIÓN" "Lanzando microservicio EduTech..."
    if [ -f "$ROOT_DIR/scripts/mac/iniciar.sh" ]; then
        "$ROOT_DIR/scripts/mac/iniciar.sh"
    else
        echo -e "${RED}❌ Script de inicio no encontrado${NC}"
    fi
}

cmd_detener() {
    show_operation_banner "🛑 DETENIENDO APLICACIÓN" "Parando microservicio de forma segura..."
    if [ -f "$ROOT_DIR/scripts/mac/detener.sh" ]; then
        "$ROOT_DIR/scripts/mac/detener.sh"
    else
        echo -e "${RED}❌ Script de detención no encontrado${NC}"
    fi
}

cmd_reiniciar() {
    show_operation_banner "🔄 REINICIANDO APLICACIÓN" "Reiniciando microservicio EduTech..."
    cmd_detener
    sleep 3
    cmd_iniciar
}

cmd_estado() {
    show_operation_banner "🔍 VERIFICANDO ESTADO" "Comprobando estado del microservicio..."
    if [ -f "$ROOT_DIR/scripts/mac/verificar-estado.sh" ]; then
        "$ROOT_DIR/scripts/mac/verificar-estado.sh"
    else
        echo -e "${RED}❌ Script de verificación no encontrado${NC}"
    fi
}

cmd_compilar() {
    show_operation_banner "🔨 COMPILANDO APLICACIÓN" "Compilando código fuente..."
    cd "$ROOT_DIR"
    mvn clean compile
}

cmd_probar() {
    show_operation_banner "🧪 EJECUTANDO PRUEBAS" "Corriendo suite completa de pruebas..."
    cd "$ROOT_DIR"
    mvn test
}

cmd_empaquetar() {
    show_operation_banner "📦 EMPAQUETANDO APLICACIÓN" "Creando JAR desplegable..."
    cd "$ROOT_DIR"
    mvn clean package -DskipTests
}

cmd_limpiar() {
    show_operation_banner "🧹 LIMPIANDO PROYECTO" "Eliminando archivos temporales..."
    cd "$ROOT_DIR"
    mvn clean
    if [ -d "logs" ]; then
        rm -f logs/*.log
        echo -e "${GREEN}✅ Registros limpiados${NC}"
    fi
    echo -e "${GREEN}✅ Limpieza completada${NC}"
}

cmd_logs() {
    show_operation_banner "📋 REGISTROS DE APLICACIÓN" "Mostrando logs recientes..."
    if [ -f "$ROOT_DIR/logs/application.log" ]; then
        tail -n 50 "$ROOT_DIR/logs/application.log"
    else
        echo -e "${YELLOW}⚠️  No se encontraron registros de aplicación${NC}"
    fi
}

cmd_salud() {
    show_operation_banner "🏥 VERIFICANDO SALUD" "Comprobando endpoints de salud..."
    
    # Cargar puerto desde variables de entorno
    local port="8083"
    if [ -f "$ROOT_DIR/.env" ]; then
        port=$(grep "^SERVER_PORT=" "$ROOT_DIR/.env" 2>/dev/null | cut -d'=' -f2 || echo "8083")
    fi
    
    echo -e "${BLUE}🔍 Verificación de Salud: http://localhost:${port}/actuator/health${NC}"
    if command -v curl >/dev/null 2>&1; then
        curl -s "http://localhost:${port}/actuator/health" | jq . 2>/dev/null || curl -s "http://localhost:${port}/actuator/health"
    else
        echo -e "${YELLOW}⚠️  curl no disponible para verificar endpoints${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}🗄️  Salud de Base de Datos: http://localhost:${port}/actuator/health/db${NC}"
    if command -v curl >/dev/null 2>&1; then
        curl -s "http://localhost:${port}/actuator/health/db" | jq . 2>/dev/null || curl -s "http://localhost:${port}/actuator/health/db"
    fi
}

cmd_metricas() {
    show_operation_banner "📊 MÉTRICAS DE APLICACIÓN" "Consultando métricas del sistema..."
    
    local port="8083"
    if [ -f "$ROOT_DIR/.env" ]; then
        port=$(grep "^SERVER_PORT=" "$ROOT_DIR/.env" 2>/dev/null | cut -d'=' -f2 || echo "8083")
    fi
    
    echo -e "${BLUE}📊 Métricas: http://localhost:${port}/actuator/metrics${NC}"
    if command -v curl >/dev/null 2>&1; then
        curl -s "http://localhost:${port}/actuator/metrics" | jq . 2>/dev/null || curl -s "http://localhost:${port}/actuator/metrics"
    else
        echo -e "${YELLOW}⚠️  curl no disponible para consultar métricas${NC}"
    fi
}

cmd_bd() {
    show_operation_banner "🗄️  OPERACIONES DE BASE DE DATOS" "Gestión de PostgreSQL..."
    echo ""
    echo -e "${CYAN}Seleccione una opción:${NC}"
    echo "1) 📊 Mostrar información de conexión"
    echo "2) 🔗 Probar conexión a la base de datos"
    echo "3) 📋 Mostrar esquema de la base de datos"
    echo "4) 🔙 Volver al menú principal"
    echo ""
    read -p "$(echo -e ${PURPLE}Ingrese su opción: ${NC})" db_choice
    
    case "$db_choice" in
        1)
            if [ -f "$ROOT_DIR/.env" ]; then
                echo -e "${GREEN}🔗 URL de Base de Datos:${NC}"
                grep "^DATABASE_URL=" "$ROOT_DIR/.env" 2>/dev/null || echo "No configurada"
                echo -e "${GREEN}👤 Usuario:${NC}"
                grep "^DATABASE_USERNAME=" "$ROOT_DIR/.env" 2>/dev/null || echo "No configurado"
            else
                echo -e "${RED}❌ Archivo .env no encontrado${NC}"
            fi
            ;;
        2)
            echo -e "${CYAN}🔍 Probando conexión a la base de datos...${NC}"
            cd "$ROOT_DIR"
            mvn spring-boot:run -Dspring-boot.run.arguments="--spring.jpa.hibernate.ddl-auto=validate" -q
            ;;
        3)
            echo -e "${CYAN}📋 Información del esquema disponible en los logs de aplicación${NC}"
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}❌ Opción inválida${NC}"
            ;;
    esac
}

cmd_dependencias() {
    show_operation_banner "🔍 VERIFICANDO DEPENDENCIAS" "Analizando dependencias del proyecto..."
    cd "$ROOT_DIR"
    echo -e "${BLUE}📦 Árbol de dependencias Maven:${NC}"
    mvn dependency:tree
    echo ""
    echo -e "${BLUE}⏰ Dependencias desactualizadas:${NC}"
    mvn versions:display-dependency-updates
}

cmd_documentar() {
    show_operation_banner "📖 GENERANDO DOCUMENTACIÓN" "Creando documentación del proyecto..."
    cd "$ROOT_DIR"
    echo -e "${CYAN}📚 Generando Javadoc...${NC}"
    mvn javadoc:javadoc
    echo -e "${GREEN}✅ Documentación generada en target/site/apidocs/${NC}"
}

cmd_info() {
    show_operation_banner "📊 INFORMACIÓN DEL PROYECTO" "Datos del microservicio EduTech..."
    echo ""
    echo -e "${GREEN}🏢 Proyecto:${NC} EduTech - Microservicio de Evaluaciones"
    echo -e "${GREEN}📋 Versión:${NC} $VERSION"
    echo -e "${GREEN}🖥️  Plataforma:${NC} macOS/Linux"
    echo -e "${GREEN}🎯 Propósito:${NC} Sistema de evaluaciones estudiantiles"
    
    if [ -f "$ROOT_DIR/pom.xml" ]; then
        local spring_version=$(grep -o '<spring-boot.version>[^<]*' "$ROOT_DIR/pom.xml" 2>/dev/null | cut -d'>' -f2)
        local java_version=$(grep -o '<java.version>[^<]*' "$ROOT_DIR/pom.xml" 2>/dev/null | cut -d'>' -f2)
        [ -n "$spring_version" ] && echo -e "${GREEN}🍃 Spring Boot:${NC} $spring_version"
        [ -n "$java_version" ] && echo -e "${GREEN}☕ Java:${NC} $java_version"
    fi
    
    echo ""
    echo -e "${BLUE}🏗️  Arquitectura:${NC}"
    echo "    ├── 🌐 API REST con 20+ endpoints"
    echo "    ├── 🗄️  Integración con PostgreSQL"
    echo "    ├── 📊 Monitoreo con Spring Boot Actuator"
    echo "    ├── 🧪 Suite completa de pruebas"
    echo "    └── 🚀 Scripts profesionales de despliegue"
    
    echo ""
    echo -e "${BLUE}📁 Estructura del Proyecto:${NC}"
    if [ -d "$ROOT_DIR/src" ]; then
        local java_files=$(find "$ROOT_DIR/src" -name "*.java" 2>/dev/null | wc -l)
        local controllers=$(find "$ROOT_DIR/src" -name "*Controller.java" 2>/dev/null | wc -l)
        local services=$(find "$ROOT_DIR/src" -name "*Service.java" 2>/dev/null | wc -l)
        local repositories=$(find "$ROOT_DIR/src" -name "*Repository.java" 2>/dev/null | wc -l)
        
        echo "    ├── 📄 Archivos Java: $java_files"
        echo "    ├── 🎛️  Controladores: $controllers"
        echo "    ├── ⚙️  Servicios: $services"
        echo "    └── 🗃️  Repositorios: $repositories"
    fi
}

cmd_ayuda() {
    show_operation_banner "💡 AYUDA DETALLADA" "Guía completa de uso del sistema..."
    echo ""
    echo -e "${GREEN}🚀 Inicio Rápido:${NC}"
    echo "   1. Ejecute 'configurar' para inicializar el entorno"
    echo "   2. Edite el archivo .env con sus credenciales de BD"
    echo "   3. Ejecute 'iniciar' para lanzar la aplicación"
    echo "   4. Use 'estado' para verificar que todo funciona"
    echo ""
    echo -e "${GREEN}🔄 Flujo de Desarrollo:${NC}"
    echo "   • Use 'compilar' antes de probar cambios"
    echo "   • Ejecute 'probar' para correr pruebas unitarias"
    echo "   • Use 'logs' para monitorear el comportamiento"
    echo "   • Consulte 'salud' para verificar endpoints"
    echo ""
    echo -e "${GREEN}🚀 Despliegue en Producción:${NC}"
    echo "   • Use 'empaquetar' para crear JAR desplegable"
    echo "   • Configure variables de entorno de producción"
    echo "   • Use endpoints de salud para monitoreo"
    echo ""
    echo -e "${GREEN}🔧 Solución de Problemas:${NC}"
    echo "   • Verifique 'estado' para salud general"
    echo "   • Revise 'logs' para detalles de errores"
    echo "   • Use 'salud' para probar endpoints"
    echo "   • Ejecute 'dependencias' para verificar librerías"
}

cmd_version() {
    show_operation_banner "📋 INFORMACIÓN DE VERSIÓN" "Detalles de versión del sistema..."
    echo ""
    echo -e "${GREEN}🎯 Script Maestro de Control:${NC} $VERSION"
    echo -e "${GREEN}📅 Fecha de Compilación:${NC} $(date '+%d de %B de %Y - %H:%M:%S')"
    echo ""
    echo -e "${BLUE}💻 Información del Sistema:${NC}"
    echo -e "${GREEN}🖥️  SO:${NC} $(uname -s) $(uname -r)"
    echo -e "${GREEN}🏗️  Arquitectura:${NC} $(uname -m)"
    
    if command -v java >/dev/null 2>&1; then
        local java_ver=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        echo -e "${GREEN}☕ Java:${NC} $java_ver"
    fi
    
    if command -v mvn >/dev/null 2>&1; then
        local maven_ver=$(mvn -version 2>/dev/null | head -n 1 | cut -d' ' -f3)
        echo -e "${GREEN}📦 Maven:${NC} $maven_ver"
    fi
}

# Función principal
main() {
    while true; do
        show_edutech_banner
        print_menu
        
        echo -e "${PURPLE}${BOLD}Ingrese su opción [0-19]: ${NC}"
        read -r choice
        
        echo ""
        case "$choice" in
            1|"configurar") cmd_configurar ;;
            2|"variables") cmd_variables ;;
            3|"iniciar") cmd_iniciar ;;
            4|"detener") cmd_detener ;;
            5|"reiniciar") cmd_reiniciar ;;
            6|"estado") cmd_estado ;;
            7|"compilar") cmd_compilar ;;
            8|"probar") cmd_probar ;;
            9|"empaquetar") cmd_empaquetar ;;
            10|"limpiar") cmd_limpiar ;;
            11|"logs") cmd_logs ;;
            12|"salud") cmd_salud ;;
            13|"metricas") cmd_metricas ;;
            14|"bd") cmd_bd ;;
            15|"dependencias") cmd_dependencias ;;
            16|"documentar") cmd_documentar ;;
            17|"info") cmd_info ;;
            18|"ayuda") cmd_ayuda ;;
            19|"version") cmd_version ;;
            0|"salir") 
                echo -e "${GREEN}👋 ¡Hasta luego! ¡Happy Coding :) !${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Opción inválida. Por favor intente de nuevo.${NC}"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}Presione cualquier tecla para continuar...${NC}"
        read -n 1 -s
    done
}

# Ejecutar función principal
main "$@"
