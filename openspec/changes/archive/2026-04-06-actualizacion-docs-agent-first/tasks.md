# Tareas: Actualización de documentación para enfoque Agent-First y CLI-First

## Fase 1: Edición de AGENTS.md

- [x] 1.1 Eliminar sección "Integración con IDEs" de AGENTS.md (líneas 156-161 completas)
- [x] 1.2 Agregar nueva sub-sección "Enfoque CLI-First" en sección de arquitectura de AGENTS.md declarando el enfoque Agent-First/CLI-First
- [x] 1.3 Listar herramientas CLI compatibles en la nueva sección: Claude Code, OpenCode, Gemini CLI, Antigravity

## Fase 2: Edición de MANUAL.md

- [x] 2.1 Modificar tabla de herramientas (líneas 342-348) para eliminar la columna "Skills Inline"
- [x] 2.2 Verificar que la tabla resultante tenga solo las columnas "Herramienta" y "Sub-agentes"
- [x] 2.3 Revisar que el texto circundante no mencione "inline" ni "Skills Inline"

## Fase 3: Edición de README.md

- [x] 3.1 Crear nueva sección "Herramientas CLI Compatibles" en README.md
- [x] 3.2 Listar las cuatro herramientas CLI con descripción breve de cada una
- [x] 3.3 Verificar que la sección destaque el carácter CLI-First del framework

## Fase 4: Verificación

- [x] 4.1 Ejecutar grep en el proyecto para confirmar que no existen menciones de "Codex", "VS Code", "Cursor" en archivos de documentación
- [x] 4.2 Verificar que no existan referencias a archivos inexistentes (`.cursorrules`, `integrations/cursor/`, `integrations/vscode/`)
- [x] 4.3 Revisar coherencia terminológica entre AGENTS.md, MANUAL.md y README.md
