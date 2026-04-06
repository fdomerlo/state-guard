---
name: sdd-status
description: >
  Muestra el estado de todos los cambios activos del DAG mediante una tabla Markdown con emojis de semáforo.
  Disparador: Cuando el orquestador te lanza para mostrar el estado de cambios activos, o el usuario ejecuta /sdd-status.
license: MIT
metadata:
  author: ctrbts-steve
  version: "1.0"
---

## Propósito

Eres un sub-agente responsable de **mostrar el estado de los cambios activos** en el DAG de SDD. Lees los archivos `state.yaml` de todos los cambios y generas una tabla Markdown con emojis de semáforo.

## Qué Recibís

El orquestador te dará:

- El modo de almacenamiento de artefactos: `openspec`

## Execution and Persistence Contract

Utiliza únicamente las rutas y el contexto que el orquestador te provea directamente.

- Lee los archivos `state.yaml` de manera masiva provistos en tu contexto y genera la tabla de estado.

## Qué Hacer

### Paso 1: Encontrar Archivos de Estado

Busca todos los archivos `state.yaml` en el directorio `openspec/changes/`:

```
openspec/changes/*/state.yaml
```

### Paso 2: Parsear cada State.yaml

Para cada archivo encontrado, extrae los siguientes campos:

- `change`: Nombre del cambio
- `current_phase`: Fase actual (explore, propose, spec, design, tasks, apply, verify, archive, done, blocked)
- `started_at`: Fecha de inicio en formato ISO 8601
- `pending_phases`: Lista de fases pendientes
- `blocked_reason`: Razón del bloqueo (si aplica)

### Paso 3: Filtrar Cambios Archivados

Ignora los cambios que tengan:

- `current_phase: done`
- `current_phase: archive`

### Paso 4: Calcular Tiempo Transcurrido

Para cada cambio activo, calcula el tiempo desde `started_at` hasta ahora:

- Formato de salida: "Xh Ym" (horas y minutos)
- Si ha pasado menos de 1 hora, mostrar solo minutos: "30m"
- Si ha pasado más de 24 horas, mostrar "24h+"

### Paso 5: Determinar Estado con Semáforo

Aplica la lógica de semáforo:

| Condición | Emoji | Significado |
|-----------|-------|-------------|
| `current_phase == "blocked"` | 🟡 | Bloqueado |
| `current_phase == "done"` | 🔴 | Completado (no debería aparecer) |
| `pending_phases` no está vacío Y `current_phase != "blocked"` | 🟢 | Activo |

### Paso 6: Formatear Tabla Markdown

Genera una tabla con las siguientes columnas:

```
| Cambio | Fase Actual | Tiempo Transcurrido | Estado |
|--------|-------------|---------------------|--------|
| feat-auth | Apply | 2h 30m | 🟢 |
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

- SIEMPRE filtrar cambios con current_phase "done" o "archive"
- Si no hay cambios activos, mostrar mensaje informativo
- Manejar gracefully archivos malformados (continuar, no fallar)
- El formato de fase debe ser legible (primera letra mayúscula)
