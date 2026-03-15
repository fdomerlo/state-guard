# Propuesta: hotfix-v1-0-1

## Intención

Este hotfix aborda dos problemas críticos de documentación en las skills del orquestador SDD:

1. **Parche BDD (Anti-GAND):** Agregar una regla estricta en `sdd-spec/SKILL.md` que prohíba el uso de palabras clave Gherkin no estándar (como "GAND"). Esto busca mantener la consistencia y claridad en la sintaxis de escenarios BDD.

2. **Parche Meta-Comandos:** Clarificar en `orchestrator-core.md` cómo el orquestador debe procesar los meta-comandos (`/sdd-continue`, `/sdd-ff`, `/sdd-new`, etc.). Actualmente existe confusión sobre si son skills físicas o instrucciones de texto que el orquestador debe interpretar internamente.

## Alcance

### Dentro del Alcance
- Agregar regla de "Sintaxis Gherkin/BDD Inmutable" en `skills/sdd-spec/SKILL.md`, sección Reglas (línea ~147)
- Agregar directiva de "META-COMANDOS VS SKILLS" en `skills/_shared/orchestrator-core.md`, después de línea 57
- Agregar nota de "Próximo Paso" que clarifique cómo el usuario debe interacturar con los comandos

### Fuera del Alcance
- Modificación de cualquier lógica de código existente
- Cambios en el comportamiento del orquestador más allá de la documentación
- Tests o validaciones automatizadas (no aplica para hotfix de documentación)

## Enfoque

Se trata de un hotfix de documentación/instrucciones. El enfoque consiste únicamente en agregar texto explicativo a los archivos de skills existentes. No hay código que ejecutar ni tests que correr. La implementación se limita a insertar lasdirectivas proporcionadas por el usuario en las ubicaciones especificadas.

## Áreas Afectadas

| Área              | Impacto     | Descripción                                              |
|-------------------|-------------|----------------------------------------------------------|
| Skill de Spec     | Modificado  | `~/.config/opencode/skills/sdd-spec/SKILL.md`         |
| Core del Orquestador | Modificado | `~/.config/opencode/skills/_shared/orchestrator-core.md` |

## Riesgos

| Riesgo                           | Probabilidad | Mitigación                              |
|----------------------------------|--------------|-----------------------------------------|
| Confusión por duplicación de reglas BDD | Baja    | La regla es complementaria a la existente |
| Orquestador malinterpreta meta-comandos | Media | La directiva es clara: son "instrucciones de texto" |
| Usuario no entiende cómo interactuar | Baja    | La nota de "Próximo Paso" clarifica el proceso |

## Plan de Rollback

Simplemente eliminar las líneas agregadas de los archivos afectados:
- Eliminar la regla de "Sintaxis Gherkin/BDD Inmutable" de `sdd-spec/SKILL.md`
- Eliminar la directiva de "META-COMANDOS VS SKILLS" y la nota de "Próximo Paso" de `orchestrator-core.md`

Los archivos originales se restauran sin efectos secundarios.

## Dependencias

- Ninguna dependencia externa requerida

## Criterios de Éxito

- [ ] Regla BDD agregada en `sdd-spec/SKILL.md` y visible en la sección Reglas
- [ ] Directiva de meta-comandos agregada en `orchestrator-core.md`
- [ ] Nota de "Próximo Paso" clarifica cómo el usuario debe interacturar
- [ ] No se rompe ninguna funcionalidad existente del orquestador
