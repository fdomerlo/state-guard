# Diseño: refactor-dry-skills

## Enfoque Técnico

La refactorización aplica el principio DRY extrayendo tres tipos de duplicación de las 14 skills SDD:

1. **Return Envelope**: Cada skill tiene una línea idéntica al final de su sección "Reglas" que referencia `skills/_shared/sdd-phase-common.md`. La solución es eliminar esta línea duplicada de los 14 archivos, dejando que el orquestador inyecte dinámicamente la referencia o que el usuario la agregue manualmente.

2. **Errores Comunes**: Las skills `sdd-propose` y `sdd-apply` contienen secciones "Errores Comunes" casi idénticas (~360 tokens). La solución es eliminar estas secciones de ambos archivos.

3. **Detección de test runner**: Las skills `sdd-apply` y `sdd-verify` tienen pseudocódigo duplicado (~100 tokens) para detectar el test runner. La solución es crear un helper compartido y referenciarlo desde ambas skills.

## Decisiones de Arquitectura

| Decisión | Alternativas | Justificación |
|----------|--------------|---------------|
| Eliminar Return Envelope de 14 archivos | Inyección dinámica vs eliminación manual | Según spec, el orquestador "DEBE inyectar dinámicamente". Por ahora, simplemente eliminar la línea estática de cada skill — el orquestador puede implementar la inyección después. |
| Eliminar Errores Comunes | Eliminar completamente vs mover a helper | La spec exige "eliminar las secciones", no moverlas. Los errores comunes son específicos de cada skill, no genéricos — no tiene sentido crear un helper. |
| Crear helper test-runner-detection | Helper en `_shared` vs dejar enlined | Amabas skills ya referencian archivos en `_shared` (ej: `sdd-phase-common.md`), seguir la misma convención. |
| Formato del helper | Markdown con pseudocódigo | Mantener consistencia con el estilo de las skills existentes. |

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `skills/_shared/test-runner-detection.md` | Crear | Helper con pseudocódigo de detección de test runner |
| `skills/sdd-explore/SKILL.md` | Modificar | Eliminar línea de Return Envelope (línea ~122) |
| `skills/sdd-propose/SKILL.md` | Modificar | Eliminar línea Return Envelope (línea ~127) + eliminar sección "Errores Comunes" completa (líneas ~129-147) |
| `skills/sdd-spec/SKILL.md` | Modificar | Eliminar línea de Return Envelope |
| `skills/sdd-design/SKILL.md` | Modificar | Eliminar línea de Return Envelope |
| `skills/sdd-tasks/SKILL.md` | Modificar | Eliminar línea de Return Envelope |
| `skills/sdd-apply/SKILL.md` | Modificar | Eliminar línea Return Envelope (línea ~183) + eliminar sección "Errores Comunes" (líneas ~185-203) + reemplazar pseudocódigo con referencia a helper |
| `skills/sdd-verify/SKILL.md` | Modificar | Eliminar línea Return Envelope (línea ~280) + reemplazar pseudocódigo con referencia a helper |
| `skills/sdd-archive/SKILL.md` | Modificar | Eliminar línea de Return Envelope |
| `skills/sdd-review/SKILL.md` | Modificar | Eliminar línea de Return Envelope |
| `skills/sdd-status/SKILL.md` | Modificar | Eliminar línea de Return Envelope |
| `skills/sdd-changelog/SKILL.md` | Modificar | Eliminar línea de Return Envelope |
| `skills/sdd-split/SKILL.md` | Modificar | Eliminar línea de Return Envelope |
| `skills/sdd-fix/SKILL.md` | Modificar | Eliminar línea de Return Envelope |
| `skills/sdd-init/SKILL.md` | Modificar | Eliminar línea de Return Envelope |

## Contenido del Helper

El archivo `skills/_shared/test-runner-detection.md` contendrá:

```markdown
# Detección de Test Runner

Pseudocódigo para detectar automáticamente el test runner del proyecto (máxima prioridad → mínima):

1. Leer `openspec/config.yaml` → `rules.apply.test_command` o `rules.verify.test_command`
2. Si no existe, buscar `package.json` → `scripts.test`
3. Si no existe, buscar `pyproject.toml` o `pytest.ini` → usar `pytest`
4. Si no existe, buscar `Makefile` → usar `make test`
5. Fallback: reportar que no se pudo detectar automáticamente
```

## Estrategia de Verificación

- Verificar que los 14 archivos NO contengan la línea "RETORNA el resultado siguiendo estrictamente el formato del Return Envelope"
- Verificar que `sdd-propose/SKILL.md` y `sdd-apply/SKILL.md` NO contengan la sección "## Errores Comunes"
- Verificar que `skills/_shared/test-runner-detection.md` existe con el pseudocódigo correcto
- Verificar que `sdd-apply/SKILL.md` y `sdd-verify/SKILL.md` referencian al helper con "Ver test-runner-detection.md en skills/_shared/"
- Verificar que las skills siguen siendo invocables (verificación funcional post-refactor)

## Preguntas Abiertas

- [ ] ¿El orquestador debe inyectar dinámicamente la referencia al Return Envelope en lugar de dejarla como texto hardcoded?
- [ ] ¿Las secciones "Errores Comunes" eliminadas deberían vivir en algún otro lugar (ej: un archivo de "best practices" por fase) o simplemente eliminarse?
- [ ] ¿El helper de test-runner-detection debe también incluir los comandos reales de ejecución (no solo la detección)?