# Diseño Técnico: fix-opencode-commands

## Resumen Ejecutivo

Este diseño técnico especifica los detalles de implementación para crear 3 nuevos comandos slash de OpenCode (`sdd-status`, `sdd-review`, `sdd-split`) y actualizar la suite de tests para verificar correctamente 11 comandos en lugar de 8. El cambio es de baja complejidad y bajo riesgo, siguiendo el patrón de comandos existentes.

## Arquitectura de Comandos Slash

### Estructura de Archivos

Cada comando slash sigue una estructura basada en YAML frontmatter + instrucciones en Markdown:

```
---
description: [Descripción breve de una línea]
agent: sdd-orchestrator
subtask: [true|false]
---

[Instrucciones del comando]
CONTEXT:
- Variables de contexto

TASK:
- Descripción de la tarea
```

### Comandos a Crear

| Archivo | Descripción | Placeholder | Frontmatter |
|---------|-------------|-------------|-------------|
| `sdd-status.md` | Muestra el estado actual del cambio SDD activo | `{workdir}`, `{project}` | `subtask: true` |
| `sdd-review.md` | Revisa un cambio SDD específico | `{workdir}`, `{project}`, `{argument}` | sin subtask |
| `sdd-split.md` | Divide una tarea grande en subtareas | `{workdir}`, `{project}`, `{argument}` | sin subtask |

### Detalle de Cada Comando

#### 1. sdd-status.md

```yaml
---
description: Muestra el estado actual del cambio SDD activo — fase, tareas completadas, siguiente paso recomendado
agent: sdd-orchestrator
subtask: true
---
```

Este comando:
- No requiere argumento (nombre del cambio se infiere del contexto)
- Lee el archivo `state.yaml` del cambio activo
- Muestra: fase actual, fases completadas, siguiente fase recomendada
- Es un `subtask: true` porque se invoca desde el flujo del orquestador

#### 2. sdd-review.md

```yaml
---
description: Realiza una revisión detallada de un cambio SDD — verifica coherencia, calidad y completitud
agent: sdd-orchestrator
---
```

Este comando:
- Requiere argumento `[change]` — nombre del cambio a revisar
- Lee todos los artefactos del cambio (propuesta, specs, diseño, tareas)
- Ejecuta verificaciones de coherencia
- Devuelve un informe estructurado

#### 3. sdd-split.md

```yaml
---
description: Analiza una tarea grande y la divide en subtareas más pequeñas y manejables
agent: sdd-orchestrator
---
```

Este comando:
- Requiere argumento `[change]` — nombre del cambio
- Lee las tareas actuales del archivo `tasks.md`
- Identifica tareas complejas que pueden dividirse
- Propone nuevas subtareas con descripciones detalladas

### Placeholders Utilizados

| Placeholder | Descripción | Ejemplo |
|-------------|-------------|---------|
| `{workdir}` | Directorio de trabajo actual | `/home/user/project` |
| `{project}` | Nombre del proyecto actual | `agentify-sdd` |
| `{argument}` | Argumento pasado al comando | `fix-bug-123` |

## Cambios en Tests

### Assertions a Modificar

Se deben actualizar 3 líneas en `scripts/install_test.sh`:

| Línea | Valor Actual | Valor Nuevo | Contexto |
|-------|-------------|-------------|----------|
| ~225 | `"8"` | `"11"` | `test_opencode_commands()` |
| ~392 | `"8"` | `"11"` | `test_all_global_opencode_commands()` |
| ~417 | `"8"` | `"11"` | `test_idempotent_opencode()` |

### Verificaciones Explícitas a Agregar

En la función `test_opencode_commands()` (~líneas 215-222), agregar después de las verificaciones existentes:

```bash
# Agregar después de assert_file_exists "$commands_dir/sdd-continue.md"
assert_file_exists "$commands_dir/sdd-status.md" || return 1
assert_file_exists "$commands_dir/sdd-review.md" || return 1
assert_file_exists "$commands_dir/sdd-split.md" || return 1
```

### Corrección de Mensaje de Test

La línea 597 en el output de tests muestra:
- **Texto actual**: "Installs 10 command files"
- **Texto esperado**: "Installs 11 command files"

Este es un mensaje cosmético en el nombre del test, no afecta la funcionalidad.

## Integración con install.sh

### Función Afectada

La función `install_opencode_commands()` en `scripts/install.sh` (líneas 366-385) copiará automáticamente los 3 nuevos comandos sin modificación:

```bash
for cmd_file in "$commands_src"/sdd-*.md; do
    local cmd_name
    cmd_name=$(basename "$cmd_file")
    cp "$cmd_file" "$commands_target/$cmd_name"
    count=$((count + 1))
done
```

El script usa globbing (`sdd-*.md`), por lo que cualquier archivo nuevo en `examples/opencode/commands/` será copiado automáticamente.

### Output Esperado

Después de la implementación, el output de instalación mostrará:
```
11 commands installed → ~/.config/opencode/commands
```

## Diagrama de Flujo de Implementación

```
┌─────────────────────────────────────────────────────────┐
│                    CREAR ARCHIVOS                       │
├─────────────────────────────────────────────────────────┤
│  examples/opencode/commands/sdd-status.md   ─┐         │
│  examples/opencode/commands/sdd-review.md   ─┼─► Nuevo │
│  examples/opencode/commands/sdd-split.md    ─┘         │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                MODIFICAR TESTS                          │
├─────────────────────────────────────────────────────────┤
│  scripts/install_test.sh                                │
│  ├── Cambiar 3 assertions: "8" → "11"                  │
│  └── Agregar 3 assert_file_exists() para nuevos cmds   │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│              VERIFICAR INSTALACIÓN                     │
├─────────────────────────────────────────────────────────┤
│  bash scripts/install_test.sh                           │
│  └── Todos los tests pasan                             │
└─────────────────────────────────────────────────────────┘
```

## Criterios de Aceptación

### Criterios Funcionales

- [ ] Los 3 archivos de comandos existen en `examples/opencode/commands/`
- [ ] Cada comando sigue la estructura de plantilla (frontmatter + contenido)
- [ ] Los placeholders `{workdir}`, `{project}`, `{argument}` están correctamente utilizados
- [ ] Los 3 nuevos comandos son copiados por `install.sh` a `~/.config/opencode/commands/`

### Criterios de Tests

- [ ] Las 3 assertions de conteo en `install_test.sh` verifican "11"
- [ ] Las 3 verificaciones explícitas de archivos nuevos están presentes
- [ ] El test `test_opencode_commands()` pasa exitosamente
- [ ] El test `test_all_global_opencode_commands()` pasa exitosamente
- [ ] El test `test_idempotent_opencode()` pasa exitosamente
- [ ] El test `test_opencode_command_content_matches_source()` pasa exitosamente

### Criterios de Integración

- [ ] `install.sh --agent opencode` muestra "11 commands installed"
- [ ] Los 11 comandos slash funcionan correctamente con OpenCode

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Test de contenido falla antes de crear los comandos | Alta | Medio | Ejecutar tests después de crear los archivos |
| install.sh no copia los nuevos comandos | Baja | Alto | Verificar que el glob `sdd-*.md` funcione |
| Mensaje incorrecto en test (línea 597) | Baja | Bajo | Documentar, no bloquea funcionalidad |

## Dependencias

- Los 3 skills ya existen en `~/.config/opencode/skills/`
- No se requiere ninguna dependencia externa adicional

## Estimación

- **Archivos a crear**: 3
- **Archivos a modificar**: 1 (`install_test.sh`)
- **Líneas de código aproximadamente**: ~60 líneas nuevas
- **Complejidad**: Baja
- **Riesgo**: Bajo

## Siguiente Fase

Recomendamos continuar a la fase de **tareas** (`sdd-tasks`) para desgloser las tareas específicas de implementación.
