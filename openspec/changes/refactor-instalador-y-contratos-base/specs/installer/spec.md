# Delta para Installer

## Requisitos MODIFICADOS

### Requisito: Marcadores de Inyección de Configuración

**Nueva descripción:**
El sistema DEBE usar marcadores HTML comment (`<!-- BEGIN SDD ORCHESTRATOR -->` / `<!-- END SDD ORCHESTRATOR -->`) para delimitar el bloque de configuración inyectado.

(Anteriormente: `### BEGIN SDD ORCHESTRATOR ###` / `### END SDD ORCHESTRATOR ###`)

#### Escenario: Inyección con Marcadores HTML

- GIVEN el usuario ejecuta `install.sh --agent opencode`
- WHEN el script escribe el bloque de configuración
- THEN DEBE usar `<!-- BEGIN SDD ORCHESTRATOR -->` como marcador de inicio
- AND DEBE usar `<!-- END SDD ORCHESTRATOR -->` como marcador de fin
- AND el bloque DEBE contener el contenido compilado de `orchestrator-core.md`

#### Escenario: Purga Idempotente con Marcadores HTML

- GIVEN el usuario tiene una instalación previa con marcadores HTML
- AND ejecuta `install.sh --agent opencode` nuevamente
- WHEN el script procesa la reinstalación
- THEN DEBE detectar `<!-- BEGIN SDD ORCHESTRATOR -->` en el archivo destino
- AND DEBE purgar el bloque anterior (entre BEGIN y END inclusive)
- AND DEBE inyectar el nuevo bloque compilado
- AND el resultado DEBE contener exactamente UN bloque del orquestador

#### Escenario: Primera Re-instalación Post-Migración

- GIVEN el usuario tiene una instalación previa con marcadores antiguos (`### BEGIN/END SDD ORCHESTRATOR ###`)
- AND ejecuta `install.sh --agent opencode` tras la actualización
- WHEN el script purga bloques existentes
- THEN NO DEBE encontrar los marcadores HTML (no existen aún)
- AND DEBE agregar el nuevo bloque con marcadores HTML
- AND el archivo DEBE contener temporalmente ambos bloques (antiguo + nuevo)
- AND la segunda ejecución DEBE purgar correctamente el bloque HTML

#### Escenario: Idempotencia Tras Múltiples Ejecuciones

- GIVEN el usuario ejecuta `install.sh --agent opencode` tres veces consecutivas
- WHEN se inspecciona el archivo de configuración destino
- THEN DEBE contener exactamente UN bloque del orquestador delimitado por marcadores HTML
- AND NO DEBE contener bloques duplicados
- AND el contenido DEBE corresponder a la última compilación

### Requisito: Actualización de Instalación Existente

**Nueva descripción:**
El sistema DEBE purgar bloques previos delimitados por `<!-- BEGIN SDD ORCHESTRATOR -->` / `<!-- END SDD ORCHESTRATOR -->`.

(Anteriormente: purgaba bloques con `### BEGIN SDD ORCHESTRATOR ###` / `### END SDD ORCHESTRATOR ###`)

#### Escenario: Purga Exitosa con awk

- GIVEN el archivo destino contiene un bloque entre `<!-- BEGIN SDD ORCHESTRATOR -->` y `<!-- END SDD ORCHESTRATOR -->`
- WHEN el script ejecuta la lógica awk de purga
- THEN DEBE eliminar todo el contenido entre los marcadores (inclusive)
- AND DEBE preservar todo el contenido fuera del bloque
- AND el archivo resultante DEBE ser válido

## Requisitos NO MODIFICADOS

Los siguientes requisitos de installer permanecen sin cambios:
- Compatibilidad con PowerShell Nativo
- Compilación de Configuración (variables `{{TOOL_NAME}}`, `{{SKILLS_PATH}}`)
- Detección de SO
- Validación de Source
- Conteo de Comandos y Skills
- Integridad de la Instalación
