---
description: Explora e investiga una idea o característica — lee el código base y compara enfoques
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-explore/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Topic to explore: {argument}
- Artifact store mode: openspec

TASK:
Explora el tema "{argument}" en este código base. Investiga el estado actual, identifica las áreas afectadas, compara enfoques y proporciona una recomendación.

Esto es solo una exploración — NO crees ningún archivo ni modifiques código. Simplemente investiga y devuelve tu análisis.

Devuelve un resultado estructurado con: status, executive_summary, detailed_report, artifacts y next_recommended.
