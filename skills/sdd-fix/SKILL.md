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


- Lee las convenciones base referenciadas en `skills/_shared/execution-contract.md` antes de proceder.


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
- **Campo `lock_phase`**: Debe existir y contener un valor válido de la misma lista. Diferenciá dos casos:
  - **Ausente** → Marcar como `schema_migration_needed` (NO como CORRUPTO — puede ser un estado válido de versión anterior del schema). Proceder al Paso 2b para inyectarlo.
  - **Presente pero con valor inválido** → Marcar como CORRUPTO y re-inferir desde artefactos.
- **Campo `status`**: Debe existir y contener un valor válido de la lista: `active`, `done`, `blocked`.
- **Campo `started_at`**: Debe existir y ser una fecha válida en formato ISO 8601.
- **Campo `last_updated`**: Debe existir y ser una fecha válida ISO 8601 posterior o igual a `started_at`.
- **Campo `completed_phases`**: Debe ser una lista (puede estar vacía).
- **Campo `pending_phases`**: Debe ser una lista (puede estar vacía).
- **Campo `blocked` (Legacy)**: Si se encuentra como booleano y equivale a `true`, debe removerse y el campo `status` debe cambiarse a `blocked`. No debe ser requerido de forma estricta.
- **Campo `blocked_reason`**: Debe existir en todos los schemas, conteniendo el literal del error (puede ser `null` si `status` no es `blocked`).

Si falta algún campo obligatorio (distinto de `lock_phase`), marcá el cambio como **CORRUPTO** en el reporte.

### Paso 2b: Migrar `lock_phase` Ausente

Si un `state.yaml` fue marcado como `schema_migration_needed` en el Paso 2, inferí el valor
correcto de `lock_phase` inspeccionando los artefactos presentes en disco:

| Condición (artefactos en disco) | `lock_phase` inferido |
|---------------------------------|-----------------------|
| Solo `proposal.md` existe | `spec` |
| `proposal.md` + `specs/` (≥1 archivo) existen, pero NO `design.md` | `design` |
| `proposal.md` + `specs/` + `design.md` existen, pero NO `tasks.md` | `tasks` |
| `proposal.md` + `specs/` + `design.md` + `tasks.md` existen, pero NO `verify-report.md` | `apply` |
| `proposal.md` + `specs/` + `design.md` + `tasks.md` + `verify-report.md` existen | `archive` |

**Fallback conservador:** Si los artefactos no permiten inferencia clara, usar el valor de
`pending_phases[0]` como fallback y registrar la razón en el reporte.

Tras inferir el valor, escribir `lock_phase: {valor}` en el `state.yaml` reparado y registrar:
```
schema_migration: lock_phase inyectado (inferido: {valor})
# o si se usó fallback:
schema_migration: lock_phase inyectado (fallback desde pending_phases[0]: {valor})
```

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
(Si hubo migraciones de schema: M cambios recibieron `lock_phase` inyectado.)

### artifacts
- `openspec/changes/{cambio}/state.yaml` — Repaired | Untouched | Reconstructed | Migrated

### schema_migrations
- `openspec/changes/{cambio}/state.yaml` — `lock_phase` inyectado (inferido: {valor})
- `openspec/changes/{cambio}/state.yaml` — `lock_phase` inyectado (fallback desde pending_phases[0]: {valor})
# Si no hubo migraciones: omitir esta sección o indicar "Ninguna"

### next_recommended
/sdd-continue para retomar el cambio reparado

### risks
- Cambios reparados pueden haber perdido progreso de fases intermedias
- Cambios con `lock_phase` migrado por fallback deben revisarse manualmente

### detailed_report
| Cambio | Fase Original | Fase Reparada | lock_phase Resultante | Problemas Encontrados |
|--------|--------------|---------------|----------------------|----------------------|
| {nombre} | tasks | spec | design | Falta design.md, Falta tasks.md |
| {nombre} | spec | spec | design | lock_phase ausente — inyectado por migración |
```

## Reglas

- NUNCA modificar artefactos de contenido (proposal.md, specs/, design.md, etc.) — solo reparar `state.yaml`
- SIEMPRE validar schema ANTES de validar coherencia en disco
- Si un `state.yaml` está completamente corrupto y no se puede inferir estado desde disco, reportarlo como irrecuperable
- Si `status` es `blocked`, NO reparar — solo reportar y respetar el bloqueo
- Si `status` es `done`, ignorar — no requiere reparación
- Manejar gracefully errores de lectura (permisos, archivos binarios, etc.)
