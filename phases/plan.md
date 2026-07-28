
# PLAN Phase

## Propósito

La fase **PLAN** absorbe el trabajo de exploración, propuesta, especificación y diseño técnico en un único bloque de planificación. Produce un `plan.md` consolidado y lo somete a un **gate de revisión humana obligatorio** antes de emitir el lock que habilita EXECUTE.

**Sub-flujo interno (no salteable):**

```
draft  →  gate (revisión humana)  →  lock
```

El lock es el evento que cierra PLAN y habilita EXECUTE. **El modelo NO puede emitir el lock sin confirmación explícita del humano.**

## Qué Hacer

### Sub-paso 1: DRAFT — Generar el plan

Investiga, analiza y produce el borrador del plan. Este paso es ejecutado por el LLM.

#### 1.1 Auto-descubrimiento del stack

Antes de analizar, entiende el entorno físico:

```bash
ls package.json pyproject.toml composer.json go.mod Cargo.toml docker-compose.yml 2>/dev/null
```

Lee los manifiestos encontrados para identificar stack, framework y herramientas clave.

#### 1.2 Exploración y análisis

- ¿Es nueva funcionalidad? ¿Bug? ¿Refactor?
- Lee el código relevante: puntos de entrada, módulos afectados, tests existentes
- Compara enfoques si hay alternativas

#### 1.3 Propuesta

- Intención clara: qué problema resuelve y por qué
- Alcance: dentro/fuera
- Enfoque técnico de alto nivel
- Áreas afectadas (tabla con rutas)
- Riesgos y plan de rollback
- Criterios de éxito (checkboxes medibles)

#### 1.4 Especificación (si el cambio lo requiere)

Para cada dominio afectado, escribe specs delta en:

```
.state-guard/changes/{change-name}/specs/{dominio}/spec.md
```

Usa formato Given/When/Then y palabras clave RFC 2119 (MUST, SHALL, SHOULD, MAY).
Si no existen specs del dominio, escribe una spec completa (no delta).

#### 1.5 Diseño técnico

Lee el código real afectado antes de diseñar. Documenta:

- Decisiones de arquitectura con justificación (la tabla Elección/Alternativas/Justificación)
- Flujo de datos (ASCII o Mermaid)
- Tabla de archivos: Archivo | Acción | Descripción
- Interfaces / contratos
- Estrategia de testing
- Preguntas abiertas (bloqueantes marcadas con `[!]`)

#### 1.6 Persistir el DRAFT

Crea los artefactos en disco **antes** de pasar al gate:

```
.state-guard/changes/{change-name}/
├── plan.md              ← propuesta + diseño consolidados
└── specs/
    └── {dominio}/
        └── spec.md      ← specs delta o completas
```

El formato de `plan.md`:

```markdown
# Plan: {Título del Cambio}

## Intención
{Qué problema resuelve y por qué}

## Alcance
### Dentro del Alcance
- {entregable}
### Fuera del Alcance
- {diferido}

## Enfoque Técnico
{Estrategia general, referencia al análisis de exploración}

## Áreas Afectadas
| Área | Impacto | Descripción |
|------|---------|-------------|
| `ruta/` | Nuevo/Modificado/Eliminado | {qué cambia} |

## Decisiones de Arquitectura
### Decisión: {Título}
**Elección**: {qué elegimos}
**Alternativas**: {qué descartamos}
**Justificación**: {por qué}

## Flujo de Datos
{diagrama ASCII o Mermaid}

## Archivos Afectados
| Archivo | Acción | Descripción |
|---------|--------|-------------|

## Estrategia de Testing
| Capa | Qué testear | Enfoque |
|------|-------------|---------|

## Riesgos
| Riesgo | Probabilidad | Mitigación |
|--------|-------------|-----------|

## Plan de Rollback
{Cómo revertir si algo sale mal}

## Criterios de Éxito
- [ ] {resultado medible 1}
- [ ] {resultado medible 2}

## Preguntas Abiertas
- [ ] {pregunta no resuelta — si bloquea, marcá con [!]}
```

---

### Sub-paso 2: GATE — Revisión humana obligatoria

**CRÍTICO: El modelo NO puede avanzar a Sub-paso 3 por su cuenta. El gate es una barrera que solo el humano puede cruzar.**

Una vez generado el draft, el modelo DEBE:

1. Presentar el `plan.md` al usuario con un resumen ejecutivo
2. Listar explícitamente las decisiones de arquitectura y las preguntas abiertas
3. Ejecutar el comando de preparación del gate out-of-band:
   ```bash
   python3 scripts/sg.py plan-approve --change {change-name}
   ```
4. Emitir el siguiente bloque textual y esperar a que el humano confirme en su propia terminal:

```
═══════════════════════════════════════════════════════════
 GATE DE REVISIÓN — PLAN listo para tu aprobación
═══════════════════════════════════════════════════════════

Revisá el plan.md. El código de confirmación fue mostrado
en tu terminal (/dev/tty) y su hash guardado en ~/.state-guard-gate/{change-name}.token

Para APROBAR y proceder a EXECUTE, ejecutá en tu propia terminal:
  sg plan-confirm --change {change-name} --token <CÓDIGO>

Si deseás solicitar cambios o cancelar, indícalo por este chat.
═══════════════════════════════════════════════════════════
```

El modelo DEBE permanecer en estado de espera. Si el usuario no ejecuta `plan-confirm`, el estado permanece en PLAN y cualquier intento de `commit` será rechazado por el middleware con `EXIT_GATE_REQUIRED (5)`.

---

### Sub-paso 3: LOCK — Emitir el lock y cerrar PLAN

Una vez que el usuario confirma en su terminal ejecutando `sg plan-confirm --change {change-name} --token <CÓDIGO>` (lo cual consume el archivo out-of-band y registra la aprobación en `state.ini[Gate]`):

1. Ejecutar COMMIT en el middleware:
   ```bash
   python3 scripts/state_manager.py commit --change {change-name} --next-phase execute
   ```
2. Reportar al usuario que PLAN está bloqueado y EXECUTE está habilitado.

El COMMIT:
- Avanza `lock_phase` a `execute`
- Libera el lock de fase
- Genera auto-checkpoint del estado del DAG

---

## Reglas

- El LLM NUNCA puede emitir el lock sin respuesta aprobatoria explícita del humano
- Si el humano pide revisiones, re-generar únicamente las secciones indicadas, no el plan completo
- Las preguntas abiertas bloqueantes (`[!]`) DEBEN resolverse antes de pasar al gate
- SIEMPRE leer el código real — nunca asumir sobre el código base
- El único archivo de propuesta es `plan.md`; NO crear `proposal.md`, `design.md` separados bajo el nuevo esquema
- Aplicar cualquier `rules.plan` de `.state-guard/config.yaml`

> Transacción: BEGIN antes de Sub-paso 1, COMMIT en Sub-paso 3 (solo tras aprobación humana). Ver `_shared/phase-common.md`.
