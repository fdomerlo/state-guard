---
description: Archiva un cambio SDD completado — sincroniza especificaciones y cierra el ciclo
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-archive/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Archiva el cambio SDD activo. Lee primero el reporte de verificación para confirmar que el cambio está listo. Luego:
1. Sincroniza las especificaciones delta hacia las especificaciones principales (fuente de la verdad)
2. Mueve la carpeta del cambio al archivo (archive) con el prefijo de fecha
3. Verifica que el archivo (archive) esté completo

Devuelve un resultado estructurado con: status, executive_summary, artifacts y next_recommended.
