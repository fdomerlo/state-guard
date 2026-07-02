---
name: sdd-continue
description: >
  Continúa un cambio SDD desde donde se quedó
  Disparador: Cuando el usuario ejecuta /sdd-continue.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "3.0"
---

# SDD-Continue Skill

## Propósito

Meta-skill responsable de continuar un cambio SDD existente. Lee `state.ini` para determinar la siguiente fase y la ejecuta inline.

## Qué Hacer

### Paso 1: Leer state.ini y Verificar Lock

```text
1. Leer `state.ini` del cambio (o explorar .agentify/changes/ si no hay argumento)
   └─ SI no existe → STOP:
      Ejecuta /sdd-fix para migrar el estado antes de continuar.

3. Verificar coherencia del lock:
   │  Ejecuta /sdd-fix para reparar el estado antes de continuar.
   │

```

### Paso 2: Verificar Recovery de Transacción Incompleta

- Verificar si el artefacto de `txn_phase` existe en disco
- Si SÍ → ejecutar COMMIT (la fase se completó pero el estado no se persistió)

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
