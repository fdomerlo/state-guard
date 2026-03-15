---
description: Desglosa un cambio en tareas de implementación
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-tasks/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Lee las especificaciones y el diseño técnico del cambio. Desglosa el cambio en tareas de implementación específicas y accionables. Cada tarea debe ser verificable y tener criterios de aceptación claros. Estructura las tareas en fases lógicas siguiendo el flujo de trabajo SDD.

Devuelve un resultado estructurado con: status, executive_summary, artifacts y next_recommended.
