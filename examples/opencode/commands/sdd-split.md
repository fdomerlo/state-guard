---
description: Analiza y divide una Proposal grande en sub-cambios
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-split/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

TASK:
Analiza la Proposal del cambio "{argument}" y, si es demasiado grande o compleja, divídela en sub-cambios manejables.

Devuelve un resultado estructurado siguiendo el Return Envelope definido en `skills/_shared/sdd-phase-common.md`.
