# Proyecto 4: Gestor de procesos seguros con enfoque en redes

## Sprint 2

- **feature/DiegoOsorio-Redes**

    - Prueba google.com, example.com y servicio local
    ```bash
    make test-nc ## Pruebas de conectividad con netcat
    ```

    - Análisis certificados Google y Example.com
    ```bash
    make test-ssl ## Análisis TLS/SSL con openssl
    ```

    - Análisis completo de puertos del sistema
    ```bash
    make test-ports ## Verificación de puertos con ss
    ```

    - Análisis completo HTTP vs HTTPS
    ```bash
    make compare-protocols ## Comparación HTTP vs HTTPS con Google
    ```

    ```bash
    make compare-example ## Comparación HTTP vs HTTPS con Example.com
    ```

    - Flujo completo de todas las funciones
    ```bash
    make demo-complete ## Demo completo de todas las funcionalidades
    ```

    - Flujo principal
    ```bash
    make all ## Flujo principal del proyecto
    ```

    
- **feature/Mora-bats**

    - Para correr los tests con **Bats**: 

    ```bash
    make test-bats
    ```

    - También se pueden ejecutar manualmente desde el directorio raíz del proyecto:
    ```bash
    bats tests/
    ```
