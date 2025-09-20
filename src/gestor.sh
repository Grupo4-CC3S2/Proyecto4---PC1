#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/network_monitor.sh"

check_service() {
    echo "=== VERIFICACIÓN INTEGRAL ==="
    
    # Verificar directamente conectividad
    echo "Verificando conectividad con servicio..."
    if test_curl; then
        echo "Servicio responde correctamente"
    else
        echo "Servicio no disponible o no responde"
    fi
}

monitor() {
    echo "=== MONITOREO COMPLETO ==="
    echo "Verificando conectividad HTTP:"
    test_curl || echo "Sin conectividad HTTP"
    echo ""
    echo "Verificando DNS:"
    test_dig
}

case "${1:-check}" in
    "check") check_service ;;
    "monitor") monitor ;;
    *) echo "Uso: $0 {check|monitor}" ;;
esac