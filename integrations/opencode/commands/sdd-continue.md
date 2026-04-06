---
description: Continúa un cambio SDD desde donde se quedó
agent: sdd-orchestrator
---
Ejecuta el meta-comando de continuación para "{argument}".
Como orquestador, lee `openspec/changes/{argument}/state.yaml` (o todos si no hay argumento) para determinar la `current_phase` y `pending_phases`. Luego, delega inmediatamente la siguiente fase al sub-agente correspondiente.

CONTEXT:

- workdir: {workdir}
