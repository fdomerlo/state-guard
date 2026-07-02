# OpenSpec File Convention (compartido entre todas las skills SDD)

## Estructura de Directorios

```text
.agentify/
├── config.yaml              ← Configuración SDD específica del proyecto
├── specs/                   ← Fuente de verdad (specs actuales del sistema)
│   └── {dominio}/
│       └── spec.md
└── changes/                 ← Cambios activos
    ├── archive/             ← Cambios completados (YYYY-MM-DD-{change-name}/)
    └── {change-name}/       ← Carpeta de cambio activo
        ├── state.ini        ← Estado del DAG transaccional (Manejado por el middleware Python)
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
| --- | --- | --- |
| orquestador | Lee | `.agentify/changes/{change-name}/state.ini` |
| sdd-hotfix | Crea | `.agentify/changes/{change-name}/state.ini` (Inicialización Bypass) |
| sdd-init | Crea | directorios base y `config.yaml` |
| sdd-explore | Crea (opcional) | `.agentify/changes/{change-name}/exploration.md` |
| sdd-propose | Crea | `.agentify/changes/{change-name}/proposal.md` |
| sdd-spec | Crea | `.agentify/changes/{change-name}/specs/{dominio}/spec.md` |
| sdd-design | Crea | `.agentify/changes/{change-name}/design.md` |
| sdd-tasks | Crea | `.agentify/changes/{change-name}/tasks.md` |
| sdd-apply | Actualiza | `.agentify/changes/{change-name}/tasks.md` (marca `[x]`) |
| sdd-verify | Crea | `.agentify/changes/{change-name}/verify-report.md` |
| sdd-archive | Mueve | `.agentify/changes/{change-name}/` → `archive/YYYY-MM-DD-{change-name}/` |

## Schema de `state.ini` (Motor ACID)

El **Memory Guard** interactúa con este archivo EXCLUSIVAMENTE a través del script `scripts/sdd_state_manager.py`. **Nunca se debe editar manualmente con herramientas de texto.**

El archivo rastrea el estado del Grafo Acíclico Dirigido (DAG).

```ini
[Metadata]
last_updated = 2026-07-02T10:30:00.000000

[Transaction]
txn_status = idle          ; idle | in_progress
txn_phase = None           ; fase actual si in_progress, sino None
txn_started_at = None

[Graph]
current_phase = propose    ; Descriptivo: última fase completada
lock_phase = spec          ; Prescriptivo: única fase autorizada a ejecutarse AHORA
completed_phases = explore, propose
pending_phases = spec, design, tasks, apply, verify, archive

```

**Semántica `lock_phase` vs `current_phase`:**

| Campo | Rol | Cuándo cambia |
| --- | --- | --- |
| `current_phase` | Descriptivo — última fase completada | Al ejecutar COMMIT transaccional |
| `lock_phase` | Prescriptivo — única fase ejecutable | Al ejecutar COMMIT (avanza el DAG) |

**Tabla de transiciones de `lock_phase` (DAG estricto):**

| Fase completada | `lock_phase` resultante |
| --- | --- |
| `explore` | `propose` |
| `propose` | `spec` |
| `spec` | `design` |
| `design` | `tasks` |
| `tasks` | `apply` |
| `hotfix` | `apply` |
| `apply` | `verify` |
| `verify` | `archive` |

## Lectura de Artefactos

Cada skill lee sus dependencias desde el filesystem:

```text
Propuesta:      .agentify/changes/{change-name}/proposal.md
Specs delta:    .agentify/changes/{change-name}/specs/
Diseño:         .agentify/changes/{change-name}/design.md
Tareas:         .agentify/changes/{change-name}/tasks.md
Configuración:  .agentify/config.yaml
Specs actuales: .agentify/specs/{dominio}/spec.md

```

## Reglas de Escritura

* SIEMPRE invocar `sdd_state_manager.py` en la terminal para mutar el estado.
* SIEMPRE crear el directorio del cambio antes de escribir artefactos.
* Si un archivo ya existe, LEERLO primero y ACTUALIZARLO (no sobreescribir ciegamente).
* Todos los nombres de cambios SDD DEBEN usar formato **kebab-case** (`agregar-modo-oscuro`).
