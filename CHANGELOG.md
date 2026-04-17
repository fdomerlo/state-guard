# Changelog

Todos los cambios completados y archivados en el proyecto.

Generado el: 2026-04-06T18:30:00Z

---

## [2026-04-16] v1.1 - Consolidación ACID y Alineamiento POSIX

**Intención**: Actualización mayor de la infraestructura orquestativa con el foco cardinal puesto en la fiabilidad del histórico, el setup agnostic y el blindaje asegurado a los contratos directos de sub-agentes en sus outputs asimétricos.

**Alcance**:
- **Unificación de esquema de estado**: Schema estricto centralizado via campo `status: active|done|blocked` erradicando variables predecibles obsoletas (`blocked` boolean).
- **Contratos de delegación deterministas**: Clarificación operativa en la fase `apply` responsabilizando al agente lector, e introducción del dictamen "Paso 0" que frena archivados por errores `CRITICAL`.
- **Soporte POSIX en instalación**: Compatibilizaciones globales universales extirpando bashismos en brackets para `scripts/install.sh`.
- **Cleanup de seguridad en rollback**: Purga terminal de targets persistentes como `git clean -fd` devolviendo el entorno nativo `restore` preservando logs.
- Documentaciones actualizadas (Warm-Boot de memoria, mitigación hallucination, table commands).

---

## [2026-04-06] purga-integraciones-inline

**Intención**: Posicionar Agentify-SDD como un marco exclusivamente Agent-First y CLI-First mediante la eliminación de soporte para herramientas visuales/pasivas (Codex, Cursor, VS Code/Copilot). Estas herramientas ejecutan skills inline sin capacidad de sub-agentes reales, lo cual es contrario al paradigma SDD.

**Alcance**:

- Eliminar físicamente las carpetas `integrations/codex/`, `integrations/cursor/`, `integrations/vscode/`
- Actualizar `scripts/install.sh` eliminando casos y opciones de menú para codex, cursor, vscode
- Actualizar `scripts/install.ps1` con los mismos cambios en PowerShell
- Actualizar `scripts/install_test.sh` eliminando bloques de tests para las 3 herramientas
- Actualizar `MANUAL.md` eliminando las 3 filas de la tabla de herramientas

---

## [2026-04-06] purga-compatibilidad-inline-core

**Intención**: Erradicar del núcleo del proyecto cualquier instrucción, modo o fallback orientado a editores inline/pasivos (VS Code, Cursor, Codex). El proyecto Agentify SDD fue diseñado originalmente para soportar dos paradigmas, pero esta dualidad genera confusión y código defensivo innecesario.

**Alcance**:

- Eliminar el modo `none` del contrato de persistencia (`persistence-contract.md`)
- Purgar menciones a modo `none` en todos los SKILL.md de fases SDD
- Eliminar la carpeta de instrucciones inline en `skills/` si existe
- Reforzar el uso de herramientas (Tools) en `sdd-apply` y `sdd-verify`
- Actualizar `skill-registry` para quitar fallback de editores inline

---

## [2026-04-06] actualizacion-docs-agent-first

**Intención**: Posicionar Agentify-SDD como framework estrictamente Agent-First y CLI-First, descontinuando soporte para editores pasivos/inline. La documentación actual contiene referencias a archivos inexistentes y menciones a funcionalidades inline que contradicen el diseño del proyecto.

**Alcance**:

- Eliminar sección "Integración con IDEs" de AGENTS.md
- Eliminar columna "Skills Inline" de la tabla en MANUAL.md
- Purgar menciones incidentales a Codex, VS Code y Cursor en README.md y MANUAL.md
- Destacar que el orquestador delega a herramientas CLI autónomas (Claude Code, OpenCode, Gemini CLI, Antigravity)

---

## [2026-04-06] corregir-instalacion-antigravity

**Intención**: Corregir un error crítico en el script de instalación de bash (`scripts/install.sh`) que impide la instalación de skills para el agente Antigravity. El error ocurre porque la ruta de destino no está definida para este agente.

**Alcance**:

- Modificar `scripts/install.sh` para incluir la ruta de Antigravity en `get_tool_path`
- Agregar validación defensiva en la función `install_skills` de `scripts/install.sh` para evitar ejecuciones con rutas vacías
- Verificar que la instalación manual y automática (`all-global`) funcione correctamente para Antigravity en Linux/WSL

---

## [2026-04-05] refactor-core-modular

**Intención**: Reducir el consumo de tokens en fases avanzadas (sdd-apply, sdd-verify) mediante la división del archivo monolítico `orchestrator-core.md` en módulos especializados, y restringir la lectura de specs históricos.

**Alcance**:

- Dividir `skills/_shared/orchestrator-core.md` extrayendo 4 módulos a archivos separados
- Crear `orchestrator-delegation.md`, `orchestrator-state.md`, `orchestrator-commands.md`, `orchestrator-context.md`
- Modificar `sdd-apply/SKILL.md` para prohibir carga de `specs/` completo
- Modificar `sdd-verify/SKILL.md` para prohibir carga de `specs/` completo
- Implementar batching de tareas: pasar solo bloque de 3 tareas al sub-agente

---

## [2026-04-05] refactor-dry-skills

**Intención**: Eliminar duplicación masiva de texto (~1020 tokens) en las skills del orquestador SDD mediante la aplicación estricta del principio DRY (Don't Repeat Yourself).

**Alcance**:

- Eliminar Return Envelope estático de 14 archivos SKILL.md
- Eliminar secciones "Errores Comunes" en sdd-propose y sdd-apply
- Crear helper `test-runner-detection.md` con pseudocódigo de detección de test runner

---

## [2026-04-05] feat-estado-y-seguridad

**Intención**: Implementar mecanismos de seguridad ante fallos y optimizar la recuperación de sesión para el orquestador SDD, evitando tener que releer todo el histórico de artefactos tras una recarga del IDE.

**Alcance**:

- Agregar campo `session_summary` al schema de `state.yaml`
- Crear skill `/sdd-checkpoint` que resuma el estado del cambio activo
- Crear skill `/sdd-rollback` que purgue la carpeta del cambio y restaure el entorno desde git
- Registrar los nuevos comandos en el orquestador

---

## [2026-04-05] update-docs-architecture

**Intención**: Actualizar la documentación oficial del repositorio para reflejar la nueva arquitectura modular, las estrategias de ahorro de tokens y las herramientas de recuperación de sesión.

**Alcance**:

- MANUAL.md: Agregar documentación de comandos /sdd-checkpoint, /sdd-rollback
- README.md: Actualizar arquitectura y tabla de comandos
- AGENTS.md: Actualizar directivas de contexto

---

## [2026-04-05] sync-opencode-commands

**Intención**: Sincronizar la integración de OpenCode CLI con la refactorización del core SDD. La integración debe reflejar las capacidades definidas en `skills/` y exponer los nuevos comandos de seguridad.

**Alcance**:

- Crear `integrations/opencode/commands/sdd-checkpoint.md`
- Crear `integrations/opencode/commands/sdd-rollback.md`
- Actualizar `integrations/opencode/opencode.json` con nuevos comandos
- Modificar `sdd-apply.md`, `sdd-propose.md`, `sdd-verify.md` con contexto de specs delta y batching

---

## [2026-03-30] auditoria-integral-base-codigo

**Intención**: Corregir deuda técnica remanente, inconsistencias entre documentación y código, y errores de lógica identificados en el repositorio agentify-sdd.

**Alcance**:

- Corregir README.md agregando comando `/sdd-propose` omitido en la tabla de comandos
- Actualizar `orchestrator-core.md` para clarificar diferencia entre meta-comandos y comandos directos
- Corregir incoherencia en `openspec-convention.md`
- Refactorizar `scripts/install.sh`: eliminar placeholders, corregir URL de error, manejo de errores explícito

---

*Para ver cambios más antiguos, consultar el historial de commits del repositorio.*
