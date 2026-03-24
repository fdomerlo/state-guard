# Tareas: Refactor Instalador y Contratos Base

## Fase 1: Marcadores HTML en Instalador

- [x] 1.1 Editar `scripts/install.sh:184` — Cambiar `marker_begin` de `"### BEGIN SDD ORCHESTRATOR ###"` a `"<!-- BEGIN SDD ORCHESTRATOR -->"`
- [x] 1.2 Editar `scripts/install.sh:185` — Cambiar `marker_end` de `"### END SDD ORCHESTRATOR ###"` a `"<!-- END SDD ORCHESTRATOR -->"`

## Fase 2: Purga de orchestrator-core.md

- [x] 2.1 Editar `skills/_shared/orchestrator-core.md:40` — Eliminar menciones a `auto`, `hybrid` y `engram`, reemplazando por afirmación positiva sobre `openspec` como modo único

## Fase 3: Verificación

- [x] 3.1 Grep en `scripts/install.sh` — Confirmar que no persisten marcadores `### BEGIN/END SDD ORCHESTRATOR ###`
- [x] 3.2 Grep en `skills/_shared/orchestrator-core.md` — Confirmar 0 resultados para `engram`, `hybrid`, `auto`
- [x] 3.3 Verificar que `orchestrator-core.md` mantiene redacción en español completa
- [x] 3.4 Verificar que `persistence-contract.md` y `openspec-convention.md` permanecen sin cambios

## Fase 4: Idempotencia y Retrocompatibilidad

- [x] 4.1 Verificar que la lógica awk de purgado (`install.sh:191`) funciona con los nuevos marcadores HTML sin modificaciones
- [x] 4.2 Confirmar que la función `compile_and_append_config` mantiene su firma sin cambios
- [x] 4.3 Documentar nota sobre retrocompatibilidad: primera re-instalación sobre marcadores viejos no purgará el bloque antiguo (se acepta duplicación temporal)
