# Tareas: Refactor Contexto y Skill Registry Local

## Fase 1: Fundación — Archivo Común y Estructuras

- [x] 1.1 Crear `skills/_shared/sdd-phase-common.md` con contrato Return Envelope en ESPAÑOL (campos: status, executive_summary, artifacts, next_recommended, risks, detailed_report opcional)
- [x] 1.2 Crear directorio `skills/skill-registry/`
- [x] 1.3 Crear directorio `.agentify/`

## Fase 2: Inyección de Presupuestos de Tamaño

- [x] 2.1 Inyectar `### Presupuesto de Tamaño` en `skills/sdd-propose/SKILL.md` (límite < 400 palabras), eliminar envelope local, agregar referencia a `sdd-phase-common.md`
- [x] 2.2 Inyectar `### Presupuesto de Tamaño` en `skills/sdd-spec/SKILL.md` (límite < 650 palabras), eliminar envelope local, agregar referencia a `sdd-phase-common.md`
- [x] 2.3 Inyectar `### Presupuesto de Tamaño` en `skills/sdd-design/SKILL.md` (límite < 800 palabras + arquitectura en tablas), eliminar envelope local, agregar referencia a `sdd-phase-common.md`
- [x] 2.4 Inyectar `### Presupuesto de Tamaño` en `skills/sdd-tasks/SKILL.md` (límite < 530 palabras), eliminar envelope local, agregar referencia a `sdd-phase-common.md`

## Fase 3: Refactorización DRY — Eliminar Envelope Local en Skills Restantes

- [x] 3.1 Eliminar envelope local y agregar referencia en `skills/sdd-explore/SKILL.md`
- [x] 3.2 Eliminar envelope local y agregar referencia en `skills/sdd-apply/SKILL.md`
- [x] 3.3 Eliminar envelope local y agregar referencia en `skills/sdd-archive/SKILL.md`
- [x] 3.4 Eliminar envelope local y agregar referencia en `skills/sdd-init/SKILL.md`
- [x] 3.5 Eliminar envelope local y agregar referencia en `skills/sdd-changelog/SKILL.md`
- [x] 3.6 Eliminar envelope local y agregar referencia en `skills/sdd-verify/SKILL.md`
- [x] 3.7 Eliminar envelope local y agregar referencia en `skills/sdd-review/SKILL.md` (adoptar detailed_report opcional)
- [x] 3.8 Eliminar envelope local y agregar referencia en `skills/sdd-split/SKILL.md` (adoptar detailed_report opcional)
- [x] 3.9 Eliminar envelope local y agregar referencia en `skills/sdd-status/SKILL.md`

## Fase 4: Skill Registry — Descubrimiento Dinámico

- [x] 4.1 Crear `skills/skill-registry/SKILL.md` con script bash POSIX (`#!/bin/sh`) que escanee `./skills/`, ignore `sdd-*` y `_`, y genere índice
- [x] 4.2 Crear script `skills/skill-registry/scan.sh` (archivo ejecutable separado) con el script POSIX de escaneo
- [x] 4.3 Modificar `skills/_shared/orchestrator-core.md` para instruir lectura de `./.agentify/skill-registry.md` al iniciar tarea

## Fase 5: Verificación

- [x] 5.1 Ejecutar script `scan.sh` y verificar que `.agentify/skill-registry.md` se genera correctamente
- [x] 5.2 Verificar con grep que las 13 skills referencian `sdd-phase-common.md` y NO contienen definición local del envelope
- [x] 5.3 Verificar que los 4 skills objetivo tienen sección `### Presupuesto de Tamaño` con límites correctos
- [x] 5.4 Verificar que `orchestrator-core.md` contiene instrucción de lectura del registry
- [x] 5.5 Verificar que ningún archivo fuera de `skills/` y `.agentify/` fue modificado
