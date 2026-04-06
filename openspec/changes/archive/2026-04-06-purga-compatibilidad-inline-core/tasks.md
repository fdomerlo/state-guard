# Tareas: Purga de Compatibilidad con Editores Inline/Pasivos

## Fase 1: Verificación Inicial

- [x] 1.1 Ejecutar `grep -r "none" skills/_shared/persistence-contract.md` para identificar menciones actuales al modo `none`
- [x] 1.2 Ejecutar `grep -r "none" skills/skill-registry/SKILL.md` para identificar menciones actuales
- [x] 1.3 Ejecutar `grep -r "none" skills/sdd-verify/SKILL.md` para identificar líneas a modificar
- [x] 1.4 Ejecutar `grep -r "none" skills/sdd-review/SKILL.md` para identificar líneas a modificar
- [x] 1.5 Ejecutar `grep -r "none" skills/sdd-fix/SKILL.md` para identificar líneas a modificar
- [x] 1.6 Ejecutar `grep -r "none" skills/sdd-split/SKILL.md` para identificar líneas a modificar

## Fase 2: Modificación de Archivos

- [x] 2.1 Modificar `skills/_shared/persistence-contract.md`: Eliminar referencias al modo `none`, forzar `openspec` como único modo válido según línea 58 del diseño
- [x] 2.2 Modificar `skills/skill-registry/SKILL.md`: Eliminar sección de fallback para editores inline (líneas 43-45 del diseño)
- [x] 2.3 Modificar `skills/sdd-verify/SKILL.md`: Eliminar menciones al modo `none` (líneas 22, 27, 170 del diseño)
- [x] 2.4 Modificar `skills/sdd-review/SKILL.md`: Eliminar menciones al modo `none` (líneas 24, 31, 120 del diseño)
- [x] 2.5 Modificar `skills/sdd-fix/SKILL.md`: Eliminar menciones al modo `none` (líneas 21, 29 del diseño)
- [x] 2.6 Modificar `skills/sdd-split/SKILL.md`: Eliminar menciones al modo `none` (líneas 20, 27, 132 del diseño)

## Fase 3: Verificación Post-Cambio

- [x] 3.1 Ejecutar `grep -r "none" skills/` para confirmar que no existen menciones residuales al modo `none`
- [x] 3.2 Ejecutar verificación con sdd-review para detectar menciones obsoletas al modo `none`
- [x] 3.3 Probar ejecución de `sdd-verify` para confirmar que la skill funciona sin el modo `none`
- [x] 3.4 Probar ejecución de `sdd-review` para confirmar funcionamiento correcto
- [x] 3.5 Probar ejecución de `sdd-fix` para confirmar funcionamiento correcto

## Fase 4: Actualización de Estado

- [x] 4.1 Actualizar `state.yaml` marcando la fase `apply` como completada
- [x] 4.2 Documentar cambios realizados en el registro del cambio
