# Tareas: fix-opencode-commands

## Fase 1: Creación de Comandos Slash

- [x] 1.1 Crear `examples/opencode/commands/sdd-status.md` con estructura de comando subtask (sin argumentos, usa `subtask: true` en frontmatter, placeholders `{workdir}` y `{project}`)
- [x] 1.2 Crear `examples/opencode/commands/sdd-review.md` con estructura de comando que acepta argumento `{argument}` para nombre del cambio
- [x] 1.3 Crear `examples/opencode/commands/sdd-split.md` con estructura de comando que acepta argumento `{argument}` para nombre del cambio

## Fase 2: Actualización de Tests

- [x] 2.1 Modificar `scripts/install_test.sh` línea ~225: cambiar assertion de `"8"` a `"11"` en `test_opencode_commands()`
- [x] 2.2 Modificar `scripts/install_test.sh` línea ~392: cambiar assertion de `"8"` a `"11"` en `test_all_global_opencode_commands()`
- [x] 2.3 Modificar `scripts/install_test.sh` línea ~417: cambiar assertion de `"8"` a `"11"` en `test_idempotent_opencode()`
- [x] 2.4 Agregar en `scripts/install_test.sh` dentro de `test_opencode_commands()` verificación explícita para `sdd-status.md` usando `assert_file_exists`
- [x] 2.5 Agregar en `scripts/install_test.sh` dentro de `test_opencode_commands()` verificación explícita para `sdd-review.md` usando `assert_file_exists`
- [x] 2.6 Agregar en `scripts/install_test.sh` dentro de `test_opencode_commands()` verificación explícita para `sdd-split.md` usando `assert_file_exists`

## Fase 3: Verificación e Integración

- [x] 3.1 Ejecutar `bash scripts/install_test.sh` para verificar que todos los tests pasan
- [x] 3.2 Verificar que la instalación con `install.sh --agent opencode` muestra "11 commands installed"
- [x] 3.3 Verificar que los 11 comandos slash están disponibles en `~/.config/opencode/commands/`

## Criterios de Verificación

| Tarea | Criterio de Éxito |
|-------|-------------------|
| 1.1 | Archivo existe, frontmatter contiene `subtask: true`, placeholders `{workdir}` y `{project}` presentes |
| 1.2 | Archivo existe, frontmatter sin subtask, placeholder `{argument}` presente en TASK |
| 1.3 | Archivo existe, frontmatter sin subtask, placeholder `{argument}` presente en TASK |
| 2.1 | Test pasa con valor "11" |
| 2.2 | Test pasa con valor "11" |
| 2.3 | Test pasa con valor "11" |
| 2.4 | Verificación explícita presente y pasando |
| 2.5 | Verificación explícita presente y pasando |
| 2.6 | Verificación explícita presente y pasando |
| 3.1 | Todos los tests de `install_test.sh` pasan (exit code 0) |
| 3.2 | Output contiene "11 commands installed" |
| 3.3 | Directorio contiene 11 archivos sdd-*.md |
