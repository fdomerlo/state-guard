# Manual Técnico — Agentify SDD

Este manual cubre la arquitectura técnica, configuración y flujos avanzados del sistema Agentify SDD.

---

## Arquitectura DRY

### Compilación Dinámica del Orquestador

El orquestador SDD sigue el principio **DRY (Don't Repeat Yourself)** mediante un sistema de compilación dinámica. En lugar de un único archivo monolítico, el orquestador se assembla dinámicamente cargando las skills individuales en tiempo de ejecución.

### Mecanismo de Carga de Skills

El orquestador utiliza **Inyección dinámica de rutas**, lo que centraliza la carga de contratos base y dependencias en el orquestador en lugar de obligar a cada sub-agente a descubrirlas:

```
Orquestador (orquestador-core)
    │
    ├── Carga persistence-contract.md  → Resuelve el modo
    ├── Carga openspec-convention.md   → Prepara rutas de contexto
    │
    ├── Inyecta contexto y rutas → sdd-init
    ├── Inyecta contexto y rutas → sdd-explore
    ├── Inyecta contexto y rutas → sdd-propose
    ├── Inyecta contexto y rutas → sdd-spec
    ├── Inyecta contexto y rutas → sdd-design
    ├── Inyecta contexto y rutas → sdd-tasks
    ├── Inyecta contexto y rutas → sdd-apply
    ├── Inyecta contexto y rutas → sdd-verify
    └── Inyecta contexto y rutas → sdd-archive
```

### Herencia Inyectada

Las skills reciben sus convenciones dinámicamente desde el orquestador, quienes las lee de `skills/_shared/`:

| Archivo | Propósito |
|---------|-----------|
| `persistence-contract.md` | El orquestador lo lee para decidir el modo (`openspec` o `none`) y se lo instruye al sub-agente |
| `openspec-convention.md` | El orquestador arma las rutas y el contexto basado en esto y se las inyecta al sub-agente |
| `sdd-phase-common.md` | Define el contrato del Return Envelope para todas las fases SDD |

Puesto que el orquestador se encarga de proveer las rutas exactas, los sub-agentes solo tienen que utilizarlas, optimizando el uso de tokens y la consistencia.

### Presupuestos de Contexto

Cada skill de fase tiene un **presupuesto de tamaño** para proteger la ventana de contexto:

| Skill | Límite |
|-------|--------|
| `sdd-propose` | < 400 palabras |
| `sdd-spec` | < 650 palabras |
| `sdd-design` | < 800 palabras (usar tablas) |
| `sdd-tasks` | < 530 palabras |

Estos límites están definidos en la sección "Reglas" de cada skill y aseguran que la salida sea concisa y enfocada

### Skill Registry Dinámico

El sistema incluye un **registry dinámico de skills** que permite el descubrimiento automático de herramientas:

- Script bash POSIX en `skills/sdd-skill-registry/scan.sh`
- Índice generado en `.agentify/skill-registry.md`
- El orquestador lee este índice al iniciar para conocer las herramientas disponibles

El registry escanea exclusivamente el directorio `skills-addons/`, extrayendo nombre, descripción, trigger y ubicación de cada SKILL.md.

---

## State Machine ACID

### Estructura de state.yaml

El archivo `state.yaml` es el núcleo del sistema de estados. Se encuentra en:

```text
openspec/changes/{nombre-del-cambio}/state.yaml
```

**Schema:**

```yaml
change: {nombre-del-cambio}
started_at: "YYYY-MM-DDTHH:MM:SS"   # ISO 8601
last_updated: "YYYY-MM-DDTHH:MM:SS" # Actualizado en cada transición
current_phase: {fase-actual}        # última fase completada exitosamente
lock_phase: {fase-siguiente}        # única fase autorizada a ejecutarse ahora
status: {estado}                    # active | done | blocked
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
session_summary:                     # bloque YAML estructurado (ver openspec-convention.md)
  archivos_modificados:
    - ruta/al/archivo.ext            # máx 10 entradas
  estado_tareas: "{X}/{Y} — última: [{ID}] {descripción breve}"
  decisiones_clave:
    - "{decisión clave}"
  proxima_accion: "/sdd-{comando} {nombre-cambio}"
```

### Propiedades ACID

**Atomicidad (Atomicity):** Cada fase se completa completamente o no se completa. El orquestador solo actualiza `state.yaml` después de que una fase termina exitosamente.

**Consistencia (Consistency):** El schema de `state.yaml` está validado. Las transiciones siguen un orden estricto definido por el grafo de dependencias.

**Aislamiento (Isolation):** Cada cambio tiene su propio `state.yaml`. Múltiples cambios pueden ejecutarse en paralelo sin interferir entre sí.

**Durabilidad (Durability):** El estado persiste en el filesystem del proyecto. Sobrevive a recargas de sesión, compactaciones de contexto y reinicios del IDE.

### Prevención de Colisiones

El orquestador detecta cambios concurrentes mediante:

1. Lectura del `state.yaml` antes de cada transición de fase
2. Verificación de que la fase anterior está marcada como completada
3. Bloqueo de fases si el campo `status` es `blocked` (proporcionando un `blocked_reason`)

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

El comando `/sdd-ff` permite ejecutar secuencialmente y sin interrupción las fases de planificación (`propose`, `spec`, `design`, `tasks`).

**Cuándo usarlo:**

- Al iniciar un cambio nuevo bien definido donde no necesitas revisar manualmente cada artefacto intermedio.

**Anti-Batching y Persistencia:**
A diferencia de pedirle al LLM que "haga todas las fases de una vez" en un solo prompt (lo que corrompe el DAG), `/sdd-ff` es una meta-skill que itera paso a paso: verifica `lock_phase` antes de delegar cada fase, escribe el `state.yaml` por cada transición e invoca a la siguiente, respetando estrictamente el principio ACID y la regla de **anti-batching**.

### /sdd-checkpoint — Guardado de Estado de Alta Fidelidad

El comando `/sdd-checkpoint` genera un **bloque YAML estructurado** analizando proactivamente
`tasks.md` y `design.md` del cambio activo. El resultado se guarda en el campo `session_summary`
de `state.yaml`, posibilitando una recuperación de contexto eficiente (**Warm-Boot**).

El checkpoint es **agnóstico al DAG**: puede ejecutarse en cualquier momento sin modificar
`lock_phase`, `current_phase` ni el flujo de fases activo.

**Cuándo usarlo:**

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

### /sdd-fix — Reparación de Problemas

El comando `/sdd-fix` detecta y repara problemas comunes en el proyecto.

**Problemas que detecta:**

- Estado corrupto en `state.yaml`
- Archivos de spec faltantes
- Referencias rotas entre artefactos
- Convenciones violadas

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
        ├── state.yaml             ← Estado del DAG
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

Agentify SDD soporta múltiples herramientas de IA:

| Herramienta | Sub-agentes | Meta-comandos SDD |
|------------|:-----------:|:-----------------:|
| Claude Code | ✅ | ✅ |
| OpenCode | ✅ | ✅ |
| Gemini CLI | ✅ (ejecuta skills inline, por lo que la anti-compactación de contexto es limitada) | ✅ |
| Antigravity | ✅ | ✅ |

La instalación varía según la herramienta. Ejecuta `scripts/install.sh` y selecciona tu herramienta.

---

## Guía de Integración: Custom Skills

El framework SDD es extensible mediante "Custom Skills", permitiendo integrar sub-agentes especializados que no son partes nativas del orquestador SDD (por ejemplo, herramientas de desarrollo frontend, diseño o base de datos).

### 1. Ubicación Física

Toda nueva skill personalizada o de terceros debe residir en su propio directorio dentro de la carpeta `skills-addons/`.
**Regla:** Asegúrate de nombrar la carpeta de forma representativa (por ejemplo, `skills-addons/frontend-design/`).

### 2. Archivo de Contrato (`SKILL.md`)

Toda skill **DEBE** contener un archivo `SKILL.md` en su raíz. Este archivo actúa como el contrato de integración, las instrucciones directas (System Prompt) generadas para la herramienta y los metadatos necesarios. Sin este archivo, el skill no existirá.

### 3. Indexación (`skill-registry`)

Una vez añadida la skill, el desarrollador (o el sistema) debe registrarla para que pueda ser descubierta. Para esto, ejecuta la skill interna de indexación o corre su script directamente:

```bash
./skills/sdd-skill-registry/scan.sh
```

Esto escaneará las carpetas y actualizará el archivo de repositorio local en `.agentify/skill-registry.md`.

### 4. Uso por el Orquestador

El orquestador SDD lee `.agentify/skill-registry.md` al inicializar contexto y mapea cada entrada como una herramienta delegable válida. Al analizar la necesidad de un usuario, se basará en atributos declarados como `name` y `description` para delegar proactivamente el trabajo de sub-agentes no nativos.

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

1. Verificar que `state.yaml` existe
2. Revisar que el campo `status` sea `active`. Si es `blocked`, revisar `blocked_reason`.
3. Ejecutar `/sdd-fix` para reparación automática

### Los artefactos no persisten

1. Confirmar que el modo `openspec` está activo
2. Verificar que el directorio `openspec/` existe
3. Revisar permisos de escritura

### Conflictos entre cambios

1. Usar `/sdd-status` para ver todos los cambios activos
2. Archivar cambios completados antes de iniciar nuevos
3. No trabajar en el mismo cambio desde múltiples sesiones

---

*Manual técnico — Agentify SDD v1.0*
