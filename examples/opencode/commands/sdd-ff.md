---
description: Avanza rápidamente (fast-forward) todas las fases de planificación SDD — desde la propuesta hasta las tareas
agent: sdd-orchestrator
---

Sigue el flujo de trabajo del orquestador SDD para avanzar rápidamente todas las fases de planificación para el cambio "{argument}".

WORKFLOW:
Ejecuta estos sub-agentes en secuencia:
1. sdd-propose — crea la propuesta
2. sdd-spec — escribe las especificaciones
3. sdd-design — crea el diseño técnico
4. sdd-tasks — desglosa en tareas de implementación

Presenta un resumen combinado después de que TODAS las fases se completen (no entre cada una).

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Change name: {argument}
- Artifact store mode: openspec

Lee las instrucciones del orquestador para coordinar este flujo de trabajo. NO ejecutes el trabajo de las fases directamente (inline) — delégalo a sub-agentes.
