# OpenSpec File Convention (compartido entre todas las skills SDD)

## Estructura de Directorios

```
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
| sdd-archive | Mueve | `openspec/changes/{change-name}/` → `openspec/changes/archive/YYYY-MM-DD-{change-name}/` |
| sdd-archive | Actualiza | `openspec/specs/{dominio}/spec.md` (fusiona deltas en specs principales) |

## Schema de state.yaml

El orquestador es el **único responsable** de escribir y mantener `state.yaml`.
Las skills de sub-agentes **nunca** escriben ni leen este archivo directamente.

```yaml
# openspec/changes/{change-name}/state.yaml

change: {nombre-del-cambio}
started_at: "YYYY-MM-DDTHH:MM:SS"   # ISO 8601 — se establece al crear, nunca se modifica
last_updated: "YYYY-MM-DDTHH:MM:SS" # actualizar en cada transición de fase
current_phase: {fase-actual}         # última fase completada exitosamente
completed_phases:                    # lista ordenada, solo fases con status: ok
  - explore    # incluir solo si sdd-explore fue ejecutado
  - propose
  # agregar fases a medida que se completan
pending_phases:                      # fases que aún no se ejecutaron
  - tasks
  - apply
  - verify
  - archive
blocked: false                       # true si verify reporta CRITICAL sin resolver
blocked_reason: null                 # descripción del bloqueo, o null si blocked: false
```

**Valores válidos para `current_phase` y elementos de listas:**
`explore | propose | spec | design | tasks | apply | verify | archive`

**Notas de transición:**

- `spec` y `design` pueden aparecer en cualquier orden en `completed_phases` (se ejecutan en paralelo).
- `current_phase` refleja la **última** de las dos en completarse cuando corren en paralelo.
- Un cambio recién creado (solo `propose` completo) tiene `current_phase: propose`.
- Al archivar exitosamente, el archivo se mueve — no hace falta actualizar `state.yaml`.

## Lectura de Artefactos

Cada skill lee sus dependencias desde el filesystem:

```
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

La regla `change_naming: kebab-case` se aplica en la fase `sdd-propose`. El nombre se valida con la regex:
```
^[a-z0-9]+(-[a-z0-9]+)*$
```

Esta regla está configurada en `openspec/config.yaml` y se aplica automáticamente durante la creación de nuevos cambios.
```

## Estructura del Archivo Histórico

Al archivar, la carpeta del cambio se mueve a:

```
openspec/changes/archive/YYYY-MM-DD-{change-name}/
```

Usar fecha ISO de hoy. El archivo es un **RASTRO DE AUDITORÍA** — nunca eliminar ni modificar.
