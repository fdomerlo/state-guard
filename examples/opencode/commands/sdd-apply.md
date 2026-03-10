---
description: Implementa las tareas SDD — escribe código siguiendo especificaciones y diseño
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-apply/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

La habilidad sdd-apply (v2.0) soporta el flujo de trabajo TDD (ciclo RED-GREEN-REFACTOR) cuando `tdd: true` está configurado en los metadatos de la tarea. Cuando TDD está activo, escribe una prueba que falle primero, luego implementa el código mínimo para pasarla, y finalmente refactoriza.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Encuentra los artefactos activos del cambio SDD (propuesta, especificaciones, diseño, tareas). Léelos para entender qué necesita ser implementado.

Implementa las tareas restantes incompletas. Para cada tarea:
1. Lee los escenarios de especificación relevantes (criterios de aceptación)
2. Lee las decisiones de diseño (enfoque técnico)
3. Lee los patrones de código existentes en el proyecto
4. Escribe el código (si TDD está habilitado: escribe primero una prueba que falle, luego implementa, luego refactoriza)
5. Marca la tarea como completada [x]

Devuelve un resultado estructurado con: status, executive_summary, detailed_report (archivos cambiados), artifacts y next_recommended.
