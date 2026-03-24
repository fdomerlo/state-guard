# Diseño: Refactor Instalador y Contratos Base

## Enfoque Técnico

Cambio directo de dos artefactos: (1) reemplazar marcadores de texto plano por comentarios HTML en `install.sh` para preservar renderizado Markdown en IDEs, y (2) purgar menciones a dependencias externas (`engram`, `hybrid`) en `orchestrator-core.md` para garantizar arquitectura 100% on-premise.

## Decisiones de Arquitectura

### Decisión: Marcadores HTML vs. texto plano

**Elección**: `<!-- BEGIN SDD ORCHESTRATOR -->` / `<!-- END SDD ORCHESTRATOR -->`
**Alternativas consideradas**: Mantener `### BEGIN/END SDD ORCHESTRATOR ###`, usar `---` fences
**Justificación**: Los comentarios HTML son invisibles en renderizado Markdown de IDEs (VS Code, Cursor), eliminando ruido visual. Son compatibles con la lógica awk existente que busca cadenas literales exactas.

### Decisión: Solo editar línea 40 de orchestrator-core.md

**Elección**: Modificar únicamente la línea 40 eliminando menciones a `auto`, `hybrid`, `engram`
**Alternativas consideradas**: Reescribir toda la sección "Política de Almacenamiento"
**Justificación**: El resto de la sección es correcto y coherente. Solo la línea 40 contiene las referencias indeseadas. Principio de mínimo cambio.

## Flujo de Datos

```
install.sh (compile_and_append_config)
    │
    ├─ Lee marker_begin/marker_end (variables locales)
    ├─ awk purga bloque existente entre marcadores
    ├─ Escribe marker_begin → contenido → marker_end
    │
    └─ Resultado: archivo config con bloque delimitado por HTML comments

orchestrator-core.md
    │
    ├─ Se compila con sed ({{TOOL_NAME}}, {{SKILLS_PATH}})
    ├─ Se inyecta dentro del bloque delimitado por install.sh
    │
    └─ Resultado: prompt del orquestador sin menciones a engram/hybrid
```

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `scripts/install.sh:184-185` | Modificar | `marker_begin` y `marker_end` a `<!-- BEGIN/END SDD ORCHESTRATOR -->` |
| `skills/_shared/orchestrator-core.md:40` | Modificar | Eliminar "auto", "hybrid", "engram" de la política de almacenamiento |

## Interfaces / Contratos

La función `compile_and_append_config` mantiene su firma sin cambios:

```bash
compile_and_append_config() {
    local target_file="$1"   # Archivo destino (CLAUDE.md, .cursorrules, etc.)
    local header_file="$2"   # Header específico del tool
    local tool_name="$3"     # Nombre legible del tool
    local skills_path="$4"   # Ruta donde se copian los skills
}
```

La lógica awk de purgado (línea 191) funciona sin modificaciones porque busca las cadenas literales almacenadas en `marker_begin`/`marker_end`:

```bash
awk "/$marker_begin/{flag=1} /$marker_end/{flag=0; next} !flag" "$target_file"
```

## Estrategia de Testing

| Capa | Qué Testear | Enfoque |
|------|-------------|---------|
| Manual | Instalación idempotente | Ejecutar `install.sh` dos veces sobre mismo archivo, verificar sin duplicación |
| Manual | Purga correcta | Verificar que bloque viejo `### ###` no persiste tras re-instalación |
| Manual | Renderizado | Abrir CLAUDE.md/.cursorrules en IDE y confirmar que marcadores son invisibles |
| Manual | Contenido orchestrator-core | Grep para `engram`, `hybrid`, `auto` — debe retornar 0 resultados |

## Migración / Despliegue

**Retrocompatibilidad**: Primera re-instalación sobre config existente con marcadores viejos (`### ###`) NO purgará el bloque antiguo (awk buscará `<!-- -->`). Se acepta duplicación temporal. Segunda ejecución purgará correctamente usando los nuevos marcadores.

**Rollback**: `git checkout scripts/install.sh skills/_shared/orchestrator-core.md`

## Preguntas Abiertas

- [ ] ¿Debe documentarse en CHANGELOG el cambio de formato de marcadores para usuarios existentes?
