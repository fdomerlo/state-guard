# Diseño Técnico: fix-init-config-template

## Decisiones de Arquitectura

1. **Inyección YAML Transparente**:
   El mecanismo principal es actualizar los templates *hardcodeados* (los strings literales o bloques heredados en Markdown) en lugar de agregar lógica dinámica condicional, para asegurar que la inyección inicial sea agnóstica a librerías y dependa exclusivamente pura de texto. 

2. **Garantía DRY**:
   Para evitar divergencias, la misma cadena exacta YAML usada en la creación inicial (`sdd-init`) debe reproducirse en la lectura de reglas técnicas oficiales del manual (`openspec-convention.md`).

## Cambios de Archivos Previstos

| Archivo | Acción | Notas |
|---------|--------|-------|
| `skills/sdd-init/SKILL.md` | Modificar | Expandir el payload YAML bajo su sección de Paso 3 (Generar la Configuración). |
| `skills/_shared/openspec-convention.md` | Modificar | Igualar el payload en la "Referencia del config.yaml". |

## Estructura YAML Objetivo
Las directivas deben insertarse respetando la sangría de 2/4 espacios correspondientes. Por ejemplo:
```yaml
  design:
    - Incluir diagramas de secuencia para flujos complejos
    - Documentar decisiones de arquitectura con justificación
    - "[!] Si proposal.md marca el riesgo como Medio/Alto, DEBES incluir una Estrategia de Testing rigurosa."
    - "Explotar razonamiento arquitectónico: DEBES incluir diagramas Mermaid exhaustivos (State, Sequence o Class) para cualquier flujo no trivial."
    - "Priorizar modularidad extrema: Diseña el sistema asumiendo que el código será escrito por un modelo de IA con ventana de contexto limitada. Interfaces claras y acoplamiento nulo."
  tasks:
    - Agrupar tareas por fase (infraestructura, implementación, testing)
    - Usar numeración jerárquica (1.1, 1.2, etc.)
    - Mantener tareas pequeñas, completables en una sesión
    - "[!] Si design.md incluye una Estrategia de Testing, DEBES generar tareas explícitas para escribir esos tests."
    - "Granularidad Atómica: Cada tarea debe ser lo suficientemente pequeña para implementarse en un solo archivo o módulo lógico. Evitar 'tareas monstruo'."
  apply:
    - Seguir los patrones y convenciones de código existentes
    - Cargar skills de codificación relevantes para el stack del proyecto
    - "Código Defensivo y Pragmatismo: Aplica principios SOLID, DRY y Clean Code. Prefiere Early Returns (Guard Clauses). NUNCA sobre-ingeniar."
    - "Completitud: No uses placeholders como '...código restante aquí...'. Si escribes un archivo, escríbelo completo y listo para producción."
```
