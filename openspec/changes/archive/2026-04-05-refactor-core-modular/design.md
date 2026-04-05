# Diseño: refactor-core-modular

## Enfoque Técnico

Dividir `orchestrator-core.md` (~157 líneas) en 4 módulos especializados que el orquestador puede referenciar selectivamente. Modificar `sdd-apply` y `sdd-verify` para restringir su contexto a specs delta únicamente, e implementar batching de tareas (3 por lote) para mantener el consumo de tokens dentro de la ventana de contexto disponible.

## Decisiones de Arquitectura

| Decisión | Alternativas | Justificación |
|----------|--------------|---------------|
| Módulos de 40-50 líneas c/u | Módulos más pequeños o un solo archivo | Equilibrio entre granularidad y cohesion; cada módulo representa un dominio logical |
| Batching de 3 tareas | 1 tarea o 5+ tareas | 3 es el punto óptimo: suficiente para progreso, suficiente contexto para el sub-agente sin saturar |
| Orquestador actualiza tasks.md | Sub-agente actualiza | Evita que el sub-agente rereescriba el archivo completo; el orquestador mantiene el estado global |
| Specs delta solo | Specs completos + delta | La propuesta original especifica solo specs delta; specs históricos no son necesarios para implementación actual |

## Extracción de Módulos de orchestrator-core.md

| Sección Original | Módulo Destino | Líneas Aproximadas |
|------------------|----------------|---------------------|
| Reglas de Delegación | orchestrator-delegation.md | 11-33 |
| Gestión de Estado + Recovery | orchestrator-state.md | 78-112, 150-157 |
| Comandos de Orquestación | orchestrator-commands.md | 43-77 |
| Protocolo de Contexto | orchestrator-context.md | 119-139 |

## Restricción de Contexto

### sdd-apply (SKILL.md, Paso 1)

**Cambio**: Modificar "Paso 1: Leer el Contexto" para restricción:

```
1. Leer las specs — SOLO openspec/changes/{nombre}/specs/ (NO openspec/specs/)
2. Leer el diseño — SOLO openspec/changes/{nombre}/design.md
3. Leer las tareas — SOLO el bloque de 3 tareas proporcionado por el orquestador (NO tasks.md completo)
4. Leer convenciones — solo config.yaml del proyecto
```

**Eliminar** la referencia a "leer el código existente en los archivos afectados" como paso obligatorio — el sub-agente decide qué leer según las tareas asignadas.

### sdd-verify (SKILL.md, Paso 1)

**Cambio**: Modificar flujo para restricción:

```
1. Leer tasks.md — SOLO del cambio actual
2. Leer specs — SOLO openspec/changes/{nombre}/specs/ (NO specs históricos)
3. Leer diseño — SOLO design.md del cambio actual
```

**Eliminar** la búsqueda general de "código existente" — el sub-agente ya sabe qué archivos fueron modificados por las tareas completadas.

## Batching de Tareas

### Flujo del Orquestador

```
1. Leer tasks.md completo
2. Extraer las primeras 3 tareas pendientes ([ ])
3. Construir mensaje para sdd-apply:
   - "Implementar las siguientes tareas:"
   - Lista inline de las 3 tareas (descripción completa)
   - Rutas: specs/, design.md del cambio
4. Invocar sdd-apply
5. Al retornar el sub-agente:
   - Parsear las tareas completadas del resumen
   - Actualizar tasks.md marcando [x] las completadas
   - Si quedan tareas → repetir batch siguiente
```

### Formato del Bloque de Tareas

El orquestador pasa tareas como texto inline:

```
## Tareas a Implementar (Lote 1/3)

- [ ] 1.1 Crear archivo X con funcionalidad Y
- [ ] 1.2 Modificar archivo Z para agregar W
- [ ] 1.3 Crear test para funcionalidad Y
```

El sub-agente NO carga tasks.md — recibe las tareas directamente.

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| skills/_shared/orchestrator-delegation.md | Crear | Reglas de delegación (líneas 11-33) |
| skills/_shared/orchestrator-state.md | Crear | Gestión de state.yaml + recovery (líneas 78-112, 150-157) |
| skills/_shared/orchestrator-commands.md | Crear | Meta-comandos + grafo (líneas 43-77) |
| skills/_shared/orchestrator-context.md | Crear | Protocolo de contexto (líneas 119-139) |
| skills/_shared/orchestrator-core.md | Modificar | Reducir a ~50 líneas + referencias a módulos |
| skills/sdd-apply/SKILL.md | Modificar | Restricción contexto + batching |
| skills/sdd-verify/SKILL.md | Modificar | Restricción contexto |

## Preguntas Abiertas

- [ ] ¿Hay alguna sección crítica que no debe modularizarse? (Regla de idioma debe stay in core)
- [ ] ¿El batch de 3 tareas es suficiente para cambios grandes? (considerar parámetro configurable)
- [ ] ¿Debe el sub-agente poder solicitar más contexto si lo necesita?
