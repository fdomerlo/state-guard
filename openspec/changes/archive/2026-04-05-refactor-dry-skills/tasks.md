# Tareas: refactor-dry-skills

## Fase 1: Preparación

- [x] 1.1 Leer `skills/_shared/sdd-phase-common.md` como referencia del Return Envelope
- [x] 1.2 Identificar líneas exactas del Return Envelope en los 14 archivos usando grep

## Fase 2: Eliminar Return Envelope de 14 archivos

- [x] 2.1 Eliminar Return Envelope de `skills/sdd-explore/SKILL.md`
- [x] 2.2 Eliminar Return Envelope de `skills/sdd-propose/SKILL.md`
- [x] 2.3 Eliminar Return Envelope de `skills/sdd-spec/SKILL.md`
- [x] 2.4 Eliminar Return Envelope de `skills/sdd-design/SKILL.md`
- [x] 2.5 Eliminar Return Envelope de `skills/sdd-tasks/SKILL.md`
- [x] 2.6 Eliminar Return Envelope de `skills/sdd-apply/SKILL.md`
- [x] 2.7 Eliminar Return Envelope de `skills/sdd-verify/SKILL.md`
- [x] 2.8 Eliminar Return Envelope de `skills/sdd-archive/SKILL.md`
- [x] 2.9 Eliminar Return Envelope de `skills/sdd-review/SKILL.md`
- [x] 2.10 Eliminar Return Envelope de `skills/sdd-status/SKILL.md`
- [x] 2.11 Eliminar Return Envelope de `skills/sdd-changelog/SKILL.md`
- [x] 2.12 Eliminar Return Envelope de `skills/sdd-split/SKILL.md`
- [x] 2.13 Eliminar Return Envelope de `skills/sdd-fix/SKILL.md`
- [x] 2.14 Eliminar Return Envelope de `skills/sdd-init/SKILL.md`

## Fase 3: Eliminar Errores Comunes

- [x] 3.1 Eliminar sección "Errores Comunes" de `skills/sdd-propose/SKILL.md`
- [x] 3.2 Eliminar sección "Errores Comunes" de `skills/sdd-apply/SKILL.md`

## Fase 4: Crear Helper de Test Runner

- [x] 4.1 Crear `skills/_shared/test-runner-detection.md` con pseudocódigo extraído
- [x] 4.2 Actualizar `skills/sdd-apply/SKILL.md` para referenciar al helper
- [x] 4.3 Actualizar `skills/sdd-verify/SKILL.md` para referenciar al helper

## Fase 5: Verificación

- [x] 5.1 Verificar que los 14 archivos no contengan Return Envelope estático
- [x] 5.2 Verificar que sdd-propose y sdd-apply no contengan "Errores Comunes"
- [x] 5.3 Verificar que test-runner-detection.md existe con contenido correcto
- [x] 5.4 Verificar que sdd-apply y sdd-verify referencian correctamente al helper
