# Variable para network monitoring
TARGET_URL ?= http://localhost:8081

# Targets para pruebas de red
test-curl: ## Ejecuta pruebas con curl
	@./src/network_monitor.sh curl

test-dig: ## Ejecuta pruebas con dig
	@./src/network_monitor.sh dig

test-network: ## Ejecuta todas las pruebas de red
	@./src/network_monitor.sh all