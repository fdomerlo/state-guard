---
description: Inicia un nuevo cambio SDD — ejecuta la exploración y luego crea una propuesta
agent: sdd-orchestrator
---

Sigue el flujo de trabajo del orquestador SDD para iniciar un nuevo cambio llamado "{argument}".

WORKFLOW:
1. Lanza el sub-agente sdd-explore para investigar el código base para este cambio
2. Presenta el resumen de la exploración al usuario
3. Lanza el sub-agente sdd-propose para crear una propuesta basada en la exploración
4. Presenta el resumen de la propuesta y pregunta al usuario si desea continuar con las especificaciones y el diseño

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

Lee las instrucciones del orquestador para coordinar este flujo de trabajo. NO ejecutes el trabajo de las fases directamente (inline) — delégalo a sub-agentes.
