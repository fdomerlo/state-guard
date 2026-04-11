# Propuesta: "Docs Add Custom Skills Guide"

## Intención
Necesitamos mejorar la documentación del proyecto (`MANUAL.md`) para explicar claramente cómo los desarrolladores pueden agregar, registrar y utilizar "Custom Skills" (sub-agentes no nativos de SDD) dentro del orquestador.

## Problema Actual
Actualmente no existe documentación clara sobre cómo los usuarios pueden extender el orquestador con skills/sub-agentes personalizados (ej. `frontend-design`), lo que limita la extensibilidad de la herramienta.

## Alcance
- Modificar el archivo `MANUAL.md`.
- Agregar una nueva sección titulada "Guía de Integración: Custom Skills".
- Documentar las reglas de ubicación física (`skills/`), el contrato (`SKILL.md`), la indexación (`skill-registry`) y su uso.
- Proporcionar un ejemplo real (boilerplate) del `SKILL.md` para la integración de "frontend-design".

## Riesgo Escatimado
Riesgo: Bajo (solo cambios en la documentación). No se requiere plan de rollback complejo ni afecta la lógica central.
