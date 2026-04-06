# Exploración: Purga de Integraciones Inline

**Nombre del cambio:** `purga-integraciones-inline`  
**Fecha de exploración:** 2026-04-06  
**Modo de almacenamiento:** `openspec`

---

## Estado Actual del Código

### 1. Estructura de `integrations/`

```
integrations/
├── opencode/          ← SE MANTIENE (soporta sub-agentes reales)
│   ├── opencode.json
│   ├── commands/      ← 19 comandos SDD
│   └── opencode.json
├── gemini-cli/        ← SE MANTIENE
│   └── GEMINI.md
├── claude-code/       ← SE MANTIENE
│   └── CLAUDE.md
├── antigravity/       ← SE MANTIENE
│   └── sdd-orchestrator.md
├── codex/            ← ELIMINAR (inline, sin sub-agentes)
│   └── agents.md
├── cursor/           ← ELIMINAR (inline, sin sub-agentes)
│   └── .cursorrules
└── vscode/           ← ELIMINAR (inline, sin sub-agentes)
    └── copilot-instructions.md
```

Las herramientas a eliminar (Codex, Cursor, VS Code) **no soportan sub-agentes reales**:
- Codex: ejecuta skills inline
- Cursor: ejecuta skills inline (sin Task)
- VS Code: ejecuta skills inline

Las 4 herramientas que se mantienen (Claude Code, OpenCode, Gemini CLI, Antigravity) sí soportan sub-agentes reales o tienen características diferenciadas.

---

## Áreas Afectadas con Rutas Exactas

### 2.1 Archivos a Eliminar (físicamente)

| Ruta | Descripción |
|------|--------------|
| `integrations/codex/agents.md` | Instrucciones para Codex |
| `integrations/cursor/.cursorrules` | Configuración Cursor |
| `integrations/vscode/copilot-instructions.md` | Instrucciones VS Code Copilot |

### 2.2 Scripts de Instalación

**`scripts/install.sh`** (545 líneas):

| Línea(s) | Contenido a eliminar |
|----------|---------------------|
| 97-103 | Case `codex` en `get_tool_path()` |
| 104 | Case `vscode` |
| 111-117 | Case `cursor` |
| 171 | Help: `codex, vscode, cursor` |
| 416-418 | Instalación para `codex` |
| 420-424 | Instalación para `vscode` |
| 433-436 | Instalación para `cursor` |
| 453-455 | all-global: codex + cursor |
| 483-484 | Menú interactivo: Codex, VS Code |
| 486 | Menú interactivo: Cursor |

**`scripts/install.ps1`** (625 líneas):

| Línea(s) | Contenido a eliminar |
|----------|---------------------|
| 132-135 | Case `codex` en `Get-ToolPath()` |
| 136 | Case `vscode` |
| 141-143 | Case `cursor` |
| 199 | Help: `codex, vscode, cursor` |
| 476-479 | Instalación para `codex` |
| 481-486 | Instalación para `vscode` |
| 498-502 | Instalación para `cursor` |
| 530-537 | all-global: codex + cursor |
| 570-573 | Menú interactivo: Codex, VS Code, Cursor |

### 2.3 Suite de Pruebas

**`scripts/install_test.sh`** (690 líneas):

| Línea(s) | Contenido a eliminar |
|----------|---------------------|
| 253-267 | Tests Codex: `test_install_codex`, `test_codex_skill_count` |
| 269-287 | Tests VS Code: `test_install_vscode`, `test_vscode_skill_count` |
| 305-319 | Tests Cursor: `test_install_cursor`, `test_cursor_skill_count` |
| 371-372 | `all-global` verifica Codex |
| 374 | `all-global` verifica Cursor |
| 385-386 | all-global skill count: codex, cursor |
| 436-437 | all-global idempotency: codex, cursor |
| 615-616 | Ejecución tests Codex |
| 620-621 | Ejecución tests VS Code |
| 630-631 | Ejecución tests Cursor |

### 2.4 Documentación

**`README.md`** (172 líneas):
- Sin menciones directas de Codex, Cursor o VS Code en el contenido principal
- La tabla de comandos solo lista herramientas SDD

**`MANUAL.md`** (378 líneas):

| Línea(s) | Contenido |
|----------|-----------|
| 342-350 | Tabla de integración con herramientas |

```markdown
| Codex | — | ✅ |
| VS Code | — | ✅ |
| Cursor | — | ✅ |
```

Eliminar estas 3 filas de la tabla.

---

## Enfoques de Implementación

### Enfoque 1: Eliminación Secuencial (Recomendado)

1. **Eliminar carpetas de integrations/**
   - `rm -rf integrations/codex/`
   - `rm -rf integrations/cursor/`
   - `rm -rf integrations/vscode/`

2. **Actualizar install.sh**
   - Eliminar cases en `get_tool_path()`
   - Eliminar casos en `install_for_agent()`
   - Actualizar menú interactivo (opciones 4, 5, 7)
   - Actualizar help text
   - Actualizar all-global

3. **Actualizar install.ps1**
   - Mismos cambios que install.sh pero en PowerShell

4. **Actualizar install_test.sh**
   - Eliminar bloques de tests para las 3 herramientas
   - Actualizar all-global para solo 3 herramientas (Claude Code, OpenCode, Gemini CLI)

5. **Actualizar MANUAL.md**
   - Eliminar 3 filas de la tabla de herramientas

### Enfoque 2: Eliminación con Script Automatizado

Crear script que:
1. Elimine las carpetas
2. Use `sed` o similar para limpiar referencias en scripts
3. Genere diff para revisión manual

**Riesgo:** Mayor probabilidad de errores de sintaxis en scripts.

---

## Riesgos Identificados

| Riesgo | Severidad | Mitigación |
|--------|-----------|------------|
| **Sintaxis de scripts** | Alta | Ejecutar `bash -n install.sh` y `powershell -File install.ps1 -WhatIf` después de cambios |
| **Tests rotos** | Alta | Ejecutar `bash scripts/install_test.sh` antes y después |
| **Menú interactivo desalineado** | Media | Verificar que opciones 1-10 sigan secuenciales tras eliminar 3 |
| **Links rotos en otros docs** | Baja | Buscar otras referencias con grep |
| **all-global cambia de 5 a 3 objetivos** | Media | Actualizar el mensaje "Todos los orquestadores globales configurados automáticamente" |

### Verificaciones Post-Cambio

```bash
# Validar sintaxis de scripts
bash -n scripts/install.sh
powershell -NoProfile -Command "Get-Content scripts/install.ps1 -Raw | Invoke-Expression -WhatIf" 2>&1 || true

# Ejecutar tests
bash scripts/install_test.sh

# Verificar menciones residuales
grep -r "codex\|cursor\|vscode" --include="*.sh" --include="*.ps1" --include="*.md" .
```

---

## Recomendación

**Proceder con Enfoque 1 (Eliminación Secuencial)** porque:

1. **Bajo riesgo de errores** — cambios manuales con validación inmediata
2. **Historial limpio** — cada paso es un cambio atómico verificable
3. **Compatibilidad** — los scripts mantienen funcionalidad para las 4 herramientas restantes

**Notas adicionales:**
- La opción `all-global` pasará de instalar 5 objetivos a 3 (eliminar Codex y Cursor de la lista)
- El menú interactivo mantendrá 10 opciones pero las etiquetas cambiarán
- Los tests pasarán de ~45 a ~39 tests (6 tests eliminados de herramientas inline)
- La tabla en MANUAL.md pasará de 7 a 4 filas (solo Claude Code, OpenCode, Gemini CLI, Antigravity)

---

## Artefactos Generados

| Artefacto | Ubicación |
|-----------|------------|
| Exploration report (este archivo) | `openspec/changes/purga-integraciones-inline/exploration.md` |

**Siguiente fase sugerida:** `sdd-propose` para formalizar la propuesta de cambio.