---
description: Escribe especificaciones delta para un cambio SDD
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-spec/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Analiza la propuesta del cambio proporcionada por el orquestador. Identifica los requisitos funcionales y no funcionales, los casos de uso y los criterios de aceptación. Escribe las especificaciones delta siguiendo el formato de OpenSpec y guárdalas en la carpeta specs del cambio.

Devuelve un resultado estructurado con: status, executive_summary, artifacts y next_recommended.
