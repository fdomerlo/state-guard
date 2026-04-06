# Diseño: Actualización de documentación para enfoque Agent-First y CLI-First

## Enfoque Técnico

Este cambio actualiza la documentación del proyecto para posicionar Agentify-SDD como framework exclusivamente Agent-First y CLI-First. La implementación consiste en ediciones directas y localizadas en tres archivos de documentación, eliminando referencias a funcionalidades no implementadas (Skills Inline) y menciones a editores que nunca fueron desarrollados.

## Decisiones de Arquitectura

### Decisión: Eliminación directa versus reemplazo

**Elección**: Eliminación directa de las secciones y menciones identificadas.
**Alternativas consideradas**: Reemplazar con contenido diferente (e.g., declarando que las herramientas "no son soportadas").
**Justificación**: La eliminación directa es más clara y evitará confusiones futuras. Los archivos referenciados (`.cursorrules`, `integrations/cursor/`, `integrations/vscode/`) nunca fueron creados, por lo que no existe contenido de reemplazo válido.

### Decisión: Sección CLI-First en AGENTS.md

**Elección**: Agregar una declaración explícita de enfoque CLI-First en la sección de arquitectura de AGENTS.md.
**Alternativas consideradas**: Agregar al README.md exclusivamente.
**Justificación**: AGENTS.md es el archivo de referencia para agentes, por lo que debe contener la declaración canonical del enfoque del framework.

### Decisión: Tratamiento de la tabla de herramientas en MANUAL.md

**Elección**: Eliminar la columna "Skills Inline" y mantener solo "Sub-agentes" y "Tipo".
**Alternativas consideradas**: Eliminar toda la tabla de herramientas.
**Justificación**: La tabla es útil para usuarios; solo la columna "Skills Inline" genera confusión dado que no existe tal funcionalidad.

## Cambios de Archivos

| Archivo                      | Acción    | Descripción                                                           |
|------------------------------|-----------|-----------------------------------------------------------------------|
| `AGENTS.md`                  | Modificar | Eliminar sección "Integración con IDEs" (líneas 156-161); agregar declaración CLI-First |
| `MANUAL.md`                  | Modificar | Eliminar columna "Skills Inline" de tabla de herramientas (líneas 342-348) |
| `README.md`                  | Modificar | Agregar sección destacada de herramientas CLI compatibles             |

## Detalles de Edición por Archivo

### AGENTS.md

- **Líneas 156-161**: Eliminar sección "Integración con IDEs" completa
- **Agregar**: Nueva sub-sección en sección de arquitectura declarando enfoque CLI-First y listando herramientas compatibles (Claude Code, OpenCode, Gemini CLI, Antigravity)

### MANUAL.md

- **Líneas 342-348**: Modificar tabla para eliminar columna "Skills Inline"
- La tabla resultante tendrá dos columnas: "Herramienta" y "Sub-agentes"

### README.md

- **Agregar**: Nueva sección "Herramientas CLI Compatibles" o similar
- La sección listará las cuatro herramientas CLI autónomas con descripción breve de cada una

## Estrategia de Testing

| Capa        | Qué Testear                              | Enfoque                              |
|-------------|------------------------------------------|--------------------------------------|
| Revisión    | Archivos modificados no contienen contenido no deseado | Verificación manual con grep |
| Consistencia | Coherencia entre los tres archivos    | Comparación de terminología usada  |

Dado que este es un cambio de documentación, no se requieren tests unitarios ni de integración automatizados.

## Preguntas Abiertas

- [ ] Ninguna — los requisitos están claros y el alcance es manejable

---

## Criterios de Verificación

1. `AGENTS.md` no contiene la sección "Integración con IDEs" (líneas 156-161 eliminadas)
2. `AGENTS.md` contiene declaración explícita de enfoque CLI-First
3. `MANUAL.md` no tiene columna "Skills Inline" en la tabla de herramientas
4. `README.md` incluye sección destacada de herramientas CLI compatibles
5. Ningún archivo menciona VS Code, Cursor o Codex como integraciones activas
6. No existen referencias a archivos de IDE inexistentes (`.cursorrules`, `integrations/cursor/`, `integrations/vscode/`)
