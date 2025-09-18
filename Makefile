# Makefile
# Gestor de Entorno y Ejecución para la Aplicación Flask

# ----------------------------------------------------
# Variables de Configuración (12-Factor App)
# Las variables con '?' permiten sobreescribirlas desde la línea de comandos (ej: make run PORT=9000)
# ----------------------------------------------------
VENV_DIR := .venv
REQUIREMENTS_FILE := requerimientos.txt
PYTHON_BIN := $(VENV_DIR)/bin/python

# Variables de entorno inyectadas en 'run'
PORT ?= 8081
MESSAGE ?= Ejecutando desde Makefile
RELEASE ?= v1.0

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

.PHONY: install_deps
install_deps:
	@echo "Instalando dependencias desde $(REQUIREMENTS_FILE)..."
	# Usamos el intérprete dentro del venv para instalar
	@$(PYTHON_BIN) -m pip install --upgrade pip > /dev/null 2>&1
	@$(PYTHON_BIN) -m pip install -r $(REQUIREMENTS_FILE)

# ----------------------------------------------------
# Target para Correr la Aplicación
# ----------------------------------------------------

.PHONY: run
run: setup ## Ejecuta la app Flask en primer plano con variables de entorno inyectadas
	@echo "Iniciando aplicación Flask en http://127.0.0.1:$(PORT)..."
	# Inyección de variables de entorno (12-Factor Config)
	@PORT=$(PORT) MESSAGE="$(MESSAGE)" RELEASE="$(RELEASE)" $(PYTHON_BIN) src/app.py

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