---
description: Purga la carpeta del cambio y restaura los archivos modificados desde git
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-rollback/SKILL.md PRIMERO, y luego ejecuta sus instrucciones exactamente para el cambio {argument}.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec
