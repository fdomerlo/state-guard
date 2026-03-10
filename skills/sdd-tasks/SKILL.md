---
name: sdd-tasks
description: >
  Desglosa un cambio en una lista de tareas de implementación.
  Disparador: Cuando el orquestador te lanza para crear o actualizar el desglose de tareas de un cambio.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
---

## Propósito

Eres un sub-agente responsable de crear el **DESGLOSE DE TAREAS**. Tomás la propuesta, las specs y el diseño, y producís un `tasks.md` con pasos de implementación concretos y accionables, organizados por fases.

## Qué Recibís

Del orquestador:
- Nombre del cambio
- Modo de almacenamiento de artefactos (`openspec | none`)

## Execution and Persistence Contract

Lee y sigue `skills/_shared/persistence-contract.md` para las reglas de resolución de modo.

- Si el modo es `openspec`: Lee y sigue `skills/_shared/openspec-convention.md`. Recupera `proposal`, `spec` y `design` como dependencias.
- Si el modo es `none`: Devuelve solo el resultado. Nunca crear ni modificar archivos del proyecto.

## Qué Hacer

### Paso 1: Analizar el Diseño

Del documento de diseño, identificar:
- Todos los archivos que necesitan crearse/modificarse/eliminarse
- El orden de dependencias (qué debe ir primero)
- Requisitos de testing por componente

### Paso 2: Escribir tasks.md

Crea el archivo de tareas:

```
openspec/changes/{nombre-del-cambio}/
├── proposal.md
├── specs/
├── design.md
└── tasks.md               ← Lo creas tú
```

#### Formato del Archivo de Tareas

```markdown
# Tareas: {Título del Cambio}

## Fase 1: {Nombre de Fase} (ej: Infraestructura / Fundación)

- [ ] 1.1 {Acción concreta — qué archivo, qué cambio}
- [ ] 1.2 {Acción concreta}
- [ ] 1.3 {Acción concreta}

## Fase 2: {Nombre de Fase} (ej: Implementación Central)

- [ ] 2.1 {Acción concreta}
- [ ] 2.2 {Acción concreta}
- [ ] 2.3 {Acción concreta}
- [ ] 2.4 {Acción concreta}

## Fase 3: {Nombre de Fase} (ej: Testing / Verificación)

- [ ] 3.1 {Escribir tests para ...}
- [ ] 3.2 {Escribir tests para ...}
- [ ] 3.3 {Verificar integración entre ...}

## Fase 4: {Nombre de Fase} (ej: Limpieza / Documentación)

- [ ] 4.1 {Actualizar docs/comentarios}
- [ ] 4.2 {Eliminar código temporal}
```

### Reglas de Redacción de Tareas

Cada tarea DEBE ser:

| Criterio        | Ejemplo ✅                                                    | Contra-ejemplo ❌          |
|-----------------|---------------------------------------------------------------|----------------------------|
| **Específica**  | "Crear `internal/auth/middleware.go` con validación JWT"      | "Agregar auth"             |
| **Accionable**  | "Agregar método `ValidateToken()` a `AuthService`"            | "Manejar tokens"           |
| **Verificable** | "Test: `POST /login` devuelve 401 sin token"                  | "Asegurarse de que funcione" |
| **Pequeña**     | Un archivo o una unidad lógica de trabajo                     | "Implementar la funcionalidad" |

### Lineamientos de Organización por Fases

```
Fase 1: Fundación / Infraestructura
  └─ Nuevos tipos, interfaces, cambios de base de datos, configuración
  └─ Cosas de las que dependen otras tareas

Fase 2: Implementación Central
  └─ Lógica principal, reglas de negocio, comportamiento core
  └─ El núcleo del cambio

Fase 3: Integración / Conexión
  └─ Conectar componentes, rutas, wiring de UI
  └─ Hacer que todo funcione junto

Fase 4: Testing
  └─ Tests unitarios, de integración, e2e
  └─ Verificar contra los escenarios de spec

Fase 5: Limpieza (si es necesario)
  └─ Documentación, eliminar código muerto, pulido
```

### Paso 3: Devolver Resumen

Devuelve al orquestador:

```markdown
## Tareas Creadas

**Cambio**: {nombre-del-cambio}
**Ubicación**: openspec/changes/{nombre-del-cambio}/tasks.md

### Desglose
| Fase    | Tareas | Enfoque          |
|---------|--------|------------------|
| Fase 1  | {N}    | {Nombre de fase} |
| Fase 2  | {N}    | {Nombre de fase} |
| Fase 3  | {N}    | {Nombre de fase} |
| Total   | {N}    |                  |

### Orden de Implementación
{Descripción breve del orden recomendado y por qué}

### Próximo Paso
Listo para implementación (sdd-apply).
```

## Reglas

- SIEMPRE referenciar rutas de archivos concretas en las tareas
- Las tareas DEBEN estar ordenadas por dependencia — las tareas de Fase 1 no deben depender de las de Fase 2
- Las tareas de testing deben referenciar escenarios específicos de las specs
- Cada tarea debe ser completable en UNA sesión (si una tarea parece muy grande, dividirla)
- Usar numeración jerárquica: 1.1, 1.2, 2.1, 2.2, etc.
- NUNCA incluir tareas vagas como "implementar la funcionalidad" o "agregar tests"
- Aplicar cualquier `rules.tasks` de `openspec/config.yaml`
- Si el proyecto usa TDD, integrar tareas test-first: tarea RED (escribir test fallido) → tarea GREEN (hacerlo pasar) → tarea REFACTOR (limpiar)
- Devolver un envelope estructurado con: `status`, `executive_summary`, `detailed_report` (opcional), `artifacts`, `next_recommended` y `risks`
