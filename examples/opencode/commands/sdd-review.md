---
description: Realiza una revisión detallada de un cambio SDD — verifica coherencia, calidad y completitud
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-review/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

Sigue el flujo de trabajo del orquestador SDD para revisar el cambio llamado "{argument}".

WORKFLOW:
1. Lee todos los artefactos del cambio (propuesta, specs, diseño, tareas)
2. Verifica la coherencia entre las fases completadas
3. Verifica la calidad y completitud de cada artefacto
4. Genera un informe estructurado con hallazgos y recomendaciones

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

Lee las instrucciones del orquestador para coordinar este flujo de trabajo.
