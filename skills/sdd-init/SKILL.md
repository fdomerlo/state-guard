---
name: sdd-init
description: >
  Inicializa el contexto de Desarrollo Guiado por Especificaciones (SDD) en cualquier proyecto. Detecta el stack, las convenciones e inicializa el backend de persistencia activo.
  Disparador: Cuando el usuario quiere inicializar SDD en un proyecto, o dice "sdd init", "iniciar sdd", "openspec init".
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
---

## Propósito

Eres un sub-agente responsable de **inicializar el contexto de Desarrollo Guiado por Especificaciones (SDD)** en un proyecto. Detectas el stack tecnológico y las convenciones del proyecto, y luego inicializas el backend de persistencia activo.

## Execution and Persistence Contract

Lee y sigue `skills/_shared/persistence-contract.md` para las reglas de resolución de modo.

- Si el modo es `openspec`: Lee y sigue `skills/_shared/openspec-convention.md`. Ejecuta el bootstrap completo.
- Si el modo es `none`: Devuelve el contexto detectado sin escribir archivos del proyecto.

## Qué Hacer

### Paso 1: Detectar el Contexto del Proyecto

Lee el proyecto para entender:

- Stack tecnológico (revisa `package.json`, `go.mod`, `pyproject.toml`, etc.)
- Convenciones existentes (linters, frameworks de testing, CI)
- Patrones de arquitectura en uso

### Paso 2: Inicializar el Backend de Persistencia

Si el modo se resuelve a `openspec`, crea esta estructura de directorios:

```
openspec/
├── config.yaml              ← Configuración SDD específica del proyecto
├── specs/                   ← Fuente de verdad (vacía inicialmente)
└── changes/                 ← Cambios activos
    └── archive/             ← Cambios completados
```

### Paso 3: Generar la Configuración (modo openspec)

Basándote en lo detectado, crea la configuración en modo `openspec`:

```yaml
# openspec/config.yaml
schema: spec-driven

context: |
  Stack tecnológico: {stack detectado}
  Arquitectura: {patrones detectados}
  Testing: {framework de testing detectado}
  Estilo: {linting/formateo detectado}

rules:
  change_naming: kebab-case
  proposal:
    - Incluir plan de rollback para cambios riesgosos
    - Identificar módulos/paquetes afectados
  specs:
    - Usar formato Given/When/Then para escenarios
    - Usar palabras clave RFC 2119 (MUST, SHALL, SHOULD, MAY)
  design:
    - Incluir diagramas de secuencia para flujos complejos
    - Documentar decisiones de arquitectura con justificación
    - "[!] Si proposal.md marca el riesgo como Medio/Alto, DEBES incluir una Estrategia de Testing rigurosa."
  tasks:
    - Agrupar tareas por fase (infraestructura, implementación, testing)
    - Usar numeración jerárquica (1.1, 1.2, etc.)
    - Mantener tareas pequeñas, completables en una sesión
    - "[!] Si design.md incluye una Estrategia de Testing, DEBES generar tareas explícitas para escribir esos tests."
  apply:
    - Seguir los patrones y convenciones de código existentes
    - Cargar skills de codificación relevantes para el stack del proyecto
  verify:
    - Ejecutar tests si existe infraestructura de testing
    - Comparar la implementación contra cada escenario de spec
  archive:
    - Advertir antes de fusionar deltas destructivos (eliminaciones grandes)

# Glosario de términos del dominio (opcional)
# glossary:
#   terms:
#     - term: "Artefacto"
#       definition: "Archivo generado por una fase SDD (proposal, spec, design, tasks)"
#     - term: "Cambio"
#       definition: "Una unidad de trabajo en el DAG de SDD"
#     - term: "Estado"
#       definition: "Condición actual de un cambio en el DAG de SDD"
#       aliases: ["phase"]
#     - term: "Fase"
#       definition: "Etapa del flujo SDD (explore, propose, spec, design, tasks, apply, verify, archive)"
```

### Paso 4: Devolver Resumen

Devuelve un resumen estructurado adaptado al modo resuelto:

#### Si el modo es `openspec`

```
## SDD Inicializado

**Proyecto**: {nombre del proyecto}
**Stack**: {stack detectado}
**Persistencia**: openspec

### Estructura Creada
- openspec/config.yaml ← Configuración del proyecto con contexto detectado
- openspec/specs/      ← Listo para especificaciones
- openspec/changes/    ← Listo para propuestas de cambio

### Próximos Pasos
Listo para /sdd-explore {tema} o /sdd-new {nombre-del-cambio}.
```

#### Si el modo es `none`

```
## SDD Inicializado

**Proyecto**: {nombre del proyecto}
**Stack**: {stack detectado}
**Persistencia**: none (efímero)

### Contexto Detectado
{resumen del stack y convenciones detectados}

### Recomendación
Ejecuta `sdd init` para habilitar `openspec` y persistir artefactos entre sesiones.
Sin persistencia, todos los artefactos SDD se perderán al terminar la conversación.

### Próximos Pasos
Listo para /sdd-explore {tema} o /sdd-new {nombre-del-cambio}.
```

## Reglas

- NUNCA crear archivos de spec de relleno — las specs se crean mediante sdd-spec durante un cambio
- SIEMPRE detectar el stack tecnológico real, nunca asumir
- Si el proyecto ya tiene un directorio `openspec/`, reportar qué existe y preguntar al orquestador si debe actualizarse
- Mantener el contexto en `config.yaml` CONCISO — no más de 10 líneas
- Devolver un envelope estructurado con: `status`, `executive_summary`, `detailed_report` (opcional), `artifacts`, `next_recommended` y `risks`
