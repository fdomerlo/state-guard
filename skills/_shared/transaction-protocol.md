# Protocolo de Transacciones ACID (Middleware CLI)

## Propósito

Este protocolo define cómo interactúas con el Estado del Sistema.

**REGLA DE ORO PROHIBITIVA:** Tienes ESTRICTAMENTE PROHIBIDO editar el archivo `state.ini` usando herramientas de edición de texto (como `edit_file` o `write_file`). Cualquier intento de hacerlo corromperá el Directed Acyclic Graph (DAG) y causará un fallo crítico.

El estado es inmutable de forma manual. **DEBES** invocar el middleware de base de datos usando tu herramienta de ejecución de comandos de terminal (Bash).

## Ciclo de Vida de una Transacción

### 1. BEGIN (Bloqueo de Estado)
Antes de empezar el trabajo analítico o de código de cualquier fase, registra la transacción en el sistema ejecutando:

```bash
python3 scripts/sdd_state_manager.py begin --change {nombre-del-cambio} --phase {fase-actual}

```

*Espera a que el script devuelva `SUCCESS|BEGIN` antes de continuar.*

### 2. EXECUTE (Desarrollo)

Ejecuta los objetivos de la fase actual usando tus herramientas normales (leer, escribir código, crear archivos de diseño, etc.).

### 3. COMMIT (Liberación y Avance)

Cuando hayas terminado todos los entregables de la fase, avanza el grafo metodológico ejecutando:

```bash
python3 scripts/sdd_state_manager.py commit --change {nombre-del-cambio} --next-phase {siguiente-fase-segun-orden-logico}

```