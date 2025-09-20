# Proyecto 4: Gestor de procesos seguros con enfoque en redes

## Sprint 1

### Variables de configuración del Makefile

| Variable       | Valor por defecto            | Efecto observable |
|----------------|------------------------------|-------------------|
| `PORT`         | `8081`                       | Puerto en el que Flask expone la aplicación. |
| `MESSAGE`      | `"Ejecutando desde Makefile"`| Texto que se devuelve en la respuesta JSON de la API y aparece en logs. |
| `RELEASE`      | `v1.0`                       | Versión de la app, visible en logs y respuestas de la API. |
| `APP_NAME`     | `pc14app`                    | Nombre lógico del servicio (unit file en systemd se llamará `pc14app.service`). |
| `DOMAIN`       | `pc14app.local`              | Dominio usado para pruebas locales de red. |
| `DNS_SERVER`   | `1.1.1.1`                    | Servidor DNS que se usará en pruebas con `dig`. |
| `TARGET_URL`   | `http://localhost:8081`      | URL usada en pruebas con `curl`. |
| `DESCRIPTION`  | `"PC1 Proyecto 4 - Flask App"` | Texto descriptivo que aparece en el unit file de systemd. |
| `EXEC_START`   | `$(APP_DIR)/src/process_manager.sh start` | Comando que arranca el proceso principal desde systemd. |
| `PY_BOOT`      | `python3` ó `python` (auto-detectado) | Intérprete usado para crear el entorno virtual. |

- **feature/JesusStC**

    1. app.py

        - Funcionalidad: API REST con endpoint `/` que retorna información del sistema
        - Configuración: Variables de entorno (PORT, MESSAGE, RELEASE)
        - Logging: Salida estructurada a stdout

    2. src/process_manager.sh - Script bash para manejar el ciclo de vida de la aplicación

        - Funcionalidad: Inicia, detiene y consulta estado del servicio
        - Logging: Registra salida en archivos de log
        - Variables: Configurable via variables de entorno

    3. Makefile - Automatización y Gestión del Proyecto

        - Gestión de entorno virtual
        - Instalación de dependencias
        - Ejecución de la aplicación

- **feature/Diego-Osorio**

    1. src/network_monitor.sh - Script principal con pruebas HTTP y DNS

        - Función test_curl(): Pruebas con curl, códigos HTTP, headers
        - Función test_dig(): Resolución DNS local y con servidor específico

    2. src/gestor.sh - Integrador que usa network_monitor.sh

        - Función check_service(): Verificación integral de conectividad
        - Función monitor(): Monitoreo completo HTTP + DNS

    3. Modificaciones al Makefile

        - Targets: test-curl, test-dig, test-network
        - .PHONY declarado correctamente  

- **feature/Mora-systemd**  
    En este sprint se definió el target `systemd-install`, el cual genera un servicio de `systemd` que utiliza `src/process_manager.sh start`. Ambos componentes leen las variables de entorno definidas en el `Makefile`, aplicando la práctica de **configuración por entorno** del modelo **12-Factor App**.

## Sprint 2

- **feature/DiegoOsorio-Redes**
    1. src/process_manager.sh - Se agregan pruebas avanzadas, como:
        - check_ports_ss() - Análisis Avanzado de Puertos
        - test_http_nc() - HTTP Raw con Netcat
        - test_connectivity_nc() - Verificación de Conectividad
        - analyze_tls_openssl() - Análisis TLS/SSL Seguro
        - setup_hosts() - Configuración DNS Local
        - compare_http_https() - Comparación Completa de Protocolos
        - check_pc14app_service() - Verificación Servicio Local

    2. Makefile - Automatización y Gestión del Proyecto

        - Agrega targets que ejecutan las nuevas funciones de `network_monitor.sh`.

- **feature/Mora-bats**

  1. `test_all.bats`  
     - Manejo de señales  
     - Manejo de scripts `.sh`:  
       - Finaliza con código **1** cuando un argumento no está definido  
       - Muestra el mensaje de uso cuando el argumento no es válido  
       - Verifica que el servicio se ejecute correctamente  

  2. Target `test-bats` en el **Makefile**  
     - Ejecuta los tests definidos en el archivo  
     - Pasa como variable de entorno el directorio de trabajo  
     - Crea un servicio temporal para las pruebas  