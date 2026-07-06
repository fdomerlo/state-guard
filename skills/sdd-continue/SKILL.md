---
name: sdd-continue
description: >
  Continúa un cambio SDD desde donde se quedó
  Disparador: Cuando el usuario ejecuta /sdd-continue.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "3.1"
---

# SDD-Continue Skill

## Propósito

Meta-skill responsable de continuar un cambio SDD existente. Consulta el middleware para determinar el estado real (no lee `state.ini` directamente) y ejecuta la siguiente fase inline.

## Qué Hacer

### Paso 1: Consultar Estado

```text
Invocar: sdd_state_manager.py status --change {nombre} [--ttl {segundos}]
```

Si no hay argumento `{nombre}`, explorar `.agentify/changes/` para identificar el cambio activo antes de invocar `status`.

Si `state.ini` no existe para el cambio → STOP:
```
<<<<<<< HEAD
Ejecutá /sdd-fix para migrar el estado antes de continuar.
=======
Reportar al usuario que el estado es inconsistente/corrupto — no hay skill de reparación automática.
>>>>>>> 1cbdc21 (feat: Enhance SDD State Manager with locking mechanism and session management)
```

### Paso 2: Decidir Según `lock_state`

La lógica de decisión completa (qué hacer ante `FREE`/`ACTIVE`/`STALE`, y el criterio de recovery cuando `txn_status=in_progress`) vive en `memory-guard.md` §Recovery Protocol — no la dupliques acá. Resumen de bifurcación:

```text
lock_state == ACTIVE   → STOP, reportar conflicto al usuario (otra sesión tiene el lock).
lock_state == STALE    → aplicar Recovery Protocol de memory-guard.md antes de continuar.
lock_state == FREE
  y txn_status == idle → proceder directamente al Paso 3.
  y txn_status == in_progress
                        → esto es un estado inconsistente (lock liberado pero txn abierta).
<<<<<<< HEAD
                          Ejecutá /sdd-fix para reparar antes de continuar.
=======
                          Reportar al usuario que el estado es inconsistente/corrupto — no hay skill de reparación automática.
>>>>>>> 1cbdc21 (feat: Enhance SDD State Manager with locking mechanism and session management)
```

### Paso 3: Ejecutar Siguiente Fase

Usar `lock_phase` (devuelto por `status`) para determinar qué skill invocar:

| lock_phase  | Skill a ejecutar |
|-------------|-------------------|
| `explore`   | sdd-explore       |
| `propose`   | sdd-propose        |
| `spec`      | sdd-spec           |
| `design`    | sdd-design         |
| `tasks`     | sdd-tasks          |
| `apply`     | sdd-apply          |
| `verify`    | sdd-verify         |
| `archive`   | sdd-archive        |

La transacción (BEGIN/COMMIT/ROLLBACK) la maneja la propia skill invocada, según `transaction-protocol.md`. `sdd-continue` no toma el lock de fase directamente — delega esa responsabilidad a la skill de la fase correspondiente.
