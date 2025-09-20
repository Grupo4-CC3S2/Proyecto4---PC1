#!/bin/bash
set -euo pipefail # Manejo de errores por si falla algún comando

# Variables de entorno
TARGET_URL=${TARGET_URL:-"http://localhost:8081"}
DNS_SERVER=${DNS_SERVER:-"1.1.1.1"}

# Función para pruebas con curl
test_curl() {
    echo "=== Pruebas con CURL ==="
    echo "Probando: $TARGET_URL"
    
    # Verificar código HTTP
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL")
    echo "Código HTTP: $http_code"
    
    # Verificar headers
    echo "Headers:"
    curl -I "$TARGET_URL" 2>/dev/null | head -3
}

# Función para pruebas con dig
test_dig() {
    echo "=== Pruebas con DIG ==="
    
    # Resolver localhost
    echo "Resolviendo localhost:"
    dig +short localhost
    
    # Resolver con servidor específico
    echo "Resolviendo google.com con Cloudflare con $DNS_SERVER:"
    dig @"$DNS_SERVER" google.com +short
}

# Función principal
case "${1:-notdef}" in
    "curl") test_curl ;;
    "dig") test_dig ;;
    "all") test_curl; echo ""; test_dig ;;
esac