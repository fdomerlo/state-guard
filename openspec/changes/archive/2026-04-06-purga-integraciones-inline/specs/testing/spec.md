# Spec Delta: Purga de Integraciones Inline — Testing

## Eliminación de Tests para Codex

### Escenario: Eliminar tests de Codex
- GIVEN install_test.sh contiene tests para codex (test_install_codex, test_codex_skill_count)
- WHEN Se ejecuta la purga de integraciones inline
- THEN test_install_codex DEBE SER ELIMINADO
- AND test_codex_skill_count DEBE SER ELIMINADO
- AND La sección "Codex" en el output de tests DEBE SER ELIMINADA

## Eliminación de Tests para VS Code

### Escenario: Eliminar tests de VS Code
- GIVEN install_test.sh contiene tests para vscode (test_install_vscode, test_vscode_skill_count)
- WHEN Se ejecuta la purga de integraciones inline
- THEN test_install_vscode DEBE SER ELIMINADO
- AND test_vscode_skill_count DEBE SER ELIMINADO
- AND La sección "VS Code (project-local)" en el output de tests DEBE SER ELIMINADA

## Eliminación de Tests para Cursor

### Escenario: Eliminar tests de Cursor
- GIVEN install_test.sh contiene tests para cursor (test_install_cursor, test_cursor_skill_count)
- WHEN Se ejecuta la purga de integraciones inline
- THEN test_install_cursor DEBE SER ELIMINADO
- AND test_cursor_skill_count DEBE SER ELIMINADO
- AND La sección "Cursor" en el output de tests DEBE SER ELIMINADA

## Actualización de Tests All-Global

### Escenario: Actualizar test_all_global
- GIVEN test_all_global verifica 5 directorios (claude-code, opencode, gemini-cli, codex, cursor)
- WHEN Se ejecuta la purga
- THEN test_all_global DEBE verificar solo 4 directorios (claude-code, opencode, gemini-cli, antigravity)
- AND DEBE eliminar la verificación de codex y cursor

### Escenario: Actualizar test_all_global_total_skill_count
- GIVEN test_all_global_total_skill_count espera 85 skills (5×17)
- WHEN Se ejecuta la purga
- THEN DEBE esperar 68 skills (4×17)
- AND Los directorios a verificar DEBEN ser actualizados соответственно

### Escenario: Actualizar test_all_global_opencode_commands
- GIVEN test_all_global_opencode_commands verifica que se instalen commands
- WHEN Se ejecuta la purga
- THEN test_all_global_opencode_commands DEBE continuar funcionando (OpenCode no se elimina)

### Escenario: Actualizar test_idempotent_all_global
- GIVEN test_idempotent_all_global verifica 5 directorios
- WHEN Se ejecuta la purga
- THEN DEBE verificar solo 4 directorios (claude-code, opencode, gemini-cli, antigravity)

## Validación Post-Purga

### Escenario: install_test.sh pasa todos los tests
- GIVEN install_test.sh ha sido purgado de codex, vscode, cursor
- WHEN Se ejecuta `bash scripts/install_test.sh`
- THEN DEBE mostrar 51 tests esperados (3 targets × 17 skills = 51)
- AND Todos los tests DEBEN pasar
- AND El output DEBE mostrar "All tests passed!"

### Escenario: Total de skills correcto post-purga
- GIVEN all-global ahora instala para 4 objetivos
- WHEN Se cuenta el total de SKILL.md instalados
- THEN DEBE haber 68 archivos (4 objetivos × 17 skills)

### Escenario: Test de idempotencia funciona
- GIVEN install_test.sh contiene tests de idempotencia
- WHEN Se ejecutan los tests de idempotencia
- THEN DEBEN pasar todos (la purga no afecta idempotencia)
