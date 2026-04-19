---
name: sdd-checkpoint
description: >
  Genera un resumen del estado del cambio activo y lo guarda en el campo session_summary
  del state.yaml. Permite recuperación rápida de sesión tras reload del IDE.
  Disparador: Cuando el usuario ejecuta /sdd-checkpoint para guardar estado.
license: MIT
metadata:
  author: ctrbts-steve
  version: "1.0"
---

## Propósito

Eres un sub-agente responsable de **generar un checkpoint de sesión** para el orquestador SDD. Detectás el cambio activo, leés su estado actual, generás un resumen de hasta 5 líneas y lo guardás en el campo `session_summary` del `state.yaml`.

## Qué Recibís

El orquestador te dará:

- La ruta al directorio de cambios activos

## Execution and Persistence Contract


- Lee las convenciones base referenciadas en `skills/_shared/execution-contract.md` antes de proceder.


## Qué Hacer

### Paso 1: Detectar Cambio Activo

Buscá el archivo `state.yaml` con `status: active` en el directorio:

```
openspec/changes/*/state.yaml
```

Si no existe ningún cambio activo, devolvé un error indicando que no hay cambio activo.

### Paso 2: Leer Estado del Cambio

Leé el archivo `state.yaml` del cambio activo y extraé:

- `current_phase`: fase actual del cambio
- `status`: estado actual (active | blocked | done)
- `completed_phases`: lista de fases completadas
- `pending_phases`: lista de fases pendientes

### Paso 3: Calcular Progreso de Tareas

Si existe el archivo `tasks.md` en la carpeta del cambio, leé el contenido y contá:

- Total de tareas
- Tareas completadas (marcadas con `- [x]`)

### Paso 4: Generar Resumen de 5 Líneas

Construí el resumen con el siguiente formato:

```
- Fase actual: {current_phase}
- Estado: {status}
- Progreso: {X/Y tareas completadas}
- Última acción: {breve descripción}
- next_recommended: /sdd-{siguiente comando}
```

**Reglas del resumen:**
- Máximo 5 líneas
- Usar valores del state.yaml
- `next_recommended` sugiere el siguiente comando según la fase actual:
  - Si fase = `propose` → `/sdd-spec`
  - Si fase = `spec` → `/sdd-design`
  - Si fase = `design` → `/sdd-tasks`
  - Si fase = `tasks` → `/sdd-apply`
  - Si fase = `apply` → `/sdd-verify`
  - Si fase = `verify` → `/sdd-archive`

### Paso 5: Guardar Resumen en state.yaml

Escribí el resumen en el campo `session_summary` del `state.yaml`:

```yaml
session_summary: |
  - Fase actual: {current_phase}
  - Estado: {status}
  - Progreso: {X/Y tareas completadas}
  - Última acción: {breve descripción}
  - next_recommended: /sdd-{siguiente comando}
```

Actualizá también el campo `last_updated` a la fecha/hora actual en formato ISO 8601.

### Paso 6: Devolver Resultado

Devolvé el resultado en el formato:

```markdown
## Resultado del Checkpoint

**status**: ok | error

### session_summary
```
{resumen generadp}
```

### next_recommended
/sdd-{siguiente comando}

### detailed_report
- Cambio: {nombre del cambio}
- Fase: {current_phase}
- Tareas: {X}/{Y} completadas
- Ubicación: openspec/changes/{nombre}/state.yaml
```

## Reglas

- El resumen debe ser exactamente 5 líneas máximo
- Si no hay cambio activo, mostrar error "No hay cambio activo"
- Si no existe `tasks.md`, usar "N/A" para progreso
- Siempre actualizar `last_updated` al guardar el resumen
- Mantener compatibilidad hacia atrás con state.yaml existentes (campo opcional)
