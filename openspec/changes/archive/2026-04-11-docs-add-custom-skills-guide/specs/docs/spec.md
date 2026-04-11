# Especificaciones: Guía de Custom Skills

## Requisitos
- **REQ-01**: Se MUST agregar una nueva sección "Guía de Integración: Custom Skills" dentro de `MANUAL.md`.
- **REQ-02**: La sección MUST explicar la ubicación de las skills: dentro del directorio `skills/` en una carpeta propia (ej. `skills/frontend-design/`), evitando colisiones con prefijos `sdd-*` o la carpeta `_shared/`.
- **REQ-03**: La sección MUST indicar explícitamente que cada skill requiere un archivo `SKILL.md` como contrato o prompt.
- **REQ-04**: La sección MUST instruir al desarrollador a ejecutar el skill `skill-registry` (o directamente el script `skills/skill-registry/scan.sh`) para indexar la nueva skill en `.agentify/skill-registry.md`.
- **REQ-05**: La sección MUST explicar que el orquestador lee este índice al inicio para delegar tareas basadas en el nombre y descripción del SKILL.md.
- **REQ-06**: La sección MUST incluir un bloque de código markdown con el ejemplo real (boilerplate) de un `SKILL.md` de la skill `frontend-design`.
- **REQ-07**: El tono MUST ser técnico, conciso y estrictamente en español (castellano).

## Escenarios

#### Escenario: Lectura de la guía de integración
- GIVEN un desarrollador leyendo el `MANUAL.md`
- WHEN el desarrollador busque cómo agregar sub-agentes no nativos
- THEN encontrará la sección "Guía de Integración: Custom Skills" con reglas claras de ubicación, contrato, indexación y uso.
- AND encontrará un ejemplo de `SKILL.md` listo para usar como plantilla.
