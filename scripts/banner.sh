#!/bin/bash

# =============================================================================
# EduTech Banner - Banner profesional para todos los scripts
# =============================================================================

# Colores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

show_edutech_banner() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                              ║"
    echo "║   ███████╗██████╗ ██╗   ██╗████████╗███████╗ ██████╗██╗  ██╗                ║"
    echo "║   ██╔════╝██╔══██╗██║   ██║╚══██╔══╝██╔════╝██╔════╝██║  ██║                ║"
    echo "║   █████╗  ██║  ██║██║   ██║   ██║   █████╗  ██║     ███████║                ║"
    echo "║   ██╔══╝  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║     ██╔══██║                ║"
    echo "║   ███████╗██████╔╝╚██████╔╝   ██║   ███████╗╚██████╗██║  ██║                ║"
    echo "║   ╚══════╝╚═════╝  ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝                ║"
    echo "║                                                                              ║"
    echo "║              🎓 PLATAFORMA DE EVALUACIONES ESTUDIANTILES 🎓                  ║"
    echo "║                                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}${BOLD}                    🚀 Microservicio de Evaluaciones v2.0.0"
    echo -e "                      Desarrollado con Spring Boot 3.5.0${NC}"
    echo ""
}

show_mini_banner() {
    echo -e "${PURPLE}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║   🎓 EduTech - Plataforma de Evaluaciones Estudiantiles 🎓   ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_operation_banner() {
    local operation="$1"
    local description="$2"
    echo -e "${BLUE}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║  $operation"
    echo "║  $description"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}
