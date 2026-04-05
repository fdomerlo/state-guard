# Diseño: sync-opencode-commands

## Enfoque Técnico

La implementación sigue un enfoque de **sincronización incremental** que mantiene compatibilidad hacia atrás mientras agrega los nuevos comandos de seguridad. Se crearán dos archivos de comando nuevos siguiendo el formato existente de delegación a skills, y se modificarán tres archivos existentes para agregar restricciones de contexto que optimicen el rendimiento del modelo.

## Decisiones de Arquitectura

| Decisión | Alternativas | Justificación |
|----------|--------------|---------------|
| Formato de comandos nuevos | Copiar estructura existente de `sdd-apply.md` | Consistencia con el patrón de delegación a skills en `~/.config/opencode/skills/` |
| Registro de comandos | Modificar `opencode.json` directamente | Formato simple de array JSON, sin cambios en esquema |
| Restricción de contexto | Agregar inline en prompt del comando | Minimiza cambios, mantiene todo en un archivo |
| Batching en apply | Inline task lot del orquestador | Evita lectura de `tasks.md` completo, reduce tokens |

## Formato de Comando OpenCode

Los nuevos comandos `sdd-checkpoint.md` y `sdd-rollback.md` siguen la estructura YAML + prompt existente:

```yaml
---
description: Descripción del comando
agent: sdd-orchestrator
subtask: true  # para apply, verify, checkpoint, rollback
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-{nombre}/SKILL.md PRIMERO, y luego ejecuta sus instrucciones exactamente para el cambio {argument}.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec
```

## Registro en opencode.json

Los nuevos comandos se registran en el array de configuración de OpenCode. Como el archivo actual solo define el agente `sdd-orchestrator` sin un array de comandos, se evaluará si es necesario agregar una sección de comandos o si los archivos en `commands/` se cargan automáticamente.

## Restricciones de Contexto

Se agregarán inline en cada archivo de comando existente:

**sdd-propose.md:**
```
RESTRICCIÓN: Lee solo el archivo `proposal.md` del cambio, NO toda la carpeta `changes/`.
```

**sdd-apply.md:**
```
RESTRICCIÓN: Lee solo los archivos en `openspec/changes/{nombre}/specs/`, NO toda la carpeta `specs/`.
ESPERA: Un lote de tareas inline del orquestador en lugar de leer `tasks.md` completo.
```

**sdd-verify.md:**
```
RESTRICCIÓN: Lee solo los archivos delta en `changes/{nombre}/specs/` y `design.md`, NO toda la carpeta `specs/`.
```

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `integrations/opencode/commands/sdd-checkpoint.md` | Crear | Comando checkpoint que delega al skill |
| `integrations/opencode/commands/sdd-rollback.md` | Crear | Comando rollback que delega al skill |
| `integrations/opencode/opencode.json` | Modificar | Agregar registro de comandos nuevos |
| `integrations/opencode/commands/sdd-apply.md` | Modificar | Agregar restricción de specs delta + batching |
| `integrations/opencode/commands/sdd-propose.md` | Modificar | Agregar restricción de specs delta |
| `integrations/opencode/commands/sdd-verify.md` | Modificar | Agregar restricción de specs delta |

## Preguntas Abiertas

- [ ] ¿El registro en `opencode.json` es necesario o los archivos en `commands/` se cargan automáticamente?
- [ ] ¿Hay otros comandos SDD que deberían incluirse en esta sincronización?
- [ ] ¿La restricción de batching debe incluir un límite de tareas por lote?