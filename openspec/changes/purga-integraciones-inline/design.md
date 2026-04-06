# Diseño: Purga de Integraciones Inline

## Enfoque Técnico

Eliminación secuencial manual de las carpetas de integración para herramientas que no soportan sub-agentes reales (Codex, VS Code, Cursor). Se actualizarán los scripts de instalación y la suite de pruebas para operar únicamente con las 4 herramientas restantes.

## Decisiones de Arquitectura

| Decisión | Justificación |
|----------|----------------|
| Eliminar carpetas completas | Las herramientas no tienen más uso; mantener carpetas vacías genera confusión |
| No generar warnings de deprecated | Según requisitos de negocio: "cero retrocompatibilidad, borrado absoluto" |
| Mantener 4 herramientas restantes | Claude Code, OpenCode, Gemini CLI, Antigravity son las herramientas con soporte de sub-agentes |
| Tests pasan de 7 a 3 targets | 7 targets × 17 skills = 119 archivos → 3 targets × 17 skills = 51 archivos |

## Cambios de Archivos

### 1. Eliminación de Carpetas

```text
integrations/codex/     → eliminar
integrations/cursor/    → eliminar
integrations/vscode/    → eliminar
```

### 2. scripts/install.sh

| Sección | Líneas | Cambio |
|---------|--------|--------|
| `get_tool_path()` | 97-117 | Eliminar cases: codex, vscode, cursor |
| `install_for_agent()` | 416-437 | Eliminar casos: codex, vscode, cursor |
| `all-global` | 453-456 | Eliminar instalaciones de codex y cursor |
| `interactive_menu()` | 483-488 | Reducir a 8 opciones, actualizar numeración y texto |
| `show_help()` | 171 | Actualizar lista de agentes |

### 3. scripts/install.ps1

| Sección | Líneas | Cambio |
|---------|--------|--------|
| `Get-ToolPath()` | 132-144 | Eliminar cases: codex, vscode, cursor |
| `Install-ForAgent()` | 476-503 | Eliminar casos: codex, vscode, cursor |
| `all-global` | 529-537 | Eliminar instalaciones de codex y cursor |
| `Show-InteractiveMenu()` | 570-575 | Reducir a 8 opciones, actualizar numeración |
| `Show-Help()` | 199 | Actualizar lista de agentes |

### 4. scripts/install_test.sh

| Sección | Líneas | Cambio |
|---------|--------|--------|
| Tests Codex | 257-267 | Eliminar bloque de tests |
| Tests VS Code | 273-287 | Eliminar bloque de tests |
| Tests Cursor | 309-319 | Eliminar bloque de tests |
| Tests all-global | 363-393 | Ajustar a 3 targets (claude-code, opencode, gemini-cli) |
| Idempotency all-global | 429-442 | Ajustar a 3 targets |

### 5. MANUAL.md

| Sección | Líneas | Cambio |
|---------|--------|--------|
| Tabla de herramientas | 342-350 | Eliminar filas: Codex, VS Code, Cursor |

## Estrategia de Testing

Post-cambio ejecutar en secuencia:

```bash
# 1. Validar sintaxis Bash
bash -n scripts/install.sh

# 2. Validar sintaxis PowerShell (si disponible)
pwsh -n scripts/install.ps1

# 3. Ejecutar suite de tests
bash scripts/install_test.sh

# 4. Verificar resultado esperado
# - 51 skills instaladas (3 targets × 17 skills)
# - Todos los tests pasan
```

## Plan de Ejecución

### Paso 1: Eliminar carpetas de integración

```bash
rm -rf integrations/codex/ integrations/cursor/ integrations/vscode/
```

### Paso 2: Actualizar install.sh

- Eliminar cases `codex`, `vscode`, `cursor` en `get_tool_path()`
- Eliminar casos en `install_for_agent()`
- Actualizar `all-global` para solo instalar las 3 herramientas restantes
- Actualizar menú interactivo (opciones 1-8)
- Actualizar help text

### Paso 3: Actualizar install.ps1

- Mismos cambios que install.sh en sintaxis PowerShell

### Paso 4: Actualizar install_test.sh

- Eliminar bloques de tests para codex, vscode, cursor
- Ajustar `all-global` para solo verificar los 3 targets
- Verificar que el resultado esperado sea 51 skills (no 119)

### Paso 5: Actualizar MANUAL.md

- Eliminar las 3 filas de la tabla de herramientas

### Paso 6: Validar

- Ejecutar validación de sintaxis
- Ejecutar suite de tests

## Criterios de Éxito

- [ ] Carpetas integrations/codex/, integrations/cursor/, integrations/vscode/ eliminadas físicamente
- [ ] install.sh funciona sin errores para herramientas restantes
- [ ] install.ps1 funciona sin errores para herramientas restantes
- [ ] install_test.sh pasa todos los tests (51 skills: 3 targets × 17 skills)
- [ ] MANUAL.md no menciona Codex, VS Code, Cursor
