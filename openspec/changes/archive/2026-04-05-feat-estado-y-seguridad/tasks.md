# Tareas: feat-estado-y-seguridad

## Fase 1: Modificar Schema de state.yaml

- [x] 1.1 Agregar campo `session_summary` al schema en `skills/_shared/openspec-convention.md`
  - Tipo: string, máximo 5 líneas
  - Ubicación: después de `blocked_reason`
  - Formato: incluye fase actual, estado, progreso, última acción y next_recommended

## Fase 2: Crear Skill sdd-checkpoint

- [x] 2.1 Crear estructura `skills/sdd-checkpoint/SKILL.md`
  - Trigger: `/sdd-checkpoint`
  - Tipo: skill directa (fase checkpoint)

- [x] 2.2 Implementar lógica de detección de cambio activo
  - Buscar `state.yaml` con `status: active` en `openspec/changes/*/`
  - Si no existe cambio activo, mostrar error

- [x] 2.3 Implementar generación de resumen
  - Leer `current_phase`, `completed_phases`, `pending_phases`
  - Si existe `tasks.md`, contar tareas completadas
  - Generar máximo 5 líneas de resumen

- [x] 2.4 Implementar guardado en `session_summary`
  - Escribir resumen en campo `session_summary` del `state.yaml`
  - Actualizar `last_updated` a fecha actual

## Fase 3: Crear Skill sdd-rollback

- [x] 3.1 Crear estructura `skills/sdd-rollback/SKILL.md`
  - Trigger: `/sdd-rollback`
  - Tipo: skill directa (fase rollback)

- [x] 3.2 Implementar detección de cambio activo
  - Verificar que existe cambio activo
  - Si no existe, mostrar error

- [x] 3.3 Implementar confirmación de usuario
  - Mostrar mensaje: "¿Estás seguro de revertir el cambio {nombre}? Esta acción es destructiva."
  - Si confirma: continuar con purge
  - Si cancela: salir sin acción

- [x] 3.4 Implementar purga de carpeta del cambio
  - Eliminar `openspec/changes/{nombre}/`

- [x] 3.5 Implementar restauración git
  - Ejecutar `git checkout -- .` desde raíz
  - Ejecutar `git clean -fd` desde raíz
  - Mostrar mensaje de éxito

## Fase 4: Registrar en Orquestador

- [x] 4.1 Agregar `/sdd-checkpoint` a `skills/_shared/orchestrator-commands.md`
  - Descripción: guarda resumen de sesión en state.yaml

- [x] 4.2 Agregar `/sdd-rollback` a `skills/_shared/orchestrator-commands.md`
  - Descripción: revierte cambio activo y restaura entorno

## Fase 5: Verificación

- [x] 5.1 Verificar que `session_summary` está en el schema de state.yaml
- [x] 5.2 Verificar que sdd-checkpoint genera resumen y lo guarda
- [x] 5.3 Verificar que sdd-rollback purga y restaura correctamente
- [x] 5.4 Verificar que ambos comandos están documentados en orchestrator-commands.md
- [x] 5.5 Verificar que el resumen no excede 5 líneas
- [x] 5.6 Verificar que rollback confirma antes de ejecutar operaciones destructivas