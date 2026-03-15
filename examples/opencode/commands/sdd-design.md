---
description: Crea el documento de diseño técnico para un cambio
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-design/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Lee las especificaciones del cambio y crea el documento de diseño técnico. El documento debe incluir decisiones de arquitectura, enfoque técnico, estructura de archivos, interfaces, y cualquier otra información necesaria para implementar el cambio. Sigue las decisiones de diseño del proyecto y las convenciones establecidas.

Devuelve un resultado estructurado con: status, executive_summary, artifacts y next_recommended.
