# Diseño: feat-estado-y-seguridad

## Enfoque Técnico

Implementar el campo `session_summary` como extensión del schema existente de `state.yaml`, manteniendo compatibilidad hacia atrás. Las skills `sdd-checkpoint` y `sdd-rollback` siguen el patrón de `sdd-fix` en estructura y formato YAML.

## Decisiones de Arquitectura

| Decisión | Alternativas | Justificación |
|----------|--------------|---------------|
| `session_summary` como campo opcional | Requerir siempre | Compatibilidad hacia atrás con cambios existentes |
| Checkpoint genera resumen automáticamente | Permitir entrada manual | Consistencia y automatización |
| Rollback usa git del workspace | rm + recreate | Preserva historial de git, más seguro |
| Confirmación explícita en rollback | Auto-ejecutar | Evita pérdida accidental de trabajo |

## Nuevo Campo session_summary

Agregar al schema de `state.yaml` en `skills/_shared/openspec-convention.md`:

```yaml
session_summary: |
  - Fase actual: {fase}
  - Estado: {active|blocked|done}
  - Progreso: {X/Y tareas completadas}
  - Última acción: {descripción breve}
  - next_recommended: /sdd-{comando}

```

El campo es de tipo string con máximo 5 líneas. Se coloca después de `blocked_reason`.

## Diseño de sdd-checkpoint

**Qué hace**: Genera resumen del estado actual del cambio y lo guarda en `session_summary`.

**Inputs**:
- Cambio activo (detectado desde `openspec/changes/*/state.yaml`)

**Outputs**:
- `state.yaml` actualizado con `session_summary` y `last_updated`

**Flujo**:
1. Detectar cambio activo (buscar `state.yaml` con `status: active`)
2. Leer `current_phase`, `completed_phases`, `pending_phases`
3. Si existe `tasks.md`, contar tareas completadas
4. Generar resumen de 5 líneas
5. Escribir en `session_summary` del `state.yaml`
6. Actualizar `last_updated` a fecha actual

**Comportamiento sin cambio activo**: Mostrar error "No hay cambio activo"

## Diseño de sdd-rollback

**Qué hace**: Purga la carpeta del cambio y restaura el entorno usando git.

**Inputs**:
- Cambio activo
- Confirmación del usuario

**Outputs**:
- Carpeta del cambio eliminada
- Archivos restaurados via git

**Flujo**:
1. Detectar cambio activo
2. Si no existe cambio activo, mostrar error
3. Solicitar confirmación: "¿Estás seguro de revertir el cambio {nombre}? Esta acción es destructiva."
4. Si usuario confirma:
   - Eliminar carpeta `openspec/changes/{nombre}/`
   - Ejecutar `git checkout -- .` desde raíz
   - Ejecutar `git clean -fd` desde raíz
   - Mostrar mensaje de éxito
5. Si usuario cancela, salir sin acción

**Nota de seguridad**: La confirmación es OBLIGATORIA. No ejecutar sin ella.

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `skills/_shared/openspec-convention.md` | Modificar | Agregar campo `session_summary` al schema |
| `skills/sdd-checkpoint/SKILL.md` | Crear | Skill de checkpoint |
| `skills/sdd-rollback/SKILL.md` | Crear | Skill de rollback |
| `skills/_shared/orchestrator-commands.md` | Modificar | Registrar `/sdd-checkpoint` y `/sdd-rollback` |

## Registro en Orquestador

Agregar a `orchestrator-commands.md` en sección "Skills Directos":

```markdown
- `/sdd-checkpoint` → ejecuta `sdd-checkpoint` (guarda resumen de sesión en state.yaml).
- `/sdd-rollback` → ejecuta `sdd-rollback` (revierte cambio activo y restaura entorno).
```

## Preguntas Abiertas

- [ ] ¿Debe `session_summary` incluirse en el cálculo de hash para detectar cambios?
- [ ] ¿Should `sdd-rollback` también limpiar el índice de git (git reset)?
- [ ] ¿Hay alguna consideración de seguridad adicional para entornos compartidos?
