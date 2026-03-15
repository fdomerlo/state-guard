# Diseño: hotfix-v1-0-1

## Resumen Ejecutivo

Este diseño documenta las decisiones técnicas para implementar un hotfix de documentación en las skills del orquestador SDD. El cambio es mínimo: solo implica agregar texto explicativo a dos archivos de skills existentes para clarificar reglas de sintaxis BDD y el procesamiento de meta-comandos.

## Contexto

Este hotfix surge de dos necesidades:

1. **Parche BDD:** Los escenarios BDD en las specs deben usar exclusivamente palabras clave Gherkin estándar. Se ha identificado el uso de variantes no estándar como "GAND" (Given-And) que rompen la consistencia.

2. **Parche Meta-Comandos:** Existe confusión sobre si los comandos como `/sdd-continue`, `/sdd-ff`, etc. son skills físicas o instrucciones de texto que el orquestador interpreta internamente.

## Arquitectura del Cambio

### Tipo de Cambio

- **Categoría:** Documentación / Hotfix de instrucciones
- **Complejidad:** Mínima
- **Riesgo:** Bajo

### Decisión: Estructura de Inserción

Se opta por agregar las directivas como **reglas adicionales** en las secciones existentes de los archivos de skills, en lugar de crear nuevos archivos o modificar la estructura lógica existente.

**Justificación:** Mantiene la coherencia con el formato actual de las skills y facilita el mantenimiento futuro.

## Detalles de Implementación

### 1. Modificación en `sdd-spec/SKILL.md`

**Ubicación exacta:** Después de la línea 146, en la sección "Reglas"

**Texto a agregar:**

```markdown
### Regla de Sintaxis Gherkin/BDD Inmutable

- **MUY IMPORTANTE:** Los escenarios BDD deben usar EXCLUSIVAMENTE las palabras clave Gherkin estándar: **GIVEN**, **WHEN**, **THEN**, **AND**, **BUT**.
- **NO se permite** el uso de variantes no estándar como "GAND" (Given-And), "WAND" (When-And), o cualquier otra combinación no autorizada.
- El sistema DEBE rechazar cualquier escenario que contenga variantes no estándar.
- Palabras clave válidas: GIVEN, WHEN, THEN, AND, BUT, Feature, Background, Scenario, Scenario Outline, Examples.
```

**Ubicación en el archivo:**

```markdown
## Reglas

- SIEMPRE usar el formato Given/When/Then para escenarios
- SIEMPRE usar palabras clave RFC 2119 (MUST, SHALL, SHOULD, MAY) para la fuerza de un requisito
- Si existen specs, escribir specs DELTA (secciones AGREGADOS/MODIFICADOS/ELIMINADOS)
- Si NO existen specs para el dominio, escribir una spec COMPLETA
- Todo requisito DEBE tener al menos UN escenario
- Incluir tanto caminos felices COMO casos límite
- Mantener los escenarios TESTEABLES — alguien debería poder escribir un test automatizado desde cada uno
- NO incluir detalles de implementación en las specs — las specs describen QUÉ, no CÓMO
- Aplicar cualquier `rules.specs` de `openspec/config.yaml`
- Devolver un envelope estructurado con: `status`, `executive_summary`, `detailed_report` (opcional), `artifacts`, `next_recommended` y `risks`

### Regla de Sintaxis Gherkin/BDD Inmutable

- **MUY IMPORTANTE:** Los escenarios BDD deben usar EXCLUSIVAMENTE las palabras clave Gherkin estándar: **GIVEN**, **WHEN**, **THEN**, **AND**, **BUT**.
- **NO se permite** el uso de variantes no estándar como "GAND" (Given-And), "WAND" (When-And), o cualquier otra combinación no autorizada.
- El sistema DEBE rechazar cualquier escenario que contenga variantes no estándar.
- Palabras clave válidas: GIVEN, WHEN, THEN, AND, BUT, Feature, Background, Scenario, Scenario Outline, Examples.
```

### 2. Modificación en `orchestrator-core.md`

**Ubicación exacta:** Después de la línea 57, antes de la sección "Grafo de Dependencias"

**Texto a agregar:**

```markdown
### META-COMANDOS VS SKILLS (CRÍTICO)

Los comandos que empiezan por `/sdd-` (como `/sdd-continue`, `/sdd-ff`, `/sdd-new`, etc.) **NO son skills físicas**. Son **instrucciones de texto** que el orquestador debe interpretar internamente y delegar a la skill apropiada.

**Comportamiento esperado:**
- El orquestador reconoce el patrón `/sdd-*` como una instrucción interna
- Traduce el meta-comando a la skill correspondiente (ej: `/sdd-status` → skill `sdd-status`)
- **NO** busca una skill física llamada "sdd-continue" ni ninguna otra variant
- Mantiene un mapeo interno de meta-comandos a sus acciones correspondientes

**Lista de meta-comandos soportados:**
| Meta-Comando | Skill Delegada | Descripción |
|--------------|----------------|-------------|
| `/sdd-init` | sdd-init | Inicializa el proyecto SDD |
| `/sdd-explore` | sdd-explore | Explora e investiga ideas |
| `/sdd-new` | sdd-explore + sdd-propose | Crea un nuevo cambio |
| `/sdd-continue` | sdd-* (variable) | Continúa el siguiente artefacto |
| `/sdd-ff` | sdd-propose → sdd-spec → sdd-design → sdd-tasks | Fast-forward de fases |
| `/sdd-apply` | sdd-apply | Implementa tareas |
| `/sdd-verify` | sdd-verify | Valida implementación |
| `/sdd-review` | sdd-review | Auditoría estática |
| `/sdd-split` | sdd-split | Divide proposals grandes |
| `/sdd-archive` | sdd-archive | Archiva cambio completado |
| `/sdd-changelog` | sdd-changelog | Genera CHANGELOG |
| `/sdd-status` | sdd-status | Muestra estado de cambios |
```

### 3. Nota de Próximo Paso

**Ubicación:** Al final del documento, después de la "Regla de Recuperación"

El diseño especifica que después de cualquier fase SDD, el orquestador debe incluir una nota de "Próximo Paso" para guiar al usuario. Esta nota ya está implícita en el flujo actual, pero el diseño confirma que debe ser explícita.

## Criterios de Diseño

| Criterio | Decisión |
|----------|----------|
| **Minimizar impacto** | Solo inserción de texto, sin refactorización |
| **Claridad** | Usar bloques de código para mostrar texto exacto a agregar |
| **Mantenibilidad** | Las reglas se agregaron en secciones lógicas existentes |
| **Consistencia** | El formato de las reglas sigue el estilo existente |

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Confusión por duplicación de reglas BDD | Baja | Bajo | La regla es complementaria y más específica |
| Texto insertado en ubicación incorrecta | Media | Bajo | Se especificó la línea exacta de inserción |
| El orquestador no interpreta meta-comandos correctamente | Media | Medio | La directiva es explícita sobre el comportamiento esperado |

## Plan de Implementación

### Fase 1: Aplicar cambio a `sdd-spec/SKILL.md`

1. Abrir el archivo en la ruta especificada
2. Ubicar la sección "Reglas" (línea 144)
3. Insertar la regla de "Sintaxis Gherkin/BDD Inmutable" después de la regla existente sobre palabras clave RFC 2119

### Fase 2: Aplicar cambio a `orchestrator-core.md`

1. Abrir el archivo en la ruta especificada
2. Ubicar después de la línea 57 (nota sobre meta-comandos)
3. Insertar la directiva de "META-COMANDOS VS SKILLS"

### Fase 3: Verificación

1. Confirmar que las reglas son visibles en las secciones correctas
2. Verificar que no se rompió ninguna funcionalidad existente

## Dependencias

- Ninguna dependencia externa
- Los archivos afectados ya existen y están en el estado correcto

## Archivos Modificados

| Archivo | Acción | Líneas Aproximadas |
|---------|--------|-------------------|
| `~/.config/opencode/skills/sdd-spec/SKILL.md` | Insertar | +8 líneas |
| `~/.config/opencode/skills/_shared/orchestrator-core.md` | Insertar | +25 líneas |

## Validación Post-Implementación

- [ ] La regla BDD es visible en la sección Reglas de `sdd-spec/SKILL.md`
- [ ] La directiva de meta-comandos es visible en `orchestrator-core.md`
- [ ] No se modificó ninguna funcionalidad existente del orquestador
- [ ] El formato es consistente con el resto de cada archivo
