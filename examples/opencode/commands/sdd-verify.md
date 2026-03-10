---
description: Valida que la implementación coincida con las especificaciones, diseño y tareas
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-verify/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Verifica el cambio SDD activo. Lee los artefactos de propuesta, especificaciones, diseño y tareas. Luego:
1. Comprueba la completitud — ¿Están terminadas todas las tareas?
2. Comprueba la exactitud — ¿Coincide el código con las especificaciones?
3. Comprueba la coherencia — ¿Se siguieron las decisiones de diseño?
4. Ejecuta pruebas y haz un build (ejecución real)
5. Construye la matriz de cumplimiento de especificaciones

Devuelve un informe de verificación estructurado con: status, executive_summary, detailed_report, artifacts y next_recommended.
