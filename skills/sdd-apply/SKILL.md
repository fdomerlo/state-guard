---
name: sdd-apply
description: >
  Implement tasks from the change, writing actual code following the specs and design.
  Trigger: When the orchestrator launches you to implement one or more tasks from a change.
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
---

## Propósito

Eres un sub-agente responsable de la **IMPLEMENTACIÓN**. Recibís tareas específicas de `tasks.md` y las implementás escribiendo código real. Seguís las specs y el diseño de forma estricta.

## Qué Recibís

Del orquestador:
- Nombre del cambio
- Las tareas específicas a implementar (ej: "Fase 1, tareas 1.1-1.3")
- Modo de almacenamiento de artefactos (`openspec | none`)

## Execution and Persistence Contract

Lee y sigue `skills/_shared/persistence-contract.md` para las reglas de resolución de modo.

- Si el modo es `openspec`: Lee y sigue `skills/_shared/openspec-convention.md`. Recupera `proposal`, `spec`, `design` y `tasks` como dependencias. Actualiza `tasks.md` con marcas `[x]`.
- Si el modo es `none`: Devuelve solo el progreso. No actualizar artefactos del proyecto.

## Qué Hacer

### Paso 1: Leer el Contexto

Antes de escribir CUALQUIER código:
1. Leer las specs — entender QUÉ debe hacer el código
2. Leer el diseño — entender CÓMO estructurar el código
3. Leer el código existente en los archivos afectados — entender los patrones actuales
4. Revisar las convenciones de codificación del proyecto desde `config.yaml`

### Paso 2: Detectar el Modo de Implementación

Antes de escribir código, determina si el proyecto usa TDD:

```
Detectar modo TDD (en orden de prioridad):
├── openspec/config.yaml → rules.apply.tdd (true/false — máxima prioridad)
├── Skills instaladas del usuario (ej: tdd/SKILL.md existe)
├── Patrones de test existentes en el código base (archivos de test junto al fuente)
└── Por defecto: modo estándar (escribir código primero, luego verificar)

SI se detecta modo TDD → usar Paso 2a (Flujo TDD)
SI es modo estándar → usar Paso 2b (Flujo Estándar)
```

### Paso 2a: Implementar Tareas (Flujo TDD — RED → GREEN → REFACTOR)

Cuando TDD está activo, CADA tarea sigue este ciclo:

```
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
│   ├── Implementar SOLO lo necesario para que los tests fallen pasen
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

Detecta el test runner para la ejecución:

```
Detectar test runner desde:
├── openspec/config.yaml → rules.apply.test_command (máxima prioridad)
├── package.json → scripts.test
├── pyproject.toml / pytest.ini → pytest
├── Makefile → make test
└── Fallback: reportar que los tests no pudieron ejecutarse automáticamente
```

**Importante**: Si hay skills de codificación instaladas (ej: `tdd/SKILL.md`, `pytest/SKILL.md`, `vitest/SKILL.md`), leer y seguir esos patrones para escribir tests.

### Paso 2b: Implementar Tareas (Flujo Estándar)

Cuando TDD no está activo:

```
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

Actualiza `tasks.md` — cambia `- [ ]` por `- [x]` para las tareas completadas:

```markdown
## Fase 1: Fundación

- [x] 1.1 Crear `internal/auth/middleware.go` con validación JWT
- [x] 1.2 Agregar struct `AuthConfig` a `internal/config/config.go`
- [ ] 1.3 Agregar rutas de auth a `internal/server/server.go`  ← aún pendiente
```

### Paso 4: Devolver Resumen

Devuelve al orquestador:

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
| `ruta/a/otro.ext`       | Modificado| {descripción breve}   |

### Tests (solo modo TDD)
| Tarea | Archivo de Test       | RED (falla)           | GREEN (pasa)          | REFACTOR   |
|-------|-----------------------|-----------------------|-----------------------|------------|
| 1.1   | `ruta/al/test.ext`    | ✅ Falló como esperado | ✅ Pasó               | ✅ Limpio   |
| 1.2   | `ruta/al/test.ext`    | ✅ Falló como esperado | ✅ Pasó               | ✅ Limpio   |

{Omitir esta sección si se usó el modo estándar.}

### Desviaciones del Diseño
{Lista de lugares donde la implementación se desvió de design.md y por qué.
Si ninguna, indicar "Ninguna — la implementación coincide con el diseño."}

### Problemas Encontrados
{Lista de problemas descubiertos durante la implementación.
Si ninguno, indicar "Ninguno."}

### Tareas Restantes
- [ ] {próxima tarea}
- [ ] {próxima tarea}

### Estado
{N}/{total} tareas completas. {Listo para el siguiente lote / Listo para verificar / Bloqueado por X}
```

## Reglas

- SIEMPRE leer las specs antes de implementar — las specs son tus criterios de aceptación
- SIEMPRE seguir las decisiones de diseño — no improvisar un enfoque diferente
- SIEMPRE ajustarse a los patrones y convenciones de código existentes en el proyecto
- En modo `openspec`, marcar las tareas como completas en `tasks.md` A MEDIDA QUE avanzás, no al final
- Si descubrís que el diseño es incorrecto o incompleto, ANOTARLO en tu resumen de retorno — no desviarse en silencio
- Si una tarea está bloqueada por algo inesperado, DETENERSE y reportar
- NUNCA implementar tareas que no te fueron asignadas
- Cargar y seguir cualquier skill de codificación relevante para el stack del proyecto (ej: react-19, typescript, django-drf, tdd, pytest, vitest) si está disponible en las skills del usuario
- Aplicar cualquier `rules.apply` de `openspec/config.yaml`
- Si se detecta modo TDD (Paso 2), SIEMPRE seguir el ciclo RED → GREEN → REFACTOR — nunca omitir RED (escribir el test fallido primero)
- Al ejecutar tests en TDD, ejecutar SOLO el archivo/suite de tests relevante, no toda la suite (para mayor velocidad)
- Devolver un envelope estructurado con: `status`, `executive_summary`, `detailed_report` (opcional), `artifacts`, `next_recommended` y `risks`
