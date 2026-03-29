---
description: Audita el directorio openspec/, detecta estados corruptos y repara archivos state.yaml desincronizados
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-fix/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

Sigue el flujo de trabajo del orquestador SDD para auditar y reparar el estado del proyecto.

WORKFLOW:
1. Escanea todos los archivos state.yaml en openspec/changes/
2. Valida el schema de cada state.yaml
3. Verifica que los artefactos requeridos por cada fase existan en disco
4. Repara discrepancias retrocediendo current_phase a la última fase válida
5. Genera un reporte estructurado con los resultados

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

Lee las instrucciones del orquestador para coordinar este flujo de trabajo.
