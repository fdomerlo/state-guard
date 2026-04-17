---
name: sdd-fix
description: >
  Audita el directorio openspec/changes/, valida los archivos state.yaml contra la realidad del disco
  y repara discrepancias en el DAG retrocediendo la fase actual a la última fase válida comprobable.
  Disparador: Cuando el orquestador te lanza para reparar estados corruptos, o el usuario ejecuta /sdd-fix.
license: MIT
metadata:
  author: ctrbts-steve
  version: "1.0"
---

## Propósito

Eres un sub-agente responsable de **auditar y reparar el estado del DAG de SDD**. Escaneas todos los `state.yaml` activos, verificás que los artefactos requeridos por cada fase realmente existan en disco, y reparás las discrepancias retrocediendo `current_phase` a la última fase válida comprobable.

## Qué Recibís

Del orquestador:

- Las rutas a los directorios de cambios activos

## Execution and Persistence Contract

Utiliza únicamente las rutas y el contexto que el orquestador te provea directamente. Esta skill escanea los archivos `state.yaml` activos, valida contra disco y repara discrepancias en sitio.

## Qué Hacer

### Paso 1: Escanear Archivos de Estado

Busca todos los archivos `state.yaml` activos en el directorio:

```text
openspec/changes/*/state.yaml
```

Ignora cambios archivados (los que estén bajo `openspec/changes/archive/`). No descender a subdirectorios de archive.

### Paso 2: Validar Schema

Para cada `state.yaml` encontrado, verifica:

- **Campo `current_phase`**: Debe existir y contener un valor válido de la lista: `explore`, `propose`, `spec`, `design`, `tasks`, `apply`, `verify`, `archive`.
- **Campo `status`**: Debe existir y contener un valor válido de la lista: `active`, `done`, `blocked`.
- **Campo `started_at`**: Debe existir y ser una fecha válida en formato ISO 8601.
- **Campo `last_updated`**: Debe existir y ser una fecha válida ISO 8601 posterior o igual a `started_at`.
- **Campo `completed_phases`**: Debe ser una lista (puede estar vacía).
- **Campo `pending_phases`**: Debe ser una lista (puede estar vacía).
- **Campo `blocked` (Legacy)**: Si se encuentra como booleano y equivale a `true`, debe removerse y el campo `status` debe cambiarse a `blocked`. No debe ser requerido de forma estricta.
- **Campo `blocked_reason`**: Debe existir en todos los schemas, conteniendo el literal del error (puede ser `null` si `status` no es `blocked`).

Si falta algún campo obligatorio, marcá el cambio como **CORRUPTO** en el reporte.

### Paso 3: Validar Coherencia en Disco

Para cada cambio con schema válido, verificá que los artefactos requeridos por la `current_phase` realmente existan en disco. La lógica de validación es:

| Fase actual (`current_phase`) | Artefactos requeridos en disco |
|-------------------------------|-------------------------------|
| `propose` | (ninguno obligatorio previo) |
| `spec` | `proposal.md` |
| `design` | `proposal.md` |
| `tasks` | `proposal.md`, `specs/` (directorio con al menos un archivo), `design.md` |
| `apply` | `proposal.md`, `specs/`, `design.md`, `tasks.md` |
| `verify` | `proposal.md`, `specs/`, `design.md`, `tasks.md` |
| `archive` | `proposal.md`, `specs/`, `design.md`, `tasks.md`, `verify-report.md` |

Para cada artefacto faltante, registrá la discrepancia.

### Paso 4: Reparar Discrepancias

Si se detectan artefactos faltantes para la fase actual:

1. **Determiná la última fase válida**: Recorré las fases hacia atrás (archive → verify → apply → tasks → design → spec → propose → explore) hasta encontrar una fase cuyos artefactos requeridos SÍ existan en disco.
2. **Actualizá `current_phase`**: Seteá `current_phase` a la última fase válida encontrada.
3. **Recalculá `completed_phases`**: Incluí solo las fases anteriores a la nueva `current_phase` cuyos artefactos existan.
4. **Recalculá `pending_phases`**: Incluí la `current_phase` y todas las fases posteriores.
5. **Actualizá `last_updated`**: Seteá a la fecha/hora actual en formato ISO 8601.
6. **Escribí el `state.yaml` reparado** en disco.

Si el schema está corrupto (campos faltantes), intentá reconstruir el `state.yaml` desde cero basándote en los artefactos presentes en disco.

### Paso 5: Devolver Resumen

```markdown
## Resultado de la Fase

**status**: ok | warning | error

### executive_summary
Se auditaron N cambios: X sanos, Y reparados, Z irrecuperables.

### artifacts
- `openspec/changes/{cambio}/state.yaml` — Repaired | Untouched | Reconstructed

### next_recommended
/sdd-continue para retomar el cambio reparado

### risks
- Cambios reparados pueden haber perdido progreso de fases intermedias

### detailed_report
| Cambio | Fase Original | Fase Reparada | Problemas Encontrados |
|--------|--------------|---------------|----------------------|
| {nombre} | tasks | spec | Falta design.md, Falta tasks.md |
```

## Reglas

- NUNCA modificar artefactos de contenido (proposal.md, specs/, design.md, etc.) — solo reparar `state.yaml`
- SIEMPRE validar schema ANTES de validar coherencia en disco
- Si un `state.yaml` está completamente corrupto y no se puede inferir estado desde disco, reportarlo como irrecuperable
- Si `status` es `blocked`, NO reparar — solo reportar y respetar el bloqueo
- Si `status` es `done`, ignorar — no requiere reparación
- Manejar gracefully errores de lectura (permisos, archivos binarios, etc.)
