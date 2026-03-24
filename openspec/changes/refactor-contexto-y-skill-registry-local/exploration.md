# Exploración: Refactor Contexto y Skill Registry Local

## Estado Actual

El proyecto `agentify-sdd` tiene un ecosistema SDD completo con 14 skills bajo `skills/` y 3 archivos compartidos en `skills/_shared/`. Cada skill define localmente su contrato de retorno (Return Envelope) duplicando la misma línea en sus reglas finales. No existe directorio `.agentify/` ni ningún mecanismo de skill-registry. El modo openspec está activo con 8 cambios archivados y ninguno activo.

### Estructura de directorios `skills/`

```
skills/
├── _shared/
│   ├── openspec-convention.md
│   ├── orchestrator-core.md
│   └── persistence-contract.md
├── sdd-apply/
├── sdd-archive/
├── sdd-changelog/
├── sdd-design/
├── sdd-explore/
├── sdd-init/
├── sdd-propose/
├── sdd-review/
├── sdd-spec/
├── sdd-split/
├── sdd-status/
├── sdd-tasks/
└── sdd-verify/
```

### Envelope de Retorno Duplicado (DRY Violation)

El envelope se define en la sección **Reglas** de cada skill con la misma frase literal:

```
- Devolver un envelope estructurado con: `status`, `executive_summary`, `detailed_report` (opcional), `artifacts`, `next_recommended` y `risks`
```

**Ubicaciones exactas (líneas):**
| Skill | Archivo | Línea |
|-------|---------|-------|
| sdd-propose | skills/sdd-propose/SKILL.md | 127 |
| sdd-spec | skills/sdd-spec/SKILL.md | 156 |
| sdd-design | skills/sdd-design/SKILL.md | 148 |
| sdd-tasks | skills/sdd-tasks/SKILL.md | 149 |
| sdd-explore | skills/sdd-explore/SKILL.md | 124 |
| sdd-apply | skills/sdd-apply/SKILL.md | 183 |
| sdd-archive | skills/sdd-archive/SKILL.md | 181 |
| sdd-init | skills/sdd-init/SKILL.md | 152 |
| sdd-changelog | skills/sdd-changelog/SKILL.md | 137 |
| sdd-verify | skills/sdd-verify/SKILL.md | 278 |
| sdd-status | skills/sdd-status/SKILL.md | 102 |

**Variante sin `detailed_report`:**
| Skill | Archivo | Línea |
|-------|---------|-------|
| sdd-review | skills/sdd-review/SKILL.md | 156 |
| sdd-split | skills/sdd-split/SKILL.md | 165 |

`orchestrator-core.md` (línea 126) también define el contrato de resultados pero de forma más concisa.

### Presupuestos de Tamaño (No existentes actualmente)

Ninguno de los 4 skills objetivo tiene sección de presupuesto de tamaño. Las secciones de Reglas actualmente solo contienen reglas de comportamiento y el envelope duplicado.

### Skill Registry (No existe)

- No existe `skills/skill-registry/`
- No existe `.agentify/`
- No existe ningún índice de skills

## Áreas Afectadas

- `skills/sdd-propose/SKILL.md` — inyectar presupuesto < 400 palabras, eliminar envelope local
- `skills/sdd-spec/SKILL.md` — inyectar presupuesto < 650 palabras, eliminar envelope local
- `skills/sdd-design/SKILL.md` — inyectar presupuesto < 800 palabras (arquitectura en tablas), eliminar envelope local
- `skills/sdd-tasks/SKILL.md` — inyectar presupuesto < 530 palabras, eliminar envelope local
- `skills/_shared/sdd-phase-common.md` — **nuevo archivo**: contrato DRY del Return Envelope
- `skills/skill-registry/SKILL.md` — **nuevo archivo**: script bash de descubrimiento
- `.agentify/skill-registry.md` — **nuevo archivo**: índice generado
- `skills/_shared/orchestrator-core.md` — modificar para referenciar skill-registry
- `skills/sdd-apply/SKILL.md` — eliminar envelope local, referenciar common
- `skills/sdd-archive/SKILL.md` — eliminar envelope local, referenciar common
- `skills/sdd-changelog/SKILL.md` — eliminar envelope local, referenciar common
- `skills/sdd-explore/SKILL.md` — eliminar envelope local, referenciar common
- `skills/sdd-init/SKILL.md` — eliminar envelope local, referenciar common
- `skills/sdd-review/SKILL.md` — eliminar envelope local, referenciar common
- `skills/sdd-split/SKILL.md` — eliminar envelope local, referenciar common
- `skills/sdd-status/SKILL.md` — eliminar envelope local, referenciar common
- `skills/sdd-verify/SKILL.md` — eliminar envelope local, referenciar common

## Enfoques

1. **Enfoque A — Inyección por skill + shared common + registry**
   - Se crea `sdd-phase-common.md` con el envelope completo (todos los campos incluyendo `detailed_report` opcional)
   - Se inyectan presupuestos como sub-sección dentro de "Reglas" de cada skill
   - Se crea `skill-registry/SKILL.md` con script bash POSIX puro que escanea `skills/` excluyendo `sdd-*` y `_shared`
   - Se modifica `orchestrator-core.md` para instruir lectura de `.agentify/skill-registry.md`
   - Ventajas: solución completa, DRY, extensible
   - Desventajas: alto número de archivos a tocar (13 skills + 3 nuevos)
   - Esfuerzo: Medio

2. **Enfoque B — Solo presupuestos + envelope en orchestrator-core**
   - Se mueve el envelope al `orchestrator-core.md` (ya está parcialmente ahí) sin crear `sdd-phase-common.md`
   - Los skills referencian al orchestrator-core
   - No se crea skill-registry
   - Ventajas: menos cambios, menos nuevos archivos
   - Desventajas: no resuelve el descubrimiento dinámico, acopla envelope al orchestrator
   - Esfuerzo: Bajo

## Recomendación

**Enfoque A**. Es el que mejor alinea con los requerimientos explícitos: proteger contexto con presupuestos, centralizar el envelope (DRY) y habilitar descubrimiento dinámico. El esfuerzo es mediano pero todos los cambios son contenidos y bien delimitados.

### Decisiones clave para el diseño:

1. **Envelope en `sdd-phase-common.md`**: debe incluir `detailed_report` como opcional (es la variante más común — 11 de 13 skills). Las 2 variantes sin `detailed_report` (sdd-review, sdd-split) adoptarán el formato común unificado.

2. **Script bash del skill-registry**: debe ser POSIX puro (`#!/bin/sh`), sin dependencias externas, ignorar directorios que empiecen con `sdd-` y el directorio `_shared`. Escanear SKILL.md, extraer nombre y descripción del frontmatter YAML, generar `.agentify/skill-registry.md`.

3. **Presupuestos de tamaño**: inyectar como sub-sección `### Presupuesto de Tamaño` dentro de la sección `## Reglas` de cada skill, inmediatamente antes del envelope (que será reemplazado por la referencia a common).

## Riesgos

- Modificar 13 skills simultáneamente puede introducir inconsistencias de formato si no se hace cuidadosamente
- El script bash debe ser testeado en entorno POSIX puro (sh, no bash-only) para asegurar compatibilidad
- La variante de envelope (con/sin `detailed_report`) se unifica — sdd-review y sdd-split cambian de comportamiento (bajo impacto, es solo metadata)

## Listo para Propuesta

**Sí** — La exploración está completa. El orquestador puede lanzar `sdd-propose` para crear la propuesta formal. Los requerimientos están claros, las áreas afectadas están mapeadas y el enfoque recomendado está definido.
