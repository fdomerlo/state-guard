# Propuesta: Refactor Contexto y Skill Registry Local

## Intención

El sistema de orquestación SDD actual tiene dos problemas críticos: (1) la duplicación del Return Envelope en 13 skills viola el principio DRY y crea deuda de mantenimiento, y (2) no existe mecanismo de descubrimiento dinámico de skills, lo que acopla el orquestador a un conocimiento estático de las fases disponibles. Además, la ausencia de presupuestos de tamaño en los skills de fase deja la ventana de contexto del sub-agente sin protección. Esta refactorización centraliza el contrato de retorno, inyecta límites de contexto y habilita un skill-registry local agnóstico a la herramienta.

## Alcance

### Dentro del Alcance
- Crear `skills/_shared/sdd-phase-common.md` con el contrato del Return Envelope en ESPAÑOL (status, executive_summary, detailed_report opcional, artifacts, next_recommended, risks)
- Eliminar la definición local del envelope de las 13 skills de fase y reemplazar por referencia al archivo común
- Inyectar presupuestos de tamaño en 4 skills: `sdd-propose` (< 400 palabras), `sdd-spec` (< 650), `sdd-design` (< 800 con arquitectura en tablas), `sdd-tasks` (< 530)
- Crear `skills/skill-registry/SKILL.md` con script Bash POSIX que escanee `skills/` y genere `./.agentify/skill-registry.md`
- Crear directorio `.agentify/` como destino del índice generado
- Modificar `skills/_shared/orchestrator-core.md` para instruir al orquestador a leer `.agentify/skill-registry.md` al iniciar

### Fuera del Alcance
- Modificar los scripts de instalación (`install.sh`, `install_test.sh`)
- Crear hooks automáticos que ejecuten el script de registry (queda como skill manual)
- Migrar a un sistema de registry dinámico en tiempo de ejecución (el índice es estático generado)
- Modificar configuración global (`~/.config/opencode/`, `~/.claude/`, `~/.gemini/`)

## Enfoque

**Enfoque A — Inyección por skill + shared common + registry** (recomendado por la exploración).

Se crean 3 archivos nuevos y se modifican 16 existentes:

1. **Archivo común (`sdd-phase-common.md`)**: Define el Return Envelope completo con `detailed_report` como campo opcional (variante mayoritaria: 11/13 skills). Las 2 skills sin `detailed_report` (sdd-review, sdd-split) adoptan el formato unificado — impacto mínimo.

2. **Presupuestos de tamaño**: Se inyectan como sub-sección `### Presupuesto de Tamaño` dentro de `## Reglas` de cada skill objetivo, inmediatamente antes de la referencia al envelope común.

3. **Skill Registry**: Script Bash POSIX (`#!/bin/sh`) que itera sobre directorios `skills/`, ignora `sdd-*` y `_shared`, parsea el frontmatter YAML de cada `SKILL.md` para extraer nombre y descripción, y genera `./.agentify/skill-registry.md` como índice en Markdown.

## Áreas Afectadas

| Área                                     | Impacto    | Descripción                                          |
|------------------------------------------|------------|------------------------------------------------------|
| `skills/_shared/sdd-phase-common.md`     | Nuevo      | Contrato DRY del Return Envelope                     |
| `skills/_shared/orchestrator-core.md`    | Modificado | Instrucción para leer skill-registry al iniciar      |
| `skills/skill-registry/SKILL.md`         | Nuevo      | Script bash de descubrimiento de skills              |
| `.agentify/skill-registry.md`            | Nuevo      | Índice generado por el script                        |
| `skills/sdd-propose/SKILL.md`            | Modificado | Presupuesto < 400 palabras + eliminar envelope local |
| `skills/sdd-spec/SKILL.md`               | Modificado | Presupuesto < 650 palabras + eliminar envelope local |
| `skills/sdd-design/SKILL.md`             | Modificado | Presupuesto < 800 palabras + eliminar envelope local |
| `skills/sdd-tasks/SKILL.md`              | Modificado | Presupuesto < 530 palabras + eliminar envelope local |
| `skills/sdd-explore/SKILL.md`            | Modificado | Eliminar envelope local, referenciar common           |
| `skills/sdd-apply/SKILL.md`              | Modificado | Eliminar envelope local, referenciar common           |
| `skills/sdd-archive/SKILL.md`            | Modificado | Eliminar envelope local, referenciar common           |
| `skills/sdd-init/SKILL.md`               | Modificado | Eliminar envelope local, referenciar common           |
| `skills/sdd-changelog/SKILL.md`          | Modificado | Eliminar envelope local, referenciar common           |
| `skills/sdd-verify/SKILL.md`             | Modificado | Eliminar envelope local, referenciar common           |
| `skills/sdd-review/SKILL.md`             | Modificado | Eliminar envelope local, referenciar common           |
| `skills/sdd-split/SKILL.md`              | Modificado | Eliminar envelope local, referenciar common           |
| `skills/sdd-status/SKILL.md`             | Modificado | Eliminar envelope local, referenciar common           |

## Riesgos

| Riesgo                                                                 | Probabilidad | Mitigación                                                                          |
|------------------------------------------------------------------------|--------------|-------------------------------------------------------------------------------------|
| Inconsistencias de formato al modificar 13 skills simultáneamente      | Media        | Verificar cada edición con lectura posterior; aplicar cambios secuenciales          |
| Script bash incompatible con shells no POSIX                            | Baja        | Usar `#!/bin/sh` estricto; evitar `[[`, `<<<`, arrays; testear en `sh`              |
| Unificación de envelope rompe sdd-review y sdd-split (sin detailed_report) | Baja     | `detailed_report` es opcional en el común; no rompe contratos existentes            |
| Rutas relativas del script fallan si se ejecuta fuera del root del proyecto | Media   | Documentar ejecución desde root; usar `$0` para derivar ruta relativa del script    |

## Plan de Rollback

1. Revertir los 13 archivos de skills a su estado anterior mediante `git checkout -- skills/`
2. Eliminar los 3 archivos creados: `skills/_shared/sdd-phase-common.md`, `skills/skill-registry/SKILL.md`, `.agentify/skill-registry.md`
3. Eliminar el directorio vacío: `skills/skill-registry/`, `.agentify/`
4. Restaurar `skills/_shared/orchestrator-core.md` a su versión previa

Comando de verificación rápida: `git diff --stat` debe mostrar 0 cambios tras el rollback.

## Dependencias

- Ninguna dependencia externa. Script bash POSIX puro.
- Requiere acceso de escritura al directorio del proyecto (ya verificado).

## Criterios de Éxito

- [ ] `skills/_shared/sdd-phase-common.md` existe con el contrato de Return Envelope completo en ESPAÑOL
- [ ] Las 13 skills de fase ya NO contienen la definición local del envelope
- [ ] Las 13 skills de fase referencian `sdd-phase-common.md` en su sección de Reglas
- [ ] Los 4 skills objetivo (`propose`, `spec`, `design`, `tasks`) tienen presupuesto de tamaño inyectado
- [ ] `skills/skill-registry/SKILL.md` existe con script bash funcional
- [ ] Ejecutar el script genera `./.agentify/skill-registry.md` con índice de skills no-sdd
- [ ] `orchestrator-core.md` instruye al orquestador a leer `./.agentify/skill-registry.md`
- [ ] Ningún archivo fuera de `skills/` y `.agentify/` fue modificado
- [ ] Cero dependencias externas introducidas
