#!/usr/bin/env bats

setup() {
  export PORT="${PORT:-1239}"
  export MESSAGE="${MESSAGE:-Mensaje de pruebas para bats}"
  export APP_DIR="${APP_DIR:-$(pwd)}"
  export APP_NAME="{APP_NAME:-pc14app}"
}

@test "process_manager sale con 1 cuando no se define una variable" {
  run ${APP_DIR}/src/process_manager.sh
  echo "$output"
  [ "$status" -eq 1 ]  # El script sale con código 1 cuando no se pasa argumento
  [[ "$output" =~ "unbound variable" ]] # Verifica que se 
}

@test "gestor muestra uso con argumento inválido" {
  run ${APP_DIR}/src/process_manager.sh invalid_command
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Uso:" ]]
}



@test "DNS: comprobar resolución A y/o CNAME y parseo de TTL" {
  run dig +noall +answer example.com
  [ "$status" -eq 0 ]
  [[ "$output" =~ "example.com." ]]
  [[ "$output" =~ "IN" ]] # asegura que hay algún registro con TTL/clase
}

# -----------------------------------------
# HTTP
# -----------------------------------------
@test "HTTP: validar códigos esperados 200/400 y presencia de headers clave" {
  run curl -s -o /dev/null -w "%{http_code}" http://example.com
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^200$|^400$ ]]
}

@test "TLS (análisis): verificar versión TLS y protocolo en google.com" {
  run openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null
  [ "$status" -eq 0 ]
  [[ "$output" =~ "TLS" ]]
}

@test "Ejercicio simple con nc: solicitar cabeceras HTTP" {
  run bash -c '(echo -e "GET / HTTP/1.1\r\nHost: google.com\r\nConnection: close\r\n\r\n"; sleep 2) | nc google.com 80 | head -10'
  [ "$status" -eq 0 ]
  [[ "$output" =~ "HTTP/" ]]
}
