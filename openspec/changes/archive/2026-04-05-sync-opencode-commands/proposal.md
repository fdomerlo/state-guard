---
change: sync-opencode-commands
phase: propose
started_at: "2026-04-05T21:10:00"
---

# Proposal: Sincronización de OpenCode Commands

## Intención

Sincronizar la integración de OpenCode CLI con la refactorización del core SDD. La integración debe reflejar las capacidades definidas en `skills/` y exponer los nuevos comandos de seguridad (`/sdd-checkpoint`, `/sdd-rollback`).

## Alcance

| Componente | Acción | Prioridad |
|------------|--------|-----------|
| `integrations/opencode/commands/sdd-checkpoint.md` | **CREAR** | Alta |
| `integrations/opencode/commands/sdd-rollback.md` | **CREAR** | Alta |
| `integrations/opencode/opencode.json` | Modificar (registro) | Alta |
| `integrations/opencode/commands/sdd-apply.md` | Modificar (contexto + batching) | Media |
| `integrations/opencode/commands/sdd-propose.md` | Modificar (contexto) | Media |
| `integrations/opencode/commands/sdd-verify.md` | Modificar (contexto) | Media |

### Restricciones

1. **Nuevos Comandos**: Crear archivos que deleguen al skill correspondiente en `~/.config/opencode/skills/`.
2. **Contexto Estricto**: Los comandos deben indicar al modelo leer solo "Specs Delta" (`changes/{nombre}/specs/`) y NO toda la carpeta `specs/`.
3. **Batching**: `sdd-apply.md` debe indicar esperar lote inline de tareas, no leer `tasks.md` completo.

## Enfoque

### Fase 1: Crear Comandos Faltantes

Crear `sdd-checkpoint.md` y `sdd-rollback.md` siguiendo el formato existente:

```yaml
---
description: Descripción del comando
agent: sdd-orchestrator
subtask: true  # opcional
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-{nombre}/SKILL.md PRIMERO, y luego ejecuta sus instrucciones exactamente para el cambio {argument}.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec
```

### Fase 2: Actualizar opencode.json

Agregar entradas para los nuevos comandos en el array de configuración.

### Fase 3: Optimizar Contexto

Modificar comandos existentes para:

- **sdd-propose.md**: Añadir restricción "Lee solo el archivo `proposal.md` del cambio, NO toda la carpeta `changes/`."
- **sdd-apply.md**: Añadir restricción similar + "Espera un lote de tareas inline del orquestador en lugar de leer `tasks.md` completo."
- **sdd-verify.md**: Añadir restricción "Lee solo los archivos delta en `changes/{nombre}/specs/` y `design.md`, NO toda la carpeta `specs/`."

## Criterios de Éxito

- [ ] `sdd-checkpoint.md` creado en `commands/`
- [ ] `sdd-rollback.md` creado en `commands/`
- [ ] `opencode.json` actualizado con nuevos comandos
- [ ] `sdd-apply.md` tiene restricción de specs delta + batching
- [ ] `sdd-propose.md` tiene restricción de specs delta
- [ ] `sdd-verify.md` tiene restricción de specs delta

## Plan de Rollback

```bash
git checkout -- integrations/
```
