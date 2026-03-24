# Propuesta: Refactor Instalador y Contratos Base

## Intención

Completar la adopción de mejoras arquitectónicas para agentify-sdd. Robustecer el script de instalación cambiando los marcadores de inyección por comentarios HTML (para no romper el renderizado Markdown en IDEs) y purgar los contratos compartidos para eliminar cualquier rastro de dependencias externas o bases de datos vectoriales (Engram/hybrid).

## Alcance

### Dentro del Alcance
- Editar `scripts/install.sh`: cambiar marcadores `### BEGIN/END SDD ORCHESTRATOR ###` por `<!-- BEGIN/END SDD ORCHESTRATOR -->`
- Editar `skills/_shared/orchestrator-core.md`: eliminar menciones a `hybrid`/`engram` en línea 40

### Fuera del Alcance
- Modificaciones a `skills/_shared/persistence-contract.md` (ya está limpio, sin menciones a engram/hybrid/mem_save)
- Modificaciones a `skills/_shared/openspec-convention.md` (ya documenta rutas explícitas correctamente)
- Archivo `.agent/rules/sdd-orchestrator.md` (fuera del alcance: directorio global del runtime, restringido por RESTRICCIÓN CRÍTICA DE ENTORNO)

## Enfoque

1. **Cambio directo de marcadores** en `install.sh` — Reemplazar marcadores de texto plano por HTML comments. La lógica awk de purgado (línea 191) funciona sin modificaciones porque busca cadenas literales.

2. **Purga de orchestrator-core.md** — Eliminar la mención a `auto`, `hybrid` y `engram` de la política de almacenamiento, manteniendo solo `openspec` como modo válido.

## Áreas Afectadas

| Área | Impacto | Descripción |
|------|---------|-------------|
| `scripts/install.sh:184-185` | Modificado | Variables `marker_begin` y `marker_end` a HTML comments |
| `scripts/install.sh:198,217` | Verificado | Escritura de marcadores usa las variables automáticamente |
| `skills/_shared/orchestrator-core.md:40` | Modificado | Eliminar menciones a `hybrid`/`engram` |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|--------|-------------|------------|
| Retrocompatibilidad con marcadores antiguos | Media | El purgado es idempotente: la primera re-instalación no purgará el bloque viejo (no encontrará `<!-- -->`), pero agregará uno nuevo. Segunda ejecución purgará correctamente. Se acepta duplicación temporal en primera re-instalación. |
| Alcance incompleto en purga | Baja | `orchestrator-core.md` es `_shared` y está dentro del alcance. `.agent/rules/` está fuera por restricción de entorno. |

## Plan de Rollback

1. `git checkout scripts/install.sh` — restaura marcadores originales `### BEGIN/END ###`
2. `git checkout skills/_shared/orchestrator-core.md` — restaura menciones a hybrid/engram
3. Re-ejecutar `install.sh` para regenerar configuración con marcadores antiguos

## Dependencias

- Ninguna dependencia externa. Solo edición de archivos existentes.

## Criterios de Éxito

- [ ] `scripts/install.sh` usa `<!-- BEGIN/END SDD ORCHESTRATOR -->` como marcadores
- [ ] La lógica awk de purgado funciona correctamente con los nuevos marcadores
- [ ] `orchestrator-core.md` no menciona `hybrid`, `engram` ni `auto`
- [ ] Los contratos compartidos (`persistence-contract.md`, `openspec-convention.md`) permanecen sin cambios innecesarios
- [ ] El sistema es 100% on-premise sin recomendaciones de software externo
