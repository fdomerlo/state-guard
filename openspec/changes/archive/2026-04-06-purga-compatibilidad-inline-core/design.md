# Diseño: Purga de Compatibilidad con Editores Inline/Pasivos

## Enfoque Técnico

El cambio implementa una eliminación directa de soporte para el modo `none` en el contrato de persistencia. La estrategia consiste en modificar archivos de skills para eliminar menciones al modo `none`, reforjando `openspec` como único modo válido. Este enfoque es coherente con la decisión arquitectónica ya tomada en `orchestrator-core.md` que fuerza `artifact_store.mode: openspec`.

## Decisiones de Arquitectura

### Decisión: Modo de Persistencia Único

**Elección**: Solo `openspec` como modo válido.
**Alternativas consideradas**: Mantener soporte dual (`openspec` + `none`).
**Justificación**: El framework es Agent-First/CLI-First. Todos los agentes compatibles (Claude Code, OpenCode, Gemini CLI, Antigravity) tienen capacidades nativas de I/O. El modo `none` era un fallback para editores inline que ya no son compatibles.

### Decisión: Eliminación vs. Deprecación

**Elección**: Eliminación directa de menciones al modo `none`.
**Alternativas consideradas**: Deprecar con warnings, mantener por compatibilidad.
**Justificación**: Las menciones son pocas y están localizadas. No hay usuarios-dependencia del modo `none`. La eliminación directa reduce código defensivo y confusión.

### Decisión: Verificación Activa de Menciones

**Elección**: `sdd-review` debe detectar menciones obsoletas al modo `none`.
**Alternativas consideradas**: Solo eliminar, dejar que queden como documentación histórica.
**Justificación**: La spec indica que las skills deben identificar y sugerir eliminación de referencias obsoletas.

## Flujo de Datos

```
Orquestador (mode: openspec)
    │
    ├─► persistence-contract.md (lee solo openspec)
    ├─► skill-registry/SKILL.md (lee sin fallback inline)
    ├─► sdd-verify/SKILL.md    (lee sin modo none)
    ├─► sdd-review/SKILL.md    (lee sin modo none)
    ├─► sdd-fix/SKILL.md       (lee sin modo none)
    └─► sdd-split/SKILL.md     (lee sin modo none)
```

## Cambios de Archivos

| Archivo                                  | Acción    | Descripción                                            |
|------------------------------------------|-----------|--------------------------------------------------------|
| `skills/_shared/persistence-contract.md` | Modificar | Eliminar modo `none`, forzar `openspec` único modo    |
| `skills/skill-registry/SKILL.md`         | Modificar | Eliminar fallback para editores inline (líneas 43-45) |
| `skills/sdd-verify/SKILL.md`             | Modificar | Eliminar menciones a `none` (líneas 22, 27, 170)      |
| `skills/sdd-review/SKILL.md`             | Modificar | Eliminar menciones a `none` (líneas 24, 31, 120)      |
| `skills/sdd-fix/SKILL.md`                | Modificar | Eliminar menciones a `none` (líneas 21, 29)            |
| `skills/sdd-split/SKILL.md`              | Modificar | Eliminar menciones a `none` (líneas 20, 27, 132)      |

## Interfaces / Contratos

### persistence-contract.md (modificado)

```markdown
## Resolución de Modo

El orquestador pasa `artifact_store.mode: openspec` (único modo válido).

Resolución por defecto:
1. Si el directorio `openspec/` existe → usar `openspec`.
2. Si NO existe → fallar con error indicando que se requiere inicialización.
```

### skill-registry (modificado)

```markdown
## Fallback (ELIMINADO)

[Sección eliminada completamente]
```

## Estrategia de Testing

| Capa        | Qué Testear                            | Enfoque                              |
|-------------|----------------------------------------|--------------------------------------|
| Estático    | Menciones a modo `none` eliminadas     | `grep -r "modo.*none\|none.*modo" skills/` |
| Integración | sdd-review detecta menciones residuales | Ejecutar sdd-review post-cambio     |
| Manual      | Ejecución de skills afectadas          | Verificar que sdd-verify funciona   |

## Migración / Despliegue

No se requiere migración. Los archivos se modifican directamente en el repositorio.

## Preguntas Abiertas

- [ ] ¿Verificar si `orchestrator-core.md` requiere modificaciones adicionales?
- [ ] ¿Crear documento de capacidades requeridas (specs indican que sí)?
