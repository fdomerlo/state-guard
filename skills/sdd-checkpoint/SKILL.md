---
name: sdd-checkpoint
description: >
  Genera un resumen de alta fidelidad del estado del cambio activo y lo guarda en el campo
  session_summary del state.ini. Permite recuperación rápida de sesión tras reload del IDE.
  Disparador: Cuando el usuario ejecuta /sdd-checkpoint para guardar estado, o automáticamente post-COMMIT.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "3.0"
---

# SDD-Checkpoint Skill

## Propósito

Skill responsable de **generar un checkpoint de sesión de alta fidelidad**. Detecta el cambio activo, ejecuta un análisis proactivo de sus artefactos (`tasks.md`, `design.md`) y del contexto actual, y guarda un bloque estructurado en el campo `session_summary` del `state.ini`.

**Dos modos de operación:**

2. **Manual** (`/sdd-checkpoint`): Genera un checkpoint de alta fidelidad con análisis proactivo de todos los artefactos. Útil antes de operaciones riesgosas o para refrescar el contexto.

## Qué Hacer

### Paso 1: Detectar Cambio Activo

Buscar `state.ini` con `status: active` en `.agentify/changes/*/state.ini`.

### Paso 2: Leer Estado Base

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



### Paso 4: Reportar

```markdown
## Resultado del Checkpoint

**status**: ok | error
**Cambio**: {nombre-del-cambio}

### session_summary generado
{bloque YAML generado}
```

## Reglas

- Si no hay cambio activo, mostrar error
- Si no existe `tasks.md`, usar `estado_tareas: "N/A"`
- El bloque `session_summary` NO debe superar 500 tokens
- **AGNOSTICISMO DE LOCK**: NUNCA modifica campos del DAG
