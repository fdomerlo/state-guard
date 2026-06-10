# Manual Técnico — Agentify SDD

Este manual cubre la arquitectura técnica, configuración y flujos avanzados del sistema Agentify SDD.

---

## Arquitectura Memory Guard

### Contrato Unificado

El Memory Guard es el contrato central que el agente carga al iniciar una sesión SDD. En lugar de un orquestador que despacha comandos CLI a sub-agentes, el agente ejecuta fases directamente (inline) protegido por un protocolo de persistencia transaccional.

```
Memory Guard (memory-guard.md)
    │
    ├── Carga transaction-protocol.md → Protocolo BEGIN/COMMIT/ROLLBACK
    ├── Carga capabilities.md         → Detecta capacidades del host
    ├── Carga persistence-contract.md → Resuelve el modo de persistencia
    ├── Carga openspec-convention.md  → Prepara rutas y schema
    │
    ├── Ejecuta inline → sdd-explore   (carga SKILL.md como instrucciones)
    ├── Ejecuta inline → sdd-propose
    ├── Ejecuta inline → sdd-spec
    ├── Ejecuta inline → sdd-design
    ├── Ejecuta inline → sdd-tasks
    ├── Ejecuta inline → sdd-apply     (delega si > 10 tareas y host soporta)
    ├── Ejecuta inline → sdd-verify
    └── Ejecuta inline → sdd-archive
```

### Módulos del Memory Guard

Los contratos compartidos residen en `skills/_shared/`:

| Archivo | Propósito |
|---------|-----------|
| `memory-guard.md` | Contrato unificado: identidad del agente, ejecución de fases, delegación inteligente, recovery |
| `transaction-protocol.md` | Protocolo de transacciones: ciclo BEGIN/COMMIT/ROLLBACK, campos txn_* en state.yaml, auto-checkpoint |
| `capabilities.md` | Detección de capacidades del agente host y regla de delegación inteligente |
| `context-injection.md` | Dependencias de contexto por fase y secuencia de ejecución |
| `persistence-contract.md` | Contrato de persistencia: inline vs delegada, protocolo de comunicación |
| `openspec-convention.md` | Convención de filesystem, schema state.yaml v2, tabla de transiciones de lock_phase |
| `sdd-phase-common.md` | Protocolo de transacción común a todas las skills de fase |
| `test-runner-detection.md` | Pseudocódigo para la detección automática del test runner del proyecto |

### Ejecución Inline vs Delegada

El Memory Guard ejecuta fases **inline por defecto**: carga el SKILL.md correspondiente y sigue sus instrucciones como propias. Solo delega a un sub-agente real cuando:

1. La fase es `apply` con más de 10 tareas pendientes, **Y**
2. El agente host soporta sub-agentes reales (Claude Code, OpenCode, Antigravity)

En ejecución delegada, el sub-agente persiste sus artefactos en disco pero **nunca** escribe en `state.yaml`. El Memory Guard es el único responsable del COMMIT transaccional.

### Skill Registry Dinámico

El sistema incluye un **registry dinámico de skills** que permite el descubrimiento automático de herramientas:

- Script bash POSIX en `skills/sdd-skill-registry/scan.sh`
- Índice generado en `.agentify/skill-registry.md`
- El Memory Guard lee este índice al iniciar para conocer las herramientas disponibles

El registry escanea los directorios global (`$HOME/.skills-custom`) y local (`./skills-custom`), extrayendo nombre, descripción, trigger y ubicación de cada SKILL.md.

---

## State Machine Transaccional

### Estructura de state.yaml (v2)

El archivo `state.yaml` es el núcleo del sistema de estados. Se encuentra en:

```text
openspec/changes/{nombre-del-cambio}/state.yaml
```

**Schema (v2):**

```yaml
schema_version: 2                    # Versión del schema (para migración automática)
change: {nombre-del-cambio}
started_at: "YYYY-MM-DDTHH:MM:SS"   # ISO 8601
last_updated: "YYYY-MM-DDTHH:MM:SS" # Actualizado en cada COMMIT de transacción
current_phase: {fase-actual}         # Última fase completada exitosamente
lock_phase: {fase-siguiente}         # Única fase autorizada a ejecutarse ahora
status: {estado}                     # active | done | blocked
completed_phases:
  - explore
  - propose
  # fases completadas...
pending_phases:
  - tasks
  - apply
  - verify
  - archive
blocked: false
blocked_reason: null

# --- Campos transaccionales (v2) ---
txn_status: idle                     # idle | in_progress | failed
txn_phase: null                      # Fase en ejecución, o null si idle
txn_started_at: null                 # ISO 8601 de inicio de transacción

session_summary:                     # Bloque YAML estructurado (máx 500 tokens)
  archivos_modificados:
    - ruta/al/archivo.ext            # Máx 10 entradas
  estado_tareas: "{X}/{Y} — última: [{ID}] {descripción breve}"
  decisiones_clave:
    - "{decisión clave}"
  proxima_accion: "/sdd-{comando} {nombre-cambio}"
```

### Protocolo de Transacciones

Cada fase SDD se ejecuta como una transacción atómica:

```text
IDLE → BEGIN → EXECUTE → COMMIT (éxito) o ROLLBACK (fallo) → IDLE
```

| Paso | Qué ocurre |
|------|-----------|
| **BEGIN** | Escribe `txn_status: in_progress`, `txn_phase: {fase}` en state.yaml |
| **EXECUTE** | Ejecuta la fase, persiste artefactos en disco |
| **COMMIT** | Actualiza `current_phase`, `lock_phase`, `completed_phases`, `pending_phases`, `txn_status: idle` |
| **ROLLBACK** | Si falla: `txn_status: failed`, sin modificar phases |

**Anti-batching por protocolo**: Cada fase requiere su propio ciclo BEGIN → COMMIT. `txn_phase` es un valor escalar, no una lista, lo que hace imposible ejecutar múltiples fases en una sola transacción.

### Recovery Automático

Al detectar un `state.yaml` con `txn_status: in_progress` (crash durante ejecución):

1. Verifica si el artefacto de `txn_phase` se persistió en disco
2. Si **SÍ** → ejecuta COMMIT (la fase se completó pero el estado no se persistió)
3. Si **NO** → ejecuta ROLLBACK (restaura `txn_status: idle` sin modificar phases)

### Propiedades ACID

**Atomicidad (Atomicity):** Cada fase se completa completamente o no se completa. El COMMIT solo ocurre después de que el artefacto se persistió en disco exitosamente.

**Consistencia (Consistency):** El schema de `state.yaml` v2 está validado. Las transiciones siguen un orden estricto definido por el grafo de dependencias y los campos transaccionales garantizan detección de estado intermedio.

**Aislamiento (Isolation):** Cada cambio tiene su propio `state.yaml`. Múltiples cambios pueden ejecutarse en paralelo sin interferir entre sí.

**Durabilidad (Durability):** El estado persiste en el filesystem del proyecto. Sobrevive a recargas de sesión, compactaciones de contexto y reinicios del IDE. Los campos transaccionales permiten recovery automático.

### Prevención de Colisiones

El Memory Guard detecta cambios concurrentes mediante:

1. Lectura del `state.yaml` antes de cada transacción
2. Verificación del campo `lock_phase` (única fase autorizada)
3. Bloqueo de fases si `status` es `blocked`
4. Detección de transacciones incompletas (`txn_status: in_progress`)

### Migración v1 → v2

Los `state.yaml` sin campo `schema_version` se consideran v1. La migración es automática:

1. Agregar `schema_version: 2`
2. Agregar `txn_status: idle`, `txn_phase: null`, `txn_started_at: null`
3. Si falta `lock_phase`, inferirlo desde artefactos (lógica de `sdd-fix`)

La migración la ejecuta `sdd-fix` o el Recovery Protocol al encontrar un state.yaml sin `schema_version`.

---

## Configuración con config.yaml

### Ubicación

```text
openspec/config.yaml
```

### Glosario de Configuraciones

| Campo | Descripción |
|-------|-------------|
| `schema` | Versión del schema SDD. Valor actual: `spec-driven` |
| `context` | Descripción del stack tecnológico del proyecto |
| `rules` | Reglas específicas por fase (proposal, specs, design, tasks, apply, verify, archive) |
| `glossary.terms` | (Opcional) Definiciones de términos del dominio |

### Convenciones de Nomenclatura

El sistema usa **kebab-case** para todas las configuraciones:

```yaml
rules:
  apply:
    - Usar rutas en kebab-case para nombres de cambios
    - Los nombres de archivos de skills también usan kebab-case
```

### Scripts de Mantenimiento y Desarrollo

El directorio `scripts/` incluye herramientas adicionales de soporte:
- `cleanup.sh`: Desinstala stubs y limpia los datos temporales del framework en los diferentes agentes de IA. Soporta el flag `--hard` para purgar históricos.
- `install_test.sh`: Suite de tests unitarios y de integración para validar el correcto funcionamiento del script de instalación en diferentes entornos.

### Parámetro test_command

Define el comando para ejecutar tests durante la fase de verificación:

```yaml
rules:
  verify:
    test_command: "npm test"  # o "pytest", "cargo test", etc.
```

Si no se define, la verificación reportará que los tests no pudieron ejecutarse automáticamente.

---

## Flujos Avanzados

### /sdd-split — División de Proposals

El comando `/sdd-split` analiza una proposal monolítica y la divide en sub-cambios manejables.

**Cuándo usarlo:**

- La proposal abarca múltiples dominios
- El alcance es demasiado grande para una sola iteración
- Hay dependencias entre funcionalidades que deberían implementarse por separado

**Cómo funciona:**

1. Lee la proposal original
2. Analiza los requisitos y alcance
3. Identifica puntos de división naturales
4. Genera múltiples proposals más pequeñas

**Ejemplo de uso:**

```text
/sdd-split mi-cambio-grande
```

### /sdd-ff — Avance Rápido (Fast-Forward)

El comando `/sdd-ff` permite ejecutar secuencialmente las fases de planificación (`propose`, `spec`, `design`, `tasks`).

**Cuándo usarlo:**

- Al iniciar un cambio nuevo bien definido donde no necesitas revisar manualmente cada artefacto intermedio.

**Anti-Batching Transaccional:**
A diferencia de pedirle al LLM que "haga todas las fases de una vez" en un solo prompt (lo que corrompe el DAG), `/sdd-ff` ejecuta 4 transacciones secuenciales independientes. Cada fase tiene su propio ciclo BEGIN → COMMIT, y si el agente crashea entre la transacción 2 y la 3, el Recovery Protocol continúa automáticamente desde donde quedó.

### /sdd-checkpoint — Guardado de Estado

El comando `/sdd-checkpoint` genera un **bloque YAML estructurado** analizando proactivamente
`tasks.md` y `design.md` del cambio activo. El resultado se guarda en el campo `session_summary`
de `state.yaml`, posibilitando una recuperación de contexto eficiente (**Warm-Boot**).

**Dos modos de operación:**

1. **Automático** (post-COMMIT): El protocolo de transacción genera un `session_summary` compacto después de cada fase. Esto es suficiente para la mayoría de los casos.
2. **Manual** (`/sdd-checkpoint`): Genera un checkpoint de alta fidelidad con análisis proactivo de todos los artefactos. Útil antes de operaciones riesgosas o para refrescar el contexto.

El checkpoint es **agnóstico al DAG**: puede ejecutarse en cualquier momento sin modificar
`lock_phase`, `current_phase` ni el flujo de fases activo.

**Cuándo usarlo manualmente:**

- Antes de realizar operaciones riesgosas
- Al interrumpir un lote de `sdd-apply` para preservar el estado
- Al restablecer el contexto de trabajo forzando al LLM a recargar el panorama

**Ejemplo de uso:**

```text
/sdd-checkpoint
```

### /sdd-archive — Cierre de Cambios

El comando `/sdd-archive` cierra un cambio: fusiona las specs delta en las specs principales y mueve el cambio al archivo.

**Flujo Obligatorio:**

1. Ejecutar `/sdd-verify` y asegurar que todo es correcto.
2. Realizar un `git commit` de todos los cambios de código y especificaciones.
3. Ejecutar `/sdd-archive`.

El comando realizará el **Paso 0** inhibitorio evaluando reportes previos, abortando en seco la operación si detecta resoluciones `CRITICAL`. Verificará el árbol de trabajo git e interrumpirá si detecta diferencias con cambios sin commitear.

### /sdd-review — Auditoría Estática

El comando `/sdd-review` compara el código implementado contra las especificaciones sin ejecutar tests.

**Cuándo usarlo:**

- Antes de un merge a main
- Como revisión previa a la verificación completa
- Para identificar desviaciones de diseño

**Qué analiza:**

- Cumplimiento de requisitos de specs
- Consistencia con decisiones de diseño
- Patrones de código aplicados correctamente

**Ejemplo de uso:**

```text
/sdd-review mi-cambio
```

### /sdd-fix — Reparación y Migración

El comando `/sdd-fix` detecta y repara problemas comunes en el proyecto.

**Problemas que detecta y repara:**

- Estado corrupto en `state.yaml`
- Archivos de spec faltantes
- Campo `lock_phase` ausente (inferencia desde artefactos)
- State.yaml v1 sin campos transaccionales (migración automática a v2)
- Transacciones incompletas (`txn_status: in_progress` o `failed`)

**Ejemplo de uso:**

```text
/sdd-fix
```

### /sdd-rollback — Revertir un Cambio

El comando `/sdd-rollback` purga la carpeta del cambio y restaura los archivos modificados desde git.

**⚠️ ADVERTENCIA: Pérdida de Trabajo**

Este comando **elimina permanentemente** todo el trabajo no commiteado en el directorio del cambio. Antes de ejecutar:

1. Confirma que no hay cambios sin guardar
2. Ejecuta `git status` para verificar el estado
3. Solo usar cuando el cambio no tiene solución o debe reiniciarse completamente

**Ejemplo de uso:**

```text
/sdd-rollback mi-cambio
```

---

## Estructura de Archivos OpenSpec

```text
openspec/
├── config.yaml                    ← Configuración del proyecto
├── specs/                         ← Specs actuales (fuente de verdad)
│   └── {dominio}/
│       └── spec.md
└── changes/                       ← Cambios activos y archivados
    ├── archive/
    │   └── YYYY-MM-DD-{change}/
    └── {change-name}/
        ├── state.yaml             ← Estado del DAG (v2 con campos txn_*)
        ├── proposal.md            ← Propuesta
        ├── exploration.md         ← Investigación inicial (opcional)
        ├── specs/                 ← Specs delta
        │   └── {dominio}/
        │       └── spec.md
        ├── design.md              ← Diseño técnico
        ├── tasks.md               ← Checklist de tareas
        ├── verify-report.md       ← Reporte de verificación
        └── (otros artefactos)

.agentify/                         ← Metadatos del agente
├── skill-registry.md             ← Índice dinámico de skills
└── (otros archivos de config)
```

---

## Convenciones de Estilo

### Idioma

Todos los artefactos deben escribirse en **español (castellano)**. Esto incluye:

- Propuestas y especificaciones
- Diseños y tareas
- Descripciones de código

### Formato de Specs

Las specs usan el formato **GIVEN/WHEN/THEN**:

```markdown
#### Escenario: Nombre del escenario
- GIVEN precondición
- WHEN acción
- THEN resultado esperado
- AND resultado adicional
```

### Palabras Clave RFC 2119

| Palabra | Significado |
|---------|-------------|
| **MUST / SHALL** | Requisito obligatorio |
| **SHOULD** | Recomendado, puede haber excepciones |
| **MAY** | Opcional |

---

## Integración con Herramientas

Agentify SDD soporta múltiples agentes de IA. El Memory Guard se adapta automáticamente a las capacidades de cada host:

| Herramienta | Ejecución Inline | Sub-agentes | Delegación Inteligente |
|------------|:----------------:|:-----------:|:---------------------:|
| Claude Code | ✅ | ✅ | Apply pesados |
| OpenCode | ✅ | ✅ | Apply pesados |
| Gemini CLI | ✅ | ❌ | Siempre inline |
| Antigravity | ✅ | ✅ | Apply pesados |

La instalación varía según la herramienta. Ejecuta `scripts/install.sh` y selecciona tu herramienta. Cada integración es un stub mínimo que carga `memory-guard.md` como contrato central.

---

## Guía de Integración: Custom Skills

El framework SDD es extensible mediante "Custom Skills", permitiendo integrar herramientas especializadas que no son parte nativa del framework (por ejemplo, herramientas de desarrollo frontend, diseño o base de datos).

### 1. Ubicación Física

Toda nueva skill personalizada o de terceros debe residir en su propio directorio siguiendo la convención de alcance dual:
- **Global:** `$HOME/.skills-custom/` para herramientas transversales a todos los proyectos.
- **Local:** `./skills-custom/` para herramientas específicas del proyecto en curso.

**Regla:** Asegúrate de nombrar la carpeta de forma representativa (por ejemplo, `./skills-custom/frontend-design/`).

### 2. Archivo de Contrato (`SKILL.md`)

Toda skill **DEBE** contener un archivo `SKILL.md` en su raíz. Este archivo actúa como el contrato de integración, las instrucciones directas que el agente carga inline cuando necesita ejecutar la skill. Sin este archivo, la skill no existirá.

### 3. Indexación (`skill-registry`)

Una vez añadida la skill, el desarrollador (o el sistema) debe registrarla para que pueda ser descubierta. Para esto, ejecuta el comando:

```text
/sdd-skill-registry
```

Esto escaneará las rutas global y local, y actualizará el archivo de repositorio local en `.agentify/skill-registry.md`.

### 4. Uso por el Memory Guard

El Memory Guard lee `.agentify/skill-registry.md` al inicializar contexto y mapea cada entrada como una herramienta ejecutable. Al analizar la necesidad de un usuario, se basará en atributos declarados como `name` y `description` para cargar proactivamente la skill relevante.

### Ejemplo Boilerplate (`frontend-design/SKILL.md`)

```markdown
---
name: frontend-design
description: Agente especialista en diseño UI/UX. Crea componentes web hermosos y listos para producción evitando la estética genérica por defecto de IA.
trigger: Cuando el usuario quiere crear un sitio web, un nuevo panel y componente frontend interactivo.
---

# Funcionalidad Principal
Actúas como un desarrollador y diseñador de componentes Vue/React/HTML...

# Reglas
1. Siempre sigue fielmente los colores y el design system nativo.
2. Evita usar frameworks pesados si no se solicita.
```

---

## Resolución de Problemas

### El estado no avanza

1. Verificar que `state.yaml` existe y tiene `schema_version: 2`
2. Revisar que el campo `status` sea `active`. Si es `blocked`, revisar `blocked_reason`.
3. Verificar `txn_status`: si es `in_progress`, hay una transacción incompleta; si es `failed`, hubo un error en la última fase.
4. Ejecutar `/sdd-fix` para reparación automática y migración

### Los artefactos no persisten

1. Confirmar que el modo `openspec` está activo
2. Verificar que el directorio `openspec/` existe
3. Revisar permisos de escritura

### Transacción incompleta detectada

1. El Recovery Protocol intenta resolver automáticamente al ejecutar `/sdd-continue`
2. Si persiste, ejecutar `/sdd-fix` para reparación manual
3. Como último recurso, editar manualmente `state.yaml`: setear `txn_status: idle`, `txn_phase: null`

### Conflictos entre cambios

1. Usar `/sdd-status` para ver todos los cambios activos (incluye columna de estado transaccional)
2. Archivar cambios completados antes de iniciar nuevos
3. No trabajar en el mismo cambio desde múltiples sesiones

---

*Manual técnico — Agentify SDD v2.0 — Arquitectura Memory Guard*
