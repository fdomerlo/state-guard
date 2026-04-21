---
name: sdd-checkpoint
description: >
  Genera un resumen de alta fidelidad del estado del cambio activo y lo guarda en el campo
  session_summary del state.yaml. Permite recuperación rápida de sesión tras reload del IDE.
  Disparador: Cuando el usuario ejecuta /sdd-checkpoint para guardar estado.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

## Propósito

Eres un sub-agente responsable de **generar un checkpoint de sesión de alta fidelidad** para
el orquestador SDD. Detectás el cambio activo, ejecutás un análisis proactivo de sus
artefactos (`tasks.md`, `design.md`) y del contexto de sesión actual, y guardás un bloque
YAML estructurado en el campo `session_summary` del `state.yaml`.

**Sos agnóstico al DAG de fases**: no verificás ni modificás `lock_phase`, `current_phase`,
`completed_phases` ni `pending_phases`. Tu única autorización de escritura en `state.yaml`
es el campo `session_summary` y el campo `last_updated`.

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

### Paso 2: Leer Estado Base del state.yaml

Leé el archivo `state.yaml` del cambio activo y extraé:

- `current_phase`: fase actual del cambio
- `status`: estado actual (active | blocked | done)
- `lock_phase`: valor actual (solo para informarlo en el resultado — NO modificar)

### Paso 3a: Analizar tasks.md → estado_tareas

Si existe el archivo `tasks.md` en la carpeta del cambio:

1. Contá el total de tareas (líneas que contienen `- [ ]` o `- [x]`)
2. Contá las tareas completadas (líneas con `- [x]`)
3. Identificá la **última** tarea completada: la última línea `- [x]` en el archivo, extrayendo:
   - Su ID (formato `N.N` si existe al inicio de la descripción)
   - Su descripción breve (primeras 60 caracteres de la descripción)

Construí `estado_tareas` con el formato estricto:
```
"{X}/{Y} — última: [{ID}] {descripción breve}"
# Ejemplo: "4/16 — última: [2.1] Modificar sdd-ff/SKILL.md — agregar guard"
```

Si no existe `tasks.md`:
```
estado_tareas: "N/A"
```

Si existen tareas pero ninguna completada:
```
estado_tareas: "0/{Y} — sin tareas completadas"
```

### Paso 3b: Extraer archivos_modificados del contexto de sesión

Buscá en el contexto de sesión activo (mensajes recientes del orquestador) el resumen de
retorno más reciente de `sdd-apply`. Si existe, extraé las rutas de la tabla
`### Archivos Modificados`.

```
Fuente primaria:   Tabla "### Archivos Modificados" del último resumen de sdd-apply
Fuente secundaria: Campo `archivos_modificados` del session_summary existente en state.yaml
Fallback:          Lista vacía []
```

**Reglas:**
- Usar solo rutas relativas al root del proyecto (sin `./` al inicio)
- Si hay más de 10 archivos, listar solo los últimos 10

### Paso 3c: Extraer decisiones_clave del design.md

Si existe `design.md` en la carpeta del cambio:

1. Buscá la sección `## Decisiones de Arquitectura`
2. Extraé las primeras 2 subsecciones o ítems de decisión listados
3. Truncá cada decisión a 100 caracteres máximo

Si no existe `design.md`:
```
decisiones_clave:
  - "Ver design.md cuando esté disponible"
```

### Paso 3d: Construir bloque YAML estructurado

Con los datos de los pasos 3a, 3b y 3c, construí el bloque YAML:

```yaml
session_summary:
  archivos_modificados:
    - ruta/exacta/archivo1.ext
    - ruta/exacta/archivo2.ext
  estado_tareas: "{X}/{Y} — última: [{ID}] {descripción breve}"
  decisiones_clave:
    - "{decisión 1 ≤ 100 chars}"
    - "{decisión 2 ≤ 100 chars}"
  proxima_accion: "/sdd-{siguiente-comando} {nombre-del-cambio}"
```

**Derivar `proxima_accion`** desde `lock_phase` del state.yaml:
- `lock_phase = spec`     → `/sdd-spec {cambio}` (o `/sdd-ff {cambio}`)
- `lock_phase = design`   → `/sdd-design {cambio}` (o `/sdd-ff {cambio}`)
- `lock_phase = tasks`    → `/sdd-tasks {cambio}` (o `/sdd-ff {cambio}`)
- `lock_phase = apply`    → `/sdd-apply {cambio}`
- `lock_phase = verify`   → `/sdd-verify {cambio}`
- `lock_phase = archive`  → `/sdd-archive {cambio}`

**Límite total: 500 tokens (~375 palabras).** Aplicar truncamientos si se excede.

### Paso 4: Guardar Resumen en state.yaml

Escribí **ÚNICAMENTE** los siguientes campos en el `state.yaml`:

```yaml
session_summary:
  archivos_modificados: [...]
  estado_tareas: "..."
  decisiones_clave: [...]
  proxima_accion: "..."
last_updated: "YYYY-MM-DDTHH:MM:SS±HH:MM"  # timestamp ISO 8601 actual
```

**NO modificar ningún otro campo.** `lock_phase`, `current_phase`, `completed_phases`,
`pending_phases`, `status`, `blocked`, `blocked_reason` y `started_at` son intocables.

### Paso 5: Devolver Resultado

Devolvé el resultado en el formato:

```markdown
## Resultado del Checkpoint

**status**: ok | error
**Cambio**: {nombre-del-cambio}
**lock_phase actual**: {valor} (no modificado)

### session_summary generado

```yaml
session_summary:
  archivos_modificados:
    - {rutas}
  estado_tareas: "{X}/{Y} — última: [{ID}] {texto}"
  decisiones_clave:
    - "{decisión}"
  proxima_accion: "{comando}"
```

### detailed_report
- Tareas analizadas: {X}/{Y} completadas
- Archivos extraídos desde: {fuente primaria | fallback}
- Decisiones extraídas desde: {design.md | fallback}
- Ubicación: openspec/changes/{nombre}/state.yaml
```

## Reglas

- Si no hay cambio activo, mostrar error "No hay cambio activo"
- Si no existe `tasks.md`, usar `estado_tareas: "N/A"`
- Siempre actualizar `last_updated` al guardar el resumen
- El bloque `session_summary` NO debe superar 500 tokens — aplicar truncamientos si es necesario
- **AGNOSTICISMO DE LOCK**: `sdd-checkpoint` NUNCA lee para validar, verifica ni modifica
  `lock_phase`, `current_phase`, `completed_phases` ni `pending_phases`. Opera
  transversalmente al DAG de fases sin requerir ni alterar el estado de avance.
- Los campos `session_summary` y `last_updated` son la única autorización de escritura
  en `state.yaml` de esta skill (ver `persistence-contract.md`)
- Mantener compatibilidad con state.yaml que tengan `session_summary` en formato legacy
  (texto plano) — reemplazarlo con el nuevo formato estructurado

