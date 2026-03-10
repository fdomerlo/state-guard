# Propuesta: fix-opencode-commands

## Intención
Solucionar el bug en la integración con OpenCode donde los slash commands solicitan el modo `engram` y presentan instrucciones en inglés. Se requiere alinear todos los comandos al modo `openspec` y traducir sus descripciones operacionales al español por motivos de auditoría, manteniendo las variables del framework intactas.

## Alcance

### Dentro del Alcance
- Modificar `- Artifact store mode: engram` a `- Artifact store mode: openspec` en los archivos `.md` de `examples/opencode/commands/`.
- Traducir el atributo `description` del Frontmatter de cada uno de esos archivos al español.
- Traducir las instrucciones en las secciones `TASK:` o `WORKFLOW:` al español.
- Ajustar cualquier referencia de rutas para que apunten a `~/.config/opencode/skills/`.

### Fuera del Alcance
- Refactorización lógica del comportamiento interno de los sub-agentes referenciados por los comandos.
- Alteración de variables funcionales `{workdir}`, `{project}` o `{argument}`.

## Enfoque
Actualización directa de los archivos identificados usando reemplazo de texto, respetando el formato del Frontmatter y realizando una traducción exacta y conservadora para proteger las variables.

## Áreas Afectadas

| Área                          | Impacto      | Descripción                                |
|-------------------------------|--------------|--------------------------------------------|
| `examples/opencode/commands/` | Modificado   | Actualización general a 8 archivos `.md`. |

## Riesgos

| Riesgo                                 | Probabilidad    | Mitigación                                         |
|----------------------------------------|-----------------|----------------------------------------------------|
| Modificación accidental de variables   | Baja            | Revisar sintaxis de traducción visualmente.        |

## Plan de Rollback
Revertir el último commit de git relacionado con `examples/opencode/commands/` o restaurar las versiones originales desde el control de versiones local.

## Dependencias
- Ninguna

## Criterios de Éxito
- [ ] La línea `- Artifact store mode: openspec` existe en todos los archivos pertinentes.
- [ ] No existen referencias a "engram" para el artifact store mode.
- [ ] Las secciones `TASK`/`WORKFLOW` y el campo `description` están en español.
- [ ] Las variables `{workdir}`, `{project}` y `{argument}` no han sido alteradas en absoluto.
- [ ] Las rutas apuntan a `~/.config/opencode/skills/`.
