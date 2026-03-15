---
description: Genera automáticamente CHANGELOG.md desde los cambios archivados
agent: sdd-orchestrator
subtask: true
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-changelog/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec

TASK:
Genera el changelog del proyecto. Lee todos los cambios archivados en `openspec/changes/archive/` y:
1. Extrae metadatos de cada proposal.md archivado (título, intención, alcance)
2. Genera CHANGELOG.md en la raíz del proyecto con formato:
   - Encabezado con título, descripción, fecha de generación
   - Entradas por cambio con formato: ## [{Fecha}] {Nombre}, **Intención**, **Alcance**
3. Ordena cambios por fecha (más reciente primero)
4. Maneja el caso de archive vacío

Devuelve un resultado estructurado con: status, executive_summary, artifacts y next_recommended.
