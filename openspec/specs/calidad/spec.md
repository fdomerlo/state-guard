# Delta para calidad

## Requisitos AGREGADOS

### Requisito: Completitud de comandos en documentación

La tabla de comandos del README.md SHALL incluir todos los comandos SDD disponibles para el usuario.

#### Escenario: Comando faltante en tabla de comandos

- GIVEN El usuario consulta la tabla de comandos en README.md
- WHEN Busca el comando `/sdd-propose`
- THEN El comando aparece enlistado con su descripción correspondiente

### Requisito: Clarificación de meta-comandos

El archivo orchestrator-core.md SHALL distinguir claramente entre comandos directos (skills) y meta-comandos (orquestación de fases).

#### Escenario: Identificación de meta-comandos

- GIVEN Un nuevo operador lee orchestrator-core.md
- WHEN Consulta la sección de comandos de orquestación
- THEN Los meta-comandos (`/sdd-new`, `/sdd-continue`, `/sdd-ff`) están marcados explícitamente como tales
- AND Los comandos directos (`/sdd-propose`, `/sdd-spec`, etc.) están diferenciados

### Requisito: Coherencia interna de documentación

El archivo openspec-convention.md SHALL mantener coherencia entre la tabla de rutas y las descripciones de cada skill.

#### Escenario: Descripción inconsistente de sdd-archive

- GIVEN Un operador lee la tabla de rutas y la descripción de sdd-archive
- WHEN Compara ambas secciones
- THEN Ambas indican las mismas acciones (mover a archive + fusionar deltas) sin contradicciones

### Requisito: Integridad del script de instalación

El script install.sh SHALL estar libre de placeholders y usar manejo de errores explícito.

#### Escenario: Placeholder en URL de error

- GIVEN Se ejecuta validate_source() y falla
- THEN El mensaje de error muestra una URL válida del repositorio, no un placeholder como "TU-USUARIO"

#### Escenario: Manejo de errores con operadores explícitos

- GIVEN El script encuentra una operación que puede fallar (mkdir, cp, chmod)
- WHEN La operación falla
- THEN El error se reporta claramente al usuario en lugar de silenciarse con `|| true`
- AND El flujo de ejecución se interrumpe apropiadamente si el error es crítico

### Requisito: Externalización de lógica inline

El script install.sh SHALL externalizar scripts Python inline a archivos separados cuando superen los 15 líneas.

#### Escenario: Script Python inline largo

- GIVEN El archivo install.sh contiene un bloque Python inline de más de 15 líneas
- WHEN Un desarrollador necesita mantener o debugear ese código
- THEN El código reside en un archivo dedicado en scripts/lib/ o similar
- AND install.sh lo invoca como script separado

## Requisitos MODIFICADOS

### Requisito: Mensajes de error informativos

El script install.sh SHALL mostrar mensajes de error claros con rutas específicas del sistema.

- GIVEN Una operación crítica falla
- WHEN El script reporta el error
- THEN Incluye información de contexto (ruta afectada, operación intentada) para facilitar diagnóstico

## Delta: update-docs-architecture (2026-04-05)

### Requisito: Documentación de sdd-checkpoint

El sistema DEBE documentar el comando sdd-checkpoint en MANUAL.md para permitir a los usuarios guardar el estado de la sesión manualmente.

#### Escenario: Checkpoint documentado en MANUAL

- GIVEN MANUAL.md existe en la raíz del proyecto
- WHEN se agrega sección de herramientas de recuperación con sdd-checkpoint
- THEN la documentación explica que el comando guarda resumen en session_summary y permite recuperación manual
- AND incluye ejemplo de uso: `/sdd-checkpoint`

#### Escenario: Checkpoint visible en tabla de comandos

- GIVEN MANUAL.md contiene tabla de comandos disponibles
- WHEN se actualiza la tabla
- THEN incluye fila con "sdd-checkpoint" y descripción breve

---

### Requisito: Documentación de sdd-rollback

El sistema DEBE documentar el comando sdd-rollback en MANUAL.md como herramienta de recuperación de emergencia.

#### Escenario: Rollback documentado en MANUAL

- GIVEN MANUAL.md existe en la raíz del proyecto
- WHEN se agrega documentación de sdd-rollback
- THEN la documentación lo presenta como "botón de pánico" para revertir cambios corruptos
- AND explica que purga la carpeta del cambio y restaura archivos desde git

#### Escenario: Advertencia de uso

- GIVEN MANUAL.md documenta sdd-rollback
- WHEN el usuario lee la documentación
- THEN encuentra advertencia clara sobre pérdida de trabajo no commiteado

---

### Requisito: Actualización de README con batching

El sistema DEBE actualizar README.md para documentar la estrategia de batching de tareas como método de optimización de tokens.

#### Escenario: README menciona batching

- GIVEN README.md existe en la raíz del proyecto
- WHEN se actualiza la sección de arquitectura
- THEN menciona explícitamente "batching de tareas" como característica de optimización
- AND explica brevemente su propósito: reducir overhead de contexto

---

### Requisito: Actualización de README con inyección modular

El sistema DEBE documentar la inyección modular de contexto en README.md para usuarios que implementan agentes.

#### Escenario: README menciona inyección modular

- GIVEN README.md existe en la raíz del proyecto
- WHEN se actualiza sección de arquitectura o diseño
- THEN incluye referencia a "inyección modular de contexto"
- AND la describe como técnica para cargar contexto relevante por tarea

---

### Requisito: Actualización de AGENTS.md para specs delta

El sistema DEBE actualizar AGENTS.md para especificar que los sub-agentes leen únicamente specs delta durante cambios.

#### Escenario: AGENTS refleja specs delta

- GIVEN AGENTS.md existe en la raíz del proyecto
- WHEN se actualizan las directivas de contexto
- THEN añade directiva que especifica: "sub-agentes leen specs delta de openspec/changes/{nombre}/specs/"
- AND excluye specs principales para evitar contaminación de contexto

---

### Requisito: Consistencia entre documentos

El sistema DEBE mantener consistencia terminológica entre MANUAL.md, README.md y AGENTS.md.

#### Escenario: Terminología unificada

- GIVEN los tres archivos se actualizan
- WHEN se comparan términos usados
- THEN todos usan "specs delta" para cambios activos
- AND usan "batching de tareas" consistentemente
- AND usan "inyección modular de contexto" sin variaciones

---

## Delta: sync-opencode-commands (2026-04-05)

### Requisito: Nuevos Comandos en OpenCode

El sistema DEBE incluir los comandos `sdd-checkpoint` y `sdd-rollback` en la integración de OpenCode.

#### Escenario: Comando checkpoint disponible

- GIVEN el usuario ejecuta `/sdd-checkpoint` en OpenCode
- WHEN el comando delega al skill `sdd-checkpoint`
- THEN el skill genera un checkpoint y lo guarda en el archivo de sesión
- AND retorna confirmación al usuario

#### Escenario: Comando rollback disponible

- GIVEN el usuario ejecuta `/sdd-rollback` en OpenCode
- WHEN el comando delega al skill `sdd-rollback`
- THEN el skill purga la carpeta del cambio y restaura archivos desde git
- AND retorna confirmación al usuario

### Requisito: Registro en opencode.json

El sistema DEBE registrar los nuevos comandos en el archivo de configuración de OpenCode.

#### Escenario: Comandos registrados correctamente

- GIVEN se crea un nuevo archivo de comando en `commands/`
- WHEN el archivo se agrega a `integrations/opencode/opencode.json`
- THEN el comando está disponible para ejecución via `/sdd-{nombre}`

### Requisito: Restricción de Contexto en OpenCode

El sistema DEBE indicar a los modelos de OpenCode leer solo Specs Delta.

#### Escenario: sdd-propose usa specs delta

- GIVEN `sdd-propose` se ejecuta en OpenCode
- WHEN el modelo recibe el prompt
- THEN solo lee el archivo `proposal.md` del cambio
- AND NO lee toda la carpeta `changes/`

#### Escenario: sdd-apply usa specs delta

- GIVEN `sdd-apply` se ejecuta en OpenCode
- WHEN el modelo recibe el prompt
- THEN solo lee los archivos en `openspec/changes/{nombre}/specs/`
- AND NO lee toda la carpeta `specs/` del proyecto

#### Escenario: sdd-verify usa specs delta

- GIVEN `sdd-verify` se ejecuta en OpenCode
- WHEN el modelo recibe el prompt
- THEN solo lee los archivos delta en `changes/{nombre}/specs/` y `design.md`
- AND NO lee toda la carpeta `specs/` del proyecto

### Requisito: Batching en sdd-apply

El sistema DEBE indicar al modelo esperar lote inline de tareas del orquestador.

#### Escenario: sdd-apply recibe lote inline

- GIVEN `sdd-apply` se ejecuta
- WHEN el orquestador pasa tareas inline en el prompt
- THEN el modelo procesa el lote sin leer `tasks.md` completo
- AND procesa cada tarea secuencialmente

#### Escenario: sdd-apply con batching optimiza contexto

- GIVEN múltiples tareas pending en el change
- WHEN `sdd-apply` recibe el lote
- THEN el contexto incluye solo las tareas del lote
- AND no requiere lectura adicional de archivos de tareas

## Archivos Afectados (sync-opencode-commands)

| Acción | Archivo |
|--------|---------|
| Crear | integrations/opencode/commands/sdd-checkpoint.md |
| Crear | integrations/opencode/commands/sdd-rollback.md |
| Modificar | integrations/opencode/opencode.json |
| Modificar | integrations/opencode/commands/sdd-apply.md |
| Modificar | integrations/opencode/commands/sdd-propose.md |
| Modificar | integrations/opencode/commands/sdd-verify.md |

## Criterios de Verificación (sync-opencode-commands)

1. `sdd-checkpoint.md` creado en `commands/`
2. `sdd-rollback.md` creado en `commands/`
3. `opencode.json` actualizado con nuevos comandos
4. `sdd-apply.md` tiene restricción de specs delta + batching
5. `sdd-propose.md` tiene restricción de specs delta
6. `sdd-verify.md` tiene restricción de specs delta

---

## Requisitos ELIMINADOS

### Requisito: (ninguno)

---

## Delta: refactor-dry-skills (2026-04-05)

### Requisito: Eliminación de Duplicación de Return Envelope

El orquestador DEBE inyectar dinámicamente la referencia al Return Envelope en lugar de tener texto estático en cada skill.

#### Escenario: Skill sin Return Envelope estático
- GIVEN una skill SDD sin la instrucción estática de Return Envelope
- WHEN el orquestador invoca la skill
- THEN la skill funciona correctamente sin la instrucción duplicada

#### Escenario: Verificación de todas las skills
- GIVEN los 14 archivos de skills SDD
- WHEN se verifica que ninguno contiene la línea de Return Envelope
- THEN todos los archivos pasan la verificación

### Requisito: Eliminación de Secciones Errores Comunes

El sistema DEBE eliminar las secciones "Errores Comunes" de sdd-propose y sdd-apply.

#### Escenario: Skills sin Errores Comunes
- GIVEN los archivos sdd-propose/SKILL.md y sdd-apply/SKILL.md
- WHEN se eliminan las secciones "Errores Comunes"
- THEN las skills funcionan correctamente sin esas secciones

### Requisito: Helper de Detección de Test Runner

El sistema DEBE crear un archivo helper compartido para la detección de test runner.

#### Escenario: Helper creado correctamente
- GIVEN el archivo skills/_shared/test-runner-detection.md no existe
- WHEN se crea el archivo con el pseudocódigo de detección
- THEN el archivo existe con el contenido correcto

#### Escenario: Skills referencian al helper
- GIVEN las skills sdd-apply y sdd-verify
- WHEN reemplazan el pseudocódigo duplicado con referencia al helper
- THEN las skills funcionan correctamente referenciando al helper

---

## Delta: refactor-core-modular (2026-04-05)

### Requisito: Core Modular

El sistema DEBE dividir orchestrator-core.md en módulos especializados para facilitar la carga selectiva de contexto.

#### Escenario: Módulos extraídos
- GIVEN el archivo `skills/_shared/orchestrator-core.md` existe
- WHEN se extraen las secciones no críticas a módulos separados
- THEN los módulos existen en `skills/_shared/` como archivos independientes
- AND `orchestrator-core.md` contiene referencias (links) a cada nuevo módulo

#### Escenario: Módulos creados
- GIVEN se ejecuta la refactorización
- THEN se crean los siguientes archivos en `skills/_shared/`:
  - `orchestrator-delegation.md`: Reglas de delegación
  - `orchestrator-state.md`: Gestión de state.yaml y recovery
  - `orchestrator-commands.md`: Meta-comandos y grafo de cambios
  - `orchestrator-context.md`: Protocolo de contexto

### Requisito: Restricción de Contexto en Apply

El sistema DEBE prohibir que sdd-apply cargue el directorio specs/ completo.

#### Escenario: Apply solo lee specs delta
- GIVEN sdd-apply se invoca con un cambio activo
- WHEN la skill ejecuta el paso de lectura de contexto
- THEN solo carga `openspec/changes/{nombre}/specs/` (no `openspec/specs/`)
- AND solo carga `design.md` del cambio actual
- AND el sub-agente NO recibe specs históricos

### Requisito: Restricción de Contexto en Verify

El sistema DEBE prohibir que sdd-verify cargue el directorio specs/ completo.

#### Escenario: Verify solo lee specs delta
- GIVEN sdd-verify se invoca con un cambio activo
- WHEN la skill ejecuta el paso de lectura de contexto
- THEN solo carga `openspec/changes/{nombre}/specs/` (no `openspec/specs/`)
- AND no carga specs históricos del proyecto

### Requisito: Batching de Tareas en Apply

El sistema DEBE pasar solo un bloque de tareas al sub-agente para evitar saturar la ventana de contexto.

#### Escenario: Apply recibe bloque de 3 tareas
- GIVEN el orquestador tiene `tasks.md` con múltiples tareas pendientes
- WHEN se invoca sdd-apply
- THEN el orquestador lee `tasks.md` y extrae solo las primeras 3 tareas pendientes
- AND pasa dichas tareas como texto inline al sub-agente
- AND el sub-agente NO carga `tasks.md` completo

#### Escenario: Orquestador actualiza tasks.md
- GIVEN el sub-agente completa un lote de tareas
- WHEN retorna el resultado al orquestador
- THEN el orquestador actualiza las marcas `[x]` en `tasks.md`
- AND el sub-agente NO modifica `tasks.md` directamente

## Archivos Afectados (refactor-core-modular)

| Acción | Archivo |
|--------|---------|
| Crear | skills/_shared/orchestrator-delegation.md |
| Crear | skills/_shared/orchestrator-state.md |
| Crear | skills/_shared/orchestrator-commands.md |
| Crear | skills/_shared/orchestrator-context.md |
| Modificar | skills/_shared/orchestrator-core.md |
| Modificar | skills/sdd-apply/SKILL.md |
| Modificar | skills/sdd-verify/SKILL.md

## Criterios de Verificación (refactor-core-modular)

1. orchestrator-core.md reducido y contiene referencias a módulos.
2. 4 módulos creados en `skills/_shared/`.
3. sdd-apply tiene prohibido cargar `specs/` completo.
4. sdd-verify tiene prohibido cargar `specs/` completo.
5. sdd-apply recibe solo bloque de 3 tareas.
6. El orquestador actualiza `[x]` en tasks.md.

## Archivos Afectados (refactor-dry-skills)

| Acción | Archivo |
|--------|---------|
| Actualizar | skills/sdd-explore/SKILL.md |
| Actualizar | skills/sdd-propose/SKILL.md |
| Actualizar | skills/sdd-spec/SKILL.md |
| Actualizar | skills/sdd-design/SKILL.md |
| Actualizar | skills/sdd-tasks/SKILL.md |
| Actualizar | skills/sdd-apply/SKILL.md |
| Actualizar | skills/sdd-verify/SKILL.md |
| Actualizar | skills/sdd-archive/SKILL.md |
| Actualizar | skills/sdd-review/SKILL.md |
| Actualizar | skills/sdd-status/SKILL.md |
| Actualizar | skills/sdd-changelog/SKILL.md |
| Actualizar | skills/sdd-split/SKILL.md |
| Actualizar | skills/sdd-fix/SKILL.md |
| Actualizar | skills/sdd-init/SKILL.md |
| Crear | skills/_shared/test-runner-detection.md |

## Criterios de Verificación (refactor-dry-skills)

1. Los 14 archivos SKILL.md no contienen la línea estática de Return Envelope.
2. sdd-propose/SKILL.md y sdd-apply/SKILL.md no contienen sección "Errores Comunes".
3. skills/_shared/test-runner-detection.md existe con contenido de pseudocódigo.
4. sdd-apply/SKILL.md y sdd-verify/SKILL.md referencian al helper.
5. Las skills siguen siendo invocables por el orquestador.

---

## Delta: feat-estado-y-seguridad (2026-04-05)

### Requisito: Campo session_summary en state.yaml

El sistema DEBE incluir un nuevo campo `session_summary` en el schema de state.yaml.

- **Tipo de Campo**: string
- **Máximo**: 5 líneas de texto
- **Propósito**: Almacenar resumen del estado actual del cambio para recuperación rápida de sesión

#### Escenario: Estado con session_summary

- GIVEN un change activo en cualquier fase
- WHEN se ejecuta sdd-checkpoint
- THEN el campo session_summary contiene hasta 5 líneas de resumen
- AND last_updated se actualiza automáticamente

#### Escenario: Campo session_summary ausente

- GIVEN un state.yaml existente sin campo session_summary
- WHEN se requiere leer el estado del cambio
- THEN el campo session_summary puede estar vacío o ausente
- AND el sistema lo trata como null

### Requisito: Skill sdd-checkpoint

El sistema DEBE tener una skill que resuma el estado del cambio activo.

- **Trigger**: `/sdd-checkpoint`
- **Ubicación**: `skills/sdd-checkpoint/SKILL.md`
- **Fase**: checkpoint (skill directa)

#### Escenario: Checkpoint genera resumen

- GIVEN un cambio activo con state.yaml
- WHEN el usuario ejecuta /sdd-checkpoint
- THEN la skill genera un resumen de hasta 5 líneas
- AND guarda el resumen en el campo session_summary del state.yaml
- AND actualiza el campo last_updated

#### Escenario: Checkpoint sin cambio activo

- GIVEN ningún cambio activo en el workspace
- WHEN el usuario ejecuta /sdd-checkpoint
- THEN la skill muestra error indicando que no hay cambio activo
- AND no modifica ningún archivo

### Requisito: Skill sdd-rollback

El sistema DEBE tener una skill de emergencia para revertir el entorno.

- **Trigger**: `/sdd-rollback`
- **Ubicación**: `skills/sdd-rollback/SKILL.md`
- **Fase**: rollback (skill directa)

#### Escenario: Rollback purga cambios

- GIVEN un cambio activo con problemas
- WHEN el usuario ejecuta /sdd-rollback
- THEN la carpeta del cambio en openspec/changes/{nombre}/ se purga
- AND git checkout -- . restaura archivos modificados
- AND git clean -fd elimina archivos no rastreados

#### Escenario: Rollback confirma antes de ejecutar

- GIVEN un cambio activo
- WHEN el usuario ejecuta /sdd-rollback
- THEN la skill solicita confirmación antes de proceder
- AND si el usuario confirma, ejecuta las operaciones de purge
- AND si el usuario cancela, no ejecuta ninguna acción destructiva

#### Escenario: Rollback sin cambio activo

- GIVEN ningún cambio activo
- WHEN el usuario ejecuta /sdd-rollback
- THEN la skill muestra error indicando que no hay cambio para revertir
- AND no ejecuta ninguna operación de git

### Requisito: Registro en orquestador

El sistema DEBE registrar los nuevos comandos en la documentación del orquestador.

- **Archivo**: `skills/_shared/orchestrator-commands.md`
- **Acción**: Agregar entradas para /sdd-checkpoint y /sdd-rollback

#### Escenario: Comandos registrados

- GIVEN el archivo orchestrator-commands.md existe
- WHEN se crean las skills checkpoint y rollback
- THEN se agregan entradas con trigger, descripción y ubicación
- AND el índice de skills se actualiza correctamente

## Validaciones

1. El campo session_summary NO DEBE exceder 5 líneas de texto
2. La skill sdd-checkpoint DEBE actualizar last_updated al guardar el resumen
3. La skill sdd-rollback DEBE confirmar antes de ejecutar operaciones destructivas
4. Ambos comandos DEBEN estar documentados en orchestrator-commands.md

## Notas de Implementación

- El resumen en session_summary DEBE incluir: fase actual, estado, y progreso de tareas
- El rollback DEBE ejecutar git checkout -- . desde la raíz del proyecto
- El rollback DEBE ejecutar git clean -fd desde la raíz del proyecto
