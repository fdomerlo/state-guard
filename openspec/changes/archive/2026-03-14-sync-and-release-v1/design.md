# Diseño: sync-and-release-v1 — Sincronización de Comandos OpenCode

## Enfoque Técnico

Este cambio implementa la sincronización entre comandos y skills del orquestador SDD, creando los 3 comandos faltantes (`sdd-spec`, `sdd-design`, `sdd-tasks`) y actualizando los archivos de test y documentación para reflejar el nuevo estado de 15 comandos.

El enfoque sigue la plantilla existente de comandos en `examples/opencode/commands/`, manteniendo consistencia con el patrón de diseño actual donde cada comando invoca una skill específica del orquestador.

## Decisiones de Arquitectura

### Decisión: Estructura de los Nuevos Comandos

**Elección**: Crear archivos de comando independientes que sigan la plantilla existente, sin modificar el comportamiento de las skills subyacentes.

**Alternativas consideradas**: 
- Modificar `sdd-new` para aceptar argumentos de fase específica
- Crear un comando genérico que reciba el nombre de la skill como argumento

**Justificación**: La propuesta original indica explícitamente mantener la consistencia con los comandos existentes. Los 3 comandos faltantes son atajos directos a fases específicas, diferenciándose de `sdd-new` que orquesta múltiples fases. Mantener archivos separados permite una invocación más directa y clara.

### Decisión: Actualización del Test Script

**Elección**: Modificar `scripts/install_test.sh` para esperar exactamente 15 comandos, manteniendo el array `EXPECTED_SKILLS` con 13 elementos (las skills reales) y agregar validación de sincronización commands-skills.

**Alternativas consideradas**:
- Crear un nuevo array `EXPECTED_COMMANDS` separado
- Modificar el test para verificar mapeo uno a uno

**Justificación**: La especificación de installer indica que `EXPECTED_COMMANDS` debe ser 15. El test actual ya tiene 13 skills, pero solo valida 12 comandos. Actualizar el conteo de comandos a 15 resuelve la inconsistencia.

### Decisión: Documentación en README.md

**Elección**: Agregar manualmente las 3 nuevas entradas a la tabla de comandos existente, manteniendo el formato y estilo actual.

**Alternativas consideradas**:
- Generar la tabla automáticamente desde los archivos de comandos
- Usar un script de generación de documentación

**Justificación**: El alcance de este cambio es específicamente sincronizar comandos y skills existentes, no modificar la infraestructura de documentación. El enfoque manual es consistente con el estado actual del proyecto.

## Flujo de Datos

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Flujo de Sincronización                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  examples/opencode/commands/           scripts/install_test.sh      │
│  ┌─────────────────────────┐           ┌─────────────────────────┐  │
│  │ sdd-spec.md (NUEVO)     │           │ assert_eq "15" count    │  │
│  │ sdd-design.md (NUEVO)   │           │ (comandos)              │  │
│  │ sdd-tasks.md (NUEVO)    │           └───────────┬─────────────┘  │
│  └───────────┬─────────────────┘                       │             │
│              │                                           │             │
│              ▼                                           ▼             │
│  ┌─────────────────────────────────────────────────────────────┐     │
│  │              README.md (tabla de comandos)                  │     │
│  │  - 12 comandos existentes + 3 nuevos = 15 total            │     │
│  └─────────────────────────────────────────────────────────────┘     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Cambios de Archivos

| Archivo                                   | Acción  | Descripción                                                                 |
|-------------------------------------------|---------|-----------------------------------------------------------------------------|
| `examples/opencode/commands/sdd-spec.md` | Crear   | Comando para invocar la skill de especificación                             |
| `examples/opencode/commands/sdd-design.md` | Crear | Comando para invocar la skill de diseño técnico                             |
| `examples/opencode/commands/sdd-tasks.md` | Crear   | Comando para invocar la skill de desglose de tareas                         |
| `scripts/install_test.sh`                 | Modificar | Actualizar assert_eq de 12 a 15 en líneas 229, 396, 421, y agregar mensaje de 15 comandos |
| `README.md`                               | Modificar | Agregar 3 nuevos comandos a la tabla: sdd-spec, sdd-design, sdd-tasks       |

## Interfaces / Contratos

### Estructura de Comando (Plantilla a seguir)

```yaml
---
description: {descripción breve del comando}
agent: sdd-orchestrator
subtask: true  # si aplica, como en sdd-apply.md
---

{Instrucciones específicas del comando}
```

### Comandos Nuevos — Propuesta de Contenido

**sdd-spec.md:**
```yaml
---
description: Escribe especificaciones delta para un cambio SDD
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-spec/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec
```

**sdd-design.md:**
```yaml
---
description: Crea el documento de diseño técnico para un cambio
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-design/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec
```

**sdd-tasks.md:**
```yaml
---
description: Desglosa un cambio en tareas de implementación
agent: sdd-orchestrator
---

Eres un sub-agente SDD. Lee el archivo de habilidad en ~/.config/opencode/skills/sdd-tasks/SKILL.md PRIMERO, y luego sigue sus instrucciones exactamente.

CONTEXT:
- Working directory: {workdir}
- Current project: {project}
- Artifact store mode: openspec
```

## Estrategia de Testing

| Capa           | Qué Testear                                              | Enfoque                           |
|----------------|----------------------------------------------------------|-----------------------------------|
| Unitario       | Archivos de comando creados con contenido válido         | Verificar existencia y formato    |
| Integración    | install_test.sh pasa con 15 comandos y 13 skills        | Ejecutar script de test           |
| Documentación  | README.md muestra tabla con 15 comandos                 | Verificar contenido del README    |

## Migración / Despliegue

No se requiere migración. Este cambio:
- Solo crea archivos nuevos en el repositorio
- Modifica archivos de test que no afectan producción
- Actualiza documentación

## Preguntas Abiertas

- [ ] ¿Se debe agregar `subtask: true` a los nuevos comandos? (sdd-apply.md lo tiene, sdd-new.md no)
- [ ] ¿Los nuevos comandos necesitan incluir `TASK:` o son solo descriptivos como sdd-new.md?
- [ ] ¿Debe el install_test.sh validar mapeo 1:1 entre comandos y skills?

**Recomendación**: Mantener el patrón simple (sin `subtask: true`) consistente con `sdd-new.md` para mantener coherencia con la interfaz del orquestador.
