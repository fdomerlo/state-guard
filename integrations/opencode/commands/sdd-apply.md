---
description: Implementa las tareas SDD — escribe código siguiendo especificaciones y diseño
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-apply/SKILL.md PRIMERO, y luego ejecuta sus instrucciones exactamente para el cambio {argument}.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

RESTRICCIÓN: Lee solo los archivos en `openspec/changes/{nombre}/specs/`, NO toda la carpeta `specs/`.
ESPERA: Un lote de tareas inline del orquestador en lugar de leer `tasks.md` completo.
