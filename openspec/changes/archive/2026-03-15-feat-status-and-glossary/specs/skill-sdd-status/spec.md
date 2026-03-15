# Especificación de skill-sdd-status

## Propósito

Esta especificación define el comportamiento de la nueva skill `sdd-status`, cuyo propósito es proporcionar visibilidad del estado de todos los cambios activos en el DAG de SDD mediante una tabla Markdown legible.

## Requisitos

### Requisito: Lectura de Archivos de Estado

La skill DEBE leer todos los archivos `state.yaml` ubicados en el directorio `openspec/changes/` del proyecto.

- GIVEN que existen archivos `state.yaml` en el directorio de cambios
- WHEN la skill `sdd-status` es invocada
- THEN DEBE leer el contenido de cada archivo `state.yaml` encontrado
- AND DEBE extraer los campos: `change`, `phase`, `started_at`, `pending_phases`, `blocked_reason`

### Requisito: Filtrado de Cambios Archivados

La skill DEBE ignorar los cambios que se encuentren en fase "archive" o "done".

- GIVEN que existe un cambio con `phase: archive` en su `state.yaml`
- WHEN la skill procesa los cambios
- THEN NO DEBE incluir este cambio en la tabla de salida

- GIVEN que existe un cambio con `phase: done` en su `state.yaml`
- WHEN la skill procesa los cambios
- THEN NO DEBE incluir este cambio en la tabla de salida

### Requisito: Cálculo de Tiempo Transcurrido

La skill DEBE calcular el tiempo transcurrido desde el campo `started_at` (formato ISO 8601) hasta el momento actual.

- GIVEN un cambio con `started_at: "2026-03-14T10:00:00"` y hora actual "2026-03-14T12:30:00"
- WHEN la skill calcula el tiempo transcurrido
- THEN DEBE mostrar "2h 30m" (o formato equivalente legible)

- GIVEN un cambio con `started_at` en formato ISO 8601 válido
- WHEN la skill procesa el campo
- THEN DEBE convertir el tiempo a un formato legible para humanos
- AND DEBE manejar correctamente diferencias de días, horas y minutos

### Requisito: Determinación de Estado con Semáforo

La skill DEBE mostrar emojis de semáforo para indicar el estado de cada cambio según las siguientes reglas:

- 🟢 **Activo**: `phase != "blocked"` Y `pending_phases` no está vacío
- 🟡 **Bloqueado**: `phase == "blocked"`
- 🔴 **Completado**: `phase == "done"`

- GIVEN un cambio con `phase: "tasks"` y `pending_phases: ["apply", "verify", "archive"]`
- WHEN la skill determina el estado
- THEN DEBE mostrar el emoji 🟢 (activo)

- GIVEN un cambio con `phase: "blocked"` y `blocked_reason: "Esperando decisión del usuario"`
- WHEN la skill determina el estado
- THEN DEBE mostrar el emoji 🟡 (bloqueado)

- GIVEN un cambio con `phase: "done"` y sin `pending_phases`
- WHEN la skill determina el estado
- THEN DEBE mostrar el emoji 🔴 (completado)

### Requisito: Formato de Salida Markdown

La skill DEBE formatear la salida como una tabla Markdown con las siguientes columnas:

| Cambio | Fase Actual | Tiempo Transcurrido | Estado |

- GIVEN que la skill tiene datos de múltiples cambios procesables
- WHEN genera la salida
- THEN DEBE producir una tabla Markdown válida con encabezados y filas
- AND las columnas DEBEN estar alineadas correctamente

### Requisito: Manejo de Caso Sin Cambios Activos

La skill DEBE manejar el caso donde no existan cambios activos (o todos estén archivados/completados).

- GIVEN que no existen archivos `state.yaml` con cambios activos
- WHEN la skill es invocada
- THEN DEBE mostrar un mensaje indicando que no hay cambios activos
- AND NO DEBE generar una tabla vacía

### Requisito: Integración con Orquestador

La skill DEBE estar registrada en `orchestrator-core.md` para que el orquestador pueda delegar el comando `/sdd-status` a esta skill.

- GIVEN que el usuario ejecuta `/sdd-status` en el chat
- WHEN el orquestador recibe el comando
- THEN DEBE invocar la skill `sdd-status` para procesar la solicitud

## Escenarios Adicionales

### Escenario: Cambios con Nombres con Espacios

- GIVEN un cambio llamado "feat-authentication-flow"
- WHEN la skill genera la tabla
- THEN DEBE mostrar el nombre completo incluyendo guiones
- AND DEBE mantener la consistencia en el formato de la tabla

### Escenario: Formato de Fase Legible

- GIVEN un cambio con `phase: "tasks"`
- WHEN la skill muestra la columna "Fase Actual"
- THEN DEBE mostrar "Tasks" (primera letra mayúscula) o equivalente legible
- AND NO DEBE mostrar el valor raw en minúsculas

### Escenario: Error al Leer Archivo

- GIVEN que existe un archivo `state.yaml` corrupto o con formato inválido
- WHEN la skill intenta leerlo
- THEN DEBE continuar con los demás archivos
- AND DEBE registrar o mostrar una advertencia sobre el archivo fallido
