---
description: Inicializa el contexto SDD — detecta el stack del proyecto e inicializa el backend de persistencia
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-init/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Inicializa el Desarrollo Guiado por Especificaciones (SDD) en este proyecto. Detecta el stack tecnológico, las convenciones existentes y los patrones de arquitectura. Inicializa el backend de persistencia activo según el modo de almacenamiento de artefactos resuelto.

Devuelve un resultado estructurado con: status, executive_summary, artifacts y next_recommended.
