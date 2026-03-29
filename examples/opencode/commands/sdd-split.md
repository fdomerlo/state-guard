---
description: Analiza y divide una Proposal grande en sub-cambios
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-split/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

Sigue el flujo de trabajo del orquestador SDD para dividir la Proposal del cambio llamado "{argument}".

WORKFLOW:
1. Lee el archivo proposal.md del cambio
2. Identifica si la propuesta es demasiado grande o compleja
3. Propón subdivisiones en sub-cambios más pequeños
4. Guarda el plan en split-plan.md

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

Lee las instrucciones del orquestador para coordinar este flujo de trabajo.
