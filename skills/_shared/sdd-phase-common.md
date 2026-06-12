# Contrato Común de Transacción — Fases SDD

## Propósito

Este archivo define el protocolo estándar que TODAS las skills de fase SDD DEBEN seguir para integrar la persistencia transaccional del Memory Guard. Centraliza el contrato para eliminar duplicación entre skills.

## Protocolo de Transacción por Fase

Toda skill de fase DEBE seguir este ciclo:

### 1. BEGIN — Al inicio de la fase

Escribir en `state.yaml`:

```yaml
txn_status: in_progress
txn_phase: {nombre-de-la-fase}   # ej: "spec", "design", "apply"
txn_started_at: "{timestamp ISO 8601}"
```

### 2. EXECUTE — Trabajo de la fase

Ejecutar las instrucciones del SKILL.md. Persistir el artefacto resultante en disco **antes** de actualizar `state.yaml`.

### 3. COMMIT — Al completar exitosamente

Actualizar `state.yaml` en una sola escritura:

```yaml
current_phase: {fase recién completada}
lock_phase: {siguiente fase del DAG}
completed_phases: [..., {fase recién completada}]
pending_phases: [... sin la fase recién completada]
last_updated: "{timestamp ISO 8601}"
txn_status: idle
txn_phase: null
txn_started_at: null
session_summary:
  archivos_modificados:
    - ruta/al/artefacto-creado.md
  estado_tareas: "N/A"   # o formato estricto si aplica
  decisiones_clave:
    - "{decisión relevante de esta fase}"
  proxima_accion: "/sdd-{siguiente} {nombre-cambio}"
```

### 4. ROLLBACK — Si la fase falla

```yaml
txn_status: failed
txn_phase: {fase que falló}
# NO modificar current_phase, lock_phase, completed_phases, pending_phases
```

Reportar el error al usuario.

## Reporte al Usuario (Post-COMMIT)

Después de ejecutar COMMIT, reportá al usuario un resumen conciso. No hay formato rígido — usá markdown con las secciones que aporten valor para cada fase:

| Sección | Cuándo incluir |
|---------|----------------|
| **Resumen ejecutivo** | Siempre (máx 3 líneas) |
| **Artefactos creados/modificados** | Siempre (lista de rutas) |
| **Riesgos** | Si se identificaron riesgos |
| **Próxima acción** | Siempre (comando SDD sugerido) |
| **Reporte detallado** | Solo si la fase produce análisis extenso (ej: verify) |

## Regla de Glosario

Si existe `openspec/config.yaml` con sección `glossary`, cargar los términos y usarlos consistentemente en todos los artefactos generados. Si no existe, continuar normalmente (es opcional).

## Referencia en Skills

Cada skill de fase incluye en su sección de transacción:

> Seguí el protocolo de transacción definido en `skills/_shared/sdd-phase-common.md`
