---
description: Realiza una revisión detallada de un cambio SDD — verifica coherencia, calidad y completitud
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-review/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

TASK:
Realiza una auditoría estática del cambio "{argument}" comparando los artefactos generados contra las especificaciones. Genera un informe estructurado con hallazgos y recomendaciones.

Devuelve un resultado estructurado siguiendo el Return Envelope definido en `skills/_shared/sdd-phase-common.md`.
