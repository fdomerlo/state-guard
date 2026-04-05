# Diseño: update-docs-architecture

## Enfoque Técnico

Estrategia de documentación incremental: agregar contenido nuevo sin reescribir secciones existentes. Cada archivo recibe actualizaciones focalizadas que cumplen los requisitos de la spec sin alterar la estructura actual.

## Decisiones de Arquitectura

| Decisión | Alternativas | Justificación |
|----------|--------------|---------------|
| Agregar checkpoint y rollback en sección "Flujos Avanzados" de MANUAL.md | Crear nueva sección dedicada | Mantiene coherencia orgánica con comandos existentes como sdd-fix, sdd-split |
| Insertar batching e inyección modular en sección "Conceptos Clave" de README.md | Actualizar diagrama de arquitectura | Los conceptos ya tienen presencia parcial; se expanden sin restructurar |
| Añadir directiva de specs delta en sección "State Machine" de AGENTS.md | Crear sección nueva de recuperación | Contexto de recuperación ya existe; specs delta es extensión natural |
| Actualizar tabla de comandos en README.md y AGENTS.md | Reescribir tablas | Agregar filas para checkpoint y rollback manteniendo formato existente |

## Contenido para MANUAL.md

### sdd-checkpoint (agregar después de sdd-split)

```markdown
### /sdd-checkpoint — Guardado de Sesión

El comando `/sdd-checkpoint` guarda un resumen del estado actual en el campo `session_summary` del `state.yaml`.

**Cuándo usarlo:**
- Antes de cerrar el IDE
- Para recuperar sesión tras reload
- Para documentar progreso manual

**Ejemplo de uso:**

```text
/sdd-checkpoint
```

Genera resumen de 5 líneas con fase actual, estado, progreso de tareas y siguiente comando recomendado.
```

### sdd-rollback (agregar después de sdd-fix)

```markdown
### /sdd-rollback — Reversión de Emergencia

El comando `/sdd-rollback` revierte completamente un cambio activo. **Botón de pánico** para recuperación de emergencia.

**⚠️ ADVERTENCIA:** Esta acción es destructiva:
- Elimina la carpeta `openspec/changes/{nombre}/`
- Restaura archivos modificados con `git checkout -- .`
- **Perderá todo trabajo no commiteado**

**Ejemplo de uso:**

```text
/sdd-rollback
```

El comando solicitará confirmación antes de ejecutar.
```

## Contenido para README.md

### Actualizar "Conceptos Clave"

Agregar después de "Skills como Código":

```markdown
### Batching de Tareas

El orquestador agrupa múltiples tareas related en una sola invocation para reducir overhead de contexto. Disminuye consumo de tokens en implementaciones extensas.

### Inyección Modular de Contexto

El orquestador carga contexto específico por tarea, no global. Cada skill recibe solo la información necesaria, optimizando la ventana de contexto del modelo.
```

### Actualizar tabla de comandos

Agregar filas:

```markdown
| `/sdd-checkpoint` | Guarda estado de sesión en state.yaml para recuperación | Skill Directa |
| `/sdd-rollback` | Revierte cambio activo (botón de pánico) | Skill Directa |
```

## Contenido para AGENTS.md

### Actualizar "Recuperación de Estado"

Agregar después de punto 3:

```markdown
4. Sub-agentes leen specs delta únicamente de `openspec/changes/{nombre}/specs/` — nunca de `openspec/specs/` para evitar contaminación de contexto.
```

### Actualizar tabla de comandos

Agregar filas existentes de README + agregar:

```markdown
| `/sdd-checkpoint` | Guardado de sesión | Skill Directa |
| `/sdd-rollback` | Reversión de emergencia | Skill Directa |
```

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| MANUAL.md | Modificar | Agregar documentación de checkpoint y rollback en sección "Flujos Avanzados" |
| README.md | Modificar | Agregar batching e inyección modular en "Conceptos Clave"; actualizar tabla de comandos |
| AGENTS.md | Modificar | Agregar directiva de specs delta; actualizar tabla de comandos y sección de recuperación |

## Preguntas Abiertas

- [ ] ¿El MANUAL.md debe incluir ejemplos adicionales de uso de checkpoint en flujos de trabajo reales?
- [ ] ¿Se debe documentar también `session_summary` como campo en la sección de State Machine del MANUAL?
