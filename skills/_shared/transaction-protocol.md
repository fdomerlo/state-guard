# Protocolo de Transacciones

## Propósito

Este protocolo define cómo cada fase SDD se ejecuta como una transacción atómica. Reemplaza el mecanismo de Return Envelope y garantiza que `state.yaml` siempre refleje el estado real del cambio.

## Ciclo de Vida de una Transacción

```text
IDLE → BEGIN → EXECUTE → COMMIT (éxito) o ROLLBACK (fallo) → IDLE
```

### BEGIN

Antes de registrar `in_progress`, debes capturar un snapshot rápido del estado del repositorio (ej. ejecutar `git status --porcelain` o generar un hash del directorio) y registrarlo transaccionalmente (o simplemente verificar que el árbol de trabajo esté limpio).

Luego, escribí en `state.yaml`:

```yaml
txn_status: in_progress
txn_phase: {fase a ejecutar}   # ej: "spec"
txn_started_at: "YYYY-MM-DDTHH:MM:SS"
```

Esto marca que hay una transacción en vuelo. Si el agente crashea durante la ejecución, el Recovery Protocol (ver `memory-guard.md`) puede detectar y resolver la transacción incompleta.

### EXECUTE

Ejecutá la fase siguiendo las instrucciones del SKILL.md correspondiente. Durante la ejecución:

- Persistí los artefactos en disco (el artefacto se escribe ANTES de actualizar state.yaml)
- NO modifiqués `current_phase`, `completed_phases`, `pending_phases` ni `lock_phase` todavía

### COMMIT (éxito)

Antes de consolidar el `state.yaml`, debes verificar que los archivos afectados en tu lote no hayan sido modificados por un factor externo desde el `txn_started_at`.
Si se detecta concurrencia, debes forzar un `ROLLBACK` y emitir una alerta "CONFLICTO DE CONCURRENCIA HUMANA DETECTADO".

Cuando la fase se completa exitosamente y sin conflictos, actualizá `state.yaml` atómicamente:

```yaml
# Actualizar en una sola escritura:
current_phase: {fase recién completada}
lock_phase: {siguiente fase en el DAG}
completed_phases:
  - ... (agregar la fase recién completada)
pending_phases:
  - ... (remover la fase recién completada)
last_updated: "YYYY-MM-DDTHH:MM:SS"
txn_status: idle
txn_phase: null
txn_started_at: null
```

**Tabla de transiciones de `lock_phase`:**

| Fase completada | `lock_phase` resultante |
|-----------------|-------------------------|
| `explore`       | `propose`               |
| `propose`       | `spec`                  |
| `spec`          | `design`                |
| `design`        | `tasks`                 |
| `tasks`         | `apply`                 |
| `apply`         | `verify`                |
| `verify`        | `archive`               |

### ROLLBACK (fallo)

Si la fase falla o no puede completarse:

```yaml
txn_status: failed
txn_phase: {fase que falló}
# NO modificar current_phase, lock_phase, completed_phases, pending_phases
# Preservar el estado anterior
```

Reportá el error al usuario con contexto suficiente para decidir si reintentar o ejecutar `/sdd-fix`.

## Regla Anti-Batching

El protocolo de transacción **es** el mecanismo de anti-batching. Cada fase requiere su propio ciclo BEGIN → COMMIT. No es posible ejecutar múltiples fases en una sola transacción porque `txn_phase` es un valor escalar, no una lista.

Esto significa que `/sdd-ff` ejecuta 4 transacciones secuenciales (propose → spec → design → tasks), cada una con su propio COMMIT. Si el agente crashea entre la transacción 2 y la 3, el Recovery Protocol continúa desde la fase 3.

## Checkpoint Automático

Después de cada COMMIT exitoso, actualizá el campo `session_summary` con un resumen compacto:

```yaml
session_summary:
  archivos_modificados:
    - ruta/al/artefacto.md
  estado_tareas: "N/A"  # o "{X}/{Y} — última: [{ID}] {desc}" si aplica
  decisiones_clave:
    - "{decisión relevante de esta fase}"
  proxima_accion: "/sdd-{siguiente} {nombre-cambio}"
```

Esto reemplaza la necesidad de invocar `/sdd-checkpoint` manualmente después de cada fase. El comando `/sdd-checkpoint` sigue disponible para generar checkpoints de alta fidelidad bajo demanda.

## Campos Transaccionales en state.yaml

Los siguientes campos se agregan al schema v2 de `state.yaml`:

| Campo | Tipo | Valores | Descripción |
|-------|------|---------|-------------|
| `schema_version` | Integer | `2` | Versión del schema (para migración) |
| `txn_status` | String | `idle` \| `in_progress` \| `failed` | Estado de la transacción actual |
| `txn_phase` | String \| null | fase o `null` | Fase en ejecución (solo cuando `txn_status: in_progress`) |
| `txn_started_at` | String \| null | ISO 8601 o `null` | Timestamp de inicio de la transacción |

**Valores por defecto (cambio nuevo):**

```yaml
schema_version: 2
txn_status: idle
txn_phase: null
txn_started_at: null
```

## Migración v1 → v2

Los `state.yaml` existentes (sin campo `schema_version`) se consideran v1. La migración es automática:

1. Agregar `schema_version: 2`
2. Agregar `txn_status: idle`, `txn_phase: null`, `txn_started_at: null`
3. Si falta `lock_phase`, inferirlo desde artefactos (lógica existente de `sdd-fix`)

La migración la ejecuta `sdd-fix` o el Recovery Protocol al encontrar un state.yaml sin `schema_version`.
