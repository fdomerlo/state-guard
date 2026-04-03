---
description: Inicia un nuevo cambio SDD (explore -> propose)
agent: sdd-orchestrator
---
Ejecuta el meta-comando de nuevo cambio para el feature "{argument}".
Como orquestador, inicializa el `state.yaml` y delega secuencialmente a:
1. sdd-explore (para investigar el código base)
2. sdd-propose (para redactar la propuesta inicial)

CONTEXT:
- workdir: {workdir}
- mode: openspec
