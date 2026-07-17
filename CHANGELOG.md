# Changelog

## [2.3.0] - 2026-07-17

### Changed
- **Fases core a Markdown plano**: Las 8 fases core (`explore`, `propose`, `spec`, `design`, `tasks`, `apply`, `verify`, `archive`) dejan de usar `SKILL.md` con frontmatter YAML y pasan a archivos `<fase>.md` en Markdown plano (ej. `skills/explore/explore.md`). El frontmatter YAML (`name`, `description`, `license`, `metadata`) se elimina; el contenido instructivo se conserva intacto.
- **Scripts de instalación actualizados**: `scripts/install.sh` y `tests/install_test.sh` ahora detectan ambos formatos (`<fase>.md` para fases core, `SKILL.md` para skills descubiertas por el agente).
- **Referencias actualizadas**: Se actualizaron todas las referencias en `_shared/memory-guard.md`, `_shared/phase-common.md`, `_shared/context-injection.md`, `skills/new/SKILL.md`, `skills/ff/SKILL.md` y `MANUAL.md`.

### Note
- `skills/skill-registry/` y las custom skills del usuario **mantienen** el formato `SKILL.md` con frontmatter, ya que son descubiertas dinámicamente por el agente (no invocadas determinísticamente).

## [2.2.0] - 2026-07-08

### Added
- **Auto-descubrimiento de Skills (Zero-Config)**: El script de instalación ahora lee dinámicamente el *frontmatter* YAML de cada `SKILL.md` para generar los *slash commands* al vuelo para OpenCode.

### Changed
- **Bootstrap Universal**: Se simplificó radicalmente la inyección de contexto. El contrato `memory-guard` ahora se inyecta directamente como prompt nativo en `opencode.jsonc` y `GEMINI.md`, eliminando la necesidad de archivos intermediarios.

### Removed
- Se eliminó por completo el directorio `integrations/` y todos sus archivos estáticos (`AGENTS.md`, JSONs y comandos Markdown heredados), reduciendo drásticamente la duplicación de código.
- 
## [2.1.1] - 2026-07-08

### Changed
- **Refactor de Naming**: Se eliminaron los prefijos de todos los directorios de skills, archivos de comandos e integraciones.
- **Actualización de Rutes**: Se actualizaron todas las referencias internas, scripts y prompts para reflejar los nuevos nombres de comandos (ej. `/split` en lugar de `/agentify-split`).
- **Skills Base**: Se conservaron los nombres de los archivos base en `_shared/` para distinguirlos de los comandos ejecutables.

### Fixed
- Se corrigieron rutas rotas causadas por el renombrado masivo en `scripts/install.sh`, `scripts/cleanup.sh` y comandos internos.

## [2.1.0] - 2026-07-08

### Changed
- **Migración de Estado**: Se reemplazó `state.yaml` por `state.ini` para mejorar la compatibilidad nativa con bash.
- **Gestión de Locks**: Se introdujo `_lock_utils.py` aislando la lógica de locks del negocio, resolviendo conflictos de concurrencia.
- **Límite de Tokens**: Se implementó un límite duro de ~2000 caracteres en el `session_summary` de `state-guard-checkpoint` para evitar el agotamiento de contexto.
- **Simplificación de Instalación**: Se eliminaron `packager.py` e `install.ps1`. La inyección ahora la maneja exclusivamente `install.sh` con marcadores unificados (`<!-- state-guard:begin -->`) para todos los modelos.

### Fixed
- Se diferenciaron los exit codes en `state_manager.py` para un mejor manejo de errores en el orquestador.
- Se agregó el recordatorio explícito de transacciones (BEGIN/COMMIT) en las 8 skills de fase para evitar la deriva de memoria.

## [2.0.3]

### Changed — Arquitectura: De Despachador CLI a Harness de Memoria Transaccional

- **Memory Guard**: Nuevo contrato unificado (`_shared/memory-guard.md`) que reemplaza a `core.md`, `delegation.md` y `state.md`. El agente ahora ejecuta fases inline con delegación inteligente en lugar de despachar todo a sub-agentes CLI.
- **Transaction Protocol**: Nuevo protocolo de transacciones (`_shared/transaction-protocol.md`) con ciclo BEGIN → EXECUTE → COMMIT/ROLLBACK. Reemplaza el Return Envelope (`### Lock Phase`) por escritura directa en `state.yaml`.
- **state.yaml v2**: Schema extendido con campos transaccionales (`schema_version`, `txn_status`, `txn_phase`, `txn_started_at`). Migración automática v1→v2 vía `fix`.
- **Capabilities Adapter**: Nuevo módulo unificado (`_shared/capabilities.md`) que reemplaza las 4 integraciones separadas con detección automática del agente host.
- **Context Injection**: Simplificado `context.md` → `context-injection.md` eliminando la distinción orquestador/sub-agente.
- **Presupuestos de tokens flexibles**: Eliminados los límites rígidos de palabras por fase (400 proposal, 650 spec, 800 design, 530 tasks).
- **Todas las skills de fase** (explore, propose, spec, design, tasks, apply, verify, archive): Refactorizadas con sección de Transacción integrada, sin Return Envelope, sin dependencia del orquestador.
- **Meta-skills** (new, continue, ff): Refactorizadas para ejecución inline directa con transacciones secuenciales.
- **checkpoint**: Ahora opera en modo dual (automático post-COMMIT + manual bajo demanda).
- **fix**: Añadida migración v1→v2 y resolución de transacciones incompletas.
- **status**: Muestra `txn_status` en la tabla de estado.
- **Integraciones**: OpenCode y Antigravity CLI reducidas a stubs mínimos que cargan `memory-guard.md`. Se eliminó por completo la integración obsoleta de `gemini-cli` y se renombró `antigravity` a `antigravity-cli` en todos los instaladores, scripts y documentación.
- **install.sh / cleanup.sh**: Actualizados para soportar exclusivamente `antigravity-cli` y retirar la opción de `gemini-cli`.
- **Estructura del agente**: Inicialización de la estructura del agente en el proyecto (`/init`) creando `openspec/config.yaml` y generando el índice de habilidades `.state-guard/skill-registry.md`.

### Removed

- `_shared/core.md` — Absorbido en `memory-guard.md`
- `_shared/delegation.md` — Absorbido en `memory-guard.md`
- `_shared/state.md` — Absorbido en `transaction-protocol.md`
- `_shared/execution-contract.md` — Absorbido en `transaction-protocol.md`
- `_shared/commands.md` — Absorbido en `memory-guard.md`
- `_shared/context.md` — Reemplazado por `context-injection.md`

### Added

- `_shared/memory-guard.md` — Contrato unificado de Memory Guard
- `_shared/transaction-protocol.md` — Protocolo de transacciones con ciclo BEGIN/COMMIT/ROLLBACK
- `_shared/capabilities.md` — Adapter de capacidades por agente host
- `_shared/context-injection.md` — Protocolo simplificado de inyección de contexto
- `integrations/system-prompt.md` — Template unificado de system prompt
