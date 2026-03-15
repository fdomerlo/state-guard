# Propuesta: fix-opencode-commands

## Intención

Actualizar el proyecto Agentify-SDD para reconocer y utilizar los 3 nuevos skills SDD (`sdd-status`, `sdd-review`, `sdd-split`) que ya existen en el sistema de skills pero carecen de comandos slash correspondientes. Esto permitirá a los usuarios invocar estos 3 skills desde la línea de comandos y garantizará que la suite de tests refleje correctamente la cantidad total de comandos disponibles (11 en lugar de 8).

## Alcance

### Dentro del Alcance

- Crear `examples/opencode/commands/sdd-status.md` con la instrucción para invocar el skill `sdd-status`
- Crear `examples/opencode/commands/sdd-review.md` con la instrucción para invocar el skill `sdd-review`
- Crear `examples/opencode/commands/sdd-split.md` con la instrucción para invocar el skill `sdd-split`
- Actualizar las 3 assertions en `scripts/install_test.sh` que verifican "8" comandos cambiándolas a "11"
- Agregar verificaciones explícitas de los 3 nuevos comandos en el bucle de test de `test_opencode_commands()`

### Fuera del Alcance

- Modificar la implementación de los skills subyacentes (ya existen y funcionan)
- Crear documentación adicional más allá de los 3 archivos de comandos
- Modificar otros scripts de instalación que no sean `install_test.sh`

## Enfoque

Seguir el **Enfoque 1** identificado en la exploración: creación manual de los 3 archivos de comandos copiando la estructura de plantillas existentes (`sdd-verify.md`, `sdd-archive.md`). Cada archivo de comando incluirá:

- Frontmatter con `description`, `agent`, `subtask` (si aplica)
- Referencia al skill en `~/.config/opencode/skills/{skill}/SKILL.md`
- Placeholders: `{workdir}`, `{project}`, `{argument}` según corresponda

Para los tests, se modificarán manualmente las 3 líneas de assert y se agregarán los 3 nuevos comandos al bucle de verificación de archivos.

## Áreas Afectadas

| Área                                   | Impacto      | Descripción                                                           |
|----------------------------------------|--------------|----------------------------------------------------------------------|
| `examples/opencode/commands/sdd-status.md`    | Nuevo       | Archivo de comando para skill sdd-status (sin argumento)            |
| `examples/opencode/commands/sdd-review.md`    | Nuevo       | Archivo de comando para skill sdd-review (con argumento `[change]`) |
| `examples/opencode/commands/sdd-split.md`     | Nuevo       | Archivo de comando para skill sdd-split (con argumento `[change]`)  |
| `scripts/install_test.sh`              | Modificado   | Actualizar 3 assertions de "8" a "11" y agregar verificaciones       |

## Riesgos

| Riesgo                                                      | Probabilidad | Mitigación                                                       |
|-------------------------------------------------------------|--------------|------------------------------------------------------------------|
| Test de línea 597 muestra mensaje incorrecto ("10" vs "8") | Baja         | Documentar en el PR, el test pasa pero el mensaje confunde      |
| Test de contenido falla antes de crear los comandos       | Alta         | Ejecutar tests después de crear los 3 archivos de comandos       |
| install.sh no copia los nuevos comandos                    | Media        | Verificar que install.sh incluya los 3 nuevos archivos          |

## Plan de Rollback

1. Eliminar los 3 archivos de comandos creados: `sdd-status.md`, `sdd-review.md`, `sdd-split.md`
2. Revertir los cambios en `scripts/install_test.sh` cambiando las 3 assertions de "11" de vuelta a "8"
3. Eliminar las verificaciones de los nuevos comandos agregadas al bucle de test

## Dependencias

- Ninguna dependencia externa requerida
- Los 3 skills ya existen en `~/.config/opencode/skills/`

## Criterios de Éxito

- [ ] Los 3 archivos de comandos existen en `examples/opencode/commands/` y siguen la plantilla esperada
- [ ] Las 3 assertions en `install_test.sh` verifican el valor "11"
- [ ] El test `test_opencode_commands()` pasa exitosamente
- [ ] Los 3 nuevos comandos son copiados por `install.sh` a `~/.config/opencode/commands/`
- [ ] La ejecución de `sdd-status`, `sdd-review` y `sdd-split` funciona correctamente
