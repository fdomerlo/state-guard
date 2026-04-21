---
name: sdd-continue
description: >
  Continúa un cambio SDD desde donde se quedó
  Disparador: Cuando el usuario ejecuta /sdd-continue.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.1"
---

## Propósito

Eres una meta-skill responsable de continuar un cambio SDD existente.
Como orquestador, debes leer `openspec/changes/{nombre-del-cambio}/state.yaml` (o explorar
el directorio si no se provee argumento) para determinar el estado actual y delegar la
siguiente fase al sub-agente correspondiente.

## Paso 1: Leer state.yaml y Verificar Lock

Antes de determinar qué fase ejecutar, DEBES:

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

## Paso 2: Delegar la Fase Indicada por lock_phase

Delega inmediatamente a la skill correspondiente al valor de `lock_phase`:

| `lock_phase` | Skill a invocar |
|-------------|-----------------|
| `spec`      | sdd-spec        |
| `design`    | sdd-design      |
| `tasks`     | sdd-tasks       |
| `apply`     | sdd-apply       |
| `verify`    | sdd-verify      |
| `archive`   | sdd-archive     |

## Paso 3: Actualizar state.yaml tras la Delegación

Tras completar el sub-agente, extraer `lock_phase_next` del resumen de retorno y actualizar
`state.yaml`:

```text
1. Leer sección `### Lock Phase` del resumen del sub-agente
2. Extraer `lock_phase_next`
3. SI es válido: actualizar current_phase, lock_phase, completed_phases, last_updated
4. SI no viene `lock_phase_next` (fallo del sub-agente): preservar lock_phase actual sin cambios
```

## Execution and Persistence Contract

- Lee las convenciones base referenciadas en `skills/_shared/execution-contract.md` antes de proceder.
