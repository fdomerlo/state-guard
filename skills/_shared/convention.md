# OpenSpec File Convention (compartido entre todas las skills del agente)

## Estructura de Directorios

```text
.state-guard/
├── config.yaml              ← Configuración del agente específica del proyecto
├── specs/                   ← Fuente de verdad (specs actuales del sistema)
│   └── {dominio}/
│       └── spec.md
└── changes/                 ← Cambios activos
    ├── archive/             ← Cambios completados (YYYY-MM-DD-{change-name}/)
    └── {change-name}/       ← Carpeta de cambio activo
        ├── state.ini        ← Estado del DAG + sesión (manejado por el middleware Python)
        ├── .lock            ← Lock de fase (manejado por el middleware, no tocar a mano)
        ├── .write-lock      ← Mutex de escritura de archivo, vida corta (idem)
        ├── exploration.md   ← (opcional) de explore
        ├── proposal.md      ← de propose
        ├── specs/           ← de spec (specs delta)
        │   └── {dominio}/
        │       └── spec.md
        ├── design.md        ← de design
        ├── tasks.md         ← de tasks (actualizado por apply)
        └── verify-report.md ← de verify

```

`.lock` y `.write-lock` son artefactos internos del middleware — nunca se referencian desde una skill ni se leen directamente. Se muestran acá solo para que no se los confunda con artefactos de contenido si aparecen al listar el directorio.

## Rutas de Artefactos por Skill

| Skill | Crea / Lee | Ruta |
| --- | --- | --- |
| orquestador | Lee | `.state-guard/changes/{change-name}/state.ini` |
| hotfix | Crea | `.state-guard/changes/{change-name}/state.ini` (Inicialización Bypass) |
| init | Crea | directorios base y `config.yaml` |
| explore | Crea (opcional) | `.state-guard/changes/{change-name}/exploration.md` |
| propose | Crea | `.state-guard/changes/{change-name}/proposal.md` |
| spec | Crea | `.state-guard/changes/{change-name}/specs/{dominio}/spec.md` |
| design | Crea | `.state-guard/changes/{change-name}/design.md` |
| tasks | Crea | `.state-guard/changes/{change-name}/tasks.md` |
| apply | Actualiza | `.state-guard/changes/{change-name}/tasks.md` (marca `[x]`) |
| verify | Crea | `.state-guard/changes/{change-name}/verify-report.md` |
| checkpoint | Actualiza | `.state-guard/changes/{change-name}/state.ini` → sección `[Session]` (vía middleware, ver más abajo) |
| continue | Lee | `.state-guard/changes/{change-name}/state.ini` (vía `state_manager.py status`, nunca directo) |
| archive | Mueve | `.state-guard/changes/{change-name}/` → `archive/YYYY-MM-DD-{change-name}/` |

## Schema de `state.ini` (Motor ACID)

El **Memory Guard** interactúa con este archivo EXCLUSIVAMENTE a través del script `scripts/state_manager.py`. **Nunca se debe editar manualmente con herramientas de texto — incluida la sección `[Session]`.**

El archivo rastrea el estado del Grafo Acíclico Dirigido (DAG) y, opcionalmente, un snapshot de sesión no-DAG.

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

[Session]
session_summary = ...      ; opcional — bloque generado por checkpoint, ≤500 tokens

```

`[Session]` es la sección que antes hubiera requerido un archivo `manifest.json` aparte (patrón heredado de context-guard, ya absorbido). Vive en el mismo `state.ini` para no duplicar la fuente de verdad del cambio, y su escritura no compite con el lock de fase — solo con el write-lock interno de escritura.

**Semántica `lock_phase` vs `current_phase`:**

| Campo | Rol | Cuándo cambia |
| --- | --- | --- |
| `current_phase` | Descriptivo — última fase completada | Al ejecutar COMMIT transaccional |
| `lock_phase` | Prescriptivo — única fase ejecutable | Al ejecutar COMMIT (avanza el DAG) |

**Tabla de transiciones de `lock_phase` (DAG estricto, validada en código por `TRANSITIONS` en `state_manager.py`, no solo por convención):**

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
Propuesta:      .state-guard/changes/{change-name}/proposal.md
Specs delta:    .state-guard/changes/{change-name}/specs/
Diseño:         .state-guard/changes/{change-name}/design.md
Tareas:         .state-guard/changes/{change-name}/tasks.md
Configuración:  .state-guard/config.yaml
Specs actuales: .state-guard/specs/{dominio}/spec.md
Estado (DAG+sesión): .state-guard/changes/{change-name}/state.ini (vía `state_manager.py status`)

```

## Reglas de Escritura

* SIEMPRE invocar `state_manager.py` en la terminal para mutar el estado — incluyendo `[Session]`.
* SIEMPRE crear el directorio del cambio antes de escribir artefactos.
* Si un archivo ya existe, LEERLO primero y ACTUALIZARLO (no sobreescribir ciegamente).
* Todos los nombres de cambios transaccionales DEBEN usar formato **kebab-case** (`agregar-modo-oscuro`).
