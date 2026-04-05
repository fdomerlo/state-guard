# Exploration: Feature de Estado y Seguridad

## Objetivo

Investigar el código base existente para implementar mecanismos de seguridad ante fallos y optimizar la recuperación de sesión para el orquestador SDD.

---

## 1. Schema Actual de state.yaml

### Ubicación de la Definición

- **Archivo principal**: `skills/_shared/openspec-convention.md` (líneas 43-77)
- **Referencia complementaria**: `skills/_shared/orchestrator-state.md` (líneas 18-37)

### Campos del Schema

| Campo | Tipo | Descripción | Obligatorio |
|-------|------|-------------|-------------|
| `change` | string | Nombre del cambio en formato kebab-case | Sí |
| `started_at` | ISO 8601 | Fecha de creación. Se establece al crear, nunca se modifica | Sí |
| `last_updated` | ISO 8601 | Fecha de última actualización. Actualizar en cada transición de fase | Sí |
| `current_phase` | enum | Fase actual completada: `explore`, `propose`, `spec`, `design`, `tasks`, `apply`, `verify`, `archive` | Sí |
| `status` | enum | Estado del cambio: `active`, `done`, `blocked` | Sí |
| `completed_phases` | list | Fases completadas exitosamente (solo fases con status ok) | Sí |
| `pending_phases` | list | Fases que aún no se han ejecutado | Sí |
| `blocked` | boolean | true si status es blocked y verify reporta CRITICAL sin resolver | Sí |
| `blocked_reason` | null/string | Descripción del bloqueo, o null si blocked: false | Sí |

### Ejemplo Completo

```yaml
change: feat-estado-y-seguridad
started_at: "2026-04-05T10:00:00"
last_updated: "2026-04-05T14:30:00"
current_phase: tasks
status: active
completed_phases:
  - explore
  - propose
  - spec
  - design
pending_phases:
  - tasks
  - apply
  - verify
  - archive
blocked: false
blocked_reason: null
```

### Reglas de Transición

- `spec` y `design` deben aparecer en orden secuencial estricto en `completed_phases` (no se ejecutan en paralelo).
- `current_phase` refleja la fase específica actual en el flujo lineal.
- Un cambio recién creado (solo `propose` completo) tiene `current_phase: propose`.
- Al archivar exitosamente, el archivo se mueve — no hace falta actualizar `state.yaml`.

---

## 2. Skills Existentes de Checkpoint y Rollback

### Estado de Existencia

| Skill | Ruta Buscada | Existe |
|-------|--------------|--------|
| sdd-checkpoint | `skills/**/sdd-checkpoint/SKILL.md` | No |
| sdd-rollback | `skills/**/sdd-rollback/SKILL.md` | No |

### Análisis

**No existen** skills dedicadas de checkpoint o rollback en el codebase actual.

### Referencias a "Rollback" Encontradas

Se encontraron menciones de "rollback" en los siguientes archivos:

| Archivo | Línea | Contexto |
|---------|-------|----------|
| `skills/sdd-init/SKILL.md` | 62 | Regla: "Incluir plan de rollback para cambios riesgosos" |
| `skills/sdd-propose/SKILL.md` | 120 | Requisito: "Toda propuesta DEBE tener un plan de rollback" |
| `openspec/convention.md` | 121 | Regla en config: "Incluir plan de rollback para cambios riesgosos" |
| `openspec/config.yaml` | 13 | Regla global: "Incluir plan de rollback para cambios riesgosos" |

**Nota**: Estas menciones se refieren a un **plan de rollback** como requisito documental en las propuestas, no a lógica de ejecución de rollback.

---

## 3. Comando de Checkpoint en Orquestador

### Archivo de Referencia

`skills/_shared/orchestrator-commands.md`

### Meta-comandos Existentes

| Comando | Descripción | Tipo |
|---------|-------------|------|
| `/sdd-new <change>` | Ejecuta `sdd-explore` y luego `sdd-propose` | Meta-comando |
| `/sdd-continue [change]` | Crea el siguiente artefacto faltante | Meta-comando |
| `/sdd-ff [change]` | Fast-forward: propose → spec → design → tasks | Meta-comando |

### Skills Directos Existentes

| Comando | Skill Ejecutada |
|---------|-----------------|
| `/sdd-init` | sdd-init |
| `/sdd-explore <topic>` | sdd-explore |
| `/sdd-propose <change>` | sdd-propose |
| `/sdd-spec <change>` | sdd-spec |
| `/sdd-design <change>` | sdd-design |
| `/sdd-tasks <change>` | sdd-tasks |
| `/sdd-apply [change]` | sdd-apply |
| `/sdd-verify [change]` | sdd-verify |
| `/sdd-review [change]` | sdd-review |
| `/sdd-fix` | sdd-fix |
| `/sdd-split [change]` | sdd-split |
| `/sdd-archive [change]` | sdd-archive |
| `/sdd-changelog` | sdd-changelog |
| `/sdd-status` | sdd-status |

### Búsqueda de "checkpoint"

**Resultado**: No se encontró ninguna referencia a "checkpoint" en el orquestador.

### Cómo se Registran los Comandos

Los comandos están definidos estáticamente en `orchestrator-commands.md`. El patrón observed es:

1. Los meta-comandos orquestan múltiples fases internamente
2. Los skills directos ejecutan una skill individual
3. No existe un sistema de registro dinámico de comandos

---

## 4. Funcionalidad de Rollback en Otras Skills

### Skill sdd-fix: Reparación de Estados

El skill `sdd-fix` (`skills/sdd-fix/SKILL.md`) ya implementa una lógica similar a rollback:

#### Propósito

Audita y repara el estado del DAG de SDD. Escanea todos los `state.yaml` activos, verifica que los artefactos requeridos por cada fase existan en disco, y repara discrepancias retrocediendo `current_phase` a la última fase válida comprobable.

#### Lógica de Reparación (Paso 4)

```
1. Determinar la última fase válida: Recorrer las fases hacia atrás (archive → verify → apply → tasks → design → spec → propose → explore) hasta encontrar una fase cuyos artefactos requeridos SÍ existan en disco.
2. Actualizar current_phase: Setea current_phase a la última fase válida encontrada.
3. Recalcular completed_phases: Incluir solo las fases anteriores a la nueva current_phase cuyos artefactos existan.
4. Recalcular pending_phases: Incluir la current_phase y todas las fases posteriores.
5. Actualizar last_updated: Setea a la fecha/hora actual en formato ISO 8601.
6. Escribir el state.yaml reparado en disco.
```

#### Validación de Artefactos por Fase

| Fase actual | Artefactos requeridos en disco |
|------------|-------------------------------|
| `propose` | (ninguno obligatorio previo) |
| `spec` | `proposal.md` |
| `design` | `proposal.md` |
| `tasks` | `proposal.md`, `specs/`, `design.md` |
| `apply` | `proposal.md`, `specs/`, `design.md`, `tasks.md` |
| `verify` | `proposal.md`, `specs/`, `design.md`, `tasks.md` |
| `archive` | `proposal.md`, `specs/`, `design.md`, `tasks.md`, `verify-report.md` |

### Uso de git checkout

Se encontraron referencias a `git checkout` en propuestas archivadas:

| Archivo | Uso |
|---------|-----|
| `openspec/changes/archive/2026-04-05-refactor-core-modular/proposal.md` | `git checkout -- skills/` |
| `openspec/changes/archive/2026-04-05-refactor-dry-skills/proposal.md` | `git checkout -- skills/` |

Estos se usan como **parte del plan de rollback** documentado en las propuestas, no como lógica de ejecución automática.

---

## 5. Recomendaciones de Implementación

### Análisis del Estado Actual

| Componente | Estado | Implicación |
|------------|--------|-------------|
| Schema state.yaml | Completo y documentado | No requiere cambios |
| sdd-checkpoint | No existe | Debe crearse |
| sdd-rollback | No existe | Debe crearse o integrarse |
| sdd-fix | Existe y funcional | Cumple rol de recuperación |
| Registro de comandos | Estático | Requiere extensión |

### Recomendaciones

#### Opción 1: Extender sdd-fix (Recomendado)

**Agregar funcionalidad de checkpoint a sdd-fix existente**:

- Añadir comando `/sdd-snapshot [change]` que guarda una copia de seguridad de state.yaml
- Añadir lógica para restaurar desde snapshots previos
- Beneficio: Reutiliza skill existente, menor complejidad

#### Opción 2: Crear Nuevas Skills

**Crear `sdd-checkpoint` y `sdd-rollback`**:

- `sdd-checkpoint`: Guardar estado actual con metadatos (timestamp, hash de artefactos)
- `sdd-rollback`: Restaurar a un checkpoint anterior
- Beneficio: Mayor flexibilidad y control
- Costo: Más archivos, más complejidad de mantenimiento

#### Opción 3: Mejorar Meta-comandos

**Extender `/sdd-ff` con checkpoints automáticos**:

- Guardar snapshot antes de cada fase en el fast-forward
- Permitir recuperación automática en caso de fallo
- Beneficio: Seamless para el usuario
- Costo: Requiere modificar lógica del orquestador

### Prioridad Sugerida

1. **Alta**: Documentar estructura de checkpoint en state.yaml (nuevo campo `snapshots`)
2. **Alta**: Mejorar sdd-fix para soportar restauración manual
3. **Media**: Crear skill sdd-checkpoint básica
4. **Baja**: Crear skill sdd-rollback completa

---

## 6. Archivos Relevantes Consultados

| Archivo | Ruta |
|---------|------|
| OpenSpec Convention | `skills/_shared/openspec-convention.md` |
| Orchestrator Commands | `skills/_shared/orchestrator-commands.md` |
| Orchestrator Core | `skills/_shared/orchestrator-core.md` |
| Orchestrator State | `skills/_shared/orchestrator-state.md` |
| Skill sdd-fix | `skills/sdd-fix/SKILL.md` |
| Configuración | `openspec/config.yaml` |

---

*Fecha de exploración: 2026-04-05*
