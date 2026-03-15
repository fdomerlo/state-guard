# Exploración: release-documentation-v1

## Estado Actual

### README.md Actual

El README.md actual es un documento técnico-arquitectónico de 672 líneas que contiene:

- **Problema/Solución**: Explica la sobrecarga de contexto, la falta de estructura y la memoria frágil de los assistants de IA.
- **Arquitectura**: Incluye diagramas Mermaid con 3 niveles de complejidad (sub-agentes básicos, equipos SDD, equipos completos).
- **Decisiones Arquitectónicas**: Forzar español, OpenSpec puro (eliminar Engram/híbrido).
- **Grafo de Dependencias**: Visualización del DAG (proposal → specs + design → tasks → apply → verify → archive).
- **Lista de comandos**: Solo 7 comandos principales (init, explore, new, continue, ff, apply, verify, archive).
- **Sub-agentes**: 9 skills detalladas con tabla de referencias.
- **Instalación**: Para 7 herramientas (Claude Code, OpenCode, Gemini CLI, Codex, VS Code, Antigravity, Cursor).
- **Estructura del proyecto**: Árbol de directorios.
- **Conceptos**: Specs Delta, Palabras clave RFC 2119, Ciclo de Archivo.
- **Tabla de herramientas**: Compatibilidad con sub-agentes reales vs inline.

### MANUAL.md Actual

El MANUAL.md actual es breve (79 líneas) y contiene:

- **Lección 1**: Filosofía "Especificación Primero" — El código es la última consecuencia.
- **Lección 2**: Ciclo de Vida de un Cambio — Las 6 fases principales.
- **Lección 3**: Tu Rol como "Piloto" Humano — Puntos de control críticos.
- **Decálogo**: 10 buenas prácticas (cambios atómicos, confiar en openspec/, no editar a mano, usar verify, el idioma importa, revisión Git, fallback, contexto fresco, specs como documentación, iterar propuesta).

### Estado de los Comandos

El orquestador soporta **15 comandos slash** (no 13 como indica el usuario):

| Comando | Descripción |
|---------|-------------|
| `/sdd-init` | Inicializa el proyecto SDD |
| `/sdd-explore <topic>` | Investiga una idea |
| `/sdd-new <change>` | Inicia nuevo cambio (explore + propose) |
| `/sdd-continue [change]` | Ejecuta siguiente fase pendiente |
| `/sdd-ff [change>` | Fast-forward (propose → spec → design → tasks) |
| `/sdd-apply [change]` | Implementa tareas en lotes |
| `/sdd-verify [change]` | Valida contra specs |
| `/sdd-archive [change]` | Cierra cambio y fusiona specs |
| `/sdd-status` | Muestra estado de cambios activos |
| `/sdd-review [change]` | Auditoría estática de código |
| `/sdd-split [change>` | Divide proposals monumentales |
| `/sdd-changelog` | Genera CHANGELOG.md desde archive |
| `/sdd-spec` | Escribe especificaciones delta |
| `/sdd-design` | Crea documento técnico |
| `/sdd-tasks` | Desglosa en checklist |

### Arquitectura DRY (Compilación Dinámica)

Los scripts de instalación (`install.sh` y `install.ps1`) realizan una **compilación dinámica** del orquestador:

1. **Plantilla**: `skills/_shared/orchestrator-core.md` contiene placeholders (`{{TOOL_NAME}}`, `{{SKILLS_PATH}}`, `{{EXTRA_LANGUAGE_RULE}}`).
2. **Sustitución**: El script reemplaza los placeholders con valores específicos de la herramienta destino.
3. **Inyección**: El bloque compilado se inyecta en el archivo de configuración (CLAUDE.md, GEMINI.md, opencode.json, etc.).
4. **Para OpenCode**: Usa Python para merge seguro de JSON y compilación del prompt.

### State Machine (ACID)

El orquestador mantiene integridad de estado mediante:

- **Archivo `state.yaml`**: Contiene `started_at`, `last_updated`, `phase`, `completed_phases`, `pending_phases`, `blocked`, `blocked_reason`.
- **Prevención de colisiones**: Cuando hay múltiples cambios activos, el argumento `[change]` es obligatorio para distinguir cuál se está procesando.
- **Recuperación**: Tras compactación del IDE, el orquestador lee `state.yaml` antes de cualquier acción.

### Config.yaml

El archivo `openspec/config.yaml` contiene:

- **Glosario de Dominio**: Términos canónicos específicos del proyecto.
- **Reglas de nomenclatura**: `change_naming: kebab-case` (regex: `^[a-z0-9]+(-[a-z0-9]+)*$`).
- **Configuración por fase**: `test_command`, `build_command`, `coverage_threshold`, `tdd`, etc.

---

## Áreas Afectadas

| Archivo | Contenido Actual | Qué cambiar |
|---------|------------------|-------------|
| `README.md` | 672 líneas, técnico-arquitectónico | Reescribir completamente: Pitch comercial + Quickstart |
| `MANUAL.md` | 79 líneas, introductorio | Expandir: Guía técnica profunda |
| `scripts/install.sh` | Instalador Bash | Mantener (ya correcto) |
| `scripts/install.ps1` | Instalador PowerShell | Mantener (ya correcto) |
| `skills/_shared/orchestrator-core.md` | Core compilable | Mantener (ya correcto) |
| `skills/_shared/openspec-convention.md` | Convenciones | Mantener (referencia) |

---

## Enfoques

### Enfoque 1: Reescritura Conservative

Mantener la estructura actual, solo actualizar contenido y añadir la información de arquitectura faltante.

- **Ventajas**: Menor riesgo, cambios incrementales, mantiene familiaridad.
- **Desventajas**: No aprovecha la oportunidad de mejorar la experiencia del usuario.
- **Esfuerzo**: Medio.

### Enfoque 2: Reescritura Completa (Recomendado)

Separar claramente README (Pitch) de MANUAL (Guía Técnica) con contenido nuevo y estructurado.

- **Ventajas**: Mejor experiencia para nuevos usuarios, documentación más profesional, refleja la V1.0.
- **Desventajas**: Requiere más trabajo de investigación y redacción.
- **Esfuerzo**: Alto.

---

## Recomendación

Se recomienda el **Enfoque 2 (Reescritura Completa)** por las siguientes razones:

1. **La V1.0 es un lanzamiento importante**: Merece documentación a la altura.
2. **El usuario lo pide explícitamente**: "Reescribir por completo" indica voluntad de cambio.
3. **La información ya existe en el código**: Solo hay que reorganizarla y darle formato.
4. **Mejora la adopción**: Un buen README + MANUAL reduce la curva de aprendizaje.

### Detalle del nuevo contenido:

**README.md**:
- Eliminar diagramas Mermaid complejos (mantener solo el esencial).
- Nueva propuesta de valor en el header.
- Sección de instalación simplificada (Unix vs Windows).
- Tabla de 15 comandos (no 13) con descripción breve.
- Tono: Profesional, pragmático, directo.

**MANUAL.md**:
- Nueva sección "Arquitectura DRY": Explicar compilación dinámica.
- Nueva sección "State Machine ACID": Explicar state.yaml y concurrencia.
- Nueva sección "Config.yaml": Glosario, kebab-case, test_command.
- Flujos avanzados: /sdd-split, /sdd-review, /sdd-fix.

---

## Riesgos

1. **Perder información valiosa**: Los diagramas Mermaid y las explicaciones detalladas actuales son útiles para desarrolladores. Debe preservarse lo esencial.
2. **Inconsistencia con el código**: Si la documentación no refleja el comportamiento real de los scripts, generará confusión.
3. **Comandos desactualizados**: Verificar que la lista de comandos coincida exactamente con los archivos en `examples/opencode/commands/`.

---

## Listo para Propuesta

**Sí** — La exploración está completa y revela:

- El estado actual de ambos documentos.
- La arquitectura DRY y ACID que debe documentarse.
- Los 15 comandos disponibles (no 13 como se indicó).
- Los enfoques posibles y la recomendación.

**Siguiente paso**: El orquestador debe pasar a la fase `sdd-propose` para crear `proposal.md` con el alcance exacto del trabajo de documentación.
