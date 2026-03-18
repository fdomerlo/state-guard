# Propuesta de Cambio: fix-init-config-template

## Intención

Actualizar el template base de `config.yaml` generado por la skill `sdd-init` y documentado en `openspec-convention.md` para que todos los proyectos nuevos incluyan directivas de codificación defensiva y diseño optimizado para modelos de razonamiento (como MiniMax y su contexto limitado).

## Alcance

- Modificar el archivo `skills/sdd-init/SKILL.md` (Paso 3, bloque YAML del config.yaml) para inyectar las reglas dictadas respecto a `design`, `tasks` y `apply`.
- Modificar `skills/_shared/openspec-convention.md` (Sección "Referencia del config.yaml") sincronizando las nuevas reglas inyectadas en sdd-init.

## Enfoque de Implementación

1. **Regla para `design`**:
   - Exigencia estricta de diagramas Mermaid (clases, estado y secuencia).
   - Inyectar principio de "modularidad extrema" para aliviar la carga de contexto en LLMs.
2. **Regla para `tasks`**:
   - Forzar la granularidad atómica (tareas dedicadas a un solo archivo o cambio delimitado).
3. **Regla para `apply`**:
   - Imponer el uso de Early Returns (Guard Clauses), principios SOLID y clean code.
   - Prohibición estricta de "placeholders" / código incompleto (e.g. "...codigo aquí...").

## Riesgos y Mitigación

- **Riesgo**: Perturbar el parseo de Markdown/YAML dentro de las plantillas existentes.
- **Mitigación**: Mantener al 100% la indentación y formato heredado tanto en `SKILL.md` como en `openspec-convention.md`. Validar que herramientas externas no se quiebren por agregar nuevas `rules` a la sección de configuración.

## Plan de Rollback

Deshacer los cambios de ambos archivos a través del control de versiones (Git) y correr verificaciones en los proyectos donde haya corrompido un render de templates bash/markdown localmente.
