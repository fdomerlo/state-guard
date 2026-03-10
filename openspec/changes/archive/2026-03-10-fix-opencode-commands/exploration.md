## Exploración: fix-opencode-commands

### Estado Actual
Los comandos de OpenCode (`sdd-init.md`, `sdd-new.md`, etc.) en el repositorio actualmente utilizan el modo `engram` para el almacenamiento de artefactos. Además, la descripción y las secciones `TASK:` / `WORKFLOW:` se encuentran en inglés y referencian rutas que pueden no estar adaptadas correctamente.

### Áreas Afectadas
- `examples/opencode/commands/*.md` — Los comandos slash requieren ajustes en el modo y traducción de secciones.

### Enfoques
1. **Actualización sistemática de comandos** — Reemplazo iterativo en todos los archivos markdown de `examples/opencode/commands/`.
   - Ventajas: Acelera el proceso y unifica los comandos existentes a la convención en español.
   - Desventajas: Requiere cuidado para no alterar las variables de interpolación entre llaves `{}`.
   - Esfuerzo: Bajo

### Recomendación
Avanzar con la "Actualización sistemática de comandos". Este enfoque asegura coherencia y se alinea de inmediato con las reglas dadas por el usuario para el orquestador sin complejizar el diseño.

### Riesgos
- Alterar sin querer las variables `{workdir}`, `{project}` o `{argument}`, corrompiendo el funcionamiento de los comandos en OpenCode.

### Listo para Propuesta
Sí, listo para formalizar la propuesta.
