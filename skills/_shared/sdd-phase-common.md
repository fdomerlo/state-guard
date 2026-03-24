# Contrato Común de Return Envelope — Fases SDD

## Propósito

Este archivo define el formato estándar de retorno que TODAS las skills de fase SDD DEBEN seguir al entregar resultados al orquestador. Centraliza el contrato para eliminar duplicación entre skills.

## Estructura del Return Envelope

Toda fase DEBE retornar un envelope estructurado con los siguientes campos:

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `status` | `ok` \| `warning` \| `error` | SÍ | Estado de la ejecución de la fase |
| `executive_summary` | String | SÍ | Resumen ejecutivo del resultado (máximo 3 líneas) |
| `artifacts` | Lista de rutas | SÍ | Archivos creados o modificados durante la ejecución |
| `next_recommended` | String | SÍ | Siguiente fase del DAG recomendada por esta fase |
| `risks` | Lista de strings | SÍ | Riesgos identificados durante la ejecución |
| `detailed_report` | String | NO | Reporte detallado de hallazgos, análisis o verificaciones extensas |

## Valores Permitidos para `status`

- `ok`: La fase se ejecutó correctamente, sin problemas
- `warning`: La fase se ejecutó pero con advertencias que el orquestador debe revisar
- `error`: La fase falló o no pudo completarse, requiere intervención

## Formato Markdown del Envelope

```markdown
## Resultado de la Fase

**status**: ok

### executive_summary
{Resumen conciso del resultado de la ejecución. Máximo 3 líneas.}

### artifacts
- `ruta/al/archivo1.md` — Creado
- `ruta/al/archivo2.md` — Modificado

### next_recommended
{sdd-spec | sdd-design | sdd-tasks | sdd-apply | sdd-verify | sdd-archive | Ninguna}

### risks
- {Riesgo identificado 1}
- {Riesgo identificado 2}

### detailed_report
{Opcional. Reporte extenso con análisis detallado, tablas de cumplimiento, etc.
Solo incluir si la fase produce un reporte que excede el resumen ejecutivo.}
```

## Ejemplo de Envelope Válido

```markdown
## Resultado de la Fase

**status**: ok

### executive_summary
Especificación delta creada para el dominio auth con 3 requisitos y 8 escenarios.

### artifacts
- `openspec/changes/agregar-auth/specs/auth/spec.md` — Creado

### next_recommended
sdd-design

### risks
- Ninguno identificado

### detailed_report
(No incluido — el executive_summary es suficiente)
```

## Referencia en Skills

Cada skill de fase incluye en su sección `## Reglas`:

> RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md`
