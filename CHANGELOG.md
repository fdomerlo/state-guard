# Changelog

## [2.0.3]

### Changed — Arquitectura: De Despachador CLI a Harness de Memoria Transaccional

- **Memory Guard**: Nuevo contrato unificado (`_shared/memory-guard.md`) que reemplaza a `agentify-core.md`, `agentify-delegation.md` y `agentify-state.md`. El agente ahora ejecuta fases inline con delegación inteligente en lugar de despachar todo a sub-agentes CLI.
- **Transaction Protocol**: Nuevo protocolo de transacciones (`_shared/transaction-protocol.md`) con ciclo BEGIN → EXECUTE → COMMIT/ROLLBACK. Reemplaza el Return Envelope (`### Lock Phase`) por escritura directa en `state.yaml`.
- **state.yaml v2**: Schema extendido con campos transaccionales (`schema_version`, `txn_status`, `txn_phase`, `txn_started_at`). Migración automática v1→v2 vía `agentify-fix`.
- **Capabilities Adapter**: Nuevo módulo unificado (`_shared/capabilities.md`) que reemplaza las 4 integraciones separadas con detección automática del agente host.
- **Context Injection**: Simplificado `agentify-context.md` → `context-injection.md` eliminando la distinción orquestador/sub-agente.
- **Presupuestos de tokens flexibles**: Eliminados los límites rígidos de palabras por fase (400 proposal, 650 spec, 800 design, 530 tasks).
- **Todas las skills de fase** (explore, propose, spec, design, tasks, apply, verify, archive): Refactorizadas con sección de Transacción integrada, sin Return Envelope, sin dependencia del orquestador.
- **Meta-skills** (agentify-new, agentify-continue, agentify-ff): Refactorizadas para ejecución inline directa con transacciones secuenciales.
- **agentify-checkpoint**: Ahora opera en modo dual (automático post-COMMIT + manual bajo demanda).
- **agentify-fix**: Añadida migración v1→v2 y resolución de transacciones incompletas.
- **agentify-status**: Muestra `txn_status` en la tabla de estado.
- **Integraciones**: Claude Code, Antigravity CLI y OpenCode reducidas a stubs mínimos que cargan `memory-guard.md`. Se eliminó por completo la integración obsoleta de `gemini-cli` y se renombró `antigravity` a `antigravity-cli` en todos los instaladores, scripts y documentación.
- **install.sh / cleanup.sh**: Actualizados para soportar exclusivamente `antigravity-cli` y retirar la opción de `gemini-cli`.
- **Estructura del agente**: Inicialización de la estructura del agente en el proyecto (`/agentify-init`) creando `openspec/config.yaml` y generando el índice de habilidades `.agentify/skill-registry.md`.


### Removed

- `_shared/agentify-core.md` — Absorbido en `memory-guard.md`
- `_shared/agentify-delegation.md` — Absorbido en `memory-guard.md`
- `_shared/agentify-state.md` — Absorbido en `transaction-protocol.md`
- `_shared/execution-contract.md` — Absorbido en `transaction-protocol.md`
- `_shared/agentify-commands.md` — Absorbido en `memory-guard.md`
- `_shared/agentify-context.md` — Reemplazado por `context-injection.md`

### Added

- `_shared/memory-guard.md` — Contrato unificado de Memory Guard
- `_shared/transaction-protocol.md` — Protocolo de transacciones con ciclo BEGIN/COMMIT/ROLLBACK
- `_shared/capabilities.md` — Adapter de capacidades por agente host
- `_shared/context-injection.md` — Protocolo simplificado de inyección de contexto
- `integrations/system-prompt.md` — Template unificado de system prompt
