# Protocolo de Transacciones ACID (Middleware CLI)

## Propósito

Este protocolo define cómo interactúas con el Estado del Sistema.

**REGLA DE ORO PROHIBITIVA:** Tienes ESTRICTAMENTE PROHIBIDO editar el archivo `state.ini` usando herramientas de edición de texto (como `edit_file` o `write_file`). Cualquier intento de hacerlo corromperá el Directed Acyclic Graph (DAG) y causará un fallo crítico. **Esto incluye el campo `session_summary`** — incluso para un checkpoint que no toca el DAG, la escritura pasa siempre por el middleware.

El estado es inmutable de forma manual. **DEBES** invocar el middleware de base de datos usando tu herramienta de ejecución de comandos.

Internamente, cada subcomando que escribe (`begin`, `commit`, `rollback`, `checkpoint`) serializa su escritura mediante un write-lock de archivo de vida corta. No necesitás saber esto para operarlo — está para que dos operaciones concurrentes (por ejemplo un `commit` y un `checkpoint` disparados casi al mismo tiempo) no se pisen entre sí.

## Ciclo de Vida de una Transacción

### 1. BEGIN (Bloqueo de Fase)

Antes de empezar el trabajo analítico o de código de cualquier fase, registra la transacción invocando el middleware en tu terminal:

**Comando:** `mmx_state_manager.py begin --change {nombre-del-cambio} --phase {fase-actual} [--ttl {segundos}]`

*Espera a que el script devuelva `SUCCESS|BEGIN` antes de continuar.*

Si devuelve `ERROR: Ya hay una transacción en progreso`, significa que otra sesión tiene el lock de fase activo. No reintentes automáticamente — reportá el conflicto al usuario. `--ttl` (default 1800s) define cuándo un lock se considera abandonado (crash de sesión) y puede ser retomado.

### 2. EXECUTE (Desarrollo)

Ejecuta los objetivos de la fase actual usando tus herramientas normales (leer, escribir código, crear archivos de diseño, etc.).

### 3. COMMIT (Liberación y Avance)

Cuando hayas terminado todos los entregables de la fase, avanza el grafo metodológico:

**Comando:** `mmx_state_manager.py commit --change {nombre-del-cambio} --next-phase {siguiente-fase-segun-orden-logico}`

El middleware valida la transición contra la tabla del DAG (ver `mmx-convention.md`). Si `--next-phase` no es la fase permitida desde `txn_phase`, el comando falla con `ERROR: Transición inválida` — **este es un rechazo del código, no una convención que dependa de que vos calcules bien la siguiente fase.** Si falla, no reintentes con otro valor arbitrario: leé el mensaje, que indica cuál es la única fase válida.

### 4. ROLLBACK (Cancelación de Transacción)

Si una transacción en progreso no puede completarse (error irrecuperable, cambio de alcance, cancelación explícita del usuario), revertila en lugar de dejarla colgada:

**Comando:** `mmx_state_manager.py rollback --change {nombre-del-cambio}`

Restaura `txn_status` a `idle` y libera el lock de fase. No modifica `completed_phases`, `pending_phases` ni `lock_phase` — la transacción simplemente nunca ocurrió a efectos del DAG.

## Operaciones Fuera del DAG

### CHECKPOINT (Snapshot de Sesión)

Guarda un resumen de alta fidelidad en `session_summary`, sin tocar el estado del DAG:

**Comando:** `mmx_state_manager.py checkpoint --change {nombre-del-cambio} --summary "{bloque generado}"`

Puede ejecutarse en cualquier momento, incluso con una transacción de fase en progreso — no compite por el lock de fase (`.lock`), solo por el write-lock interno de escritura al archivo.

### STATUS (Lectura de Diagnóstico)

Lectura machine-readable del estado actual, usada por `mmx-continue` y por el Recovery Protocol:

**Comando:** `mmx_state_manager.py status --change {nombre-del-cambio} [--ttl {segundos}]`

Devuelve `txn_status`, `txn_phase`, `lock_phase`, y `lock_state` (`FREE`, `ACTIVE`, o `STALE`). No modifica nada — es seguro invocarlo en cualquier momento para decidir el siguiente paso.
