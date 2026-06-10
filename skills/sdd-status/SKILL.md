---
name: sdd-status
description: >
  Muestra el estado de todos los cambios activos del DAG mediante una tabla Markdown con emojis de semáforo.
  Disparador: Cuando el orquestador te lanza para mostrar el estado de cambios activos, o el usuario ejecuta /sdd-status.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

# SDD-Status Skill

## Propósito

Eres un sub-agente responsable de **mostrar el estado de los cambios activos** en el DAG de SDD. Lees los archivos `state.yaml` de todos los cambios y generas una tabla Markdown con emojis de semáforo.

## Qué Recibís

El orquestador te dará:

- Referencias a los archivos `state.yaml` activos

## Referencia

Consultar `skills/_shared/openspec-convention.md` para el schema de `state.yaml` (v2).

## Qué Hacer

### Paso 1: Encontrar Archivos de Estado

Busca todos los archivos `state.yaml` en el directorio `openspec/changes/`:

```text
openspec/changes/*/state.yaml
```

### Paso 2: Parsear cada State.yaml

Para cada archivo encontrado, extrae los siguientes campos:

- `change`: Nombre del cambio
- `current_phase`: Fase actual (explore, propose, spec, design, tasks, apply, verify, archive)
- `status`: Estado actual (active, done, blocked)
- `started_at`: Fecha de inicio en formato ISO 8601
- `pending_phases`: Lista de fases pendientes
- `blocked_reason`: Razón del bloqueo (si aplica)
- `txn_status`: Estado de transacción (idle, in_progress, failed)

### Paso 3: Filtrar Cambios Archivados

Ignora los cambios que tengan:

- `status: done`
- `current_phase: archive`

### Paso 4: Calcular Tiempo Transcurrido

Para cada cambio activo, calcula el tiempo desde `started_at` hasta ahora:

- Formato de salida: "Xh Ym" (horas y minutos)
- Si ha pasado menos de 1 hora, mostrar solo minutos: "30m"
- Si ha pasado más de 24 horas, mostrar "24h+"

### Paso 5: Determinar Estado con Semáforo

Aplica la lógica de semáforo:

```text
| Condición | Emoji | Significado |
|-----------|-------|-------------|
| `status == "blocked"` | 🟡 | Bloqueado |
| `status == "done"` | 🔴 | Completado (no debería aparecer) |
| `status == "active"` | 🟢 | Activo |
| `txn_status == "in_progress"` | 🔵 | Transacción en vuelo |
| `txn_status == "failed"` | 🟠 | Transacción fallida |
```

### Paso 6: Formatear Tabla Markdown

Genera una tabla con las siguientes columnas:

```text
| Cambio | Fase Actual | Tiempo Transcurrido | Estado | Txn |
|--------|-------------|---------------------|--------|-----|
| feat-auth | Apply | 2h 30m | 🟢 | idle |
```

- **Cambio**: Nombre del cambio (de `change`)
- **Fase Actual**: Current_phase con primera letra mayúscula (de `current_phase`)
- **Tiempo Transcurrido**: Formato "Xh Ym" (del cálculo)
- **Estado**: Emoji del semáforo

### Paso 7: Manejar Casos Edge

- **Sin cambios activos**: Mostrar mensaje informativo, no tabla vacía
- **Archivo corrupto**: Continuar con los demás archivos, mostrar advertencia

### Paso 8: Devolver Resultado

Devuelve la tabla Markdown con el estado de todos los cambios activos.

## Reglas

- SIEMPRE filtrar cambios con status "done" o current_phase "archive"
- Si no hay cambios activos, mostrar mensaje informativo
- Manejar gracefully archivos malformados (continuar, no fallar)
- El formato de fase debe ser legible (primera letra mayúscula)
