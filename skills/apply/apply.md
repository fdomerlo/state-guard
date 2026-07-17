
# Apply Skill

## Propósito

Skill responsable de la **IMPLEMENTACIÓN**. Recibe tareas específicas de `tasks.md` y las implementa escribiendo código real. Sigue las specs y el diseño de forma estricta.

## Qué Hacer

### Paso 1: Leer el Contexto

Antes de escribir CUALQUIER código, leé las dependencias del cambio actual:

1. **Specs delta del cambio** — leer todos los archivos en `.state-guard/changes/{nombre-del-cambio}/specs/`
2. **Diseño** — leer `.state-guard/changes/{nombre-del-cambio}/design.md`
3. **Tareas** — leer `.state-guard/changes/{nombre-del-cambio}/tasks.md`
4. **Código existente** — leer los archivos afectados para seguir patrones actuales
5. **Convenciones** — leer `config.yaml` para reglas de codificación

**NOTA:** SOLO leer specs delta del cambio actual. NUNCA leer `specs/` completo del proyecto.

### Paso 1b: Selección de Lote

Identificá las próximas 3 tareas pendientes (no completadas) de `tasks.md`. Si ejecutás inline, podés ajustar el tamaño del lote según tu contexto disponible.

### Paso 2: Detectar el Modo de Implementación

Determina si el proyecto usa TDD:

```text
Detectar modo TDD (en orden de prioridad):
├── .state-guard/config.yaml → rules.apply.tdd (true/false — máxima prioridad)
├── Skills instaladas del usuario (ej: tdd/SKILL.md existe)
├── Patrones de test existentes en el código base (archivos de test junto al fuente)
└── Por defecto: modo estándar (escribir código primero, luego verificar)

SI se detecta modo TDD → usar Paso 2a (Flujo TDD)
SI es modo estándar → usar Paso 2b (Flujo Estándar)
```

### Paso 2a: Implementar Tareas (Flujo TDD — RED → GREEN → REFACTOR)

CRÍTICO: Debes ejecutar los tests utilizando una herramienta de terminal real. ESTÁ PROHIBIDO simular o inferir que un test pasó sin haber ejecutado el comando y analizado su salida estándar.

Cuando TDD está activo, CADA tarea sigue este ciclo:

```text
PARA CADA TAREA:
├── 1. ENTENDER
│   ├── Leer la descripción de la tarea
│   ├── Leer los escenarios de spec relevantes (son tus criterios de aceptación)
│   ├── Leer las decisiones de diseño (limitan tu enfoque)
│   └── Leer los patrones de código y test existentes
│
├── 2. RED — Escribir un test fallido PRIMERO
│   ├── Escribir test(s) que describan el comportamiento esperado según los escenarios de spec
│   ├── Ejecutar tests — confirmar que FALLAN (esto prueba que el test tiene sentido)
│   └── Si el test pasa inmediatamente → el comportamiento ya existe o el test es incorrecto
│
├── 3. GREEN — Escribir el código mínimo para pasar
│   ├── Implementar SOLO lo necesario para que los tests pasen
│   ├── Ejecutar tests — confirmar que PASAN
│   └── NO agregar funcionalidad extra más allá de lo que el test requiere
│
├── 4. REFACTOR — Limpiar sin cambiar el comportamiento
│   ├── Mejorar estructura del código, nombres, duplicaciones
│   ├── Ejecutar tests nuevamente — confirmar que SIGUEN PASANDO
│   └── Ajustarse a las convenciones y patrones del proyecto
│
├── 5. Marcar la tarea como completa [x] en tasks.md
└── 6. Anotar cualquier problema o desviación
```

Detecta el test runner consultando `skills/_shared/test-runner-detection.md` con parámetro `{fase}=apply`.

### Paso 2b: Implementar Tareas (Flujo Estándar)

Cuando TDD no está activo:

```text
PARA CADA TAREA:
├── Leer la descripción de la tarea
├── Leer los escenarios de spec relevantes (son tus criterios de aceptación)
├── Leer las decisiones de diseño (limitan tu enfoque)
├── Leer los patrones de código existentes (seguir el estilo del proyecto)
├── Escribir el código
├── Marcar la tarea como completa [x] en tasks.md
└── Anotar cualquier problema o desviación
```

### Paso 3: Marcar Tareas como Completas

Actualiza directamente `tasks.md` — cambiar `- [ ]` por `- [x]` para las tareas completadas.

### Paso 4: Reportar

```markdown
## Progreso de Implementación

**Cambio**: {nombre-del-cambio}
**Modo**: {TDD | Estándar}

### Tareas Completadas
- [x] {descripción tarea 1.1}
- [x] {descripción tarea 1.2}

### Archivos Modificados
| Archivo                 | Acción    | Qué se hizo           |
|-------------------------|-----------|-----------------------|
| `ruta/al/archivo.ext`   | Creado    | {descripción breve}   |

### Desviaciones del Diseño
{Lista o "Ninguna — la implementación coincide con el diseño."}

### Problemas Encontrados
{Lista o "Ninguno."}

### Estado
{N}/{total} tareas completas. {Listo para verificar / Siguiente lote pendiente}
```

## Reglas

- SIEMPRE leer las specs antes de implementar — las specs son tus criterios de aceptación
- SIEMPRE seguir las decisiones de diseño — no improvisar un enfoque diferente
- SIEMPRE ajustarse a los patrones y convenciones de código existentes en el proyecto
- Marcar las tareas completadas en `tasks.md` al momento de cerrarlas
- Si descubrís que el diseño es incorrecto o incompleto, ANOTARLO — no desviarse en silencio
- Si una tarea está bloqueada por algo inesperado, DETENERSE y reportar
- NUNCA implementar tareas que no te fueron asignadas
- Cargar y seguir cualquier skill de codificación relevante para el stack del proyecto
- Aplicar cualquier `rules.apply` de `.state-guard/config.yaml`
- Si se detecta modo TDD, SIEMPRE seguir el ciclo RED → GREEN → REFACTOR
- Al ejecutar tests en TDD, ejecutar SOLO el archivo/suite de tests relevante

> Transacción: BEGIN antes de este contenido, COMMIT al terminar. Ver `_shared/phase-common.md`.
