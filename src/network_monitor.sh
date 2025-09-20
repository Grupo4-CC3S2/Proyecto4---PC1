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

# Función para verificar puertos con ss
check_ports_ss() {
    echo "=== VERIFICACIÓN DE PUERTOS CON SS ==="
    
    # Puerto específico del servicio
    echo "Verificando puerto 8081 (pc14app):"
    ss -tulpn | grep :8081 || echo "Puerto 8081 libre"
    
    # Puertos HTTPS comunes
    echo "Puertos HTTPS activos:"
    ss -tulpn | grep :443 || echo "Puerto 443 libre"
    
    # Resumen de puertos TCP activos
    echo "Puertos TCP en LISTEN:"
    ss -tln | head -5
    
    # Guardar análisis
    ss -tulpn > out/ports_analysis.txt
    echo "Análisis guardado en out/ports_analysis.txt"
}

# Función para HTTP con nc
test_http_nc() {
    echo "=== PRUEBAS HTTP CON NETCAT ==="
    
    # HTTP básico a google.com
    echo "Probando HTTP a google.com puerto 80:"
    (echo -e "GET / HTTP/1.1\r\nHost: google.com\r\nConnection: close\r\n\r\n"; sleep 2) | nc google.com 80 | head -10
    
    # HTTP a example.com (más predecible)
    echo "Probando HTTP a example.com puerto 80:"
    (echo -e "GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n"; sleep 2) | nc example.com 80 | head -5
}

# Función para verificar conectividad con nc
test_connectivity_nc() {
    echo "=== VERIFICACIÓN DE CONECTIVIDAD CON NC ==="
    
    # Test de conectividad sin enviar datos
    if nc -z google.com 80; then
        echo "Conectividad HTTP (puerto 80): OK"
    else
        echo "Conectividad HTTP (puerto 80): FALLO"
    fi
    
    if nc -z google.com 443; then
        echo "Conectividad HTTPS (puerto 443): OK"  
    else
        echo "Conectividad HTTPS (puerto 443): FALLO"
    fi
    
    # Test al servicio local
    if nc -z localhost 8081; then
        echo "Servicio local (puerto 8081): ACTIVO"
    else
        echo "Servicio local (puerto 8081): INACTIVO"
    fi
}

# Función para análisis TLS con openssl
analyze_tls_openssl() {
    echo "=== ANÁLISIS TLS CON OPENSSL ==="
    
    # Conectar a google.com y verificar certificado con timeout
    echo "Conectando a google.com:443 (TLS):"
    echo "quit" | timeout 10 openssl s_client -connect google.com:443 -servername google.com -brief 2>/dev/null | head -10 || echo "Timeout o error de conexión TLS"
    
    # Obtener información del certificado con timeout
    echo "Información del certificado de google.com:"
    echo "quit" | timeout 10 openssl s_client -connect google.com:443 -servername google.com 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null || echo "Error obteniendo certificado"
    
    # Verificar protocolo TLS con timeout
    echo "Protocolos TLS soportados:"
    echo "quit" | timeout 10 openssl s_client -connect google.com:443 -tls1_2 -brief 2>/dev/null | grep "Protocol version" || echo "Error verificando protocolo TLS"
    
    # Test alternativo con certificado más simple
    echo "Test TLS con example.com (más confiable):"
    echo "quit" | timeout 5 openssl s_client -connect example.com:443 -servername example.com -brief 2>/dev/null | head -5 || echo "Error con example.com"
}


# Función para configurar /etc/hosts
setup_hosts() {
    echo "=== CONFIGURACIÓN /etc/hosts ==="
    
    # Verificar si la entrada ya existe
    if grep -q "127.0.0.1 pc14app.local" /etc/hosts; then
        echo "Entrada pc14app.local ya existe en /etc/hosts"
    else
        echo "Añadiendo entrada a /etc/hosts..."
        echo "127.0.0.1 pc14app.local" | sudo tee -a /etc/hosts
        echo "Entrada añadida: 127.0.0.1 pc14app.local"
    fi
    
    # Verificar la configuración
    echo "Verificando resolución DNS:"
    dig +short pc14app.local || echo "Resolución local configurada"
}

# Función para comparación completa HTTP vs HTTPS
compare_http_https() {
    local target_domain="${1:-google.com}"
    echo "=== COMPARACIÓN HTTP vs HTTPS CON $target_domain ==="
    
    # Crear directorio de salida si no existe
    mkdir -p out
    
    # Análisis con curl
    echo "--- Análisis con CURL ---"
    echo "HTTP ($target_domain):"
    curl -I "http://$target_domain" 2>/dev/null | head -3
    echo "HTTPS ($target_domain):"
    curl -I "https://$target_domain" 2>/dev/null | head -3
    
    # Análisis con netcat (HTTP únicamente)
    echo "--- Análisis con NETCAT (solo HTTP) ---"
    echo "HTTP raw response a $target_domain:"
    (echo -e "GET / HTTP/1.1\r\nHost: $target_domain\r\nConnection: close\r\n\r\n"; sleep 1) | nc "$target_domain" 80 | head -5
    
    # Análisis con openssl (HTTPS únicamente) - CON TIMEOUT
    echo "--- Análisis con OPENSSL (solo HTTPS) ---"
    echo "HTTPS handshake y certificado $target_domain:"
    echo "quit" | timeout 10 openssl s_client -connect "$target_domain:443" -servername "$target_domain" -brief 2>/dev/null | head -8 || echo "Error o timeout en conexión HTTPS"
    
    # Diferencias observadas
    echo "--- DIFERENCIAS HTTP vs HTTPS ---"
    echo "HTTP: Sin encriptación, puerto 80, posible redirección a HTTPS"
    echo "HTTPS: TLS/SSL, puerto 443, certificado digital, handshake encriptado"
    echo "Seguridad: HTTPS protege datos con TLS 1.2/1.3"
    
    # Guardar análisis
    local output_file="out/${target_domain}_http_https_comparison.txt"
    echo "Análisis guardado en $output_file"
    {
        echo "=== COMPARACIÓN HTTP vs HTTPS CON $target_domain ==="
        echo "Fecha: $(date)"
        echo ""
        echo "HTTP Response Headers ($target_domain):"
        curl -I "http://$target_domain" 2>/dev/null
        echo ""
        echo "HTTPS Response Headers ($target_domain):"
        curl -I "https://$target_domain" 2>/dev/null
        echo ""
        echo "TLS Certificate Info ($target_domain):"
        echo "quit" | timeout 10 openssl s_client -connect "$target_domain:443" -servername "$target_domain" 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null || echo "Error obteniendo certificado"
    } > "$output_file"
}

# Función para verificar pc14app
check_pc14app_service() {
    echo "=== VERIFICACIÓN SERVICIO PC14APP ==="
    
    # Verificar puerto con ss
    echo "Estado puerto 8081 (pc14app):"
    ss -tulpn | grep :8081 || echo "Puerto 8081 no activo"
    
    # Test de conectividad local
    echo "Test conectividad pc14app.local:"
    if nc -z pc14app.local 8081 2>/dev/null; then
        echo "pc14app.local:8081 - ACTIVO"
    else
        echo "pc14app.local:8081 - INACTIVO"
    fi
    
    # Test HTTP a pc14app
    echo "Test HTTP a pc14app.local:"
    curl -I http://pc14app.local:8081 2>/dev/null | head -3 || echo "Servicio no responde HTTP"
    
    # Test conectividad localhost
    echo "Test conectividad localhost:8081:"
    if nc -z localhost 8081 2>/dev/null; then
        echo "localhost:8081 - ACTIVO"
        curl -I http://localhost:8081 2>/dev/null | head -3 || echo "Error HTTP localhost"
    else
        echo "localhost:8081 - INACTIVO"
    fi
}

# Función principal
case "${1:-all}" in
    "curl") test_curl ;;
    "dig") test_dig ;;
    "nc") test_http_nc; test_connectivity_nc ;;
    "ssl") analyze_tls_openssl ;;
    "ports") check_ports_ss ;;
    "compare") compare_http_https google.com ;;
    "compare-example") compare_http_https example.com ;;
    "hosts") setup_hosts ;;
    "pc14app") check_pc14app_service ;;
    "all") 
        setup_hosts
        echo ""
        test_curl
        echo ""
        test_dig  
        echo ""
        test_connectivity_nc
        echo ""
        check_ports_ss
        echo ""
        compare_http_https google.com
        echo ""
        check_pc14app_service
        ;;
esac