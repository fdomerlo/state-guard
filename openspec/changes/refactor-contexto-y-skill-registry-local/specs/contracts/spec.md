# Especificación de Contratos Compartidos y Presupuestos de Contexto

## Propósito

Centralizar el contrato del Return Envelope y los presupuestos de tamaño de contexto para todas las skills de fase SDD, eliminando duplicación y protegiendo la ventana de contexto de sub-agentes.

## Requisitos AGREGADOS

### Requisito: Archivo Común de Return Envelope

El sistema DEBE crear `skills/_shared/sdd-phase-common.md` que defina el contrato del Return Envelope en ESPAÑOL.

El archivo DEBE contener la definición de los campos: `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`, y `detailed_report` (opcional).

#### Escenario: Archivo Común Existe con Campos Correctos

- GIVEN que se ejecuta la implementación de este cambio
- WHEN se verifica la existencia de `skills/_shared/sdd-phase-common.md`
- THEN el archivo DEBE existir
- AND el archivo DEBE definir `status` con valores permitidos: `ok`, `warning`, `error`
- AND el archivo DEBE definir `executive_summary` como string descriptivo
- AND el archivo DEBE definir `artifacts` como lista de rutas de archivos creados/modificados
- AND el archivo DEBE definir `next_recommended` como siguiente fase del DAG
- AND el archivo DEBE definir `risks` como lista de riesgos identificados
- AND el archivo DEBE definir `detailed_report` como campo OPCIONAL (MAY contener reporte extenso)

#### Escenario: Formato del Envelope en el Archivo Común

- GIVEN que `skills/_shared/sdd-phase-common.md` existe
- WHEN un sub-agente lee el contrato
- THEN DEBE encontrar la estructura del envelope como plantilla Markdown
- AND los campos DEBEN estar documentados con ejemplos de valores válidos
- AND la documentación DEBE estar íntegramente en ESPAÑOL

### Requisito: Referencia al Contrato Común en Skills de Fase

Cada una de las 13 skills de fase DEBE reemplazar su definición local del Return Envelope por una referencia a `skills/_shared/sdd-phase-common.md`.

Las skills afectadas son: `sdd-explore`, `sdd-propose`, `sdd-spec`, `sdd-design`, `sdd-tasks`, `sdd-apply`, `sdd-verify`, `sdd-review`, `sdd-split`, `sdd-status`, `sdd-archive`, `sdd-init`, `sdd-changelog`.

#### Escenario: Skill de Fase Referencia al Archivo Común

- GIVEN una skill de fase cualquiera (ej: `sdd-propose/SKILL.md`)
- WHEN se lee la sección de Reglas
- THEN DEBE contener la instrucción: "requiere y sigue el formato de `skills/_shared/sdd-phase-common.md`"
- AND NO DEBE contener la definición local completa del envelope (campos listados inline)

#### Escenario: Consistencia de Envelope Unificado

- GIVEN que las 13 skills fueron modificadas
- WHEN se compara la definición de envelope entre skills
- THEN todas DEBEN referenciar el mismo archivo común
- AND `sdd-review` y `sdd-split` DEBEN adoptar `detailed_report` como opcional (unificación con variante mayoritaria)

### Requisito: Presupuesto de Tamaño en Skills de Fase Críticos

Los 4 skills de fase con mayor complejidad DEBEN tener una sección `### Presupuesto de Tamaño` inyectada dentro de `## Reglas`.

| Skill | Límite | Justificación |
|-------|--------|---------------|
| `sdd-propose` | < 400 palabras | Propuesta concisa |
| `sdd-spec` | < 650 palabras | Specs compactas con tablas |
| `sdd-design` | < 800 palabras | Arquitectura en tablas |
| `sdd-tasks` | < 530 palabras | Desglose directo |

#### Escenario: Presupuesto Inyectado Correctamente

- GIVEN la skill `sdd-spec/SKILL.md` tras la modificación
- WHEN se lee la sección `## Reglas`
- THEN DEBE contener una sub-sección `### Presupuesto de Tamaño`
- AND la sub-sección DEBE especificar el límite de palabras (< 650 para sdd-spec)
- AND la sub-sección DEBE estar ubicada inmediatamente antes de la referencia al envelope común

#### Escenario: Presupuesto con Formato de Tabla para sdd-design

- GIVEN la skill `sdd-design/SKILL.md` tras la modificación
- WHEN se lee la sección `### Presupuesto de Tamaño`
- THEN DEBE incluir la instrucción de usar arquitectura en tablas para comprimir
- AND el límite DEBE ser < 800 palabras

#### Escenario: Skill Sin Presupuesto No Es Modificada

- GIVEN una skill de fase NO objetivo (ej: `sdd-explore`)
- WHEN se lee la sección `## Reglas`
- THEN NO DEBE contener sub-sección `### Presupuesto de Tamaño`
- AND DEBE contener la referencia al envelope común

## Requisitos ELIMINADOS

### Requisito: Definición Local del Return Envelope (13 skills)

(Motivo: Duplicación DRY — se centraliza en `sdd-phase-common.md`)

Cada skill de fase DEBE eliminar su bloque local de definición del Return Envelope (las secciones tipo "Devolver un envelope estructurado con...").

#### Escenario: Definición Local Eliminada

- GIVEN una skill de fase modificada (ej: `sdd-archive/SKILL.md`)
- WHEN se busca el patrón "Devolver un envelope estructurado con"
- THEN NO DEBE aparecer con la lista inline de campos
- AND DEBE aparecer la referencia al archivo común en su lugar

## Requisitos MODIFICADOS

### Requisito: Sección de Reglas en Skills de Fase

**Nueva descripción:**
La sección `## Reglas` de cada skill de fase DEBE contener (1) la referencia a `skills/_shared/sdd-phase-common.md`, (2) las reglas específicas de la skill, y (3) presupuesto de tamaño si aplica.

(Anteriormente: La sección contenía la definición inline del envelope duplicada en cada skill)

#### Escenario: Reglas Estructuradas Correctamente

- GIVEN cualquier skill de fase modificada
- WHEN se lee la sección `## Reglas`
- THEN DEBE contener la referencia al envelope común como primera o última regla relacionada con resultados
- AND DEBE mantener todas las reglas específicas de la skill intactas
