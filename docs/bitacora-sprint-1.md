# Proyecto 4: Gestor de procesos seguros con enfoque en redes

## Sprint 1

- **Jesus Diego Santa Cruz Basilio**

    - Configuración inicial
        ```bash
        make setup  # Crear entorno virtual e instalar dependencias
        ```

    - Ejecución de la aplicación
        ```bash
        make run  # Ejecutar todo
        ```
    
    - Gestión del entorno
        ```bash
        make help       # Ver todos los comandos disponibles
        make clean      # Limpiar entorno virtual
        make tools      # Verificar herramientas del sistema
        ```

    - Uso directo del process manager
        ```bash
        ./src/process_manager.sh start      # Iniciar servicio directamente
        ```

- **Jesus Diego Osorio Tello**

    - Hacemos ejecutable nuestros scripts.
        ```bash
        chmod +x src/network_monitor.sh
        chmod +x src/gestor.sh
        ```
    - Probamos `network_monitor` directamente
        ```bash
        ./src/network_monitor.sh curl # Ejecuta solo test curl
        ./src/network_monitor.sh dig  # Ejecuta solo test dig
        ./src/network_monitor.sh all  # Ejecuta ambos test
        ```
    - Probamos `gestor`
        ```bash
        ./src/gestor.sh check       # Verifica conectividad
        ./src/gestor.sh monitor     # Monitoreo completo
        ```
    - Mediante targets de `Makefile`
        ```bash
        make test-curl           # Muestra pruebas con CURL
        make test-dig            # Muestra pruebas con DIG
        make test-network        # Ejecuta ambas pruebas
        ```
- **Fernando Mora Evangelista**

    - `make tools`: Verifica la disponibilidad de las utilidades requeridas por el proyecto (ej. `python3`, `pip`, `systemctl`). Si falta alguna, muestra un mensaje de error y termina con código de salida 1.
    - `make systemd-install`: Construye el unit file `out/pc14app.service` a partir de la plantilla `systemd/pc14app.service`. Sustituye los placeholders (`{{VAR}}`) por las variables definidas en el `Makefile`. Requiere ejecutar previamente `make setup`.