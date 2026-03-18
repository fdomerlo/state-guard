# Exploración: optimize-minimax-config

## Tema

Actualizar el archivo `openspec/config.yaml` del proyecto para inyectar directivas estrictas de diseño de sistemas y codificación defensiva, optimizadas para el motor de razonamiento MiniMax M2.5.

---

## Estado Actual

### Estructura del Archivo `openspec/config.yaml`

El archivo de configuración actual tiene la siguiente organización:

| Sección | Descripción |
|---------|-------------|
| `schema` | Define el esquema del proyecto (spec-driven) |
| `context` | Información contextual sobre el stack tecnológico, arquitectura y estilo |
| `rules` | Reglas organizadas por fase del flujo SDD |
| `glossary` | Glosario de términos del dominio (actualmente comentado) |

### Fases Actuales y Reglas Existentes

**Fase: `proposal`** (2 reglas)
- Incluir plan de rollback para cambios riesgosos
- Identificar módulos/paquetes afectados

**Fase: `specs`** (2 reglas)
- Usar formato Given/When/Then para escenarios
- Usar palabras clave RFC 2119 (MUST, SHALL, SHOULD, MAY)

**Fase: `design`** (3 reglas)
- Incluir diagramas de secuencia para flujos complejos
- Documentar decisiones de arquitectura con justificación
- "[!] Si proposal.md marca el riesgo como Medio/Alto, DEBES incluir una Estrategia de Testing rigurosa."

**Fase: `tasks`** (4 reglas)
- Agrupar tareas por fase (infraestructura, implementación, testing)
- Usar numeración jerárquica (1.1, 1.2, etc.)
- Mantener tareas pequeñas, completables en una sesión
- "[!] Si design.md incluye una Estrategia de Testing, DEBES generar tareas explícitas para escribir esos tests."

**Fase: `apply`** (2 reglas)
- Seguir los patrones y convenciones de código existentes
- Cargar skills de codificación relevantes para el stack del proyecto

**Fase: `verify`** (2 reglas)
- Ejecutar tests si existe infraestructura de testing
- Comparar la implementación contra cada escenario de spec

**Fase: `archive`** (1 regla)
- Advertir antes de fusionar deltas destructivos (eliminaciones grandes)

---

## Áreas Afectadas

### Objetivo: Expandir la sección `rules` en `openspec/config.yaml`

Se modificará exclusivamente el archivo `openspec/config.yaml` agregando nuevas reglas a las fases `design`, `tasks` y `apply`.

### Nuevas Reglas a Inyectar

**Fase: `design`** (se agregarán 2 reglas)

1. "Explotar razonamiento arquitectónico: DEBES incluir diagramas Mermaid exhaustivos (State, Sequence o Class) para cualquier flujo no trivial."
2. "Priorizar modularidad extrema: Diseña el sistema asumiendo que el código será escrito por un modelo de IA con ventana de contexto limitada. Interfaces claras y acoplamiento nulo."

**Fase: `tasks`** (se agregará 1 regla)

1. "Granularidad Atómica: Cada tarea debe ser lo suficientemente pequeña para implementarse en un solo archivo o módulo lógico. Evitar 'tareas monstruo'."

**Fase: `apply`** (se agregarán 2 reglas)

1. "Código Defensivo y Pragmatismo: Aplica principios SOLID, DRY y Clean Code. Prefiere Early Returns (Guard Clauses). NUNCA sobre-ingeniar."
2. "Completitud: No uses placeholders como '...código restante aquí...'. Si escribes un archivo, escríbelo completo y listo para producción."

---

## Enfoques

### Enfoque 1: Inyección Directa de Reglas

Agregar las nuevas reglas como elementos de lista bajo cada fase correspondiente, manteniendo el formato YAML existente.

- **Ventajas:** Simple, mantiene consistencia con el formato actual, no altera la estructura general.
- **Desventajas:** Ninguna identificada.
- **Esfuerzo:** Bajo.

### Enfoque 2: Crear Nueva Sección Separada

Crear una nueva sección `rules:minimax` paralela a `rules` con las directivas específicas de MiniMax.

- **Ventajas:** Separación clara de responsabilidades.
- **Desventajas:** Rompe con la convención actual donde todas las reglas están bajo una sola clave `rules`, dificulta la lectura secuencial por fase.
- **Esfuerzo:** Medio.

---

## Recomendación

Se recomienda utilizar el **Enfoque 1: Inyección Directa de Reglas**. Esta aproximación mantiene la consistencia con el formato existente del archivo, donde las reglas están organizadas por fase bajo una única clave `rules`. Las nuevas directivas se insertarán como elementos de lista dentro de las fases existentes (`design`, `tasks`, `apply`).

### Formato de Implementación

Las nuevas reglas se agregarán siguiendo la convención actual:
- Usar viñetas con guiones (-)
- Mantener texto en español
- Preservar el `context` existente sin modificaciones
- Preservar el `glossary` comentado sin modificaciones

### Resultado Esperado

Después de la modificación, el archivo `config.yaml` tendrá las siguientes adiciones:

- **Fase `design`:** Pasa de 3 a 5 reglas
- **Fase `tasks`:** Pasa de 4 a 5 reglas
- **Fase `apply`:** Pasa de 2 a 4 reglas

---

## Restricciones Técnicas

1. **Validez YAML:** El archivo debe continuar siendo un YAML válido después de la modificación.
2. **Idioma:** Todo el texto de las nuevas reglas debe estar en español.
3. **Preservación:** Se debe mantener intacto el `context` existente y el `glossary` comentado.
4. **Formato:** Las reglas deben seguir el formato de lista con guiones (-).

---

## Riesgos

1. **Riesgo de validación:** Un error de sangría podría invalidar el YAML. Se debe verificar la estructura después de la modificación.
2. **Riesgo de redundancia:** Algunas reglas nuevas podrían duplicar conceptos con reglas existentes. Se debe revisar que no haya redundancia semántica.

---

## Listo para Propuesta

**Sí.** La exploración es suficiente para pasar a la fase de propuesta.

La fase `proposal` debe definir:
- La estructura exacta del YAML modificado
- El orden específico de inserción de las nuevas reglas
- El plan de verificación de validez del YAML
