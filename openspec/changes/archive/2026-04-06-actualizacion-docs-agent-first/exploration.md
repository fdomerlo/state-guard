## Exploración: Actualización de documentación para reflejar enfoque Agent-First y CLI-First

### Estado Actual

El proyecto Agentify SDD actualmente mantiene documentación que sugiere soporte para editoresinline/pasivos, aunque el framework está diseñado exclusivamente para agentes autônomos con capacidad de I/O en disco. Tras analizar los archivos clave, encontré lo siguiente:

**AGENTS.md** contiene una sección denominada "Integración con IDEs" (líneas 156-161) que hace referencia a archivos de configuración para editores que no existen en el repositorio: `.cursorrules` en raíz, `integrations/cursor/.cursorrules` e `integrations/vscode/copilot-instructions.md`. Estos archivos no fueron hallados mediante búsqueda glob, lo que genera una discrepancia entre la documentación y la realidad del proyecto.

**MANUAL.md** incluye una tabla titled "Integración con Herramientas" (líneas 338-349) con dos columnas: "Sub-agentes" y "Skills Inline". Esta tabla lista cuatro herramientas donde tres de ellas (Claude Code, OpenCode, Antigravity) tienen marca de verificación en ambas columnas, mientras que Gemini CLI solo tiene marca en "Skills Inline". La existencia de esta columna de "Skills Inline" implica que el sistema soporta ejecución inline, contradictorio con el enfoque purely agent-first que se desea comunicar.

**README.md** no contiene menciones explícitas a Codex, VS Code o Cursor. Su narrativa técnica describe correctamente al orquestador delegando tareas, pero no hay una declaración explícita de que el framework sea exclusivamente CLI-first.

**Directorio integrations/** contiene carpetas para cuatro herramientas: antigravity, claude-code, gemini-cli y opencode. No existen carpetas para cursor ni vscode, confirmando que la integración con estos editores nunca fue implementada más allá de menciones documentales.

### Áreas Afectadas

- `AGENTS.md` líneas 156-161 — Sección "Integración con IDEs" con referencias a archivos inexistentes
- `MANUAL.md` líneas 338-349 — Tabla "Integración con Herramientas" con columna "Skills Inline" que debe eliminarse
- `README.md` — Requiere revisión para asegurar que la narrativa destaque el carácter exclusively CLI-first
- `integrations/` — Las carpetas cursor y vscode no existen, pero la documentación las menciona

### Enfoques

**Enfoque 1 — Conservative (solo edición directa)**

Editar únicamente los archivos mencionados en las restricciones técnicas: AGENTS.md y MANUAL.md. Eliminar la sección de integración con IDEs en AGENTS.md, modificar la tabla en MANUAL.md quitando la columna "Skills Inline", y verificar que README.md no requiera cambios adicionales. Las carpetas no existentes en integrations/ se leave as-is.

- Ventajas: Mínimo riesgo, cambios localizados, fácil de revertir
- Desventajas: No aborda posibles menciones indirectas en otros archivos, no hay declaración explicita del enfoque
- Esfuerzo: Bajo

**Enfoque 2 — Completo con búsqueda extensiva**

Ejecutar una búsqueda comprehensiva con grep en todo el proyecto buscando términos como "cursor", "vscode", "codex", "inline" para identificar cualquier mención incidental. Aplicar los cambios en todos los archivos afectados y actualizar la narrativa en README.md para explicitly declare el enfoque agent-first.

- Ventajas: Asegura consistencia total, declaración clara del posicionamiento
- Desventajas: Mayor superficie de cambio, requiere más pruebas de coherencia
- Esfuerzo: Medio

### Recomendación

Recomiendo el **Enfoque 1** como punto de partida por ser más conservador y permitir iteración. Los cambios específicos están claramente definidos en las restricciones técnicas proporcionadas. Tras implementar estos cambios, se puede evaluar si es necesario expandir la búsqueda.

La implementación implicaría: en AGENTS.md, eliminar las líneas 156-161 completamente (sección "Integración con IDEs"); en MANUAL.md, modificar la tabla para usar solo la columna "Sub-agentes" con marca de verificación para todas las herramientas listed (Claude Code, OpenCode, Antigravity, Gemini CLI); en README.md, agregar una nota breve declarando el posicionamiento agent-first.

### Riesgos

- **Inconsistencia temporal:** Si la documentación se actualiza pero los scripts de instalación no se modifican, podría haber confusión durante la setup
- **Obsolescencia de integraciones:** Las carpetas en integrations/ podrían contener archivos que hacen referencia a editores descontinuados
- **Rechazo comunitario:** Usuarios que esperaban soporte para VS Code o Cursor podrían expresar preocupación

### Listo para Propuesta

**Sí** — La información recolectada es suficiente para crear una propuesta formal. La propuesta debería incluir: intención clara de posicionar Agentify SDD como framework agent-first, alcance cubriendo los tres archivos principales (AGENTS.md, MANUAL.md, README.md), y enfoque de implementación mediante edición directa siguiendo las restricciones técnicas proporcionadas.