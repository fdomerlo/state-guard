---
description: Valida que la implementación coincida con las especificaciones, diseño y tareas
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-verify/SKILL.md PRIMERO, y luego ejecuta sus instrucciones exactamente para el cambio {argument}.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

RESTRICCIÓN: Lee solo los archivos delta en `openspec/changes/{nombre}/specs/` y `design.md`, NO toda la carpeta `specs/`.
