# Especificación: Actualización de Template config.yaml

## Visión General

Esta especificación define los requisitos y escenarios para actualizar los templates base de inicialización del proyecto (`config.yaml`) generados por la skill `sdd-init` y documentados en `openspec-convention.md`. El objetivo es forzar prácticas de codificación defensiva y diseños aptos para LLMs con contexto limitado.

## Requisitos

### Requisito 1: Modificación de Reglas de Diseño (design)

La sección `rules.design` del template de `config.yaml` debe exigir (MUST) diagramas estructurales (Sequence, State, Class) en `design.md` y priorizar la "modularidad extrema" para modelos con ventana de contexto estrecha.
**Nivel de obligatoriedad**: MUST

### Requisito 2: Modificación de Reglas de Tareas (tasks)

La sección `rules.tasks` debe exigir explícitamente "Granularidad Atómica" en la partición de tareas, evitando que los sub-agentes escriban múltiples archivos simultáneamente bajo una misma tarea.
**Nivel de obligatoriedad**: MUST

### Requisito 3: Modificación de Reglas de Implementación (apply)

La sección `rules.apply` debe imponer "Código Defensivo y Pragmatismo", exigiendo el uso de Early Returns (Guard Clauses), principios SOLID y Clean Code. Asimismo, debe quedar terminantemente prohibido el uso de espacios incompletos en el código impreso, es decir prohibir placeholders (ej. "...codigo restante aqui...").
**Nivel de obligatoriedad**: MUST

### Requisito 4: Consistencia de Documentación Oficial

Las mismas modificaciones al bloque YAML realizadas en los scripts de la skill `sdd-init` deben reflejarse textualmente de igual forma en `skills/_shared/openspec-convention.md`.
**Nivel de obligatoriedad**: MUST

## Escenarios (Behavioral Specs)

### Escenario 1.1: Despliegue de Configuración Estricta

**GIVEN** que el usuario u Orquestador ejecuta el bootstrap mediante `sdd-init` sobre un nuevo proyecto vacío
**WHEN** el sub-agente inyecta la configuración local en `openspec/config.yaml`
**THEN** el YAML renderizado MUST reflejar bajo `rules.design` la directriz obligatoria de "diagramas Mermaid exhaustivos" y "modularidad extrema".
**AND** MUST contemplar en `rules.tasks` la limitación a "granularidad atómica".
**AND** MUST incluir en `rules.apply` la estricta "completitud", indicando la erradicación del comportamiento de dejar placeholders.

### Escenario 1.2: Auditoria de Documentación (DRY)

**GIVEN** que un sub-agente (o desarrollador) analiza y lee `skills/_shared/openspec-convention.md` como framework principal
**WHEN** ubica la sección referencial denominada "Referencia del config.yaml"
**THEN** el bloque de código formatado como YAML MUST emular 1:1 el mismo set exhaustivo de reglas documentadas en la nueva versión de la skill `sdd-init`.
