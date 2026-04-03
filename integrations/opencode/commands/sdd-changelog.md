---
description: Genera automáticamente CHANGELOG.md desde los cambios archivados
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-changelog/SKILL.md PRIMERO, y luego ejecuta sus instrucciones exactamente para el cambio {argument}.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec
