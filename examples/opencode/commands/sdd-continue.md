---
description: Continúa la siguiente fase SDD en la cadena de dependencias
agent: sdd-orchestrator
---

Sigue el flujo de trabajo del orquestador SDD para continuar el cambio activo.

WORKFLOW:
1. Comprueba qué artefactos ya existen para el cambio activo (propuesta, especificaciones, diseño, tareas)
2. Determina la próxima fase necesaria según el grafo de dependencias:
   proposal → [specs ∥ design] → tasks → apply → verify → archive
3. Lanza el sub-agente apropiado para la siguiente fase
4. Presenta el resultado y pide al usuario que proceda

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

Lee las instrucciones del orquestador para coordinar este flujo de trabajo. NO ejecutes el trabajo de las fases directamente (inline) — delégalo a sub-agentes.
