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

clean() {
  echo "Limpiando servicio $SERVICE_NAME..."

  # 1. Detener el servicio
  echo "Deteniendo servicio systemd $SERVICE_NAME..."
  sudo systemctl disable "${SERVICE_NAME}.service" 2>/dev/null || true

  # 2. Borrar unit file del sistema si existe
  if [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
    echo "Eliminando unit file /etc/systemd/system/${SERVICE_NAME}.service..."
    sudo rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
  fi

  # 3. Recargar systemd
  echo "Recargando systemd daemon..."
  sudo systemctl daemon-reload || true

  # 4. Eliminar entorno virtual
  if [ -d "$VENV_DIR" ]; then
    echo "Eliminando entorno virtual en $VENV_DIR..."
    rm -rf "$VENV_DIR"
  fi

  echo "==> Limpieza completada."
}



trap "echo '[trap] SIGINT singal capturado con trap'; exit 0" INT
trap "echo '[trap] TERM signal capturado con trap'; clean ; exit 0" TERM

case "$1" in
  start) start ;;
  *)
    echo "Uso: $0 {start|stop|status}"
    exit 1
    ;;
esac
