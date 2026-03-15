# Diseño: refactor-workflow-optimization

## Enfoque Técnico

Este cambio optimiza el flujo de trabajo del orquestador SDD mediante la implementación de cuatro reglas de negocio que mejoran la experiencia del usuario y la robustez del sistema. Se modificarán los archivos de skills existentes (`orchestrator-core.md`, `sdd-propose`, `sdd-apply`, `sdd-verify`) para agregar lógica condicional sin cambiar la arquitectura general. La estrategia es implementar cada regla de forma independiente y luego verificar que las interacciones entre ellas sean coherentes.

## Decisiones de Arquitectura

### Decisión: Detección de cambios activos para la Regla de Concurrencia

**Elección**: Contar carpetas en `openspec/changes/` ignorando `archive/`
**Alternativas consideradas**: 
- Usar `state.yaml` para determinar cambios activos (descartado: requiere que todos los cambios tengan state.yaml)
- Mantener un registro en memoria (descartado: no survives context loss)
**Justificación**: Contar carpetas es stateless y survive a resets. El directorio `archive/` se ignora porque esos cambios ya están completados y no deben aparecer en la lista de selección.

### Decisión: Detección de herramienta para Paralelismo Condicional

**Elección**: Usar la variable de templating `{{TOOL_NAME}}` ya existente en el prompt
**Alternativas consideradas**:
- Detectar vía variables de entorno (descartado: no todas las herramientas setean variables confiables)
- Preguntar al usuario (descartado: introduce fricción innecesaria)
**Justificación**: `{{TOOL_NAME}}` ya está definida en el orchestrator-core.md actual y contiene el nombre de la herramienta de ejecución. Es el mecanismo de templating más robusto disponible.

### Decisión: Lista explícita de herramientas con soporte de sub-agentes

**Elección**: Lista fija de herramientas: Claude Code, OpenCode (soporte nativo); Gemini CLI, Codex (inline)
**Alternativas consideradas**:
- Detección dinámica basada en capacidades (descartado: complejidad innecesaria)
- Regex match en `{{TOOL_NAME}}` (descartado: riesgo de falsos positivos)
**Justificación**: Las herramientas evolucionan lentamente. Una lista explícita es más predecible y fácil de mantener. Si la herramienta no está en la lista, se usa fallback seguro (secuencial).

### Decisión: Formato de verify-report.md para consumo por /sdd-fix

**Elección**: Estructura con campos explícitos: Status, Errores, Detalles
**Alternativas consideradas**:
- Usar formato JSON (descartado: los skills SDD trabajan con markdown)
- Reusar estructura de tasks.md (descartado: semánticamente diferente)
**Justificación**: El formato markdown con campos explícitos permite parsing simple por el orquestador y es legible por humanos. El skill sdd-verify ya genera reportes en markdown.

### Decisión: Contexto de errores para sdd-apply

**Elección**: Pasar errores como texto en la descripción de la fase al delegar
**Alternativas consideradas**:
- Escribir archivo temporal de errores (descartado: complejidad adicional de archivos)
- Modificar state.yaml (descartado: cambiaría el schema de state.yaml)
**Justificación**: El orquestador pasa contexto a los sub-agentes via el mensaje de invocación. Es el mecanismo ya establecido y no requiere cambios en la infraestructura.

## Flujo de Datos

```
Usuario ejecuta comando
         │
         ▼
┌─────────────────────────────────────────┐
│      orchestrator-core.md               │
│  (procesa comando, detecta modo)       │
└───────────────┬─────────────────────────┘
                │
    ┌───────────┴───────────┐
    ▼                       ▼
Regla de              Regla de
Concurrencia          Paralelismo
    │                       │
    ▼                       ▼
[Un cambio]        [Herramienta con sub-agents?]
    │                       │
    │                  ┌────┴────┐
    │                  ▼         ▼
    │              Paralelo   Secuencial
    │                       │
    └───────────┬───────────┘
                ▼
         Ejecución de fase(s)
                │
                ▼
┌─────────────────────────────────────────┐
│         sdd-apply / sdd-verify          │
│  (recibe contexto de errores si aplica) │
└─────────────────────────────────────────┘
```

## Cambios de Archivos

| Archivo                                    | Acción    | Descripción                                                                                         |
|-------------------------------------------|-----------|-----------------------------------------------------------------------------------------------------|
| `skills/_shared/orchestrator-core.md`     | Modificar | Agregar Regla de Concurrencia (líneas ~43-53), Regla de Paralelismo Condicional, Regla del Loop de Fix (`/sdd-fix`) |
| `skills/sdd-propose/SKILL.md`             | Modificar | Agregar validación de contexto de exploración (buscar `exploration.md` o contexto efímero)        |
| `skills/sdd-apply/SKILL.md`               | Modificar | Agregar acepta de errores del verify como entrada en el paso de "Qué Recibís" y procesamiento      |
| `skills/sdd-verify/SKILL.md`              | Modificar | Asegurar formato estructurado del reporte con campos Status, Errores, Detalles                    |
| `openspec/changes/refactor-workflow-optimization/design.md` | Crear | Este documento de diseño técnico                                                                     |

## Interfaces / Contratos

### Contrato: Regla de Concurrencia (Stateless)

```markdown
Entrada: comando sin argumento [change]
Proceso:
  1. Listar carpetas en openspec/changes/ (ignorar archive/)
  2. Si count == 1 → usar ese cambio
  3. Si count > 1 → detener, listar cambios, pedir selección
  4. Si count == 0 → error "no hay cambios activos"
Salida: change seleccionado o mensaje de selección
```

### Contrato: Regla de Paralelismo Condicional

```markdown
Entrada: /sdd-continue o /sdd-ff, fases siguientes = spec + design
Proceso:
  1. Leer {{TOOL_NAME}}
  2. Si tool in [Claude Code, OpenCode] → ejecutar en paralelo
  3. Si tool in [Gemini CLI, Codex] → ejecutar secuencial
  4. Si tool unknown → fallback secuencial
Salida: fases ejecutadas en el orden apropiado
```

### Contrato: Regla del Loop de Fix

```markdown
Entrada: /sdd-fix [change]
Proceso:
  1. Leer verify-report.md del cambio
  2. Si no existe → error "ejecute verify primero"
  3. Si status == ÉXITO → informar "no hay errores"
  4. Si status == FALLO → extraer errores, lanzar sdd-apply con errores como contexto
  5. sdd-apply actualiza tasks.md con correcciones
Salida: tareas corregidas, estado actualizado
```

## Estrategia de Testing

| Capa        | Qué Testear                                                              | Enfoque                                                        |
|-------------|--------------------------------------------------------------------------|----------------------------------------------------------------|
| Unitario    | Lógica de detección de cambios activos, detección de herramienta        | Revisión manual de las condiciones en el código               |
| Integración | Flujo completo: /sdd-fix con verify fallido, /sdd-ff con paralelismo    | Ejecutar los comandos y verificar el comportamiento observado  |
| E2E         | Usuario con múltiples cambios ejecuta comandos sin argumento              | Simular escenario real con casos de prueba manuales           |

**Nota**: No existen tests unitarios formales en el proyecto para skills. La validación será manual ejecutando los comandos en contexto real y verificando el comportamiento contra las specs.

## Migración / Despliegue

No se requiere migración. Los cambios son en archivos de configuración de skills (prompts) y no afectan datos persistentes ni estructura de archivos existente.

## Preguntas Abiertas

- [ ] ¿Se debe agregar un límite de reintentos al loop de fix para prevenir ciclos infinitos? (La spec no lo especifica, pero podría ser necesario en producción)
- [ ] ¿La lista de herramientas con soporte de sub-agentes debe ser extensible por configuración? (Actualmente hardcoded en el orchestrator-core.md)
- [ ] ¿Debe el orquestador cachear la detección de herramienta o recalcular en cada comando? (Impacto en performance vs. flexibilidad)