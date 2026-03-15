# Exploración: fix-opencode-commands

## Estado Actual

### Comandos OpenCode existentes (8 archivos)
El directorio `examples/opencode/commands/` contiene actualmente 8 comandos:
1. `sdd-init.md` — Inicializa el contexto SDD
2. `sdd-new.md` — Inicia un nuevo cambio SDD (toma argumento `{argument}`)
3. `sdd-continue.md` — Continúa un cambio existente
4. `sdd-apply.md` — Implementa tareas de un cambio
5. `sdd-ff.md` — Ejecuta el flujo completo (fast-forward)
6. `sdd-archive.md` — Archiva un cambio completado
7. `sdd-explore.md` — Explora e investiga ideas
8. `sdd-verify.md` — Valida que la implementación coincida con specs

### Skills SDD existentes (12 archivos)
Los 12 skills ya existen en `skills/`:
- sdd-apply, sdd-archive, sdd-design, sdd-explore, sdd-init, sdd-propose
- **sdd-review** (ya existe)
- **sdd-split** (ya existe)
- **sdd-status** (ya existe)
- sdd-spec, sdd-tasks, sdd-verify

### Tests que verifican cantidad de comandos
El archivo `scripts/install_test.sh` tiene las siguientes assertions que deben actualizarse:

| Línea | Test | Valor actual | Valor nuevo |
|-------|------|--------------|-------------|
| 225 | `test_opencode_commands()` | 8 | 11 |
| 392 | `test_all_global_opencode_commands()` | 8 | 11 |
| 417 | `test_idempotent_opencode()` | 8 | 11 |

También hay verificaciones explícitas de archivos en `test_opencode_commands()` (líneas 215-222) que solo verifican 8 comandos.

## Áreas Afectadas

- `examples/opencode/commands/` — Necesita 3 archivos nuevos
- `scripts/install_test.sh` — Necesita actualizar 3 assertions de conteo + agregar verificaciones de nuevos comandos

## Enfoques

### Enfoque 1: Crear comandos manualmente
Crear los 3 archivos de comandos copiando la estructura de plantillas existentes.

- **Ventajas**: Control total sobre el contenido, proceso simple
- **Desventajas**: Trabajo repetitivo, riesgo de inconsistencias menores
- **Esfuerzo**: Bajo

### Enfoque 2: Generar mediante script
Crear un script que genere los comandos a partir de una plantilla.

- **Ventajas**: Consistencia garantizada, reutilizable
- **Desventajas**: Requiere crear el script, overkill para 3 archivos
- **Esfuerzo**: Medio

## Recomendación

Seguir el **Enfoque 1** (manual) ya que son solo 3 archivos y la estructura es simple. Los archivos deben seguir el patrón observed en `sdd-verify.md` y `sdd-new.md`:

- Frontmatter con `description`, `agent`, `subtask` (si aplica)
- Referencia al skill en `~/.config/opencode/skills/{skill}/SKILL.md`
- placeholders: `{workdir}`, `{project}`, `{argument}` (si es necesario)

## Tareas específicas identificadas

### Objetivo 1 - Crear Slash Commands (3 archivos):
1. `examples/opencode/commands/sdd-status.md` — sin argumento
2. `examples/opencode/commands/sdd-review.md` — con argumento `[change]`
3. `examples/opencode/commands/sdd-split.md` — con argumento `[change]`

### Objetivo 2 - Actualizar Suite de Tests (3 assertions + verificación de archivos):
1. Línea 225: cambiar `8` a `11`
2. Línea 392: cambiar `8` a `11`
3. Línea 417: cambiar `8` a `11`
4. Agregar verificaciones de archivos para los 3 nuevos comandos en el bucle `for` de `test_opencode_commands()`

## Riesgos

- **Riesgo 1**: Al actualizar los tests, el test de "10 command files" en la línea 597 muestra un mensaje incorrecto (dice "10" pero verifica "8")
- **Riesgo 2**: El test de contenido (`test_opencode_command_content_matches_source`) fallará si los nuevos comandos no existen en el source
- **Riesgo 3**: El install.sh debe copiar los nuevos comandos a `~/.config/opencode/commands/`

## Listo para Propuesta

**Sí** — La exploración está completa. Se requiere:
1. Crear 3 archivos de comandos siguiendo las plantillas
2. Actualizar 3 valores de aserción en install_test.sh
3. Agregar verificaciones explícitas de los 3 nuevos comandos en el bucle de test

El cambio es directo y de bajo riesgo.
