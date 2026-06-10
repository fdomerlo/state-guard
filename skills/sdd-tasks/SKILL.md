---
name: sdd-tasks
description: >
  Desglosa un cambio en tareas de implementación con numeración jerárquica.
  Disparador: Cuando el usuario ejecuta /sdd-tasks para crear el checklist de tareas.
license: MIT
metadata:
  author: ctrbts-steve
  version: "3.0"
---

# SDD-Tasks Skill

## Propósito

Skill responsable del **DESGLOSE EN TAREAS**. Toma las specs y el diseño, y produce un `tasks.md` con tareas concretas, atómicas y agrupadas por fase.

## Transacción

Seguí el protocolo de transacción definido en `skills/_shared/sdd-phase-common.md`:

- **BEGIN**: `txn_status: in_progress`, `txn_phase: tasks`
- **COMMIT**: `current_phase: tasks`, `lock_phase: apply`
- **ROLLBACK**: Si falla, restaurar `txn_status: failed` sin modificar phases

## Qué Hacer

### Paso 1: Leer Dependencias

Lee los artefactos del cambio:

1. **Specs delta** — `openspec/changes/{nombre-del-cambio}/specs/`
2. **Diseño** — `openspec/changes/{nombre-del-cambio}/design.md`

### Paso 2: Escribir tasks.md

Crea el archivo de tareas:

```text
openspec/changes/{nombre-del-cambio}/
├── proposal.md
├── specs/
├── design.md
└── tasks.md              ← Lo creas tú
```

#### Formato

```markdown
# Tareas: {Título del Cambio}

## Fase 1: {Nombre de la Fase} (ej: Infraestructura)

- [ ] 1.1 {Tarea atómica con ruta de archivo específica}
- [ ] 1.2 {Tarea atómica}

## Fase 2: {Nombre de la Fase} (ej: Implementación Core)

- [ ] 2.1 {Tarea atómica}
- [ ] 2.2 {Tarea atómica}
- [ ] 2.3 {Tarea atómica}

## Fase 3: {Nombre de la Fase} (ej: Testing)

- [ ] 3.1 {Tarea atómica}
```

### Paso 3: Persistir y Reportar

Ejecutá COMMIT en `state.yaml` y reportá al usuario:

```markdown
## Tareas Creadas

**Cambio**: {nombre-del-cambio}
**Total**: {N} tareas en {M} fases

### Resumen por Fase
| Fase | Tareas | Enfoque |
|------|--------|---------|
| {nombre} | {N} | {descripción breve} |

### Próximo Paso
Listo para implementar (`/sdd-apply`).
```

## Reglas

- Agrupar tareas por fase (infraestructura, implementación, testing)
- Usar numeración jerárquica (1.1, 1.2, etc.)
- Cada tarea DEBE ser lo suficientemente pequeña para implementarse en un solo archivo o módulo lógico — evitar "tareas monstruo"
- Cada tarea DEBE incluir rutas de archivos concretas cuando sea posible
- Las tareas deben ser completables en una sesión
- Referenciar escenarios de spec específicos como criterios de aceptación
- Aplicar cualquier `rules.tasks` de `openspec/config.yaml`
