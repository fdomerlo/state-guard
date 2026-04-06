# Exploración: Erradicar compatibilidad con modelos inline/pasivos del Core

## Estado Actual

El proyecto **Agentify SDD** fue diseñado originalmente para soportar dos paradigmas de ejecución:
1. **Agentes CLI con I/O nativo** (Claude Code, OpenCode, Gemini CLI, Antigravity) — tienen acceso completo a filesystem y herramientas
2. **Editores inline/pasivos** (VS Code, Cursor, Codex) — sin acceso a disco, ejecutan en contexto efímero del prompt

El código base contiene múltiples referencias al "modo none" como fallback para editores que no pueden escribir archivos. Estas referencias deben eliminarse dado que el framework ahora asume exclusivamente agentes con capacidades de I/O.

## Áreas Afectadas

| Archivo | Tipo de Afección | Descripción |
|---------|-----------------|-------------|
| `skills/_shared/persistence-contract.md` | **CRÍTICA** | Define el modo `none` como opción válida en líneas 5, 19, 29, 36, 39 |
| `skills/sdd-apply/SKILL.md` | Media | Referencias a "inline" en contexto de pasar tareas (líneas 47, 49) — estos son inocuos |
| `skills/sdd-verify/SKILL.md` | Media | Línea 27 y 170 — mención a modo `none` |
| `skills/sdd-review/SKILL.md` | Media | Línea 31 y 120 — mención a modo `none` |
| `skills/sdd-fix/SKILL.md` | Baja | Línea 29 — mención a modo `none` |
| `skills/sdd-split/SKILL.md` | Media | Línea 27 y 132 — mención a modo `none` |
| `skills/skill-registry/SKILL.md` | **CRÍTICA** | Líneas 44-45 — fallback específico para "Cursor, VSCode Copilot o Codex" |
| `skills/_shared/orchestrator-core.md` | **CRÍTICA** | Línea 28 — fuerza `artifact_store.mode: openspec` (ya alineado) |

## Enfoques

### Enfoque 1: Eliminación Total del Modo "none"
- **Descripción**: Eliminar completamente las menciones al modo `none` de todos los archivos de skills. El contrato de persistencia solo soportará `openspec`.
- **Ventajas**: 
  - Simplifica el código base
  - Elimina la complejidad de bifurcación en cada skill
  - Refuerza el contrato Agent-First/CLI-First
- **Desventajas**: 
  - Requiere edición en múltiples archivos
  - Puede quebrar si hay usuarios con configuraciones legacy
- **Esfuerzo**: Alto — requiere editar ~8 archivos

### Enfoque 2: Deprecación Suave con Warning
- **Descripción**: Mantener la infraestructura del modo `none` pero marcarlo como deprecado, emitiendo advertencias cuando se detecte uso.
- **Ventajas**: 
  - backward compatible
  - Da tiempo a usuarios a migrar
- **Desventajas**: 
  - Mantiene código muerto
  - Complegidad adicional
- **Esfuerzo**: Medio

### Enfoque 3: Documentar solo en Orchestrator Core (Status Quo)
- **Descripción**: Dejar las menciones existentes pero forzar `openspec` a nivel de orquestador (ya implementado en orchestrator-core.md línea 28).
- **Ventajas**: 
  - No requiere cambios
  - El comportamiento real ya es `openspec`
- **Desventajas**: 
  - Confusión potencial por documentación contradictoria
  - Mantiene referencias a modos no soportados
- **Esfuerzo**: Bajo

## Recomendación

**Enfoque 1: Eliminación Total** — Es el más limpio y alinea el framework con su diseño Agent-First/CLI-First declarado en AGENTS.md.

Archivos a modificar:
1. `skills/_shared/persistence-contract.md` — Eliminar todas las menciones a `none`, líneas 5, 12, 19, 29, 36, 39
2. `skills/sdd-apply/SKILL.md` — Las referencias "inline" son inocuas (se refieren a formato de texto), pero pueden clarificarse
3. `skills/sdd-verify/SKILL.md` — Eliminar menciones a `none`, líneas 27, 170
4. `skills/sdd-review/SKILL.md` — Eliminar menciones a `none`, líneas 31, 120
5. `skills/sdd-fix/SKILL.md` — Eliminar mención a `none`, línea 29
6. `skills/sdd-split/SKILL.md` — Eliminar menciones a `none`, líneas 27, 132
7. `skills/skill-registry/SKILL.md` — Eliminar fallback para editores inline, líneas 44-45

## Riesgos

- **Riesgo 1**: Que algún usuario aún use el modo `none` y observe comportamiento roto — Mitigación: El orchestrator-core.md ya fuerza `openspec`, este cambio es solo documental.
- **Riesgo 2**: Que el cambio rompa scripts que dependan del texto "none" — Mitigación: Revisar是否有 scripts en el proyecto.
- **Riesgo 3**: Que la documentación de AGENTS.md contradiga los cambios — Mitigación: Verificar consistencia.

## Listo para Propuesta

**Sí** — La investigación revela que el cambio es straightforward. La propuesta debe:
- Enumerar archivos a modificar
- Especificar exactamente qué texto eliminar
- Incluir verificación de consistencia con AGENTS.md
- Proponer actualizar el mensaje de error cuando no se pueda escribir (si aplica)

El alcance es claro y el esfuerzo es manejable (~8 archivos, cambios menores en cada uno).
