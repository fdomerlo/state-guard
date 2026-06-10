# OpenSpec File Convention (compartido entre todas las skills SDD)

## Estructura de Directorios

```text
openspec/
├── config.yaml              ← Configuración SDD específica del proyecto
├── specs/                   ← Fuente de verdad (specs actuales del sistema)
│   └── {dominio}/
│       └── spec.md
└── changes/                 ← Cambios activos
    ├── archive/             ← Cambios completados (YYYY-MM-DD-{change-name}/)
    └── {change-name}/       ← Carpeta de cambio activo
        ├── state.yaml       ← Estado del DAG (orquestador — sobrevive a compactación)
        ├── exploration.md   ← (opcional) de sdd-explore
        ├── proposal.md      ← de sdd-propose
        ├── specs/           ← de sdd-spec (specs delta)
        │   └── {dominio}/
        │       └── spec.md
        ├── design.md        ← de sdd-design
        ├── tasks.md         ← de sdd-tasks (actualizado por sdd-apply)
        └── verify-report.md ← de sdd-verify
```

## Rutas de Artefactos por Skill

| Skill | Crea / Lee | Ruta |
|-------|-----------|------|
| orquestador | Crea/Actualiza | `openspec/changes/{change-name}/state.yaml` |
| sdd-init | Crea | `openspec/config.yaml`, `openspec/specs/`, `openspec/changes/`, `openspec/changes/archive/` |
| sdd-explore | Crea (opcional) | `openspec/changes/{change-name}/exploration.md` |
| sdd-propose | Crea | `openspec/changes/{change-name}/proposal.md` |
| sdd-spec | Crea | `openspec/changes/{change-name}/specs/{dominio}/spec.md` |
| sdd-design | Crea | `openspec/changes/{change-name}/design.md` |
| sdd-tasks | Crea | `openspec/changes/{change-name}/tasks.md` |
| sdd-apply | Actualiza | `openspec/changes/{change-name}/tasks.md` (marca `[x]`) |
| sdd-verify | Crea | `openspec/changes/{change-name}/verify-report.md` |
| sdd-review | Crea (opcional) | `openspec/changes/{change-name}/review-report.md` |
| sdd-fix | Repara | `openspec/changes/{change-name}/state.yaml` |
| sdd-archive | Mueve | `openspec/changes/{change-name}/` → `openspec/changes/archive/YYYY-MM-DD-{change-name}/` |
| sdd-archive | Actualiza | `openspec/specs/{dominio}/spec.md` (fusiona deltas en specs principales) |

## Schema de state.yaml (v2)

El **Memory Guard** es el único responsable de escribir y mantener `state.yaml` a través del protocolo de transacciones (ver `transaction-protocol.md`).

Las skills tienen estas autorizaciones de acceso:

- `sdd-status`: autorización para leerlo masivamente.
- `sdd-checkpoint`: autorización para escribir el campo `session_summary`.
- `sdd-fix`: autorización para reparar y migrar el archivo completo.

Los campos `lock_phase`, `current_phase`, `completed_phases` y `pending_phases` se actualizan exclusivamente mediante COMMIT transaccional.

```yaml
# openspec/changes/{change-name}/state.yaml (v2)

schema_version: 2                    # versión del schema (para migración automática)
change: {nombre-del-cambio}
started_at: "YYYY-MM-DDTHH:MM:SS"   # ISO 8601 — se establece al crear, nunca se modifica
last_updated: "YYYY-MM-DDTHH:MM:SS" # actualizar en cada COMMIT de transacción
current_phase: {fase-actual}         # descriptivo: última fase completada exitosamente
lock_phase: {fase-siguiente}         # prescriptivo: la ÚNICA fase autorizada a ejecutarse ahora
                                     # Valores válidos: propose | spec | design | tasks | apply | verify | archive
                                     # Inicialización: primera fase de pending_phases al crear el cambio
status: active                       # active | done | blocked (default: active)
completed_phases:                    # lista ordenada, solo fases completadas exitosamente
  - explore    # incluir solo si sdd-explore fue ejecutado
  - propose
  # agregar fases a medida que se completan
pending_phases:                      # fases que aún no se ejecutaron
  - tasks
  - apply
  - verify
  - archive
blocked: false                       # true si status es blocked y verify reporta CRITICAL sin resolver
blocked_reason: null                 # descripción del bloqueo, o null si blocked: false

# --- Campos transaccionales (v2) ---
txn_status: idle                     # idle | in_progress | failed
txn_phase: null                      # fase en ejecución, o null si txn_status == idle
txn_started_at: null                 # ISO 8601 de inicio de transacción, o null

session_summary:                     # bloque YAML estructurado — límite total: 500 tokens
  archivos_modificados:              # rutas exactas modificadas en el lote actual (máx 10 entradas)
    - ruta/al/archivo.ext
  estado_tareas: "{X}/{Y} — última: [{ID}] {descripción breve}"  # formato estricto
  decisiones_clave:                  # máximo 2 decisiones técnicas para continuar
    - "{decisión 1 (máx 100 chars)}"
  proxima_accion: "/sdd-{comando} {nombre-cambio}"  # comando completo ejecutable
```

**Límite de tokens en `session_summary`:** El bloque completo NO DEBE superar 500 tokens
(~375 palabras). Si se alcanza el límite, truncar aplicando estas prioridades:

1. `archivos_modificados` → listar solo los últimos 10 archivos.
2. `decisiones_clave` → listar máximo 2 ítems, truncar cada uno a 100 caracteres.
3. `estado_tareas` y `proxima_accion` son inamovibles — nunca se truncan.

**Formatos obligatorios por subcampo:**

| Subcampo | Tipo | Formato / Restricciones |
|----------|------|--------------------------|
| `archivos_modificados` | Lista YAML | Rutas relativas al root; `[]` si sin cambios; máx 10 |
| `estado_tareas` | String | `"{X}/{Y} — última: [{ID}] {texto}"` o `"N/A"` si no hay tasks.md |
| `decisiones_clave` | Lista YAML | Máx 2 ítems, cada uno ≤ 100 caracteres |
| `proxima_accion` | String | Comando completo: `/sdd-{cmd} {nombre-cambio}` |

**Valores válidos para `current_phase`, `lock_phase` y elementos de listas:**
`explore | propose | spec | design | tasks | apply | verify | archive`

**Notas de transición:**

- `spec` y `design` deben aparecer en orden secuencial estricto en `completed_phases` (no se ejecutan en paralelo).
- `current_phase` refleja la última fase completada (descriptivo/histórico).
- `lock_phase` indica la única fase que puede ejecutarse en este momento (prescriptivo/restrictivo). Se actualiza exclusivamente durante el COMMIT de una transacción.
- Un cambio recién creado (solo `propose` completo) tiene `current_phase: propose` y `lock_phase: spec`.
- `sdd-new` DEBE inicializar `lock_phase` con el valor de la primera fase en `pending_phases`.
- Al archivar exitosamente, el archivo se mueve — no hace falta actualizar `state.yaml`.

**Tabla de transiciones de `lock_phase` (DAG estricto):**

| Fase completada | `lock_phase` resultante |
|-----------------|-------------------------|
| `explore`        | `propose`               |
| `propose`        | `spec`                  |
| `spec`           | `design`                |
| `design`         | `tasks`                 |
| `tasks`          | `apply`                 |
| `apply`          | `verify`                |
| `verify`         | `archive`               |

**Semántica `lock_phase` vs `current_phase`:**

| Campo | Rol | Cuándo cambia |
|-------|-----|---------------|
| `current_phase` | Descriptivo — última fase completada | Al ejecutar COMMIT de transacción |
| `lock_phase` | Prescriptivo — única fase ejecutable | Al ejecutar COMMIT de transacción (según tabla de transiciones) |

**Error de transición inválida:** Si se intenta ejecutar una fase distinta a `lock_phase`, DEBE detenerse la ejecución e informar:

```text
ERROR: Transición inválida de lock semántico.
  Fase solicitada : {fase_solicitada}
  lock_phase actual: {lock_phase}
  Ejecuta /sdd-fix para auditar y reparar el estado antes de continuar.
```

**Migración v1 → v2:** Los `state.yaml` sin campo `schema_version` se consideran v1 y se migran automáticamente (ver `transaction-protocol.md`).

## Lectura de Artefactos

Cada skill lee sus dependencias desde el filesystem:

```text
Propuesta:      openspec/changes/{change-name}/proposal.md
Specs delta:    openspec/changes/{change-name}/specs/  (todos los subdirectorios de dominio)
Diseño:         openspec/changes/{change-name}/design.md
Tareas:         openspec/changes/{change-name}/tasks.md
Verificación:   openspec/changes/{change-name}/verify-report.md
Configuración:  openspec/config.yaml
Specs actuales: openspec/specs/{dominio}/spec.md
```

## Reglas de Escritura

- SIEMPRE crear el directorio del cambio antes de escribir artefactos.
- Si un archivo ya existe, LEERLO primero y ACTUALIZARLO (no sobreescribir ciegamente).
- Si el directorio del cambio ya existe con artefactos, el cambio está siendo CONTINUADO.
- Usar la sección `rules` de `openspec/config.yaml` para aplicar restricciones del proyecto por fase.

## Referencia del config.yaml

```yaml
# openspec/config.yaml
schema: spec-driven

context: |
  Stack tecnológico: {detectado}
  Arquitectura: {detectado}
  Testing: {detectado}
  Estilo: {detectado}

# Glosario de dominio (opcional — recomendado para proyectos con terminología específica)
# Los sub-agentes cargan este glosario y usan los términos de forma consistente en todos los artefactos.
glossary:
  {término}: >
    {Definición canónica del concepto en el dominio del proyecto.}

rules:
  change_naming: kebab-case
  proposal:
    - Incluir plan de rollback para cambios riesgosos
  specs:
    - Usar Given/When/Then para escenarios
    - Usar palabras clave RFC 2119 (MUST, SHALL, SHOULD, MAY)
  design:
    - Incluir diagramas de secuencia para flujos complejos
    - Documentar decisiones de arquitectura con justificación
    - "Explotar razonamiento arquitectónico: DEBES incluir diagramas Mermaid exhaustivos (State, Sequence o Class) para cualquier flujo no trivial."
    - "Priorizar modularidad extrema: Diseña el sistema asumiendo que el código será escrito por un modelo de IA con ventana de contexto limitada. Interfaces claras y acoplamiento nulo."
  tasks:
    - Agrupar por fase, usar numeración jerárquica
    - Mantener tareas completables en una sesión
    - "Granularidad Atómica: Cada tarea debe ser lo suficientemente pequeña para implementarse en un solo archivo o módulo lógico. Evitar 'tareas monstruo'."
  apply:
    - Seguir los patrones y convenciones de código existentes
    - "Código Defensivo y Pragmatismo: Aplica principios SOLID, DRY y Clean Code. Prefiere Early Returns (Guard Clauses). NUNCA sobre-ingeniar."
    - "Completitud: No uses placeholders como '...código restante aquí...'. Si escribes un archivo, escríbelo completo y listo para producción."
    tdd: false
    test_command: ""
  verify:
    test_command: ""
    build_command: ""
    coverage_threshold: 0
  archive:
    - Advertir antes de fusionar deltas destructivos

## Regla de Nomenclatura de Cambios

Todos los nombres de cambios SDD DEBEN usar formato **kebab-case** (palabras separadas por guiones, todo en minúsculas).

### Ejemplos válidos:
- `agregar-modo-oscuro`
- `fix-auth-bug`
- `refactor-user-service`
- `mejora-rendimiento-consultas`

### Ejemplos INVÁLIDOS:
- `agregarModoOscuro` (camelCase)
- `AgregarModoOscuro` (PascalCase)
- `agregar_modo_oscuro` (snake_case)
- `agregar modo oscuro` (espacios)

### Validación

La regla `change_naming: kebab-case` se aplica en la fase `sdd-propose`. El nombre se valida con la regex: `^[a-z0-9]+(-[a-z0-9]+)*$`

Esta regla está configurada en `openspec/config.yaml` y se aplica automáticamente durante la creación de nuevos cambios.
```

## Estructura del Archivo Histórico

Al archivar, la carpeta del cambio se mueve a:

```text
openspec/changes/archive/YYYY-MM-DD-{change-name}/
```

Usar fecha ISO de hoy. El archivo es un **RASTRO DE AUDITORÍA** — nunca eliminar ni modificar.

**Fusión de Deltas**: Al archivar, los specs delta en `specs/{dominio}/` se fusionan automáticamente con los specs principales en `openspec/specs/{dominio}/spec.md`. Esta fusión actualiza los requisitos principales con los cambios implementados en el cambio archivado.
