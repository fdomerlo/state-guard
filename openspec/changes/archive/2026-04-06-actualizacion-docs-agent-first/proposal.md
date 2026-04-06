# Propuesta: Actualización de documentación para reflejar enfoque Agent-First y CLI-First

## Intención

Posicionar Agentify-SDD como framework estrictamente "Agent-First" y "CLI-First", descontinuando soporte para editores pasivos/inline. La documentación actual contiene referencias a archivos inexistentes (`.cursorrules`, `integrations/cursor/`, `integrations/vscode/`) y menciones a funcionalidades inline que contradicen el diseño del proyecto.

## Alcance

### Dentro del Alcance
- Eliminar sección "Integración con IDEs" de AGENTS.md (líneas 156-161)
- Eliminar columna "Skills Inline" de la tabla en MANUAL.md (líneas 338-349)
- Purgar menciones incidentales a Codex, VS Code y Cursor en README.md y MANUAL.md
- Destacar que el orquestador delega a herramientas CLI autónomas (Claude Code, OpenCode, Gemini CLI, Antigravity)

### Fuera del Alcance
- Modificar scripts de instalación
- Crear nuevas integraciones con editores
- Actualizar archivos de configuración de herramientas existentes

## Enfoque

Edición directa (Enfoque 1 conservador). Se editarán los tres archivos principales con cambios localizados y de bajo riesgo. Los cambios son reversibles mediante git revert.

## Áreas Afectadas

| Área | Impacto | Descripción |
|------|---------|-------------|
| `AGENTS.md` | Modificado | Eliminar sección "Integración con IDEs" con referencias a archivos inexistentes |
| `MANUAL.md` | Modificado | Eliminar columna "Skills Inline" de tabla de herramientas |
| `README.md` | Modificado | Destacar carácter CLI-first del framework |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|--------|--------------|-------------|
| Documentación contradictoria tras cambios | Baja | Revisión manual post-cambio |
| Rechazo de usuarios que esperaban soporte VS Code/Cursor | Baja | Comunicar que el soporte nunca fue implementado |

## Plan de Rollback

Ejecutar `git revert` o restaurar archivos desde el commit anterior. Los cambios son completamente reversibles al estar solo en archivos de documentación.

## Dependencias

- Ninguna dependencia externa
- Solo se requiere acceso a los archivos AGENTS.md, MANUAL.md y README.md

## Criterios de Éxito

- [ ] AGENTS.md no contiene sección "Integración con IDEs"
- [ ] MANUAL.md no tiene columna "Skills Inline"
- [ ] README.md destaca el carácter CLI-First del framework
- [ ] No existen menciones a Codex, VS Code o Cursor como integraciones activas
