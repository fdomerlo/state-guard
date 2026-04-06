# Spec Delta: Purga de Integraciones Inline — Install

## Eliminación de Agentes

### Escenario: Eliminar soporte para Codex
- GIVEN El script install.sh contiene casos para codex en `get_tool_path()` Y en `install_for_agent()` Y en `show_help()` Y en `interactive_menu()`
- WHEN Se ejecuta la purga de integraciones inline
- THEN El caso `codex` DEBE SER ELIMINADO de `get_tool_path()`
- AND El caso `codex` DEBE SER ELIMINADO de `install_for_agent()`
- AND La cadena `codex` DEBE SER ELIMINADA de `show_help()`
- AND La opción 4 Y caso 4 DEBEN SER ELIMINADOS de `interactive_menu()`

### Escenario: Eliminar soporte para VS Code (Copilot)
- GIVEN El script install.sh contiene casos para vscode en `get_tool_path()` Y en `install_for_agent()` Y en `show_help()` Y en `interactive_menu()`
- WHEN Se ejecuta la purga de integraciones inline
- THEN El caso `vscode` DEBE SER ELIMINADO de `get_tool_path()`
- AND El caso `vscode` DEBE SER ELIMINADO de `install_for_agent()`
- AND La cadena `vscode` DEBE SER ELIMINADA de `show_help()`
- AND La opción 5 Y caso 5 DEBEN SER ELIMINADOS de `interactive_menu()`

### Escenario: Eliminar soporte para Cursor
- GIVEN El script install.sh contiene casos para cursor en `get_tool_path()` Y en `install_for_agent()` Y en `show_help()` Y en `interactive_menu()`
- WHEN Se ejecuta la purga de integraciones inline
- THEN El caso `cursor` DEBE SER ELIMINADO de `get_tool_path()`
- AND El caso `cursor` DEBE SER ELIMINADO de `install_for_agent()`
- AND La cadena `cursor` DEBE SER ELIMINADA de `show_help()`
- AND La opción 7 Y caso 7 DEBEN SER ELIMINADOS de `interactive_menu()`

### Escenario: Actualizar opción "All global"
- GIVEN El script install.sh contiene `all-global` que instala para codex Y cursor
- WHEN Se ejecuta la purga de integraciones inline
- THEN `all-global` DEBE instalar solo para claude-code, opencode, gemini-cli, antigravity (4 objetivos)
- AND La cadena en el mensaje DEBE actualizar a "Claude Code + OpenCode + Gemini CLI + Antigravity"

### Escenario: Actualizar menú interactivo
- GIVEN El menú interactivo tiene 10 opciones
- WHEN Se eliminan codex, vscode, cursor
- THEN El menú DEBE tener 7 opciones
- AND Las opciones DEBEN re numerarse consecutivamente desde 1
- AND Los casos en el switch DEBEN actualizarse соответственно

## Validación Post-Purga

### Escenario: install.sh funciona para Claude Code
- GIVEN install.sh ha sido purgado de codex, vscode, cursor
- WHEN Se ejecuta `bash install.sh --agent claude-code`
- THEN El script DEBE completar sin errores
- AND DEBE instalar las 17 skills en ~/.claude/skills

### Escenario: install.sh funciona para OpenCode
- GIVEN install.sh ha sido purgado de codex, vscode, cursor
- WHEN Se ejecuta `bash install.sh --agent opencode`
- THEN El script DEBE completar sin errores
- AND DEBE instalar las 17 skills en ~/.config/opencode/skills

### Escenario: install.sh funciona para Gemini CLI
- GIVEN install.sh ha sido purgado de codex, vscode, cursor
- WHEN Se ejecuta `bash install.sh --agent gemini-cli`
- THEN El script DEBE completar sin errores
- AND DEBE instalar las 17 skills en ~/.gemini/skills

### Escenario: install.sh funciona para Antigravity
- GIVEN install.sh ha sido purgado de codex, vscode, cursor
- WHEN Se ejecuta `bash install.sh --agent antigravity`
- THEN El script DEBE completar sin errores
- AND DEBE instalar las 17 skills en ~/.gemini/antigravity/skills

### Escenario: Validación de sintaxis Bash
- GIVEN install.sh ha sido modificado
- WHEN Se ejecuta `bash -n install.sh`
- THEN El comando DEBE exits con código 0 (sin errores de sintaxis)

## PowerShell (install.ps1)

### Escenario: Purga equivalente en install.ps1
- GIVEN install.ps1 contiene los mismos casos para codex, vscode, cursor
- WHEN Se ejecuta la purga
- THEN install.ps1 DEBE ser actualizado con los mismos cambios que install.sh
- AND La función Get-ToolPath DEBE eliminar codex, vscode, cursor
- AND La función Install-ForAgent DEBE eliminar codex, vscode, cursor
- AND Show-InteractiveMenu DEBE actualizar el menú a 7 opciones
- AND La ayuda DEBE actualizarse соответственно

### Escenario: install.ps1 funciona post-purga
- WHEN Se ejecuta `pwsh install.ps1 -Agent claude-code` (o cualquier agente válido)
- THEN El script DEBE completar sin errores
