# Propuesta: Purga de Compatibilidad con Editores Inline/Pasivos

## Intención

Erradicar del núcleo del proyecto cualquier instrucción, modo o fallback orientado a editores inline/pasivos (VS Code, Cursor, Codex). El proyecto Agentify SDD fue diseñado originalmente para soportar dos paradigmas (agentes CLI con I/O nativo + editores inline), pero esta dualidad genera confusión y código defensivo innecesario. Asumimos que el 100% de los sub-agentes tienen acceso a herramientas nativas (filesystem, ejecución de comandos).

## Alcance

### Dentro del Alcance
- Eliminar el modo `none` del contrato de persistencia (`persistence-contract.md`)
- Purgar menciones a modo `none` en todos los SKILL.md de fases SDD
- Eliminar la carpeta de instrucciones inline en `skills/` si existe
- Reforzar el uso de herramientas (Tools) en `sdd-apply` y `sdd-verify`
- Actualizar `skill-registry` para quitar fallback de editores inline

### Fuera del Alcance
- Modificar agentes externos (Claude Code, OpenCode, Gemini CLI)
- Crear documentación sobre editores soportados
- Cambiar la estructura de carpetas `openspec/`

## Enfoque

Eliminación directa:移除 referencias al modo `none` y ediciones inline de archivos clave. El archivo `orchestrator-core.md` ya fuerza `artifact_store.mode: openspec`, por lo que el cambio es coherente con la dirección existente. Los archivos afectados requieren cambios menores (eliminación de menciones, no refactorización).

## Áreas Afectadas

| Área | Impacto | Descripción |
|------|---------|-------------|
| `skills/_shared/persistence-contract.md` | Modificado | Eliminar modo `none` como opción válida |
| `skills/_shared/orchestrator-core.md` | Modificado | Reforzar openspec como único modo |
| `skills/sdd-verify/SKILL.md` | Modificado | Eliminar menciones a modo `none` |
| `skills/sdd-review/SKILL.md` | Modificado | Eliminar menciones a modo `none` |
| `skills/sdd-fix/SKILL.md` | Modificado | Eliminar menciones a modo `none` |
| `skills/sdd-split/SKILL.md` | Modificado | Eliminar menciones a modo `none` |
| `skills/skill-registry/SKILL.md` | Modificado | Eliminar fallback para editores inline |
| `skills/` (raíz) | Eliminado | Instrucciones inline si existen |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|--------|--------------|-------------|
| Usuario con editor sin I/O no pueda usar SDD | Baja | Los agentes CLI modernos todos tienen acceso a disco; el cambio alinea con realidad actual |
| Romper alguna referencia accidental | Baja | Auditoría con sdd-review post-implementación |

## Plan de Rollback

1. Restaurar archivos modificados desde Git (`git checkout -- skills/`)
2. Eliminar cualquier archivo nuevo creado
3. El estado del DAG permanece intacto en `state.yaml`

## Dependencias

- Ninguna. El cambio es autocontenido.

## Criterios de Éxito

- [ ] Modo `none` eliminado de `persistence-contract.md`
- [ ] Ningún SKILL.md referencia modo `none`
- [ ] `orchestrator-core.md` sigue forzando `openspec`
- [ ] sdd-review pasa sin advertencias sobre modo `none`