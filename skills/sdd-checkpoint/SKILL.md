---
name: sdd-checkpoint
description: >
  Genera un resumen de alta fidelidad del estado del cambio activo y lo guarda en el campo
  session_summary del state.yaml. Permite recuperación rápida de sesión tras reload del IDE.
  Disparador: Cuando el usuario ejecuta /sdd-checkpoint para guardar estado, o automáticamente post-COMMIT.
license: MIT
metadata:
  author: fdomerlo-steve
  version: "3.0"
---

# SDD-Checkpoint Skill

## Propósito

Skill responsable de **generar un checkpoint de sesión de alta fidelidad**. Detecta el cambio activo, ejecuta un análisis proactivo de sus artefactos (`tasks.md`, `design.md`) y del contexto actual, y guarda un bloque YAML estructurado en el campo `session_summary` del `state.yaml`.

**Dos modos de operación:**

1. **Automático** (post-COMMIT): El protocolo de transacción genera un `session_summary` compacto después de cada COMMIT. Esto es suficiente para la mayoría de los casos.
2. **Manual** (`/sdd-checkpoint`): Genera un checkpoint de alta fidelidad con análisis proactivo de todos los artefactos. Útil antes de operaciones riesgosas o para refrescar el contexto.

**Agnosticismo de DAG**: no verifica ni modifica `lock_phase`, `current_phase`, `completed_phases` ni `pending_phases`. Opera transversalmente al DAG de fases.

## Qué Hacer

### Paso 1: Detectar Cambio Activo

Buscar `state.yaml` con `status: active` en `openspec/changes/*/state.yaml`.

### Paso 2: Leer Estado Base

Extraer de `state.yaml`: `current_phase`, `status`, `lock_phase` (solo para informar — NO modificar).

### Paso 3a: Analizar tasks.md → estado_tareas

Si existe `tasks.md`:

1. Contar total de tareas (`- [ ]` y `- [x]`)
2. Contar completadas (`- [x]`)
3. Identificar la última tarea completada

Formato: `"{X}/{Y} — última: [{ID}] {descripción breve}"`

Si no existe: `estado_tareas: "N/A"`

### Paso 3b: Extraer archivos_modificados

```text
Fuente primaria:   Tabla "### Archivos Modificados" del último resumen de sdd-apply
Fuente secundaria: Campo `archivos_modificados` del session_summary existente
Fallback:          Lista vacía []
```

Máximo 10 archivos, rutas relativas al root.

### Paso 3c: Extraer decisiones_clave del design.md

Si existe `design.md`: extraer las primeras 2 decisiones de la sección `## Decisiones de Arquitectura`, truncar a 100 chars cada una.

### Paso 3d: Construir y Guardar

Escribir **ÚNICAMENTE** `session_summary` y `last_updated` en `state.yaml`:

```yaml
session_summary:
  archivos_modificados:
    - ruta/exacta/archivo.ext
  estado_tareas: "{X}/{Y} — última: [{ID}] {texto}"
  decisiones_clave:
    - "{decisión ≤ 100 chars}"
  proxima_accion: "/sdd-{siguiente} {nombre-cambio}"
last_updated: "YYYY-MM-DDTHH:MM:SS"
```

**NO modificar ningún otro campo.** `lock_phase`, `current_phase`, `completed_phases`, `pending_phases`, `status`, `blocked`, `blocked_reason`, `started_at` y campos `txn_*` son intocables.

### Paso 4: Reportar

```markdown
## Resultado del Checkpoint

**status**: ok | error
**Cambio**: {nombre-del-cambio}
**lock_phase actual**: {valor} (no modificado)

### session_summary generado
{bloque YAML generado}
```

## Reglas

- Si no hay cambio activo, mostrar error
- Si no existe `tasks.md`, usar `estado_tareas: "N/A"`
- Siempre actualizar `last_updated` al guardar
- El bloque `session_summary` NO debe superar 500 tokens
- **AGNOSTICISMO DE LOCK**: NUNCA modifica campos del DAG
- `session_summary` y `last_updated` son la única autorización de escritura
- Mantener compatibilidad con state.yaml legacy (reemplazar formato antiguo)
