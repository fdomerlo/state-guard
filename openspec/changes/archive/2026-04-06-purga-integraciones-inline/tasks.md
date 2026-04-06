# Tareas: Purga de Integraciones Inline

## Fase 1: Eliminación de Carpetas

- [x] **Tarea 1.1** — Eliminar carpeta `integrations/codex/` completamente
  - Verificar que no existen otros archivos que dependan de esta ruta
  - Ejecutar: `rm -rf integrations/codex/`

- [x] **Tarea 1.2** — Eliminar carpeta `integrations/cursor/` completamente
  - Verificar que no existen otros archivos que dependan de esta ruta
  - Ejecutar: `rm -rf integrations/cursor/`

- [x] **Tarea 1.3** — Eliminar carpeta `integrations/vscode/` completamente
  - Verificar que no existen otros archivos que dependan de esta ruta
  - Ejecutar: `rm -rf integrations/vscode/`

## Fase 2: Scripts de Instalación

- [x] **Tarea 2.1** — Actualizar `scripts/install.sh`
  - Eliminar cases `codex`, `vscode`, `cursor` de `get_tool_path()` (líneas 97-117)
  - Eliminar casos de `install_for_agent()` (líneas 416-437)
  - Eliminar instalaciones de codex y cursor en `all-global` (líneas 453-456)
  - Reducir menú interactivo a 8 opciones, actualizar numeración (líneas 483-488)
  - Actualizar lista de agentes en `show_help()` (línea 171)

- [x] **Tarea 2.2** — Actualizar `scripts/install.ps1`
  - Eliminar cases `codex`, `vscode`, `cursor` de `Get-ToolPath()` (líneas 132-144)
  - Eliminar casos de `Install-ForAgent()` (líneas 476-503)
  - Eliminar instalaciones de codex y cursor en `all-global` (líneas 529-537)
  - Reducir menú interactivo a 8 opciones, actualizar numeración (líneas 570-575)
  - Actualizar lista de agentes en `Show-Help()` (línea 199)

## Fase 3: Suite de Pruebas

- [x] **Tarea 3.1** — Actualizar `scripts/install_test.sh`
  - Eliminar bloque de tests para Codex (líneas 257-267)
  - Eliminar bloque de tests para VS Code (líneas 273-287)
  - Eliminar bloque de tests para Cursor (líneas 309-319)
  - Ajustar tests de `all-global` a 3 targets (líneas 363-393)
  - Ajustar idempotency de `all-global` a 3 targets (líneas 429-442)
  - Actualizar expectativa a 51 skills (3 targets × 17 skills)

## Fase 4: Documentación

- [x] **Tarea 4.1** — Actualizar `MANUAL.md`
  - Eliminar fila de Codex en tabla de herramientas (línea ~342)
  - Eliminar fila de VS Code en tabla de herramientas (línea ~344)
  - Eliminar fila de Cursor en tabla de herramientas (línea ~346)

## Fase 5: Verificación

- [x] **Tarea 5.1** — Validar sintaxis de `install.sh`
  - Ejecutar: `bash -n scripts/install.sh`
  - Verificar salida sin errores

- [x] **Tarea 5.2** — Validar sintaxis de `install.ps1`
  - Ejecutar: `pwsh -n scripts/install.ps1`
  - Verificar salida sin errores

- [x] **Tarea 5.3** — Ejecutar suite de tests completa
  - Ejecutar: `bash scripts/install_test.sh`
  - Verificar que pasan todos los tests
  - Confirmar resultado: 51 skills instaladas (3 targets × 17 skills)

- [x] **Tarea 5.4** — Verificar MANUAL.md
  - Confirmar que no existen menciones de "Codex", "VS Code", "Cursor" en el archivo