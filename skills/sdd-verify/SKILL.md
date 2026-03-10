---
name: sdd-verify
description: >
  Valida que la implementación coincida con las especificaciones, el diseño y las tareas.
  Disparador: Cuando el orquestador te lanza para verificar un cambio completado (o parcialmente completado).
license: MIT
metadata:
  author: gentleman-programming
  version: "2.0"
---

## Propósito

Eres un sub-agente responsable de la **VERIFICACIÓN**. Eres la puerta de calidad. Tu trabajo es demostrar —con evidencia de ejecución real— que la implementación está completa, es correcta y cumple conductualmente con las specs.

El análisis estático por sí solo NO es suficiente. DEBES ejecutar el código.

## Qué Recibís

Del orquestador:
- Nombre del cambio
- Modo de almacenamiento de artefactos (`openspec | none`)

## Execution and Persistence Contract

Lee y sigue `skills/_shared/persistence-contract.md` para las reglas de resolución de modo.

- Si el modo es `openspec`: Lee y sigue `skills/_shared/openspec-convention.md`. Recupera `proposal`, `spec`, `design` y `tasks` como dependencias. Guarda el reporte en `openspec/changes/{nombre-del-cambio}/verify-report.md`.
- Si el modo es `none`: Devuelve el reporte de verificación solo de forma inline. Nunca escribir archivos.

## Qué Hacer

### Paso 1: Verificar Completitud

Verificar que TODAS las tareas estén hechas:

```
Leer tasks.md
├── Contar total de tareas
├── Contar tareas completadas [x]
├── Listar tareas incompletas [ ]
└── Marcar: CRITICAL si tareas centrales incompletas, WARNING si tareas de limpieza incompletas
```

### Paso 2: Verificar Corrección (Coincidencia Estática con Specs)

Para CADA requisito y escenario de spec, buscar en el código base evidencia estructural:

```
PARA CADA REQUISITO en specs/:
├── Buscar evidencia de implementación en el código base
├── Para cada ESCENARIO:
│   ├── ¿La precondición GIVEN está manejada en el código?
│   ├── ¿La acción WHEN está implementada?
│   ├── ¿El resultado THEN se produce?
│   └── ¿Los casos límite están cubiertos?
└── Marcar: CRITICAL si falta el requisito, WARNING si el escenario está cubierto parcialmente
```

Nota: Esto es solo análisis estático. La validación conductual con ejecución real ocurre en el Paso 5.

### Paso 3: Verificar Coherencia (Coincidencia con Diseño)

Verificar que se siguieron las decisiones de diseño:

```
PARA CADA DECISIÓN en design.md:
├── ¿Se usó realmente el enfoque elegido?
├── ¿Se implementaron accidentalmente las alternativas rechazadas?
├── ¿Los cambios de archivos coinciden con la tabla "Cambios de Archivos"?
└── Marcar: WARNING si se encontró una desviación (puede ser una mejora válida)
```

### Paso 4: Verificar Testing (Estático)

Verificar que los archivos de test existen y cubren los escenarios correctos:

```
Buscar archivos de test relacionados con el cambio
├── ¿Existen tests para cada escenario de spec?
├── ¿Los tests cubren caminos felices?
├── ¿Los tests cubren casos límite?
├── ¿Los tests cubren estados de error?
└── Marcar: WARNING si hay escenarios sin tests, SUGGESTION si la cobertura puede mejorar
```

### Paso 4b: Ejecutar Tests (Ejecución Real)

Detectar el test runner del proyecto y ejecutar los tests:

```
Detectar test runner desde:
├── openspec/config.yaml → rules.verify.test_command (máxima prioridad)
├── package.json → scripts.test
├── pyproject.toml / pytest.ini → pytest
├── Makefile → make test
└── Fallback: consultar al orquestador

Ejecutar: {test_command}
Capturar:
├── Total de tests ejecutados
├── Pasaron
├── Fallaron (listar cada uno con nombre y error)
├── Omitidos
└── Código de salida

Marcar: CRITICAL si el código de salida != 0 (algún test falló)
Marcar: WARNING si tests omitidos se relacionan con áreas modificadas
```

### Paso 4c: Build y Verificación de Tipos (Ejecución Real)

Detectar y ejecutar el comando de build/type-check:

```
Detectar comando de build desde:
├── openspec/config.yaml → rules.verify.build_command (máxima prioridad)
├── package.json → scripts.build → también ejecutar tsc --noEmit si existe tsconfig.json
├── pyproject.toml → python -m build o equivalente
├── Makefile → make build
└── Fallback: omitir y reportar como WARNING (no CRITICAL)

Ejecutar: {build_command}
Capturar:
├── Código de salida
├── Errores (si los hay)
└── Advertencias (si son significativas)

Marcar: CRITICAL si el build falla (código de salida != 0)
Marcar: WARNING si hay errores de tipos aunque el build pase
```

### Paso 4d: Validación de Cobertura (Ejecución Real — si el umbral está configurado)

Ejecutar con cobertura solo si `rules.verify.coverage_threshold` está definido en `openspec/config.yaml`:

```
SI coverage_threshold está configurado:
├── Ejecutar: {test_command} --coverage (o equivalente para el test runner)
├── Parsear el reporte de cobertura
├── Comparar el % total de cobertura contra el umbral
├── Marcar: WARNING si está por debajo del umbral (no CRITICAL — la cobertura sola no bloquea)
└── Reportar cobertura por archivo solo para los archivos modificados

SI coverage_threshold NO está configurado:
└── Omitir este paso, reportar como "No configurado"
```

### Paso 5: Matriz de Cumplimiento de Specs (Validación Conductual)

Este es el paso más importante. Cruzar CADA escenario de spec contra los resultados reales de la ejecución de tests del Paso 4b para construir evidencia conductual.

Para cada escenario de las specs, encontrar qué test(s) lo cubren y cuál fue el resultado:

```
PARA CADA REQUISITO en specs/:
  PARA CADA ESCENARIO:
  ├── Encontrar tests que cubren este escenario (por nombre, descripción o ruta de archivo)
  ├── Consultar el resultado de ese test desde la salida del Paso 4b
  ├── Asignar estado de cumplimiento:
  │   ├── ✅ CUMPLE     → el test existe Y pasó
  │   ├── ❌ FALLANDO   → el test existe PERO falló (CRITICAL)
  │   ├── ❌ SIN TEST   → no se encontró test para este escenario (CRITICAL)
  │   └── ⚠️ PARCIAL   → el test existe, pasa, pero cubre solo parte del escenario (WARNING)
  └── Registrar: requisito, escenario, archivo de test, nombre de test, resultado
```

Un escenario de spec solo se considera CUMPLIDO cuando existe un test que pasó demostrando el comportamiento en runtime. Que el código exista en el código base NO es evidencia suficiente.

### Paso 6: Persistir el Reporte de Verificación

Persiste el reporte según el `artifact_store.mode` resuelto, siguiendo las convenciones en `skills/_shared/`:

- **openspec**: Escribir en `openspec/changes/{nombre-del-cambio}/verify-report.md`
- **none**: Devolver el reporte completo de forma inline, NO escribir ningún archivo

### Paso 7: Devolver Resumen

Devuelve al orquestador el mismo contenido que escribiste en `verify-report.md`:

```markdown
## Reporte de Verificación

**Cambio**: {nombre-del-cambio}
**Versión**: {versión de spec o N/A}

---

### Completitud
| Métrica              | Valor |
|----------------------|-------|
| Tareas totales       | {N}   |
| Tareas completas     | {N}   |
| Tareas incompletas   | {N}   |

{Listar tareas incompletas si las hay}

---

### Ejecución de Build y Tests

**Build**: ✅ Pasó / ❌ Falló
```
{salida del comando de build o error si falló}
```

**Tests**: ✅ {N} pasaron / ❌ {N} fallaron / ⚠️ {N} omitidos
```
{nombres de tests fallidos y errores si los hay}
```

**Cobertura**: {N}% / umbral: {N}% → ✅ Por encima del umbral / ⚠️ Por debajo del umbral / ➖ No configurado

---

### Matriz de Cumplimiento de Specs

| Requisito         | Escenario         | Test                              | Resultado       |
|-------------------|-------------------|-----------------------------------|-----------------|
| {REQ-01: nombre}  | {Nombre escenario}| `{archivo test} > {nombre test}`  | ✅ CUMPLE        |
| {REQ-01: nombre}  | {Nombre escenario}| `{archivo test} > {nombre test}`  | ❌ FALLANDO      |
| {REQ-02: nombre}  | {Nombre escenario}| (ninguno encontrado)              | ❌ SIN TEST      |
| {REQ-02: nombre}  | {Nombre escenario}| `{archivo test} > {nombre test}`  | ⚠️ PARCIAL      |

**Resumen de cumplimiento**: {N}/{total} escenarios cumplen

---

### Corrección (Estático — Evidencia Estructural)
| Requisito       | Estado              | Notas                    |
|-----------------|---------------------|--------------------------|
| {Nombre req}    | ✅ Implementado      | {nota breve}             |
| {Nombre req}    | ⚠️ Parcial          | {qué falta}              |
| {Nombre req}    | ❌ Faltante          | {no implementado}        |

---

### Coherencia (Diseño)
| Decisión           | ¿Seguida? | Notas                  |
|--------------------|-----------|------------------------|
| {Nombre decisión}  | ✅ Sí     |                        |
| {Nombre decisión}  | ⚠️ Desviación | {cómo y por qué}   |

---

### Problemas Encontrados

**CRITICAL** (deben resolverse antes de archivar):
{Lista o "Ninguno"}

**WARNING** (deberían resolverse):
{Lista o "Ninguno"}

**SUGGESTION** (mejoras deseables):
{Lista o "Ninguno"}

---

### Veredicto
{APROBADO / APROBADO CON ADVERTENCIAS / RECHAZADO}

{Resumen en una línea del estado general}
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
- NO corregir ningún problema — solo reportarlos. El orquestador decide qué hacer.
- En modo `openspec`, SIEMPRE guardar el reporte en `openspec/changes/{nombre-del-cambio}/verify-report.md` — esto persiste la verificación para sdd-archive y el rastro de auditoría
- Aplicar cualquier `rules.verify` de `openspec/config.yaml`
- Devolver un envelope estructurado con: `status`, `executive_summary`, `detailed_report` (opcional), `artifacts`, `next_recommended` y `risks`
