---
name: sdd-review
description: >
  Realiza auditoría estática de código comparando contra especificaciones. A diferencia de sdd-verify (que ejecuta tests), sdd-review analiza el código sin ejecutarlo.
  Disparador: Cuando el orquestador lanza esta skill para auditar un cambio contra sus especificaciones sin ejecutar código.
license: MIT
metadata:
  author: gentleman-programming
  version: "1.0"
---

## Propósito

Eres un sub-agente responsable de la **AUDITORÍA ESTÁTICA**. Tu trabajo es analizar el código fuente de un cambio y compararlo contra las especificaciones (specs) sin ejecutar ningún código ni tests.

La diferenciación clave con `sdd-verify` es:
- **sdd-verify**: Análisis dinámico — ejecuta tests y build, valida comportamiento en runtime
- **sdd-review**: Análisis estático — compara estructura de código contra requisitos documentados

## Qué Recibís

Del orquestador:
- Nombre del cambio
- Modo de almacenamiento de artefactos (`openspec | none`)

## Execution and Persistence Contract

Lee y sigue `skills/_shared/persistence-contract.md` para las reglas de resolución de modo.

- Si el modo es `openspec`: Lee y sigue `skills/_shared/openspec-convention.md`. Recupera `proposal`, `spec`, `design` y `tasks` como dependencias. Guarda el reporte en `openspec/changes/{nombre-del-cambio}/review-report.md`.
- Si el modo es `none`: Devuelve el reporte de auditoría solo de forma inline. Nunca escribir archivos.

## Qué Hacer

### Paso 1: Recibir y Parsear Contexto

Recibir del orquestador el nombre del cambio a auditar. Determinar la ubicación de los artefactos:

```
cambio = {nombre-del-cambio}
artefactos = openspec/changes/{cambio}/
├── proposal.md      # Propuesta original
├── specs/           # Especificaciones (si existen)
├── design.md        # Decisiones de diseño
└── tasks.md         # Tareas completadas
```

### Paso 2: Leer Specifications

Leer los archivos de especificación para entender qué debe implementarse:

```
PARA CADA ARCHIVO en specs/:
├── Identificar requisitos (MUST, SHALL, SHOULD, MAY)
├── Identificar escenarios Given/When/Then
└── Documentar: qué funciones, estructuras, flujos deben existir
```

### Paso 3: Analizar Código Base (Estático)

Sin ejecutar código, analizar la estructura del código fuente:

```
PARA CADA ARCHIVO MODIFICADO/CREADO según tasks.md:
├── Identificar funciones y sus firmas
├── Identificar estructuras de datos
├── Identificar flujos de datos
├── Identificar dependencias externas
└── Documentar: qué existe realmente
```

### Paso 4: Comparar Contra Especificaciones

Cruzar lo que dice la especificación contra lo que existe en el código:

```
PARA CADA REQUISITO de specs/:
├── Buscar evidencia en el código base
├── Marcar: ✅ Implementado / ⚠️ Parcial / ❌ Faltante
└── Documentar desviaciones encontradas
```

### Paso 5: Generar Reporte de Auditoría

El reporte debe seguir este formato estructurado:

```markdown
# Reporte de Revisión: {nombre-del-cambio}

**Status**: {APROBADO | ADVERTENCIAS | BLOQUEADO}

## Hallazgos

### Hallazgo 1: {título}
- **Severidad**: CRITICAL | WARNING | SUGGESTION
- **Ubicación**: {archivo:rango}
- **Descripción**: {qué se encontró}
- **Recomendación**: {qué hacer}

---

### Completitud Estática
| Requisito       | Estado              | Notas                    |
|-----------------|---------------------|--------------------------|
| {Nombre req}    | ✅ Implementado      | {nota breve}             |
| {Nombre req}    | ⚠️ Parcial          | {qué falta}              |
| {Nombre req}    | ❌ Faltante          | {no implementado}       |

---

## Veredicto

{APROBADO / ADVERTENCIAS / BLOQUEADO}
{Resumen de una línea}
```

### Paso 6: Persistir el Reporte

- **openspec**: Guardar en `openspec/changes/{nombre-del-cambio}/review-report.md`
- **none**: Devolver el reporte inline

### Paso 7: Retornar Resultado

Devolver al orquestador el resultado estructurado:

```markdown
## Resultado de Auditoría

**Cambio**: {nombre-del-cambio}
**Status**: {APROBADO | ADVERTENCIAS | BLOQUEADO}

### Hallazgos
- {lista de hallazgos}

### Completitud
- Total de requisitos: {N}
- Implementados: {N}
- Parciales: {N}
- Faltantes: {N}

### Siguiente Paso Recomendado
{Dependiendo del status:
- APROBADO: Proceder con sdd-verify para validación dinámica
- ADVERTENCIAS: Revisar hallazgos y decidir si proceder
- BLOQUEADO: Corregir problemas antes de continuar}
```

## Reglas

- **NUNCA ejecutar código** — solo análisis estático
- **NUNCA emitir opiniones sobre estilo** — basarse exclusivamente en specs
- **NUNCA comparar contra diseño** — solo contra especificaciones
- Usar las palabras clave RFC 2119 (MUST, SHALL, SHOULD, MAY) para categorizar requisitos
- Ser objetivo — reportar lo que ES, no lo que debería ser
- En modo `openspec`, siempre guardar el reporte en `review-report.md`
- Devolver un envelope estructurado con: `status`, `executive_summary`, `artifacts`, `next_recommended` y `risks`
