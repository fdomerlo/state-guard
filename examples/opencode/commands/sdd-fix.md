---
description: Audita el directorio openspec/, detecta estados corruptos y repara archivos state.yaml desincronizados
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-fix/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Audita todos los archivos `state.yaml` activos en `openspec/changes/`, valida su schema y coherencia contra los artefactos en disco, y repara las discrepancias encontradas.

Devuelve un resultado estructurado siguiendo el Return Envelope definido en `skills/_shared/sdd-phase-common.md`.
