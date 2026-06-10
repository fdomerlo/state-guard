---
name: sdd-fix
description: >
  Audita el directorio openspec/changes/, valida los archivos state.yaml contra la realidad del disco
  y repara discrepancias en el DAG retrocediendo la fase actual a la última fase válida comprobable.
  También migra state.yaml v1 → v2 y resuelve transacciones incompletas.
  Disparador: Cuando el usuario ejecuta /sdd-fix, o el Memory Guard detecta un estado inválido.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

# SDD-Fix Skill

## Propósito

Skill responsable de **auditar y reparar el estado del DAG de SDD**. Escanea todos los `state.yaml` activos, verifica que los artefactos requeridos por cada fase existan en disco, repara discrepancias, migra schemas v1→v2, y resuelve transacciones incompletas.

## Qué Hacer

### Paso 1: Escanear Archivos de Estado

Buscar todos los `state.yaml` activos en `openspec/changes/*/state.yaml`. Ignorar cambios archivados.

### Paso 2: Validar Schema y Migrar v1 → v2

Para cada `state.yaml`:

**Campos obligatorios (v1 y v2):**
- `current_phase`: valor válido de `explore|propose|spec|design|tasks|apply|verify|archive`
- `status`: valor válido de `active|done|blocked`
- `started_at`: fecha ISO 8601
- `last_updated`: fecha ISO 8601 ≥ `started_at`
- `completed_phases`: lista (puede estar vacía)
- `pending_phases`: lista (puede estar vacía)
- `blocked_reason`: string o null

**Migración de `lock_phase` ausente:**

Si `lock_phase` no existe, inferir desde artefactos:

| Artefactos en disco | `lock_phase` inferido |
|---------------------|-----------------------|
| Solo `proposal.md` | `spec` |
| `proposal.md` + `specs/` (≥1 archivo), NO `design.md` | `design` |
| `proposal.md` + `specs/` + `design.md`, NO `tasks.md` | `tasks` |
| `proposal.md` + `specs/` + `design.md` + `tasks.md`, NO `verify-report.md` | `apply` |
| Todos los artefactos incluyendo `verify-report.md` | `archive` |

**Fallback**: Si la inferencia no es clara, usar `pending_phases[0]`.

**Migración v1 → v2 (campos transaccionales):**

Si `schema_version` no existe:

```yaml
# Agregar campos v2:
schema_version: 2
txn_status: idle
txn_phase: null
txn_started_at: null
```

**Campo `blocked` legacy:**

Si existe `blocked: true` como booleano, removerlo y cambiar `status` a `blocked`.

### Paso 3: Resolver Transacciones Incompletas

Si `txn_status` es `in_progress`:

1. Verificar si el artefacto de `txn_phase` existe en disco
2. Si SÍ → ejecutar COMMIT (la fase se completó pero el estado no se persistió)
3. Si NO → ejecutar ROLLBACK (`txn_status: idle`, sin modificar phases)

Si `txn_status` es `failed`:

1. Limpiar a `txn_status: idle`
2. Registrar en el reporte

### Paso 4: Validar Coherencia en Disco

Para cada cambio con schema válido, verificar que los artefactos requeridos existan:

| Fase actual (`current_phase`) | Artefactos requeridos en disco |
|-------------------------------|-------------------------------|
| `propose` | (ninguno obligatorio previo) |
| `spec` | `proposal.md` |
| `design` | `proposal.md` |
| `tasks` | `proposal.md`, `specs/` (≥1 archivo), `design.md` |
| `apply` | `proposal.md`, `specs/`, `design.md`, `tasks.md` |
| `verify` | `proposal.md`, `specs/`, `design.md`, `tasks.md` |
| `archive` | `proposal.md`, `specs/`, `design.md`, `tasks.md`, `verify-report.md` |

### Paso 5: Reparar Discrepancias

Si se detectan artefactos faltantes:

1. Recorrer las fases hacia atrás hasta encontrar una fase válida
2. Actualizar `current_phase` a la última fase válida
3. Recalcular `completed_phases`, `pending_phases` y `lock_phase`
4. Actualizar `last_updated`
5. Escribir el `state.yaml` reparado

### Paso 6: Reportar

```markdown
## Resultado de Auditoría

**status**: ok | warning | error

### Resumen
Se auditaron N cambios: X sanos, Y reparados, Z irrecuperables.
M cambios migrados a schema v2. T transacciones incompletas resueltas.

### Detalle
| Cambio | Fase Original | Fase Reparada | lock_phase | Acciones |
|--------|--------------|---------------|------------|----------|
| {nombre} | tasks | spec | design | Falta design.md; migrado a v2 |

### Próximo Paso
`/sdd-continue` para retomar el cambio reparado.

### Riesgos
- Cambios reparados pueden haber perdido progreso de fases intermedias
- Cambios con `lock_phase` inferido por fallback deben revisarse manualmente
```

## Reglas

- NUNCA modificar artefactos de contenido (proposal.md, specs/, design.md, etc.) — solo reparar `state.yaml`
- SIEMPRE validar schema ANTES de validar coherencia en disco
- Si un `state.yaml` está completamente corrupto, reportarlo como irrecuperable
- Si `status` es `blocked`, NO reparar — solo reportar y respetar el bloqueo
- Si `status` es `done`, ignorar — no requiere reparación
- Manejar gracefully errores de lectura
