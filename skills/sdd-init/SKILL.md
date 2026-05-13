---
name: sdd-init
description: >
  Inicializa el contexto de Desarrollo Guiado por Especificaciones (SDD) en cualquier proyecto. Detecta el stack, las convenciones e inicializa el backend de persistencia activo.
  Disparador: Cuando el usuario quiere inicializar SDD en un proyecto, o dice "sdd init", "iniciar sdd", "openspec init".
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

## Propósito

Eres un sub-agente responsable de **inicializar el contexto de Desarrollo Guiado por Especificaciones (SDD)** en un proyecto. Detectas el stack tecnológico y las convenciones del proyecto, y luego inicializas el backend de persistencia activo.

## Execution and Persistence Contract


- Lee las convenciones base referenciadas en `skills/_shared/execution-contract.md` antes de proceder.


## Qué Hacer

### Paso 1: Detectar el Contexto del Proyecto

Lee el proyecto para entender:

- Stack tecnológico (revisa `package.json`, `go.mod`, `pyproject.toml`, etc.)
- Convenciones existentes (linters, frameworks de testing, CI)
- Patrones de arquitectura en uso

### Paso 2: Inicializar la Estructura OpenSpec

Crea esta estructura de directorios en la raíz del proyecto:

```text
openspec/
├── config.yaml              ← Configuración SDD específica del proyecto
├── specs/                   ← Fuente de verdad (vacía inicialmente)
└── changes/                 ← Cambios activos
    └── archive/             ← Cambios completados
```

### Paso 3: Generar la Configuración

Basándote en lo detectado, crea el archivo `openspec/config.yaml`:

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
  apply:
    - Seguir los patrones y convenciones de código existentes
    - "Código Defensivo y Pragmatismo: Aplica principios SOLID, DRY y Clean Code. Prefiere Early Returns (Guard Clauses). NUNCA sobre-ingeniar."
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
```

### Paso 4: Inicializar Registry de Skills

Como paso final, ejecuta `skills/sdd-skill-registry/scan.sh` (o inicializa el archivo `.agentify/skill-registry.md` vacío) para habilitar el descubrimiento de skills.

### Paso 5: Devolver Resumen

Devuelve un resumen estructurado del estado resultante:

```
## SDD Inicializado

**Proyecto**: {nombre del proyecto}
**Stack**: {stack detectado}
**Persistencia**: File System (OpenSpec)

### Estructura Creada
- openspec/config.yaml ← Configuración del proyecto con contexto detectado
- openspec/specs/      ← Listo para especificaciones
- openspec/changes/    ← Listo para propuestas de cambio

### Próximos Pasos
Listo para /sdd-explore {tema} o /sdd-new {nombre-del-cambio}.
```

 Próximos Pasos
Listo para /sdd-explore {tema} o /sdd-new {nombre-del-cambio}.

```

## Reglas

- NUNCA crear archivos de spec de relleno — las specs se crean mediante sdd-spec durante un cambio
- SIEMPRE detectar el stack tecnológico real, nunca asumir
- Si el proyecto ya tiene un directorio `openspec/`, reportar qué existe y preguntar al orquestador si debe actualizarse
- Mantener el contexto en `config.yaml` CONCISO — no más de 10 líneas
