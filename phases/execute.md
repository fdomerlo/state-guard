
# EXECUTE Phase

## Propósito

La fase **EXECUTE** absorbe el trabajo de desglose en tareas (`tasks`) e implementación (`apply`). Es la única fase que produce cambios en el código fuente del proyecto.

**Prerequisito:** `lock_phase == execute` — esto solo ocurre después de que el humano aprobó el lock de PLAN.

## Qué Hacer

### Paso 1: Leer el Contexto

Antes de escribir CUALQUIER código:

1. **Plan** — leer `.state-guard/changes/{change-name}/objective.md` y `design.md`
2. **Specs delta** — leer todos los archivos en `.state-guard/changes/{change-name}/specs/`
3. **Código existente** — leer los archivos afectados según la tabla de archivos del plan
4. **Convenciones** — leer `config.yaml` si existe

**REGLA CRÍTICA:** Solo leer specs delta del cambio actual. NUNCA leer `specs/` completo del proyecto.

### Paso 2: Generar tasks.md

A partir del plan, produce el desglose de tareas atómicas:

```
.state-guard/changes/{change-name}/
├── objective.md         ← (ya existe)
├── design.md            ← (ya existe)
├── specs/               ← (ya existe)
└── tasks.md             ← Lo creas vos
```

Formato:

```markdown
# Tareas: {Título del Cambio}

## Fase 1: {Nombre} (ej: Infraestructura)

- [ ] [T001] {Tarea atómica con ruta de archivo específica}
- [ ] [T002] {Tarea atómica}

## Fase 2: {Nombre} (ej: Implementación Core)

- [ ] [T003] {Tarea atómica}

## Fase 3: {Nombre} (ej: Testing)

- [ ] [T004] {Tarea atómica}
```

Reglas del desglose:
- Cada tarea = un archivo o módulo lógico (sin "tareas monstruo")
- IDs de tarea en formato `[Txxx]` — son usados por el CLI (`mark_task_completed`)
- Agrupar por fase: infraestructura → implementación → testing
- Referenciar escenarios de spec como criterios de aceptación

### Paso 3: Detectar Modo de Implementación

```text
Detectar modo TDD (en orden de prioridad):
├── .state-guard/config.yaml → rules.apply.tdd (true/false)
├── Skills instaladas del usuario (ej: tdd/SKILL.md existe)
├── Patrones de test existentes en el código base
└── Por defecto: modo estándar (código primero)
```

### Paso 4: Implementar Tareas

#### Modo TDD (RED → GREEN → REFACTOR)

Para cada tarea:
1. **ENTENDER**: Leer descripción + escenarios de spec relevantes
2. **RED**: Escribir test que describe el comportamiento esperado → confirmar que FALLA
3. **GREEN**: Implementar el mínimo código para que el test pase → confirmar que PASA
4. **REFACTOR**: Limpiar sin cambiar comportamiento → confirmar que SIGUE PASANDO
5. Marcar tarea `[x]` en `tasks.md`

> CRÍTICO: Ejecutar tests con una terminal real. PROHIBIDO simular o inferir resultados.

Detectar test runner desde `phases/_shared/test-runner-detection.md`.

#### Modo Estándar

Para cada tarea:
1. Leer descripción y escenarios de spec
2. Leer patrones de código existentes
3. Escribir el código
4. Marcar tarea `[x]` en `tasks.md`

#### Tamaño del lote

Por defecto: 3 tareas por invocación. Ajustar según contexto disponible.
Si hay más de 10 tareas pendientes Y el host soporta sub-agentes → delegar según `memory-guard.md §Delegación`.

### Paso 5: Verificar progreso con el middleware

```bash
python3 scripts/state_manager.py check-completion --change {change-name}
```

Reporta `total`, `completed`, `all_complete`, `last_completed_id`.

### Paso 6: Reportar

```markdown
## Progreso de Implementación

**Cambio**: {change-name}
**Modo**: {TDD | Estándar}

### Tareas Completadas
- [x] [T001] {descripción}
- [x] [T002] {descripción}

### Archivos Modificados
| Archivo | Acción | Qué se hizo |
|---------|--------|-------------|
| `ruta/archivo.ext` | Creado/Modificado | {descripción} |

### Desviaciones del Plan
{Lista o "Ninguna — la implementación coincide con el plan."}

### Problemas Encontrados
{Lista o "Ninguno."}

### Estado
{N}/{total} tareas completas. {Listo para VERIFY / Siguiente lote pendiente}
```

## Reglas

- SIEMPRE leer las specs antes de implementar — son los criterios de aceptación
- SIEMPRE seguir las decisiones de arquitectura del plan — no improvisar
- SIEMPRE ajustarse a los patrones de código existentes
- Marcar las tareas `[x]` en `tasks.md` al completarlas
- Si el plan es incorrecto/incompleto, ANOTARLO — no desviarse en silencio
- Si una tarea está bloqueada, DETENERSE y reportar
- Aplicar cualquier `rules.apply` de `.state-guard/config.yaml`

> Transacción: BEGIN antes de este contenido, COMMIT al terminar. Ver `_shared/phase-common.md`.
