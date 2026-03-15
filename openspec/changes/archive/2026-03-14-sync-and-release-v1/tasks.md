# Tareas: sync-and-release-v1 — Sincronización de Comandos OpenCode

## Fase 1: Preparación y Análisis

- [x] 1.1 Revisar plantilla de comandos existentes en `examples/opencode/commands/` para mantener consistencia de formato
- [x] 1.2 Identificar líneas exactas en `scripts/install_test.sh` que necesitan actualización (líneas 229, 396, 421)
- [x] 1.3 Localizar tabla de comandos en `README.md` para saber dónde agregar los nuevos comandos

## Fase 2: Creación de Archivos de Comando

- [x] 2.1 Crear `examples/opencode/commands/sdd-spec.md` siguiendo la plantilla del diseño (líneas 91-103)
- [x] 2.2 Crear `examples/opencode/commands/sdd-design.md` siguiendo la plantilla del diseño (líneas 105-118)
- [x] 2.3 Crear `examples/opencode/commands/sdd-tasks.md` siguiendo la plantilla del diseño (líneas 120-133)

## Fase 3: Actualización de Scripts de Test

- [x] 3.1 Modificar `scripts/install_test.sh` línea 229: cambiar assert_eq de 12 a 15 comandos
- [x] 3.2 Modificar `scripts/install_test.sh` línea 396: cambiar assert_eq de 12 a 15 comandos
- [x] 3.3 Modificar `scripts/install_test.sh` línea 421: cambiar assert_eq de 12 a 15 comandos
- [x] 3.4 Actualizar mensaje en `scripts/install_test.sh` para indicar "15 comandos" en lugar de "12 comandos"

## Fase 4: Actualización de Documentación

- [x] 4.1 Agregar entrada para `sdd-spec` en la tabla de comandos de `README.md`
- [x] 4.2 Agregar entrada para `sdd-design` en la tabla de comandos de `README.md`
- [x] 4.3 Agregar entrada para `sdd-tasks` en la tabla de comandos de `README.md`
- [x] 4.4 Actualizar el conteo total de comandos en `README.md` de 12 a 15

## Fase 5: Verificación

- [ ] 5.1 Ejecutar `scripts/install_test.sh` para verificar que los tests pasan con 15 comandos
- [ ] 5.2 Verificar que los 3 nuevos archivos de comando existen en `examples/opencode/commands/`
- [ ] 5.3 Verificar que `README.md` muestra correctamente la tabla con 15 comandos

## Fase 6: Rollback (Opcional - Solo si es necesario)

- [ ] 6.1 Eliminar `examples/opencode/commands/sdd-spec.md` si se requiere rollback
- [ ] 6.2 Eliminar `examples/opencode/commands/sdd-design.md` si se requiere rollback
- [ ] 6.3 Eliminar `examples/opencode/commands/sdd-tasks.md` si se requiere rollback
- [ ] 6.4 Revertir cambios en `scripts/install_test.sh` (contar de 15 a 12)
- [ ] 6.5 Revertir cambios en `README.md` (volver a 12 comandos)
