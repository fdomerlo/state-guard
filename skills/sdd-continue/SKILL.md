---
name: sdd-continue
description: >
  Continúa un cambio SDD desde donde se quedó
  Disparador: Cuando el usuario ejecuta /sdd-continue.
license: MIT
metadata:
  author: ctrbts-steve
  version: "3.0"
---

# SDD-Continue Skill

## Propósito

Meta-skill responsable de continuar un cambio SDD existente. Lee `state.yaml` para determinar la siguiente fase y la ejecuta inline.

## Qué Hacer

### Paso 1: Leer state.yaml y Verificar Lock

```text
1. Leer `state.yaml` del cambio (o explorar openspec/changes/ si no hay argumento)
2. Verificar que existe el campo `lock_phase`:
   └─ SI no existe → STOP:
      ERROR: Campo `lock_phase` ausente en state.yaml.
      Ejecuta /sdd-fix para migrar el estado antes de continuar.

3. Verificar coherencia del lock:
   ├─ SI `lock_phase` está en `completed_phases` → STOP:
   │  ERROR: lock_phase inconsistente — la fase '{lock_phase}' ya figura en completed_phases.
   │  Ejecuta /sdd-fix para reparar el estado antes de continuar.
   │
   └─ SI `lock_phase` es válido y no está completada → PROCEDER

4. La fase a ejecutar ES lock_phase (no inferir desde current_phase ni pending_phases)
```

### Paso 2: Verificar Recovery de Transacción Incompleta

Si `txn_status` es `in_progress`:
- Verificar si el artefacto de `txn_phase` existe en disco
- Si SÍ → ejecutar COMMIT (la fase se completó pero el estado no se persistió)
- Si NO → ejecutar ROLLBACK y continuar con `lock_phase`

Si `txn_status` es `failed`:
- Limpiar a `txn_status: idle` y continuar con `lock_phase`

### Paso 3: Ejecutar la Fase Indicada por lock_phase

Cargá el SKILL.md correspondiente al valor de `lock_phase` y ejecutá inline:

| `lock_phase` | Skill a cargar |
|-------------|----------------|
| `explore`   | sdd-explore    |
| `propose`   | sdd-propose    |
| `spec`      | sdd-spec       |
| `design`    | sdd-design     |
| `tasks`     | sdd-tasks      |
| `apply`     | sdd-apply      |
| `verify`    | sdd-verify     |
| `archive`   | sdd-archive    |

La transacción (BEGIN/COMMIT/ROLLBACK) la maneja la propia skill según el protocolo.
