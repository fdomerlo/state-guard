# Exploration Report: OpenCode Commands Sync

**Change**: sync-opencode-commands  
**Date**: 2026-04-05  
**Phase**: explore

---

## Resumen Ejecutivo

Se realizó una investigación del código base para entender la estructura de integración de OpenCode CLI y determinar los pasos necesarios para sincronizar los comandos con la refactorización del core SDD. La integración actual consiste en 17 archivos de comandos y un archivo de configuración `opencode.json` que define el orquestador.

---

## 1. Estructura de `integrations/opencode/`

### Directorio Principal

```
integrations/opencode/
├── opencode.json           # Configuración del agente
└── commands/              # Comandos disponibles (17 archivos)
    ├── sdd-apply.md
    ├── sdd-archive.md
    ├── sdd-changelog.md
    ├── sdd-continue.md
    ├── sdd-design.md
    ├── sdd-explore.md
    ├── sdd-fix.md
    ├── sdd-ff.md
    ├── sdd-init.md
    ├── sdd-new.md
    ├── sdd-propose.md
    ├── sdd-review.md
    ├── sdd-spec.md
    ├── sdd-split.md
    ├── sdd-status.md
    ├── sdd-tasks.md
    └── sdd-verify.md
```

### Análisis de Estructura

Los archivos de comandos siguen un formato YAML frontmatter simple:

```yaml
---
description: Descripción del comando
agent: sdd-orchestrator
subtask: true  # Opcional, indica sub-tarea
---
```

 followed by a brief instruction to read the skill file.

---

## 2. Comandos Registrados en `opencode.json`

### Configuración del Agente

```json
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "sdd-orchestrator": {
      "mode": "all",
      "description": "SDD Orchestrator — lean prompt, delega trabajo a skills",
      "prompt": "# Orquestador SDD — OpenCode\n\nActúas como el Orquestador Técnico Principal...",
      "tools": {
        "read": true,
        "write": true,
        "edit": true,
        "bash": true
      }
    }
  }
}
```

### Comandos Identificados

| Comando | Descripción | Subtarea |
|---------|-------------|----------|
| sdd-init | Inicializa contexto SDD | No |
| sdd-new | Inicia nuevo cambio | No |
| sdd-continue | Continúa fase pendiente | No |
| sdd-ff | Fast-forward de planificación | No |
| sdd-explore | Investiga idea | No |
| sdd-propose | Genera propuesta | No |
| sdd-spec | Escribe especificaciones delta | No |
| sdd-design | Crea documento de diseño | No |
| sdd-tasks | Crea lista de tareas | No |
| sdd-apply | Implementa tareas | Sí |
| sdd-verify | Valida implementación | Sí |
| sdd-archive | Archiva cambio completado | No |
| sdd-fix | Repara estados corruptos | No |
| sdd-review | Auditoría estática | No |
| sdd-status | Muestra estado | No |
| sdd-changelog | Genera changelog | No |
| sdd-split | Divide tareas | No |

### Formato de Registro

El formato actual usa:
- **Frontmatter YAML**: metadata del comando
- **Template literal**: `{argument}`, `{workdir}`, `{project}` para sustitución de variables
- **Delegación**: El comando delega al skill correspondiente en `~/.config/opencode/skills/`

---

## 3. Estado de "Errores Comunes" en Comandos

### Comandos Analizados

| Comando | ¿Tiene "Errores Comunes"? |
|---------|---------------------------|
| sdd-apply.md | NO |
| sdd-propose.md | NO |
| sdd-verify.md | NO |
| sdd-spec.md | NO |
| sdd-design.md | NO |

### Hallazgo

**NO existe sección "Errores Comunes" en ningún archivo de comando de OpenCode.** Los comandos actuales son minimalistas (11-12 líneas) y solo delegan al skill correspondiente sin incluir lógica de manejo de errores ni advertencias.

---

## 4. Skills de Checkpoint y Rollback

### `sdd-checkpoint` (125 líneas)

**Propósito**: Generar resumen de sesión para recuperación tras reload del IDE.

**Funcionalidad**:
1. Detectar cambio activo buscando `state.yaml` con `status: active`
2. Leer estado del cambio (current_phase, status, completed/pending phases)
3. Calcular progreso de tareas desde `tasks.md`
4. Generar resumen de 5 líneas con formato:
   ```
   - Fase actual: {current_phase}
   - Estado: {status}
   - Progreso: {X/Y tareas completadas}
   - Última acción: {breve descripción}
   - next_recommended: /sdd-{siguiente comando}
   ```
5. Guardar en campo `session_summary` del `state.yaml`
6. Actualizar `last_updated`

**Reglas**:
- Máximo 5 líneas en resumen
- Si no hay cambio activo → error
- Si no existe `tasks.md` → usar "N/A"
- Campo opcional para compatibilidad hacia atrás

### `sdd-rollback` (97 líneas)

**Propósito**: Revertir completamente un cambio activo (skill de emergencia).

**Funcionalidad**:
1. Detectar cambio activo
2. Obtener nombre del cambio desde `state.yaml`
3. **Confirmar con usuario** (crítico)
4. Purgar carpeta `openspec/changes/{nombre}/`
5. Restaurar entorno git: `git checkout -- . && git clean -fd`

**Reglas**:
- SIEMPRE confirmar antes de operación destructiva
- Si no hay cambio activo → error
- No usar para cambios finalizados

---

## 5. Recomendaciones de Implementación

### Alta Prioridad

1. **Registrar nuevos comandos en `opencode.json`**:
   - Agregar entrada para `sdd-checkpoint`
   - Agregar entrada para `sdd-rollback`

2. **Crear archivos de comando en `integrations/opencode/commands/`**:
   - `sdd-checkpoint.md` (sigue el formato existente)
   - `sdd-rollback.md` (sigue el formato existente)

3. **Copiar a configuración del usuario**:
   - Los comandos deben estar en `~/.config/opencode/commands/`
   - Los skills deben estar en `~/.config/opencode/skills/`

### Media Prioridad

4. **Añadir sección "Errores Comunes" a comandos existentes**:
   - Aunque los skills originales pueden tener esta sección, los archivos de comando no la incluyen
   - Considerar añadir en cada comando: error de cambio activo no encontrado, permisos, formato inválido

5. **Verificar consistencia de nombres**:
   - Los nombres de comandos SDD deben ser consistentes entre:
     - `skills/sdd-*/SKILL.md` (nombre del skill)
     - `integrations/opencode/commands/sdd-*.md` (comando)
     - `openspec/changes/*/` (carpeta de cambio)

### Baja Prioridad

6. **Documentar el flujo de instalación**:
   - Crear script o instrucciones para copiar archivos de `integrations/opencode/` a `~/.config/opencode/`

---

## 6. Próximos Pasos (Fase Propose)

- Proponer estructura de cambios necesarios
- Definir alcance de la sincronización
- Identificar dependencias (scripts de instalación)

---

## Archivos Relevantes

- `/home/ctrbts/workspace/github.com/ctrbts/agentify-sdd/integrations/opencode/opencode.json`
- `/home/ctrbts/workspace/github.com/ctrbts/agentify-sdd/integrations/opencode/commands/*.md`
- `/home/ctrbts/workspace/github.com/ctrbts/agentify-sdd/skills/sdd-checkpoint/SKILL.md`
- `/home/ctrbts/workspace/github.com/ctrbts/agentify-sdd/skills/sdd-rollback/SKILL.md`
