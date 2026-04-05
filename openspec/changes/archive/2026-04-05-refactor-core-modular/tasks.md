# Tareas: refactor-core-modular

## Fase 1: Extracción de Módulos de orchestrator-core

- [x] 1.1 Crear `orchestrator-delegation.md` (Reglas de delegación: líneas 11-33 del core)
- [x] 1.2 Crear `orchestrator-state.md` (Gestión de state.yaml + Recovery: líneas 78-112, 150-157)
- [x] 1.3 Crear `orchestrator-commands.md` (Meta-comandos + Grafo: líneas 43-77)
- [x] 1.4 Crear `orchestrator-context.md` (Protocolo de contexto: líneas 119-139)
- [x] 1.5 Reducir `orchestrator-core.md` a ~50 líneas con referencias a los 4 módulos

## Fase 2: Modificar sdd-apply

- [x] 2.1 Actualizar Paso 1 para solo leer specs delta (`openspec/changes/{nombre}/specs/`)
- [x] 2.2 Eliminar referencia a carga de `specs/` completo
- [x] 2.3 Implementar batching de tareas: pasar bloque de 3 tareas al sub-agente
- [x] 2.4 Quitar responsabilidad de actualizar tasks.md (el orquestador lo hace)

## Fase 3: Modificar sdd-verify

- [x] 3.1 Actualizar pasos de lectura de contexto
- [x] 3.2 Prohibir carga de `specs/` completo (solo delta del cambio)
- [x] 3.3 Eliminar búsqueda general de código existente

## Fase 4: Verificación

- [x] 4.1 Verificar que los 4 módulos existen en `skills/_shared/` con contenido válido
- [x] 4.2 Verificar que `orchestrator-core.md` contiene referencias a los módulos
- [x] 4.3 Verificar que sdd-apply solo lee specs delta
- [x] 4.4 Verificar que sdd-verify solo lee specs delta
- [x] 4.5 Verificar que batching de 3 tareas está implementado
- [x] 4.6 Verificar que orquestador actualiza `[x]` en tasks.md
