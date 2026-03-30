---
description: Genera una propuesta (proposal.md) standalone para un cambio SDD
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-propose/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:

- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

TASK:
Genera una propuesta (proposal.md) para el cambio "{argument}". Si existe una exploración previa, úsala como input.

Devuelve un resultado estructurado siguiendo el Return Envelope definido en `skills/_shared/sdd-phase-common.md`.
