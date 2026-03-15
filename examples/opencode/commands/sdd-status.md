---
description: Muestra el estado actual del cambio SDD activo — fase, tareas completadas, siguiente paso recomendado
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-status/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Muestra el estado actual del cambio SDD activo. Lee el archivo `state.yaml` del directorio `openspec/changes/{nombre-del-cambio}/` y presenta:
1. Fase actual del cambio
2. Fases completadas
3. Tareas restantes
4. Próximo paso recomendado

Devuelve un resultado estructurado con: status, executive_summary, artifacts y next_recommended.
