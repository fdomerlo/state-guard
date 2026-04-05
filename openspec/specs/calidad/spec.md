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
