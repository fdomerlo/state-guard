---
description: Genera una propuesta (proposal.md) standalone para un cambio SDD
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-propose/SKILL.md PRIMERO, y luego ejecuta sus instrucciones exactamente para el cambio {argument}.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

RESTRICCIÓN: Lee solo el archivo `proposal.md` del cambio, NO toda la carpeta `changes/`.
