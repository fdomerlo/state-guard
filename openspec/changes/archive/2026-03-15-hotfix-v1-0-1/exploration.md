# Exploración: Hotfix v1.0.1 — Parches de Calidad Post-Lanzamiento

**Fecha de exploración:** 15 de marzo de 2026  
**Cambio:** hotfix-v1-0-1  
**Tipo:** Exploración (fase 1/6 del flujo SDD)

---

## 1. Análisis del Archivo `sdd-spec/SKILL.md`

### 1.1 Estructura Actual

El archivo tiene **165 líneas** y está organizado en las siguientes secciones principales:

| Sección | Líneas | Propósito |
|---------|--------|-----------|
| Header YAML | 1-10 | Metadatos de la skill (nombre, versión, autor) |
| Propósito | 12-14 | Descripción de la responsabilidad del sub-agente |
| Qué Recibís | 16-21 | Inputs que recibe del orquestador |
| Execution and Persistence Contract | 22-28 | Reglas de lectura/escritura según modo |
| Qué Hacer | 29-142 | Pasos detallados (4 pasos) + Formato |
| Reglas | 144-155 | Restricciones y normativas |
| Referencia Rápida | 157-165 | Tabla de palabras clave RFC 2119 |

### 1.2 Análisis de la Sección de Escenarios

El formato de escenarios está definido en las **líneas 64-95** dentro del "Formato de Spec Delta":

```markdown
#### Escenario: {Escenario del camino feliz}

- GIVEN {precondición}
- WHEN {acción}
- THEN {resultado esperado}
- AND {resultado adicional, si aplica}
```

**Observación clave:** Las palabras clave ya están estandarizadas como `GIVEN`, `WHEN`, `THEN`, `AND` en mayúsculas (líneas 66-69).

### 1.3 Ubicación Identificada para la Regla BDD

**Opción A (Recomendada):** Agregar como regla en la sección **Reglas** (líneas 144-155)

La regla existente en la línea 146 dice:
> "SIEMPRE usar el formato Given/When/Then para escenarios"

El lugar ideal sería agregar una nueva regla justo después o como expansión de la regla 146, haciendo énfasis en la inmutabilidad del vocabulario Gherkin.

**Opción B (Alternativa):** Agregar en el formato de spec delta, cerca de las líneas 66-69

Esta opción es menos visible pero más contextual.

### 1.4 texts de Seguridad

- **Bajo riesgo:** Modificar un archivo de documentación/guía no afecta la ejecución directa del código
- **Impacto:** Afectará el comportamiento de futuros sub-agentes que ejecuten `sdd-spec`
- **Reversibilidad:** Alta — el cambio es simplemente agregar texto instructivo

---

## 2. Análisis del Archivo `orchestrator-core.md`

### 2.1 Estructura Actual

El archivo tiene **142 líneas** y está organizado en:

| Sección | Líneas | Propósito |
|---------|--------|-----------|
| Header | 1-3 | Identificación del orquestador |
| Regla de Idioma | 5-8 | Restricción de idioma |
| Reglas de Delegación | 11-32 | Normas de coordinación |
| Flujo de Trabajo SDD | 35-42 | Política de almacenamiento |
| Comandos de Orquestación | 43-57 | Lista de comandos y nota de meta-comandos |
| Grafo de Dependencias | 59-66 | Diagrama visual de fases |
| Gestión de Estado | 68-106 | Protocolo de state.yaml |
| Protocolo de Contexto | 107-122 | Reglas de lectura/escritura |
| Contrato de Resultados | 124-126 | Estructura de respuesta |
| Estado y Convenciones | 128-133 | Archivos de referencia |
| Regla de Recuperación | 135-142 | Protocolo de recovery |

### 2.2 Análisis de la Sección de Comandos

La sección **Comandos de Orquestación** (líneas 43-57) contiene:

```markdown
- `/sdd-init` → ejecuta `sdd-init` (inicializa el proyecto forzando el modo openspec).
- `/sdd-explore <topic>` → ejecuta `sdd-explore`.
- `/sdd-new <change>` → ejecuta `sdd-explore` y luego `sdd-propose`.
- `/sdd-continue [change]` → crea el siguiente artefacto faltante en la cadena de dependencias.
- `/sdd-ff [change]` → ejecuta `sdd-propose` → `sdd-spec` → `sdd-design` → `sdd-tasks`.
- `/sdd-apply [change]` → ejecuta `sdd-apply` en lotes.
- `/sdd-status` → ejecuta `sdd-status` (muestra el estado de todos los cambios activos).
- `/sdd-verify [change]` → ejecuta `sdd-verify`.
- `/sdd-review [change]` → ejecuta `sdd-review` (auditoría estática de código contra specs).
- `/sdd-split [change]` → ejecuta `sdd-split` (divide proposals monolíticas en sub-cambios).
- `/sdd-archive [change]` → ejecuta `sdd-archive`.
- `/sdd-changelog` → ejecuta `sdd-changelog` (genera CHANGELOG.md desde archive).
*(Nota: `/sdd-new`, `/sdd-continue`, y `/sdd-ff` son meta-comandos que TÚ manejas orquestando fases; no son skills directos).*
```

**Observación clave:** Ya existe una nota sobre meta-comandos en la línea 57, pero es breve y no cubre todos los comandos de flujo.

### 2.3 Análisis de "Próximo Paso"

El concepto de "Próximo Paso" aparece en:

1. **Línea 31:** "Sugiere SDD: 'Esto es ideal para usar `/sdd-new {nombre-feature}`'"
2. **Línea 122:** "Delegá → recibís el resultado → escribí `state.yaml` → mostrás resumen al usuario"
3. **En las skills delegadas:** Cada skill tiene su propio "Próximo Paso" al final

No hay una sección统一的 de "Próximo Paso" en el orquestador core — cada skill delegable devuelve su propia recomendación.

### 2.4 Ubicación Identificada para la Directiva de Meta-Comandos

**Ubicación exacta:** Líneas 56-57, expandiendo la nota existente

La nota actual dice:
> *(Nota: `/sdd-new`, `/sdd-continue`, y `/sdd-ff` son meta-comandos que TÚ manejas orquestando fases; no son skills directos).*

Debería expandirse para incluir:
1. La directiva explícita sobre cómo處理ar los meta-comandos
2. La instrucción clara de que el usuario debe tipear el comando manualmente

**Sobre "Próximo Paso":** No hay una sección centralizada para esto en orchestrator-core. La recomendación sería agregar una nota al final de la sección de Comandos (después de la línea 57) sobre cómo el usuario debe interacturar.

### 2.5 texts de Seguridad

- **Bajo riesgo:** Es un archivo de configuración/orientación
- **Impacto:** Cambiará cómo el orquestador interpreta los comandos del usuario
- **Reversibilidad:** Alta — solo se agrega documentación instructiva

---

## 3. Resumen de Modificaciones Recomendadas

### 3.1 Archivo 1: `skills/sdd-spec/SKILL.md`

| Qué agregar | Dónde | Cómo |
|------------|-------|------|
| Regla ESTRICTA de sintaxis Gherkin | Sección **Reglas** (línea ~147, después de "SIEMPRE usar el formato Given/When/Then") | Agregar nueva regla sobre prohibición de palabras inventadas |

**Texto sugerido para agregar:**

```markdown
- **Sintaxis Gherkin/BDD Inmutable:** Los escenarios DEBEN usar exclusivamente las palabras clave estándar: `Given`, `When`, `Then`, `And`, `But`. Está estrictamente PROHIBIDO inventar, abreviar o combinar palabras (ej. NUNCA usar 'GAND').
```

### 3.2 Archivo 2: `skills/_shared/orchestrator-core.md`

| Qué agregar | Dónde | Cómo |
|------------|-------|------|
| Directiva de meta-comandos vs skills | Sección **Comandos de Orquestación**, líneas 56-57 | Expandir la nota existente con directiva explícita |
| Instructivo de "Próximo Paso" para el usuario | Sección **Comandos de Orquestación**, después de la nota de meta-comandos | Agregar nota sobre cómo el usuario debe interacturar |

**Texto sugerido para agregar (después de línea 57):**

```markdown
**META-COMANDOS VS SKILLS:** Los comandos de flujo como `/sdd-continue`, `/sdd-ff`, `/sdd-new` y `/sdd-fix` son instrucciones de texto para ti. NO son skills físicas ni tools. Cuando el usuario los escriba, NO intentes ejecutar una tool con ese nombre. Debes evaluar el estado actual internamente y luego delegar a la skill real correspondiente (ej. `sdd-spec`, `sdd-design`).

**Cómo avanzar de fase:** Cuando indiques un "Próximo Paso" al usuario, usa el formato: "Escribe en el chat `/sdd-continue [change]` para avanzar a la siguiente fase", dejando claro que el usuario debe tipear el comando manualmente si su IDE no lo autocompleta.
```

---

## 4. Riesgos Identificados

| Riesgo | Nivel | Mitigación |
|--------|-------|------------|
| **Confusión por duplicación de reglas** | Bajo | La regla BDD es complementaria a la existente "Given/When/Then" — la refuerza con más detalle |
| **Impacto en sub-agentes existentes** | Bajo | Los sub-agentes ya usan Given/When/Then — esta regla clarifica la restricción sin cambiar comportamiento |
| **Orquestador malinterpreta meta-comandos** | Medio | La directiva es clara: son "instrucciones de texto", no tools. El cambio alivia la confusión, no la crea |
| **Usuario no entiende cómo interacturar** | Bajo | La nota de "Próximo Paso" clarifica que debe tipear manualmente |

---

## 5. Recomendación Final

**Enfoque:** Implementar ambos parches siguiendo las ubicaciones identificadas.

**Prioridad:** 
1. Primero el parche BDD en `sdd-spec/SKILL.md` (más crítico para calidad de specs)
2. Segundo el parche de meta-comandos en `orchestrator-core.md` (mayor impacto en UX)

**Validación sugerida:**
- Después de aplicar los cambios, ejecutar una exploración de prueba para verificar que las reglas se aplican correctamente
- Verificar que el orquestador responde correctamente a los comandos de flujo

---

## 6. Próximo Paso

Esta exploración está lista para la fase de propuesta (`sdd-propose`). El análisis identifica claramente las ubicaciones y los textos sugeridos para ambos parches.

**Siguiente fase recomendada:** `/sdd-propose` para formalizar la intención del hotfix.
