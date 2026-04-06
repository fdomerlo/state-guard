# Propuesta: Purga de Integraciones Inline

## Intención

Posicionar Agentify-SDD como un marco exclusivamente **Agent-First** y **CLI-First** mediante la eliminación de soporte para herramientas visuales/pasivas (Codex, Cursor, VS Code/Copilot). Estas herramientas ejecutan skills inline sin capacidad de sub-agentes reales, lo cual es contrario al paradigma SDD que requiere orquestación de múltiples agentes.

## Alcance

### Dentro del Alcance
- Eliminar físicamente las carpetas `integrations/codex/`, `integrations/cursor/`, `integrations/vscode/`
- Actualizar `scripts/install.sh` eliminando casos y opciones de menú para codex, cursor, vscode
- Actualizar `scripts/install.ps1` con los mismos cambios en PowerShell
- Actualizar `scripts/install_test.sh` eliminando bloques de tests para las 3 herramientas
- Actualizar `MANUAL.md` eliminando las 3 filas de la tabla de herramientas

### Fuera del Alcance
- Modificar funcionalidades de las 4 herramientas restantes (Claude Code, OpenCode, Gemini CLI, Antigravity)
- Crear nuevas integraciones

## Enfoque

Implementación secuencial manual (Enfoque 1 de la exploración):
1. Eliminar carpetas de integrations/ con `rm -rf`
2. Actualizar install.sh: eliminar cases en `get_tool_path()`, casos en `install_for_agent()`, opciones de menú
3. Actualizar install.ps1: mismos cambios en PowerShell
4. Actualizar install_test.sh: eliminar bloques de tests, ajustar `all-global` a 3 objetivos
5. Actualizar MANUAL.md: eliminar filas de la tabla de herramientas
6. Validar con `bash -n install.sh` y ejecutar `bash scripts/install_test.sh`

## Áreas Afectadas

| Área              | Impacto      | Descripción                            |
|-------------------|-------------|----------------------------------------|
| `integrations/codex/`    | Eliminado   | Carpeta completa                       |
| `integrations/cursor/`    | Eliminado   | Carpeta completa                       |
| `integrations/vscode/`    | Eliminado   | Carpeta completa                       |
| `scripts/install.sh`     | Modificado  | Eliminados 15+ casos/referencias       |
| `scripts/install.ps1`    | Modificado  | Eliminados 15+ casos/referencias       |
| `scripts/install_test.sh`| Modificado  | Eliminados 6 bloques de tests         |
| `MANUAL.md`              | Modificado  | Eliminadas 3 filas de tabla           |

## Riesgos

| Riesgo               | Probabilidad | Mitigación                          |
|----------------------|--------------|-------------------------------------|
| Sintaxis de scripts rota | Alta    | Ejecutar `bash -n install.sh` post-cambio |
| Tests rotos          | Alta         | Ejecutar `bash scripts/install_test.sh` post-cambio |
| Menú desalineado     | Media        | Verificar opciones secuenciales     |

## Plan de Rollback

```bash
git checkout -- integrations/ scripts/install.sh scripts/install.ps1 scripts/install_test.sh MANUAL.md
```

## Dependencias

- Ninguna dependencia externa

## Criterios de Éxito

- [ ] Carpetas integrations/codex/, integrations/cursor/, integrations/vscode/ eliminadas físicamente
- [ ] install.sh funciona sin errores para herramientas restantes
- [ ] install.ps1 funciona sin errores para herramientas restantes
- [ ] install_test.sh pasa todos los tests (51 skills: 3 targets × 17 skills)
- [ ] MANUAL.md no menciona Codex, VS Code, Cursor
