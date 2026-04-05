# Tareas: sync-opencode-commands

## Fase 1: Crear Nuevos Comandos

- [x] 1.1 Crear `integrations/opencode/commands/sdd-checkpoint.md`
  - Formato: YAML header + prompt de delegación al skill
  - Referencia: estructura de `sdd-apply.md` existente
- [x] 1.2 Crear `integrations/opencode/commands/sdd-rollback.md`
  - Formato: YAML header + prompt de delegación al skill
  - Referencia: estructura de `sdd-apply.md` existente

## Fase 2: Actualizar Registro JSON

- [x] 2.1 Verificar formato actual de `integrations/opencode/opencode.json`
- [x] 2.2 Agregar entrada para `sdd-checkpoint` al registro
- [x] 2.3 Agregar entrada para `sdd-rollback` al registro

## Fase 3: Aplicar Restricciones de Contexto

- [x] 3.1 Modificar `integrations/opencode/commands/sdd-apply.md`
  - Agregar RESTRICCIÓN: specs delta (solo `changes/{nombre}/specs/`)
  - Agregar ESPERA: lote inline de tareas (no leer `tasks.md`)
- [x] 3.2 Modificar `integrations/opencode/commands/sdd-propose.md`
  - Agregar RESTRICCIÓN: solo `proposal.md` del cambio
- [x] 3.3 Modificar `integrations/opencode/commands/sdd-verify.md`
  - Agregar RESTRICCIÓN: specs delta + `design.md`

## Fase 4: Verificación

- [x] 4.1 Verificar archivos de comandos creados existen
- [x] 4.2 Verificar opencode.json tiene nuevos comandos
- [x] 4.3 Verificar restricciones aplicadas en cada comando
- [x] 4.4 Ejecutar `/sdd-review sync-opencode-commands` (auditoría estática)
