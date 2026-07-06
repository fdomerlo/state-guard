---
name: agentify-init
description: >
  Inicializa el entorno de ejecución con memoria transaccional en cualquier proyecto. Detecta el stack, las convenciones e inicializa el backend de persistencia activo.
  Disparador: Cuando el usuario quiere inicializar Agentify en un proyecto, o dice "iniciar agentify", "agentify init".
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "2.0"
---

# Agentify-Init Skill

## Propósito

Eres un sub-agente responsable de **inicializar el entorno con memoria transaccional** en un proyecto. Detectas el stack tecnológico y las convenciones del proyecto, y luego inicializas el backend de persistencia activo.

## Referencia

Consultar `skills/_shared/agentify-convention.md` para el schema de `state.ini`.

## Qué Hacer

### Paso 1: Detectar el Contexto del Proyecto

Lee el proyecto para entender:

- Stack tecnológico (revisa `package.json`, `go.mod`, `pyproject.toml`, etc.)
- Convenciones existentes (linters, frameworks de testing, CI)
- Patrones de arquitectura en uso

### Paso 2: Inicializar la Estructura OpenSpec

Crea esta estructura de directorios en la raíz del proyecto:

```text
.agentify/
├── config.yaml              ← Configuración del agente específica del proyecto
├── specs/                   ← Fuente de verdad (vacía inicialmente)
└── changes/                 ← Cambios activos
    └── archive/             ← Cambios completados
```

### Paso 3: Generar la Configuración

Basándote en lo detectado, crea el archivo `.agentify/config.yaml`:

```yaml
# .agentify/config.yaml
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
#       definition: "Archivo generado por una fase del agente (proposal, spec, design, tasks)"
```

### Paso 4: Inicializar Registry de Skills

Como paso final, ejecuta `skills/agentify-skill-registry/scan.sh` (o inicializa el archivo `.agentify/skill-registry.md` vacío) para habilitar el descubrimiento de skills.

### Paso 5: Devolver Resumen

Devuelve un resumen estructurado del estado resultante:

```text
## Agentify Inicializado

**Proyecto**: {nombre del proyecto}
**Stack**: {stack detectado}
**Persistencia**: File System (OpenSpec)

### Estructura Creada
- .agentify/config.yaml ← Configuración del proyecto con contexto detectado
- .agentify/specs/      ← Listo para especificaciones
- .agentify/changes/    ← Listo para propuestas de cambio

### Próximos Pasos
Listo para /agentify-explore {tema} o /agentify-new {nombre-del-cambio}.
```

## Reglas

- NUNCA crear archivos de spec de relleno — las specs se crean mediante agentify-spec durante un cambio
- SIEMPRE detectar el stack tecnológico real, nunca asumir
- Si el proyecto ya tiene un directorio `.agentify/`, reportar qué existe y preguntar al orquestador si debe actualizarse
- Mantener el contexto en `config.yaml` CONCISO — no más de 10 líneas
