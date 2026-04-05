# Especificación de Calidad - Refactorización Core Modular

## Propósito

Esta especificación define los requisitos para reducir el consumo de tokens en fases avanzadas del orquestador SDD mediante la modularización del archivo orchestrator-core.md y la restricción de contexto en las skills sdd-apply y sdd-verify.

## Requisitos

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

## Criterios de Verificación

- [ ] orchestrator-core.md reducido y contiene referencias a módulos
- [ ] 4 módulos creados en `skills/_shared/`
- [ ] sdd-apply tiene prohibido cargar `specs/` completo
- [ ] sdd-verify tiene prohibido cargar `specs/` completo
- [ ] sdd-apply recibe solo bloque de 3 tareas
- [ ] El orquestador actualiza `[x]` en tasks.md
