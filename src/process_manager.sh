#!/bin/bash
# src/process_manager.sh
# Gestor de Procesos (genérico, sin dependencia del Makefile)

# ----------------------------------------------------
# Variables de configuración con valores por defecto
# Pueden ser sobreescritas al invocar el script:
#   CMD="python otro.py" SERVICE_NAME=api ./src/process_manager.sh start
# ----------------------------------------------------

APP_DIR="${APP_DIR:-..}"
VENV_DIR="${VENV_DIR:-${APP_DIR}/venv}"
SERVICE_NAME="${SERVICE_NAME:-pc14app}"
LOG_FILE="${LOG_FILE:-${APP_DIR}/out/${SERVICE_NAME}.log}"
PYTHON_BIN="${VENV_DIR}/bin/python"

PORT="${PORT:-8081}"
MESSAGE="${MESSAGE:-PC1 proyecto 4}"
RELEASE="${RELEASE:-v0}"

set -euo pipefail


# ----------------------------------------------------
# Función START
# ----------------------------------------------------
start() {
  echo "Iniciando $SERVICE_NAME..."
  PORT=$PORT MESSAGE=$MESSAGE RELEASE=$RELEASE \
    $PYTHON_BIN $APP_DIR/app.py 2>&1 | tee $LOG_FILE
  return 0
}
case "$1" in
  start) start ;;
  stop) stop ;;
  status) status ;;
  *)
    echo "Uso: $0 {start|stop|status}"
    exit 1
    ;;
esac
