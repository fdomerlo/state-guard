# Comandos de Orquestación

## Meta-comandos de Orquestación

Los siguientes comandos son **meta-comandos** — el orquestador los maneja directamente orquestando múltiples fases:

- `/sdd-new <change>` → ejecuta `sdd-explore` y luego `sdd-propose`.
- `/sdd-continue [change]` → crea el siguiente artefacto faltante en la cadena de dependencias.
- `/sdd-ff [change]` → ejecuta `sdd-propose` → `sdd-spec` → `sdd-design` → `sdd-tasks`. Cuando ejecutes el meta-comando `/sdd-ff`, TIENES ESTRICTAMENTE PROHIBIDO esperar hasta el final para guardar el estado. DEBES escribir/actualizar `state.yaml` en el disco después de completar CADA fase interna (propose, spec, design, tasks) para garantizar la recuperación en caso de fallo del IDE.

## Skills Directos

Los siguientes comandos ejecutan **skills individuales** que puedes invocar directamente:

- `/sdd-init` → ejecuta `sdd-init` (inicializa el proyecto y las convenciones SDD).
- `/sdd-explore <topic>` → ejecuta `sdd-explore`.
- `/sdd-propose <change>` → ejecuta la skill `sdd-propose` para crear o iterar sobre una propuesta de manera independiente.
- `/sdd-spec <change>` → ejecuta `sdd-spec` para escribir especificaciones delta.
- `/sdd-design <change>` → ejecuta `sdd-design` para crear el documento de diseño técnico.
- `/sdd-tasks <change>` → ejecuta `sdd-tasks` para desglosar en tareas de implementación.
- `/sdd-apply [change]` → ejecuta `sdd-apply` en lotes.
- `/sdd-verify [change]` → ejecuta `sdd-verify`.
- `/sdd-review [change]` → ejecuta `sdd-review` (auditoría estática de código contra specs).
- `/sdd-fix` → ejecuta `sdd-fix` (audita y repara estados corruptos o archivos faltantes).
- `/sdd-split [change]` → ejecuta `sdd-split` (divide proposals monolíticas en sub-cambios).
- `/sdd-archive [change]` → ejecuta `sdd-archive`.
- `/sdd-changelog` → ejecuta `sdd-changelog` (genera CHANGELOG.md desde archive).
- `/sdd-status` → ejecuta `sdd-status` (muestra el estado de todos los cambios activos).
- `/sdd-checkpoint` → ejecuta `sdd-checkpoint` (guarda resumen de sesión en state.yaml).
- `/sdd-rollback` → ejecuta `sdd-rollback` (revierte cambio activo y restaura entorno).
- `/sdd-skill-registry` → ejecuta `sdd-skill-registry` (escanea `skills-addons/` y actualiza el índice de herramientas de terceros en `.agentify/skill-registry.md`).

## Grafo de Dependencias

```text
explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive
```
