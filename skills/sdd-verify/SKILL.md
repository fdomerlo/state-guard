---
name: sdd-verify
description: >
  Valida que la implementación coincida con las especificaciones, el diseño y las tareas.
  Disparador: Cuando el usuario ejecuta /sdd-verify para verificar un cambio completado.
license: MIT
metadata:
  author: fdomerlo-steve
  version: "3.0"
---

# SDD-Verify Skill

## Propósito

Skill responsable de la **VERIFICACIÓN**. Sos la puerta de calidad. Tu trabajo es demostrar —con evidencia de ejecución real— que la implementación está completa, es correcta y cumple conductualmente con las specs.

El análisis estático por sí solo NO es suficiente. DEBÉS ejecutar el código.

## Qué Hacer

### Paso 0: Leer el Contexto

Antes de verificar, leé las dependencias del cambio actual:

1. **Specs delta del cambio** — leer todos los archivos en `openspec/changes/{nombre-del-cambio}/specs/`
2. **Diseño** — leer `openspec/changes/{nombre-del-cambio}/design.md`
3. **Tareas** — leer `openspec/changes/{nombre-del-cambio}/tasks.md`

**REGLA CRÍTICA**: Queda PROHIBIDO cargar o leer `specs/` completo del proyecto. Solo specs delta del cambio activo.
**REGLA CRÍTICA**: Queda PROHIBIDO buscar en todo el código base. Solo leer archivos específicos mencionados en las tareas del cambio.

### Paso 1: Verificar Completitud

```text
Leer tasks.md
├── Contar total de tareas
├── Contar tareas completadas [x]
├── Listar tareas incompletas [ ]
└── Marcar: CRITICAL si tareas centrales incompletas, WARNING si tareas de limpieza incompletas
```

### Paso 2: Verificar Corrección (Coincidencia Estática con Specs)

```text
PARA CADA REQUISITO en specs/:
├── Buscar evidencia de implementación en el código base
├── Para cada ESCENARIO:
│   ├── ¿La precondición GIVEN está manejada en el código?
│   ├── ¿La acción WHEN está implementada?
│   ├── ¿El resultado THEN se produce?
│   └── ¿Los casos límite están cubiertos?
└── Marcar: CRITICAL si falta el requisito, WARNING si el escenario está cubierto parcialmente
```

### Paso 3: Verificar Coherencia (Coincidencia con Diseño)

```text
PARA CADA DECISIÓN en design.md:
├── ¿Se usó realmente el enfoque elegido?
├── ¿Se implementaron accidentalmente las alternativas rechazadas?
├── ¿Los cambios de archivos coinciden con la tabla "Cambios de Archivos"?
└── Marcar: WARNING si se encontró una desviación
```

### Paso 4: Verificar Testing (Estático)

```text
Buscar archivos de test relacionados con el cambio
├── ¿Existen tests para cada escenario de spec?
├── ¿Los tests cubren caminos felices?
├── ¿Los tests cubren casos límite?
├── ¿Los tests cubren estados de error?
└── Marcar: WARNING si hay escenarios sin tests, SUGGESTION si la cobertura puede mejorar
```

### Paso 4b: Ejecutar Tests (Ejecución Real)

CRÍTICO: Debes ejecutar usando una herramienta de terminal real. ESTÁ PROHIBIDO simular o inferir el resultado.

Detectar el test runner consultando `skills/_shared/test-runner-detection.md` con parámetro `{fase}=verify`.

### Paso 4c: Build y Verificación de Tipos (Ejecución Real)

```text
Detectar comando de build desde:
├── openspec/config.yaml → rules.verify.build_command (máxima prioridad)
├── package.json → scripts.build → también ejecutar tsc --noEmit si existe tsconfig.json
├── pyproject.toml → python -m build o equivalente
├── Makefile → make build
└── Fallback: omitir y reportar como WARNING (no CRITICAL)
```

### Paso 4d: Validación de Cobertura (si configurado)

Solo ejecutar si `rules.verify.coverage_threshold` está definido en `openspec/config.yaml`.

### Paso 5: Matriz de Cumplimiento de Specs (Validación Conductual)

Este es el paso más importante. Cruzar CADA escenario de spec contra los resultados reales de la ejecución de tests:

```text
PARA CADA REQUISITO en specs/:
  PARA CADA ESCENARIO:
  ├── Encontrar tests que cubren este escenario
  ├── Consultar el resultado de ese test desde la salida del Paso 4b
  ├── Asignar estado de cumplimiento:
  │   ├── ✅ CUMPLE     → el test existe Y pasó
  │   ├── ❌ FALLANDO   → el test existe PERO falló (CRITICAL)
  │   ├── ❌ SIN TEST   → no se encontró test para este escenario (CRITICAL)
  │   └── ⚠️ PARCIAL   → el test existe, pasa, pero cubre solo parte del escenario (WARNING)
  └── Registrar: requisito, escenario, archivo de test, nombre de test, resultado
```

### Paso 6: Persistir el Reporte de Verificación

Escribir el reporte completo en `openspec/changes/{nombre-del-cambio}/verify-report.md`.

### Paso 7: Reportar

Si hay issues CRITICAL → ejecutá ROLLBACK y reportá los problemas.

```markdown
## Reporte de Verificación

**Cambio**: {nombre-del-cambio}

### Completitud
| Métrica              | Valor |
|----------------------|-------|
| Tareas totales       | {N}   |
| Tareas completas     | {N}   |
| Tareas incompletas   | {N}   |

### Ejecución de Build y Tests
**Build**: ✅ Pasó / ❌ Falló
**Tests**: ✅ {N} pasaron / ❌ {N} fallaron / ⚠️ {N} omitidos
**Cobertura**: {N}% / umbral: {N}% → ✅/⚠️/➖

### Matriz de Cumplimiento de Specs
| Requisito | Escenario | Test | Resultado |
|-----------|-----------|------|-----------|
| {REQ-01}  | {Nombre}  | `{test}` | ✅ CUMPLE |

### Problemas Encontrados
**CRITICAL**: {Lista o "Ninguno"}
**WARNING**: {Lista o "Ninguno"}
**SUGGESTION**: {Lista o "Ninguno"}

### Veredicto
{APROBADO / APROBADO CON ADVERTENCIAS / RECHAZADO}
```

## Reglas

- SIEMPRE leer el código fuente real — no confiar en resúmenes
- SIEMPRE ejecutar tests — el análisis estático solo no es verificación
- Un escenario de spec solo es CUMPLIDO cuando un test que lo cubre ha PASADO
- Comparar contra SPECS primero (corrección conductual), DISEÑO segundo (corrección estructural)
- Ser objetivo — reportar lo que ES, no lo que debería ser
- Los issues CRITICAL = deben resolverse antes de archivar
- Los WARNING = deberían resolverse pero no bloquean
- Las SUGGESTION = mejoras, no bloqueantes
- NO corregir ningún problema — solo reportarlos
- SIEMPRE guardar el reporte en `openspec/changes/{nombre-del-cambio}/verify-report.md`
- Aplicar cualquier `rules.verify` de `openspec/config.yaml`
