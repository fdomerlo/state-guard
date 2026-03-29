# Changelog

Todos los cambios completados y archivados en el proyecto.

Generado el: 2026-03-24T12:00:00Z

---

## [2026-03-29] feat-sdd-fix

**Intención**: Implementación completa de la skill `sdd-fix` para auditoría y reparación de estados corruptos, incluyendo comando OpenCode y actualización de la suite de tests.

**Alcance**:

- Crear `skills/sdd-fix/SKILL.md` — skill de auditoría que escanea `state.yaml`, valida schema y coherencia en disco, y repara discrepancias retrocediendo `current_phase` a la última fase válida
- Crear `examples/opencode/commands/sdd-fix.md` — comando slash para OpenCode
- Registrar `/sdd-fix` en `skills/_shared/orchestrator-core.md`
- Actualizar `scripts/install_test.sh` (14→15 skills, 15→16 comandos, 70→75 global)
- Restaurar la sección `/sdd-fix` en `MANUAL.md` (previamente documentada pero sin implementación)

---

## [2026-03-29] refactor-orchestrator-core

**Intención**: Refactorizar la arquitectura del orquestador SDD para eliminar deuda técnica, optimizar el consumo de tokens y asegurar la precisión en las validaciones de git y testing.

**Alcance**:

- **Core**: Unificación del esquema de estado (`state.yaml`) para utilizar exclusivamente `current_phase`.
- **Arquitectura**: Sincronización del DAG a un flujo estrictamente lineal (`explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive`).
- **Optimización de Tokens**: Eliminación de la carga redundante de contratos globales (`openspec-convention.md`, `persistence-contract.md`) en los sub-agentes, delegando la provisión de rutas exactas al orquestador.
- **Seguridad**: Refuerzo de `sdd-archive` para bloquear el archivado ante cualquier cambio no commiteado en el repositorio (no solo en la carpeta de specs).
- **Testing**: Prohibición estricta de validaciones estáticas/alucinadas en `sdd-apply` y `sdd-verify`; ahora se exige ejecución real en terminal.

## [2026-03-24] refactor-instalador-y-contratos-base

**Intención**: Robustecer el script de instalación cambiando los marcadores de inyección por comentarios HTML (para no romper el renderizado Markdown en los IDEs) y purgar los contratos de persistencia compartidos para eliminar cualquier rastro de dependencias externas o bases de datos vectoriales (Engram).

**Alcance**:

- Cambiar marcadores `### BEGIN/END SDD ORCHESTRATOR ###` por `<!-- BEGIN/END SDD ORCHESTRATOR -->` en `scripts/install.sh`
- Purga de menciones a `engram`, `hybrid` y `auto` en `skills/_shared/orchestrator-core.md`
- Los contratos `persistence-contract.md` y `openspec-convention.md` ya estaban limpios

---

## [2026-03-24] refactor-contexto-y-skill-registry-local

**Intención**: Centralizar el contrato DRY del Return Envelope en un archivo común, inyectar presupuestos de tamaño en las skills de fase para proteger la ventana de contexto, y habilitar el descubrimiento dinámico de skills mediante un registry generado automáticamente.

**Alcance**:

- Crear `skills/_shared/sdd-phase-common.md` con el contrato del Return Envelope unificado
- Inyectar presupuestos de tamaño en 4 skills de fase (`sdd-propose` <400 palabras, `sdd-spec` <650 palabras, `sdd-design` <800 palabras, `sdd-tasks` <530 palabras)
- Eliminar el envelope duplicado de 13 skills, referenciando el archivo común
- Crear `skills/skill-registry/SKILL.md` con script bash POSIX para descubrimiento dinámico
- Generar índice en `.agentify/skill-registry.md`
- Actualizar `orchestrator-core.md` para leer el registry al iniciar tareas

---

## [2026-03-18] fix-opencode-commands

**Intención**: Actualizar el proyecto Agentify-SDD para reconocer y utilizar los 3 nuevos skills SDD (`sdd-status`, `sdd-review`, `sdd-split`) que ya existen en el sistema de skills pero carecen de comandos slash correspondientes. Esto permitirá a los usuarios invocar estos 3 skills desde la línea de comandos y garantizará que la suite de tests refleje correctamente la cantidad total de comandos disponibles (11 en lugar de 8).

**Alcance**:

- Crear `examples/opencode/commands/sdd-status.md` con la instrucción para invocar el skill `sdd-status`
- Crear `examples/opencode/commands/sdd-review.md` con la instrucción para invocar el skill `sdd-review`
- Crear `examples/opencode/commands/sdd-split.md` con la instrucción para invocar el skill `sdd-split`
- Actualizar las 3 assertions en `scripts/install_test.sh` que verifican "8" comandos cambiándolas a "11"
- Agregar verificaciones explícitas de los 3 nuevos comandos en el bucle de test de `test_opencode_commands()`

---

## [2026-03-18] fix-init-config-template

**Intención**: Actualizar el template base de `config.yaml` generado por la skill `sdd-init` y documentado en `openspec-convention.md` para que todos los proyectos nuevos incluyan directivas de codificación defensiva y diseño optimizado para modelos de razonamiento (como MiniMax y su contexto limitado).

**Alcance**:

- Modificar el archivo `skills/sdd-init/SKILL.md` (Paso 3, bloque YAML del config.yaml) para inyectar las reglas dictadas respecto a `design`, `tasks` y `apply`.
- Modificar `skills/_shared/openspec-convention.md` (Sección "Referencia del config.yaml") sincronizando las nuevas reglas inyectadas en sdd-init.

---

## [2026-03-18] feat-productivity-tools

**Intención**: Crear dos nuevas skills SDD para aumentar la productividad del flujo de trabajo: `/sdd-review` para auditoría estática de código contra especificaciones, y `/sdd-split` para dividir propuestas monolíticas en iteraciones manejables. Estas herramientas completan el ciclo de desarrollo guiado por especificaciones añadiendo capacidades de revisión rápida y refinamiento iterativo.

**Alcance**:

- **Skill `sdd-review`**: Crear `skills/sdd-review/SKILL.md` para auditoría de código mediante análisis estático puro (sin ejecución de tests). El output será un reporte de revisión objetivo basado exclusivamente en lo que dicen los specs.
- **Skill `sdd-split`**: Crear `skills/sdd-split/SKILL.md` para detectar proposals demasiado grandes y generar un plan de partición con comandos `/sdd-new` sugeridos.
- **Actualización del ecosistema**: Registrar los nuevos comandos en `orchestrator-core.md` y actualizar los contadores en los scripts de instalación.

---

## [2026-03-16] optimize-minimax-config

**Intención**: Actualizar el archivo `openspec/config.yaml` del proyecto para inyectar directivas estrictas de diseño de sistemas y codificación defensiva, optimizadas para el motor de razonamiento MiniMax M2.5. El objetivo es mejorar la calidad del código generado por modelos de IA mediante reglas que fomenten diagramas exhaustivos, modularidad extrema, granularidad atómica en tareas, código defensivo y completitud sin placeholders.

**Alcance**:

- Modificar `openspec/config.yaml` agregando 5 nuevas reglas en las fases `design`, `tasks` y `apply`
- Verificar que el YAML resultante sea válido
- Preservar el `context` y `glossary` existentes sin modificaciones

---

## [2026-03-15] hotfix-v1-0-1

**Intención**: Este hotfix aborda dos problemas críticos de documentación en las skills del orquestador SDD: Parche BDD (Anti-GAND) agregando una regla estricta que prohíba palabras clave no estándar, y Parche Meta-Comandos clarificando cómo debe procesarse `/sdd-continue`, `/sdd-ff`, etc.

**Alcance**:

- Agregar regla de "Sintaxis Gherkin/BDD Inmutable" en `skills/sdd-spec/SKILL.md`, sección Reglas
- Agregar directiva de "META-COMANDOS VS SKILLS" en `skills/_shared/orchestrator-core.md`
- Agregar nota de "Próximo Paso" que clarifique cómo el usuario debe interacturar con los comandos

---

## [2026-03-15] feat-status-and-glossary

**Intención**: Implementar dos características complementarias para mejorar la visibilidad y consistencia del proyecto Agentify-SDD: Skill `sdd-status` para mostrar visualmente el estado del DAG, y Glosario de Dominio para compartir terminología consistente entre sub-agentes.

**Alcance**:

- Crear skill `skills/sdd-status/SKILL.md`
- Actualizar `skills/_shared/orchestrator-core.md`
- Actualizar `scripts/install_test.sh`
- Modificar `skills/sdd-init/SKILL.md` para incluir el bloque `glossary:`
- Modificar `skills/_shared/persistence-contract.md` para instruir cargar el glosario

---

## [2026-03-14] sync-and-release-v1

**Intención**: Sincronizar el número de comandos de OpenCode con las skills disponibles, creando los 3 comandos faltantes (sdd-spec, sdd-design, sdd-tasks) para alcanzar el objetivo de 15 comandos. Este cambio resuelve la inconsistencia entre el número de skills y comandos.

**Alcance**:

- Crear `examples/opencode/commands/sdd-spec.md`
- Crear `examples/opencode/commands/sdd-design.md`
- Crear `examples/opencode/commands/sdd-tasks.md`
- Actualizar `scripts/install_test.sh` respecto al recuento de comandos
- Actualizar `README.md`

---

## [2026-03-14] refactor-workflow-optimization

**Intención**: Optimizar el flujo de trabajo del orquestador SDD para manejar concurrencia, reducir latencia mediante paralelismo condicional, prevenir alucinaciones en propuestas, y cerrar el ciclo de feedback de verificación añadiendo el lazo automático `/sdd-fix`.

**Alcance**:

- Modificar `orchestrator-core.md` (Regla de Concurrencia, Regla de Paralelismo, Loop de Fix)
- Actualizar `sdd-apply/SKILL.md`
- Actualizar `sdd-verify/SKILL.md`
- Modificar `sdd-propose/SKILL.md` para validar existencia de exploración previa

---

## [2026-03-14] feat-last-mile-polish

**Intención**: Implementar mejoras finales de calidad para el proyecto agentify-sdd: validación de seguridad en el archivo (verificación de git), soporte nativo para Windows mediante PowerShell, autogeneración de changelogs, y reglas estrictas de naming para prevenir errores.

**Alcance**:

- **Seguridad en sdd-archive**: Modificar `skills/sdd-archive/SKILL.md` para verificar estado de git
- **Soporte Nativo Windows**: Crear script en `scripts/install.ps1`
- **Autogeneración Changelog**: Crear `skills/sdd-changelog/SKILL.md`
- **Naming y Errores**: Imponer `change_naming: kebab-case` en templates
