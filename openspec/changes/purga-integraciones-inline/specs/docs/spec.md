# Spec Delta: Purga de Integraciones Inline — Documentación

## Eliminación de Referencias en MANUAL.md

### Escenario: Eliminar fila de Codex en tabla de herramientas
- GIVEN MANUAL.md contiene una fila para Codex en la tabla de herramientas
- WHEN Se ejecuta la purga de integraciones inline
- THEN La fila "Codex" DEBE SER ELIMINADA de la tabla

### Escenario: Eliminar fila de VS Code en tabla de herramientas
- GIVEN MANUAL.md contiene una fila para VS Code en la tabla de herramientas
- WHEN Se ejecuta la purga de integraciones inline
- THEN La fila "VS Code" DEBE SER ELIMINADA de la tabla

### Escenario: Eliminar fila de Cursor en tabla de herramientas
- GIVEN MANUAL.md contiene una fila para Cursor en la tabla de herramientas
- WHEN Se ejecuta la purga de integraciones inline
- THEN La fila "Cursor" DEBE SER ELIMINADA de la tabla

### Escenario: Tabla de herramientas reducida
- GIVEN MANUAL.md tenía 7 filas en la tabla de herramientas
- WHEN Se eliminan codex, vscode, cursor
- THEN La tabla DEBE tener 4 filas (Claude Code, OpenCode, Antigravity, Gemini CLI)
- AND La columna "Skills Inline" DEBE mostrar "✅" para Claude Code, OpenCode, Antigravity, "✅" para Gemini CLI

## Validación Post-Purga

### Escenario: MANUAL.md no menciona Codex
- GIVEN MANUAL.md ha sido purgado
- WHEN Se busca la cadena "Codex" en el archivo
- THEN NO DEBE encontrar coincidencias

### Escenario: MANUAL.md no menciona VS Code
- GIVEN MANUAL.md ha sido purgado
- WHEN Se busca la cadena "VS Code" o "VSCode" en el archivo
- THEN NO DEBE encontrar coincidencias

### Escenario: MANUAL.md no menciona Cursor
- GIVEN MANUAL.md ha sido purgado
- WHEN Se busca la cadena "Cursor" en el archivo
- THEN NO DEBE encontrar coincidencias

### Escenario: MANUAL.md mantiene coherencia
- GIVEN MANUAL.md ha sido actualizado tras la purga
- WHEN Se revisa el documento
- THEN Las instrucciones de instalación DEBEN seguir siendo válidas
- AND El documento DEBE seguir siendo legible y coherente
