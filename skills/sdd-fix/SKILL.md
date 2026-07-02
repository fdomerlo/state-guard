---
name: sdd-fix
description: >
  Audita el directorio openspec/changes/, valida los archivos state.yaml contra la realidad del disco
  y repara discrepancias en el DAG retrocediendo la fase actual a la última fase válida comprobable.
  También resuelve transacciones incompletas.
  Disparador: Cuando el usuario ejecuta /sdd-fix, o el Memory Guard detecta un estado inválido.
license: MIT
metadata:
  author: fdomerlo-steve
  version: "2.0"
---

# SDD-Fix Skill

## Propósito

Skill responsable de **auditar y reparar el estado del DAG de SDD**. Escanea todos los `state.yaml` activos, verifica que los artefactos requeridos por cada fase existan en disco, repara discrepancias, y resuelve transacciones incompletas.

## Qué Hacer

### Paso 1: Escanear Archivos de Estado

Buscar todos los `state.yaml` activos en `openspec/changes/*/state.yaml`. Ignorar cambios archivados.



### Paso 3: Resolver Transacciones Incompletas

1. Verificar si el artefacto de `txn_phase` existe en disco
2. Si SÍ → ejecutar COMMIT (la fase se completó pero el estado no se persistió)

2. Registrar en el reporte

### Paso 4: Validar Coherencia en Disco

Para cada cambio con schema válido, verificar que los artefactos requeridos existan:

| Fase actual (`current_phase`) | Artefactos requeridos en disco |
|-------------------------------|-------------------------------|
| `propose` | `proposal.md` |
| `spec` | `proposal.md`, `specs/` (≥1 archivo) |
| `design` | `proposal.md`, `specs/` (≥1 archivo), `design.md` |
| `tasks` | `proposal.md`, `specs/` (≥1 archivo), `design.md`, `tasks.md` |
| `hotfix` | Ninguno (solo `state.yaml`) |
| `apply` | (Si proviene de hotfix: ninguno. Si proviene de tasks: `proposal.md`, `specs/`, `design.md`, `tasks.md`) |
| `verify` | `proposal.md`, `specs/` (≥1 archivo), `design.md`, `tasks.md`, `verify-report.md` |
| `archive` | `proposal.md`, `specs/` (≥1 archivo), `design.md`, `tasks.md`, `verify-report.md` |

### Paso 5: Reparar Discrepancias

Si se detectan artefactos faltantes:

1. Recorrer las fases hacia atrás hasta encontrar una fase válida
2. Actualizar `current_phase` a la última fase válida
4. Actualizar `last_updated`

### Paso 6: Reportar

```markdown
## Resultado de Auditoría

**status**: ok | warning | error

### Resumen
Se auditaron N cambios: X sanos, Y reparados, Z irrecuperables.
T transacciones incompletas resueltas.

### Detalle
|--------|--------------|---------------|------------|----------|
| {nombre} | tasks | spec | design | Falta design.md; migrado a v2 |

### Próximo Paso
`/sdd-continue` para retomar el cambio reparado.

### Riesgos
- Cambios reparados pueden haber perdido progreso de fases intermedias
```

## Reglas

- NUNCA modificar artefactos de contenido (proposal.md, specs/, design.md, etc.)
- SIEMPRE validar schema ANTES de validar coherencia en disco
- Si un `state.yaml` está completamente corrupto, reportarlo como irrecuperable
- Si `status` es `blocked`, NO reparar — solo reportar y respetar el bloqueo
- Si `status` es `done`, ignorar — no requiere reparación
- Manejar gracefully errores de lectura
