# Makefile
# Gestor de Entorno y Ejecución para la Aplicación Flask

# ----------------------------------------------------
# Variables de Configuración (12-Factor App)
# Las variables con '?' permiten sobreescribirlas desde la línea de comandos (ej: make run PORT=9000)
# ----------------------------------------------------
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
.DEFAULT_GOAL := help

APP_DIR := $(shell pwd)
VENV_DIR := venv
REQUIREMENTS_FILE := requerimientos.txt
PYTHON_BIN := $(APP_DIR)/$(VENV_DIR)/bin/python

# Variables de entorno inyectadas en 'run'
PORT ?= 8081
MESSAGE ?= Ejecutando desde Makefile
RELEASE ?= v1.0
APP_NAME ?= pc14app
DOMAIN   ?= pc14app.local
DNS_SERVER ?= 1.1.1.1 ## TODO servidor DNS para pruebas (dig)
TARGET_URL ?= http://localhost:8081

# Variables systemd
DESCRIPTION ?= PC1 Proyecto 4 - Flask App
USER ?= flaskuser
GROUP ?= flaskuser
EXEC_START ?=$(APP_DIR)/src/process_manager.sh start
SYSTEMD_DIR := $(APP_DIR)/systemd
SERVICE_TEMPLATE := $(SYSTEMD_DIR)/pc14app.service
SERVICE_FILE := $(APP_DIR)/out/pc14app.service

# ----------------------------------------------------
# Detección del intérprete de Python
# ----------------------------------------------------

# Busca python3 o python para crear el venv
PY_BOOT := $(shell if command -v python3 >/dev/null 2>&1; then echo "python3"; else echo "python"; fi)

# ----------------------------------------------------
# Targets para Configuración y Entorno Virtual
# ----------------------------------------------------

.PHONY: setup
setup: $(VENV_DIR) install_deps ## Crea el venv e instala todas las dependencias
	@echo "Configuración de entorno lista."

# Target para crear el entorno virtual
$(VENV_DIR):
	@echo "Creando entorno virtual en $(VENV_DIR) con $(PY_BOOT)..."
	@$(PY_BOOT) -m venv $(VENV_DIR)

.PHONY: venv-recreate
venv-recreate: ## Recrear la venv desde cero
	@rm -rf $(VENV)
	@$(MAKE) prepare

.PHONY: install_deps
install_deps:
	@echo "Instalando dependencias desde $(REQUIREMENTS_FILE)..."
	# Usamos el intérprete dentro del venv para instalar
	@$(PYTHON_BIN) -m pip install --upgrade pip > /dev/null
	@$(PYTHON_BIN) -m pip install -r $(REQUIREMENTS_FILE) > /dev/null

# ----------------------------------------------------
# Target para Correr la Aplicación
# ----------------------------------------------------

.PHONY: run
run: setup ## Ejecuta la app Flask en primer plano con variables de entorno inyectadas
	@echo "Iniciando aplicación Flask en http://127.0.0.1:$(PORT)..."
	# Inyección de variables de entorno (12-Factor Config)
	@APP_DIR=$(APP_DIR) PORT=$(PORT) MESSAGE="$(MESSAGE)" RELEASE="$(RELEASE)" src/process_manager.sh start

# ----------------------------------------------------
# Targets de Limpieza y Ayuda
# ----------------------------------------------------

.PHONY: clean
clean: ## Elimina el entorno virtual (VENV_DIR) y archivos temporales
	@echo "Limpiando el entorno virtual"
	@rm -rf $(VENV_DIR)

.PHONY: help
help: ## Muestra los targets disponibles
	@echo "Uso: make <target>"
	@grep -E '^[a-zA-Z0-9_\-]+:.*?##' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?##"}{printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ----------------------------------------------------
# Targets de pruebas curl y dig
# ----------------------------------------------------

.PHONY: test-curl test-dig test-network help
test-curl: ## Ejecuta pruebas con curl
	@./src/network_monitor.sh curl

test-dig: ## Ejecuta pruebas con dig
	@./src/network_monitor.sh dig

test-network: ## Ejecuta todas las pruebas de red
	@./src/network_monitor.sh all

# ----------------------------------------------------
# systemd
# ----------------------------------------------------

tools: ## Verifica disponibilidad de utilidades.
	@command -v $(PYTHON_BOOT) >/dev/null || { echo "[ERROR] falta $(PYTHON_BOOT)"; exit 1; }
	@command -v pip >/dev/null || { echo "[ERROR] falta pip"; exit 1; }
	@command -v bats >/dev/null || { echo "[ERROR] falta bats"; exit 1; }
	@command -v grep >/dev/null || { echo "[ERROR] falta grep"; exit 1; }
	@command -v awk >/dev/null || { echo "[ERROR] falta awk"; exit 1; }
	@command -v tar >/dev/null || { echo "[ERROR] falta tar"; exit 1; }
	@command -v sha256sum >/dev/null || { echo "[ERROR] falta sha256sum"; exit 1; }
	@command -v curl >/dev/null || { echo "[ERROR] falta curl"; exit 1; }
	@command -v git >/dev/null || { echo "[ERROR] falta git"; exit 1; }
	@command -v openssl >/dev/null || { echo "[ERROR] falta openssl"; exit 1; }
	@command -v dig >/dev/null || { echo "[ERROR] falta dig"; exit 1; }
	@command -v ss >/dev/null || { echo "[ERROR] falta ss"; exit 1; }
	@command -v xargs >/dev/null || { echo "[ERROR] falta xargs"; exit 1; }
	@command -v sed >/dev/null || { echo "[ERROR] falta sed"; exit 1; }
	@command -v tee >/dev/null || { echo "[ERROR] falta tee"; exit 1; }
	@echo "Todas las herramientas necesarias están disponibles."

systemd-install: $(SERVICE_FILE) ## Instalar el servicio con systemd
	@echo "Archivo systemd generado en $(SERVICE_FILE)"
	@echo "Instalando el servicio"
	@command -v systemctl 1>/dev/null 2>&1 || echo "[ERROR] NO systemctl"
	@sudo cp $(SERVICE_FILE) /etc/systemd/system/$(APP_NAME).service
	@sudo systemctl daemon-reload 2>/dev/null || true
	@sudo systemctl enable $(APP_NAME).service 2>/dev/null || true
	@sudo systemctl restart $(APP_NAME).service 2>/dev/null || true

.PHONY: $(SERVICE_FILE)
$(SERVICE_FILE): $(SERVICE_TEMPLATE)
	@sed \
		-e 's|{{DESCRIPTION}}|$(DESCRIPTION)|g' \
		-e 's|{{APP_DIR}}|$(APP_DIR)|g' \
		-e 's|{{EXEC_START}}|$(EXEC_START)|g' \
		-e 's|{{PYTHON_BIN}}|$(PYTHON_BIN)|g' \
		-e 's|{{PORT}}|$(PORT)|g' \
		-e 's|{{MESSAGE}}|$(MESSAGE)|g' \
		-e 's|{{RELEASE}}|$(RELEASE)|g' \
		$< > $@
