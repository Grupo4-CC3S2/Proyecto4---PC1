#!/bin/bash
# src/process_manager.sh
# Gestor de Procesos para la aplicación Flask

# Variables de configuración
SERVICE_NAME="flask_app"
# Usamos 'out/' para el PID, siguiendo la estructura del repositorio
PID_FILE="out/$SERVICE_NAME.pid" 
MAKEFILE_PATH="./Makefile"

# Asegura que el directorio 'out' exista para guardar el PID
mkdir -p out

# ----------------------------------------------------
# 1. Función START (Iniciar el proceso)
# ----------------------------------------------------
start() {
    # 1. Verificar si ya está corriendo (usa el PID del archivo)
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "✅ Servicio $SERVICE_NAME ya está activo (PID: $(cat "$PID_FILE"))."
        return 0 # Código de salida de éxito
    fi

    echo "🚀 Iniciando $SERVICE_NAME..."
    
    # 2. Ejecuta 'make run' en segundo plano (&) y lo redirige a un log
    # El 'nohup' previene que el proceso muera si la terminal se cierra
    nohup make -f "$MAKEFILE_PATH" run > out/service.log 2>&1 &
    
    # 3. Captura el PID del último proceso en segundo plano ($!)
    PID=$!
    echo "$PID" > "$PID_FILE"
    echo "✅ Servicio iniciado con éxito. PID: $PID. Logs en out/service.log"
    return 0
}

# ----------------------------------------------------
# 2. Función STOP (Detener el proceso)
# ----------------------------------------------------
stop() {
    if [ ! -f "$PID_FILE" ]; then
        echo "❌ El archivo PID no existe. El servicio no está corriendo."
        return 1
    fi
    
    PID=$(cat "$PID_FILE")
    echo "🛑 Deteniendo servicio $SERVICE_NAME (PID: $PID)..."

    # Envía la señal de terminación (SIGTERM) para un cierre ordenado
    kill "$PID" 2>/dev/null
    
    sleep 3 # Espera a que el proceso termine

    # Si aún sigue vivo, lo mata forzosamente (SIGKILL)
    if kill -0 "$PID" 2>/dev/null; then
        echo "⚠️ El proceso no se detuvo, enviando SIGKILL (matar forzosamente)."
        kill -9 "$PID" 2>/dev/null
    fi

    rm -f "$PID_FILE"
    echo "✅ Servicio detenido y archivo PID eliminado."
    return 0
}

# ----------------------------------------------------
# 3. Función STATUS (Verificar el estado)
# ----------------------------------------------------
status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        # kill -0 verifica si el proceso existe y está vivo sin enviarle una señal
        if kill -0 "$PID" 2>/dev/null; then
            echo "🟢 El servicio $SERVICE_NAME está ACTIVO (PID: $PID)."
            return 0 # Código de éxito: ACTIVO
        else
            echo "🔴 El proceso (PID: $PID) no está corriendo. Limpiando archivo PID."
            rm -f "$PID_FILE"
            return 3 # Código de error: INACTIVO/MUERTO (Estándar de systemd)
        fi
    else
        echo "⚪ El servicio $SERVICE_NAME está INACTIVO (Archivo PID no encontrado)."
        return 3 # Código de error: INACTIVO
    fi
}

# ----------------------------------------------------
# Lógica Principal CLI (Manejo de Argumentos)
# ----------------------------------------------------

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    *)
        echo "Uso: $0 {start|stop|status}"
        exit 1 # Código de salida para uso incorrecto
esac