#!/usr/bin/env bats

setup() {
  export PORT="${PORT:-1239}"
  export MESSAGE="${MESSAGE:-Mensaje de pruebas para bats}"
  export APP_DIR="${APP_DIR:-$(pwd)}"
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

@test "process_manager atrapa la TERM signal" {
  run timeout 3s bash -c '
    APP_DIR='"${APP_DIR}"' PORT='"${PORT}"' MESSAGE="'"${MESSAGE}"'" '"${APP_DIR}"'/src/process_manager.sh start 
  '
  # Verificamos que se haya capturado la SIGTERM con trap
  [[ "$output" =~ "trap" ]]
  [[ "$output" =~ "TERM" ]] 
}

@test "pc14app responde correctamente" {
  run timeout 3s bash -c '
    APP_DIR='"${APP_DIR}"' PORT='"${PORT}"' MESSAGE="'"${MESSAGE}"'" '"${APP_DIR}"'/src/process_manager.sh start 1>/dev/null 2>&1 &
    sleep 1
    curl -s http://127.0.0.1:${PORT}
    wait $!
  '
  # Verificamos que se haya capturado la SIGTERM con trap
  [[ "$output" =~ "status\":\"ok" ]]
}