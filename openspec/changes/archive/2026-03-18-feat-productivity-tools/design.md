# Diseño: feat-productivity-tools

## Enfoque Técnico

Este cambio introduce dos nuevas skills SDD para cerrar brechas en el flujo de trabajo: una skill de auditoría estática (`sdd-review`) que complementa la verificación dinámica existente (`sdd-verify`), y una skill de división de propuestas (`sdd-split`) para manejar proposals monolíticas. El enfoque principal es la reutilización inteligente de patrones existentes — `sdd-review` toma la estructura de `sdd-verify` pero elimina la ejecución de código, mientras que `sdd-split` se construye desde cero con heurísticas simples de partición.

## Decisiones de Arquitectura

### Decisión 1: Estructura de sdd-review (Auditoría Estática)

**Elección**: Follow-the-leader de sdd-verify sin ejecución de tests.
**Alternativas consideradas**: Crear una estructura completamente nueva, integrar review dentro de sdd-verify como modo.
**Justificación**: El usuario quiere diferenciación clara entre review (estático) y verify (dinámico). Copiar la estructura de sdd-verify garantiza consistencia en el formato de salida y reduce la carga cognitiva para usuarios que ya conocen verify.

### Decisión 2: Formato de Salida de sdd-review

**Elección**: Reporte estructurado con tres categorías: APROBADO, ADVERTENCIAS, BLOQUEADO.
**Alternativas consideradas**: Formato libre estilo auditoría,评分 numérica (0-100).
**Justificación**: Las tres categorías son足够 simples para decisiones rápidas pero significativas. Un formato libre sería difícil de parsear para el orquestador. Una评分 numérica es subjetiva y no comunica la naturaleza de los problemas.

### Decisión 3: Algoritmo de sdd-split

**Elección**: Heurística basada en secciones y dependencias lógica de la proposal.
**Alternativas consideradas**:LLM-powered splitting, tamaño de archivo (líneas), número de objetivos.
**Justificación**: Una propuesta bien escrita tiene secciones claras (Objetivos, Áreas Afectadas, Riesgos). La heurística simple de detectar这些 secciones y sus interdependencias es más confiable que un tamaño arbitrario. Un LLM adicional sería sobre-engineering para este caso de uso.

### Decisión 4: Formato de Salida de sdd-split

**Elección**: Lista de sub-cambios con comandos `/sdd-new` sugeridos y justificación breve.
**Alternativas consideradas**: JSON estructurado, diagrama de dependencias, narrativa descriptiva.
**Justificación**: El formato de lista con comandos es directamente accionable por el orquestador. JSON sería útil para consumo programático pero no es el caso de uso principal. Un diagrama requiere rendering adicional.

### Decisión 5: Ubicación de los Nuevos Comandos en orchestrator-core

**Elección**: Añadir `/sdd-review` y `/sdd-split` después de `/sdd-fix` en la sección de comandos.
**Alternativas consideradas**: Sección separada al final, agrupar bajo "Herramientas adicionales".
**Justificación**: Mantener la sección existente de comandos facilita la referencia. El usuario ya sabe dónde buscar la lista de comandos.

## Flujo de Datos

```
                    ┌─────────────────────────────────────────┐
                    │           Orquestador SDD              │
                    │                                         │
    ┌──────────────▼──────────────┐                          │
    │  Usuario ejecuta /sdd-review │                          │
    └──────────────┬──────────────┘                          │
                   │                                           │
                   ▼                                           │
    ┌─────────────────────────────────────────┐              │
    │         sdd-review (Skill)               │              │
    │                                         │              │
    │  1. Lee proposal.md y specs/            │              │
    │  2. Analiza código base (estático)      │              │
    │  3. Compara estructura vs requisitos    │              │
    │  4. Genera reporte en 3 categorías       │              │
    └─────────────────────────────────────────┘              │
                   │                                           │
                   ▼                                           │
    ┌─────────────────────────────────────────┐              │
    │     review-report.md (OpenSpec)         │              │
    └─────────────────────────────────────────┘              │


    ┌─────────────────────────────────────────────────────────┐
    │           Usuario ejecuta /sdd-split                    │
    └─────────────────────────────────────────────────────────┘
                         │
                         ▼
    ┌─────────────────────────────────────────┐
    │         sdd-split (Skill)               │
    │                                         │
    │  1. Lee proposal.md                    │
    │  2. Identifica objetivos y dependencias │
    │  3. Agrupa por cohesión lógica          │
    │  4. Genera plan de partición             │
    └─────────────────────────────────────────┘
                         │
                         ▼
    ┌─────────────────────────────────────────┐
    │   split-plan.md (plan de sub-cambios)   │
    │   └── Comandos /sdd-new sugeridos       │
    └─────────────────────────────────────────┘
```

## Cambios de Archivos

| Archivo                                 | Acción   | Descripción                                                                 |
|------------------------------------------|----------|-----------------------------------------------------------------------------|
| `skills/sdd-review/SKILL.md`             | Crear    | Skill de auditoría estática contra especificaciones                         |
| `skills/sdd-split/SKILL.md`              | Crear    | Skill de división de proposals en sub-cambios                              |
| `skills/_shared/orchestrator-core.md`   | Modificar| Añadir `/sdd-review` y `/sdd-split` a la sección de comandos              |
| `scripts/install.sh`                     | Modificar| Actualizar mensajes de contador de "10 skills" a "12 skills"             |
| `scripts/install_test.sh`                | Modificar| Actualizar EXPECTED_SKILLS de 10 a 12 elementos y verificaciones         |

## Interfaces / Contratos

### Contrato: Salida de sdd-review

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
| {Nombre req}    | ❌ Faltante          | {no implementado}        |

---

### Veredicto
{APROBADO / ADVERTENCIAS / BLOQUEADO}
{Resumen de una línea}
```

### Contrato: Salida de sdd-split

```markdown
# Plan de Partición: {nombre-del-cambio}

## Sub-cambios Sugeridos

### Sub-cambio 1: {nombre-sub-cambio-1}
- **Objetivos abarcados**: {lista de objetivos originales}
- **Justificación**: {por qué se agrupan juntos}
- **Comando sugerido**: `/sdd-new {nombre-sub-cambio-1}`

### Sub-cambio 2: {nombre-sub-cambio-2}
- **Objetivos abarcados**: {lista de objetivos originales}
- **Justificación**: {por qué se agrupan juntos}
- **Comando sugerido**: `/sdd-new {nombre-sub-cambio-2}`

---

## Recomendaciones de Secuencia

{Orden sugerido para ejecutar los sub-cambios, considerando dependencias}

## Notas

{Preocupaciones o advertencias sobre la partición}
```

## Estrategia de Testing

| Capa        | Qué Testear                                              | Enfoque                                                      |
|-------------|----------------------------------------------------------|--------------------------------------------------------------|
| Unitaria    | sdd-review: categorización correcta de hallazgos        | Verificar que cada tipo de desviación se categoriza bien   |
| Unitaria    | sdd-split: partición de objetivos relacionados         | Probar con proposals de prueba con diferentes estructuras  |
| Integración | install.sh: conteo de 12 skills                         | Ejecutar scripts y verificar salida                         |
| Integración | install_test.sh: pasan con EXPECTED_SKILLS=12          | Ejecutar suite completa                                     |
| Sistema     | orquestador-core.md: nuevos comandos registrados        | Verificar presencia en lista de comandos                   |

### Plan de Testing Específico

1. **Test de sdd-review**: Crear una proposal de prueba con desviaciones，故意 y verificar que el reporte las captura correctamente.
2. **Test de sdd-split**: Usar una proposal existente compleja (si la hay) o crear una de prueba con 5+ objetivos y verificar que la partición es razonable.
3. **Test de scripts**: Ejecutar `scripts/install_test.sh` y verificar que pasa con el nuevo conteo.
4. **Test de idempotencia**: Ejecutar install.sh dos veces y verificar que las skills no se duplican.

## Migración / Despliegue

No se requiere migración. Los cambios son puramente incrementales:

1. Se añaden dos nuevos archivos de skill
2. Se modifica el archivo de core del orquestador
3. Se actualizan los scripts de instalación

No hay datos existentes que migrar, no hay feature flags, y el cambio es transparente para cualquier change existente. Los nuevos comandos simplemente aparecerán disponibles para nuevos cambios.

## Preguntas Abiertas

- [ ] ¿Cuál es el tamaño máximo de proposal que sdd-split puede manejar eficientemente? ¿Deberíamos añadir un límite o warning?
- [ ] ¿Debe sdd-review ejecutarse siempre antes de sdd-verify, o son independientes?
- [ ] ¿El plan de split debe considerar el orden de dependencias entre sub-cambios automáticamente?