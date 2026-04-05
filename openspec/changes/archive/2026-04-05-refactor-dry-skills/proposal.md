# Proposal: refactor-dry-skills

## Intención de Negocio

Eliminar duplicación masiva de texto (~1020 tokens) en las skills del orquestador SDD mediante la aplicación estricta del principio DRY (Don't Repeat Yourself). El cambio elimina tres tipos de duplicación: Return Envelope, Errores Comunes, y detección de test runner.

## Tipo de Cambio

Refactorización de archivos de configuración (skills Markdown).

## Alcance

### Eliminaciones

| Tipo Duplicación | Archivos Afectados | Tokens Estimados |
|------------------|-------------------|------------------|
| Return Envelope estático | 14 archivos SKILL.md | ~560 |
| Errores Comunes | 2 archivos SKILL.md | ~360 |
| Detección test runner | 2 archivos SKILL.md | ~100 |

### Archivos a Modificar

- `skills/sdd-explore/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-propose/SKILL.md` - Eliminar Return Envelope + Errores Comunes
- `skills/sdd-spec/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-design/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-tasks/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-apply/SKILL.md` - Eliminar Return Envelope + Errores Comunes + Referenciar helper
- `skills/sdd-verify/SKILL.md` - Eliminar Return Envelope + Referenciar helper
- `skills/sdd-archive/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-review/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-status/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-changelog/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-split/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-fix/SKILL.md` - Eliminar Return Envelope
- `skills/sdd-init/SKILL.md` - Eliminar Return Envelope

### Archivos a Crear

- `skills/_shared/test-runner-detection.md` - Helper con pseudocódigo de detección de test runner

## Enfoque

1. **Identificar línea exacta** de cada Return Envelope en los 14 archivos
2. **Eliminar** la línea de Return Envelope de cada archivo
3. **Eliminar** secciones "Errores Comunes" en sdd-propose y sdd-apply
4. **Crear** helper `test-runner-detection.md` con el pseudocódigo extraído
5. **Reemplazar** pseudocódigo duplicado con referencia al helper
6. **Verificar** que las skills siguen funcionales post-cambio

## Criterios de Éxito

- ~1020 tokens eliminados de duplicación
- 14 archivos actualizados (Return Envelope)
- 2 archivos actualizados (Errores Comunes eliminados)
- 2 archivos actualizados (referencia a helper)
- 1 nuevo archivo helper creado
- Las skills siguen funcionales

## Plan de Rollback

```bash
git checkout -- skills/
```
