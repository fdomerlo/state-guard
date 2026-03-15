---
description: Analiza una tarea grande y la divide en subtareas más pequeñas y manejables
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-split/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

Sigue el flujo de trabajo del orquestador SDD para dividir las tareas del cambio llamado "{argument}".

WORKFLOW:
1. Lee el archivo de tareas (tasks.md) del cambio
2. Identifica tareas que son demasiado grandes o complejas
3. Propón subdivisiones con descripciones claras
4. Actualiza el archivo tasks.md con las nuevas subtareas

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

Lee las instrucciones del orquestador para coordinar este flujo de trabajo.
