## Exploración: Aniquilación del Concepto de Modos

### Estado Actual
El framework Agentify-SDD mantiene la abstracción `artifact_store.mode` (con valores como `openspec` o `none`) heredada de versiones anteriores donde la persistencia externa podía variar. Actualmente, el framework es estrictamente Agent-First, lo que significa que la persistencia en disco mediante el sistema OpenSpec es universal y obligatoria. Mantener estas variables y tablas comparativas en la documentación genera confusión y código innecesario.

### Áreas Afectadas
- `openspec/specs/persistencia/spec.md` — Contiene las definiciones de reglas para los modos y cómo el orquestador debe forzarlos. Todo este capítulo de "resolución" es obsoleto.
- `skills/_shared/persistence-contract.md` — Es el contrato de persistencia. Contiene tablas comparativas y ejemplos que inyectan el modo.
- `skills/_shared/orchestrator-core.md` — Establece la configuración por defecto incluyendo el modo.
- `skills/sdd-init/SKILL.md` — Tiene procesos para forzar y detectar el modo.
- `skills/sdd-verify/SKILL.md` — Utiliza el modo resuelto para persistir reportes.
- `skills/_shared/orchestrator-commands.md` — Contiene descripciones de comandos que mencionan el forzado del modo.
- `README.md` — (Mencionado en la búsqueda anterior) — Tiene una sección dedicada al Modo OpenSpec que debe ser simplificada a "Persistencia de Artefactos".

### Enfoques
1. **Purga Definitiva (Recomendado)** — Eliminar toda mención a `artifact_store.mode` y tratar la persistencia en disco como el único comportamiento disponible. Simplifica drásticamente el código del orquestador y los contratos de los sub-agentes.
   - Ventajas: Máxima simplicidad, reducción de tokens en prompts, flujo de datos predecible.
   - Desventajas: Rompe cualquier código legacy que dependa de esa clave en el config.yaml.
   - Esfuerzo: Medio.

2. **Obsolescencia Suave** — Dejar la clave en el código pero eliminarla de toda la documentación.
   - Ventajas: Retrocompatibilidad con scripts externos.
   - Desventajas: Mantiene "ruido" arquitectónico que eventualmente habrá que limpiar.
   - Esfuerzo: Bajo.

### Recomendación
Adoptar el enfoque de **Purga Definitiva**. El objetivo del repositorio es ser un estado del arte en Agent-First, y las abstracciones innecesarias son un antipatrón en este contexto.

### Riesgos
- **Ruptura de Configuración**: Si hay scripts de usuario (bash/python) que consulten el `config.yaml` y fallen si no encuentran la clave `mode`. Se recomienda actualizar cualquier ejemplo de scripts en la carpeta `scripts/`.
- **Inconsistencia en Specs**: Algunas specs principales podrían tener dependencias lógicas cruzadas con la definición de "Modo". Será necesaria una revisión manual detallada durante la fase de Especificación.

### Listo para Propuesta
Sí — El alcance está claro. El orquestador puede proceder a redactar la propuesta de cambio estructural.
