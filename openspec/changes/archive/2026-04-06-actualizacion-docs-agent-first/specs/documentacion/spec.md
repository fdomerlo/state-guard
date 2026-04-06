# Delta para documentación

## Requisitos AGREGADOS

### Requisito: Sección CLI-First en AGENTS.md

El archivo AGENTS.md SHALL incluir una sección que declare explícitamente el enfoque CLI-First del framework.

#### Escenario: Sección CLI-First presente

- GIVEN el archivo AGENTS.md existe en la raíz del proyecto
- WHEN se lee la sección de arquitectura
- THEN existe una declaración clara: "Agentify-SDD es un framework Agent-First y CLI-First"
- AND menciona las herramientas CLI soportadas (Claude Code, OpenCode, Gemini CLI, Antigravity)

### Requisito: Destacado de herramientas CLI en documentación

El archivo README.md SHALL incluir una sección destacada que enumere las herramientas CLI compatibles.

#### Escenario: README lista herramientas CLI

- GIVEN README.md existe en la raíz del proyecto
- WHEN se consulta la sección de integración
- THEN presenta una lista de herramientas CLI autónomas compatibles
- AND cada herramienta incluye descripción breve de su propósito

---

## Requisitos MODIFICADOS

### Requisito: Eliminación de sección de IDEs en AGENTS.md

El archivo AGENTS.md SHALL eliminar la sección "Integración con IDEs" y sus referencias a archivos inexistentes.

#### Escenario: Sección IDEs eliminada

- GIVEN AGENTS.md contiene sección "Integración con IDEs"
- WHEN se ejecuta el cambio de actualización
- THEN la sección "Integración con IDEs" ya no existe
- AND las referencias a `.cursorrules`, `integrations/cursor/`, `integrations/vscode/` son eliminadas

(Anteriormente: La sección existía con enlaces a archivos que no existen en el repositorio)

### Requisito: Eliminación de columna Skills Inline en MANUAL.md

El archivo MANUAL.md SHALL eliminar la columna "Skills Inline" de la tabla de herramientas.

#### Escenario: Columna Inline eliminada

- GIVEN MANUAL.md contiene tabla con columna "Skills Inline"
- WHEN se ejecuta el cambio
- THEN la columna "Skills Inline" es eliminada de la tabla
- AND la tabla solo contiene columnas válidas: Comando, Descripción, Tipo

(Anteriormente: La tabla incluía columna "Skills Inline" con valores "N/A" o similares)

### Requisito: Purgado de menciones a editores en README.md

El archivo README.md SHALL eliminar menciones a Codex, VS Code y Cursor como integraciones activas.

#### Escenario: Menciones a editores eliminadas

- GIVEN README.md contiene menciones a VS Code, Cursor o Codex
- WHEN se ejecuta el cambio
- THEN esas menciones son eliminadas o reemplazadas con referencias a herramientas CLI
- AND el documento no sugiere soporte para editores inline/pasivos

(Anteriormente: El documento mencionaba这些 herramientas como opciones de integración)

### Requisito: Actualización de área afectada en AGENTS.md

El archivo AGENTS.md SHALL actualizar la tabla de "Áreas Afectadas" para reflejar solo documentación.

#### Escenario: Áreas Afectadas actualizadas

- GIVEN AGENTS.md contiene tabla de áreas afectadas
- WHEN se actualiza para el cambio actual
- THEN las entradas muestran solo modificaciones a archivos de documentación
- AND no hay referencia a archivos de configuración de IDEs

(Anteriormente: Incluía referencias a integraciones con IDEs que nunca fueron implementadas)

---

## Requisitos ELIMINADOS

### Requisito: Referencias a archivos de IDE inexistentes

Las referencias a archivos de configuración de IDEs que no existen en el repositorio SHALL ser eliminadas.

(Motivo: Los archivos `.cursorrules`, `integrations/cursor/.cursorrules`, `integrations/vscode/copilot-instructions.md` nunca fueron creados, por lo que las referencias son enlaces rotos que confunden a los usuarios)

#### Escenario: Referencias eliminadas

- GIVEN la documentación ссылается a archivos inexistentes
- WHEN se ejecuta el cambio
- THEN todas las referencias a esos archivos son eliminadas
- AND no existen enlaces rotos en la documentación

### Requisito: Menciones a "Skills Inline" como característica

El concepto de "Skills Inline" SHALL ser eliminado de la documentación.

(Motivo: El framework nunca implementó esta funcionalidad y la tabla sugiere una característica que no existe)

#### Escenario: Concepto Inline eliminado

- GIVEN MANUAL.md menciona "Skills Inline"
- WHEN se ejecuta el cambio
- THEN el término no aparece en la documentación
- AND la tabla de herramientas solo lista skills ejecutables vía CLI

---

## Criterios de Verificación

1. AGENTS.md no contiene sección "Integración con IDEs"
2. AGENTS.md contiene declaración explícita de enfoque CLI-First
3. MANUAL.md no tiene columna "Skills Inline"
4. README.md destaca herramientas CLI compatibles
5. Ningún archivo menciona VS Code, Cursor o Codex como integraciones activas
6. No existen referencias a archivos de IDE inexistentes

---

## Archivos Afectados

| Acción | Archivo |
|--------|---------|
| Modificar | AGENTS.md |
| Modificar | MANUAL.md |
| Modificar | README.md |
