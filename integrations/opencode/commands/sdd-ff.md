---
description: Ejecuta propose, spec, design y tasks en secuencia
agent: sdd-orchestrator
---
Ejecuta el meta-comando SDD Fast-Forward para el cambio "{argument}".
Como orquestador, debes delegar secuencialmente a los siguientes sub-agentes, recordando GRABAR el `state.yaml` después de CADA fase interna:
1. sdd-propose
2. sdd-spec
3. sdd-design
4. sdd-tasks

CONTEXT:
- workdir: {workdir}
- mode: openspec
