# Manual Técnico — Agentify SDD

Este manual cubre la arquitectura técnica, configuración y flujos avanzados del sistema Agentify SDD.

---

## Arquitectura DRY

### Compilación Dinámica del Orquestador

El orquestador SDD sigue el principio **DRY (Don't Repeat Yourself)** mediante un sistema de compilación dinámica. En lugar de un único archivo monolítico, el orquestador se assembla dinámicamente cargando las skills individuales en tiempo de ejecución.

### Mecanismo de Carga de Skills

```
Orquestador (orquestador-core)
    │
    ├── Carga persistence-contract.md  → Reglas de resolución de modo
    ├── Carga openspec-convention.md   → Convenciones de archivos
    │
    ├── Carga sdd-init/SKILL.md        → Skill de inicialización
    ├── Carga sdd-explore/SKILL.md     → Skill de exploración
    ├── Carga sdd-propose/SKILL.md     → Skill de propuesta
    ├── Carga sdd-spec/SKILL.md        → Skill de especificación
    ├── Carga sdd-design/SKILL.md       → Skill de diseño
    ├── Carga sdd-tasks/SKILL.md        → Skill de planificación
    ├── Carga sdd-apply/SKILL.md        → Skill de implementación
    ├── Carga sdd-verify/SKILL.md       → Skill de verificación
    └── Carga sdd-archive/SKILL.md      → Skill de archivado
```

### Herencia de Skills

Las skills comparten convenciones a través de archivos en `skills/_shared/`:

| Archivo | Propósito |
|---------|-----------|
| `persistence-contract.md` | Define cómo se comportan los modos `openspec` y `none` |
| `openspec-convention.md` | Define rutas de archivos, estructura de directorios y schema de `state.yaml` |

Cada skill referencia estos archivos compartidos, evitando duplicación de reglas y asegurando consistencia.

---

## State Machine ACID

### Estructura de state.yaml

El archivo `state.yaml` es el núcleo del sistema de estados. Se encuentra en:

```
openspec/changes/{nombre-del-cambio}/state.yaml
```

**Schema:**

```yaml
change: {nombre-del-cambio}
started_at: "YYYY-MM-DDTHH:MM:SS"   # ISO 8601
last_updated: "YYYY-MM-DDTHH:MM:SS" # Actualizado en cada transición
phase: {fase-actual}                 # explore|propose|spec|design|tasks|apply|verify|archive
completed_phases:
  - explore
  - propose
  # fases completadas...
pending_phases:
  - tasks
  - apply
  - verify
  - archive
blocked_reason: null                  # null o descripción del bloqueo
```

### Propiedades ACID

**Atomicidad:** Cada fase se completa completamente o no se completa. El orquestador solo actualiza `state.yaml` después de que una fase termina exitosamente.

**Consistencia:** El schema de `state.yaml` está validado. Las transiciones siguen un orden estricto definido por el grafo de dependencias.

**Aislamiento (Isolation):** Cada cambio tiene su propio `state.yaml`. Múltiples cambios pueden ejecutarse en paralelo sin interferir entre sí.

**Durabilidad:** El estado persiste en el filesystem del proyecto. Sobrevive a recargas de sesión, compactaciones de contexto y reinicios del IDE.

### Prevención de Colisiones

El orquestador detecta cambios concurrentes mediante:
1. Lectura del `state.yaml` antes de cada transición de fase
2. Verificación de que la fase anterior está marcada como completada
3. Bloqueo de fases si `blocked_reason` no es null

---

## Configuración con config.yaml

### Ubicación

```
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

Si no se define, la verificación报告会 que los tests no pudieron ejecutarse automáticamente.

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
```
/sdd-split mi-cambio-grande
```

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
```
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
```
/sdd-fix
```

---

## Estructura de Archivos OpenSpec

```
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
        ├── specs/                 ← Specs delta
        │   └── {dominio}/
        │       └── spec.md
        ├── design.md              ← Diseño técnico
        ├── tasks.md               ← Checklist de tareas
        └── verify-report.md       ← Reporte de verificación
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

| Herramienta | Sub-agentes | Skills Inline |
|-------------|:-----------:|:-------------:|
| Claude Code | ✅ | ✅ |
| OpenCode | ✅ | ✅ |
| Antigravity | ✅ | ✅ |
| Gemini CLI | — | ✅ |
| Codex | — | ✅ |
| VS Code | — | ✅ |
| Cursor | — | ✅ |

La instalación varía según la herramienta. Ejecuta `scripts/install.sh` y selecciona tu herramienta.

---

## Resolución de Problemas

### El estado no avanza

1. Verificar que `state.yaml` existe
2. Revisar que `blocked_reason` sea null
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
