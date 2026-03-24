## Exploración: refactor-instalador-y-contratos-base

### Estado Actual

#### Instalador (`scripts/install.sh`)
- La función `compile_and_append_config` (líneas 178-220) usa marcadores de texto plano:
  - `marker_begin="### BEGIN SDD ORCHESTRATOR ###"` (línea 184)
  - `marker_end="### END SDD ORCHESTRATOR ###"` (línea 185)
- La lógica de purgado usa `awk` con flag: busca `marker_begin`, activa flag, luego busca `marker_end` y desactiva flag, saltando la línea del end marker (línea 191).
- Los marcadores actuales son texto visible que puede romper el renderizado Markdown en IDEs.
- La lógica awk (`awk "/$marker_begin/{flag=1} /$marker_end/{flag=0; next} !flag"`) funcionará correctamente con HTML comments porque awk solo busca las cadenas literales — no requiere escaping especial para `<!-- -->`.

#### Contrato de Persistencia (`skills/_shared/persistence-contract.md`)
- **Sin menciones** a `engram`, `hybrid` o `mem_save`. Ya está limpio.
- Resolución de modo: solo `openspec` y `none` (líneas 5-12). Correcto.
- Sección `detail_level` y `glossary` presentes y funcionales.

#### Convención OpenSpec (`skills/_shared/openspec-convention.md`)
- Tabla de "Rutas de Artefactos por Skill" (líneas 27-39) usa rutas explícitas como `openspec/changes/{change-name}/proposal.md`. Correcto.
- Documentación de carpeta de archivo: `openspec/changes/archive/YYYY-MM-DD-{change-name}/` (líneas 170-178). Correcto.
- Sin menciones a engram, hybrid o mem_save.

#### Archivo con menciones fuera de alcance
- `skills/_shared/orchestrator-core.md` línea 40: menciona `hybrid` y `engram` en la política de almacenamiento. **Fuera del alcance estricto** de `./skills/_shared/` — pero debe ser verificado por el orquestador.
- `.agent/rules/sdd-orchestrator.md` línea 76: copia idéntica del orchestrator-core (generado por install.sh). **Fuera del alcance**.

### Áreas Afectadas
- `scripts/install.sh:184-185` — Variables `marker_begin` y `marker_end` a cambiar por HTML comments
- `scripts/install.sh:191` — Lógica awk de purgado (funcionará sin cambios, solo verificar)
- `scripts/install.sh:198-199,217` — Escritura de marcadores en el archivo destino (usará los nuevos valores automáticamente)
- `skills/_shared/persistence-contract.md` — **No requiere cambios** (ya está limpio)
- `skills/_shared/openspec-convention.md` — **No requiere cambios** (ya documenta rutas correctamente)
- `skills/_shared/orchestrator-core.md:40` — Referencia a `hybrid`/`engram` fuera del alcance estricto pero relevante arquitectónicamente

### Enfoques

1. **Cambio directo de marcadores** — Reemplazar `### BEGIN/END SDD ORCHESTRATOR ###` por `<!-- BEGIN/END SDD ORCHESTRATOR -->`
   - Ventajas: Cambio mínimo, awk funciona sin modificaciones, HTML invisible en render
   - Desventajas: Ruptura de compatibilidad con instalaciones previas (el purgado anterior no encontrará los nuevos markers en instalaciones viejas, pero esto es idempotente: la primera vez purga lo viejo, la segunda purga lo nuevo)
   - Esfuerzo: Bajo

2. **Purga de orchestrator-core.md** — Eliminar menciones a `hybrid`/`engram` del orchestrator-core.md
   - Ventajas: Consistencia total del ecosistema, no dejar rastro de dependencias externas
   - Desventajas: Fuera del alcance estricto de `./skills/_shared/` (orchestrator-core.md es `_shared` pero la regla solo cubre contratos Markdown)
   - Esfuerzo: Bajo

### Recomendación
- Aplicar el enfoque 1 (cambio directo de marcadores) — es el core de este cambio.
- Considerar incluir el enfoque 2 (purga de orchestrator-core.md) como parte del cambio ya que también está en `skills/_shared/` y contiene las mismas referencias indeseadas.
- `persistence-contract.md` y `openspec-convention.md` **no requieren modificaciones** — ya cumplen con los requisitos.

### Riesgos
- **Compatibilidad hacia atrás**: Instalaciones previas con marcadores `### BEGIN/END ###` no serán purgadas por la nueva lógica con `<!-- -->`. Mitigación: el purgado es idempotente — si no encuentra el marker, simplemente agrega un nuevo bloque (duplicación en primera ejecución). Se puede mitigar agregando purga dual temporal o aceptando que la primera re-instalación tendrá doble bloque.
- **Alcance incompleto**: `orchestrator-core.md` y `.agent/rules/sdd-orchestrator.md` también mencionan `engram`/`hybrid`. Si el objetivo es purga total de rastros, estos archivos deben incluirse.

### Listo para Propuesta
**Sí** — La investigación es suficiente. El orquestador debe comunicar al usuario que:
1. Los cambios en `persistence-contract.md` y `openspec-convention.md` son innecesarios (ya cumplen los requisitos).
2. El cambio real se concentra en `install.sh` (marcadores HTML).
3. Se recomienda incluir `orchestrator-core.md` en la purga de menciones a `engram`/`hybrid`.
