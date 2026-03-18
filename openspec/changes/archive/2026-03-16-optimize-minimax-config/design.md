# Diseño: optimize-minimax-config

## Enfoque Técnico

Este cambio consiste en la **inyección directa de 5 nuevas reglas** en el archivo de configuración `openspec/config.yaml`, específicamente en las fases `design`, `tasks` y `apply`. El enfoque es simple y conservativo: agregar las reglas como nuevos elementos de lista dentro de las secciones existentes, manteniendo el formato YAML actual y preservando todo el contenido preexistente (context y glossary).

## Decisiones de Arquitectura

### Decisión: Estructura de Inyección de Reglas

**Elección**: Agregar las nuevas reglas como elementos de lista individuales dentro de cada fase existente (`design`, `tasks`, `apply`), usando el mismo formato de guiones (-) que las reglas existentes.

**Alternativas consideradas**: 
- Crear una nueva sección separada para reglas "MiniMax" — descartado por romper el formato consistente
- Reescribir todo el archivo con formato diferente — descartado por innecesario y riesgoso

**Justificación**: El archivo actual usa listas con guiones para cada regla. Mantener este formato asegura consistencia visual y reduce el riesgo de errores de sintaxis YAML. Las fases existentes ya tienen un patrón claro de lista que debemos seguir.

### Decisión: Distribución de las 5 Reglas por Fase

**Elección**: 
- Fase `design`: 2 nuevas reglas (RF-001: Diagramas Mermaid, RF-002: Modularidad extrema)
- Fase `tasks`: 1 nueva regla (RF-003: Granularidad atómica)
- Fase `apply`: 2 nuevas reglas (RF-004: Código defensivo, RF-005: Completitud)

**Alternativas consideradas**: 
- Agrupar todas las reglas en una sola fase — descartado por violar la semántica de las specs
- Distribuir uniformemente — no aplica, las specs definen la distribución exacta

**Justificación**: Las especificaciones (spec.md) definen explícitamente qué regla va en cada fase. La propuesta y specs son la fuente de verdad para la distribución.

### Decisión: Preservación de Contenido Existente

**Elección**: No modificar las secciones `context:`, `glossary:` ni ninguna regla existente. Solo agregar las nuevas reglas al final de cada lista de fase.

**Alternativas consideradas**: 
- Reformatear todo el archivo — descartado por riesgo innecesario
- Eliminar reglas redundantes — no hay redundancia identificada

**Justificación**: El requisito no funcional RNF-002 exige preservar context y glossary. Además, las reglas existentes son válidas y complementarias a las nuevas.

## Flujo de Datos

No aplica para este cambio. El archivo `config.yaml` es un archivo de configuración estática que no tiene flujo de datos durante la ejecución.

```
┌─────────────────────┐
│  openspec/config.yaml  │
│  (archivo estático)   │
└─────────────────────┘
        │
        ▼ (lectura por skills SDD)
┌─────────────────────┐
│  Orquestador SDD     │
│  (parsea reglas)     │
└─────────────────────┘
```

## Cambios de Archivos

| Archivo                      | Acción    | Descripción                          |
|------------------------------|-----------|--------------------------------------|
| `openspec/config.yaml`       | Modificar | Agregar 5 nuevas reglas a las fases design, tasks y apply |

**Detalle de modificaciones**:
- Fase `design`: agregar 2 reglas al final de la lista existente (líneas 17-20)
- Fase `tasks`: agregar 1 regla al final de la lista existente (líneas 21-25)  
- Fase `apply`: agregar 2 reglas al final de la lista existente (líneas 26-28)

## Interfaces / Contratos

No hay nuevas interfaces ni contratos. Este cambio solo modifica el contenido de un archivo de configuración YAML existente.

## Estrategia de Testing

| Capa        | Qué Testear | Enfoque  |
|-------------|-------------|----------|
| Validación  | Sintaxis YAML | Verificar que `python3 -c "import yaml; yaml.safe_load(open('openspec/config.yaml'))"` no lance excepciones |

No se requieren tests unitarios, de integración ni E2E para este cambio de configuración.

## Migración / Despliegue

No se requiere migración. Este cambio:
- No afecta datos persistentes
- No requiere feature flags
- Es inmediato tras la fusión del cambio

## Preguntas Abiertas

- [ ] Ninguna — el cambio es directo y no presenta ambigüedades técnicas.

---

## Diseño Creado

**Cambio**: optimize-minimax-config
**Ubicación**: openspec/changes/optimize-minimax-config/design.md

### Resumen
- **Enfoque**: Inyección directa de 5 nuevas reglas en las fases design, tasks y apply de config.yaml
- **Decisiones Clave**: 3 decisiones documentadas (estructura de inyección, distribución por fase, preservación de contenido)
- **Archivos Afectados**: 1 modificado (openspec/config.yaml)
- **Estrategia de Testing**: Validación de sintaxis YAML

### Preguntas Abiertas
Ninguna

### Próximo Paso
Listo para tareas (sdd-tasks).