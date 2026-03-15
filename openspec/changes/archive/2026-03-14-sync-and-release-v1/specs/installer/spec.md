# Delta para Installer

## Propósito

Esta especificación describe los cambios necesarios en el script de instalación y test para validar correctamente la sincronización entre comandos y skills del orquestador SDD.

## Requisitos AGREGADOS

### Requisito: Conteo de Comandos y Skills

El script `install_test.sh` DEBE validar que el número de comandos equals el número de skills, siendo ambos exactamente 15.

#### Escenario: Validación de Conteo Igual a 15

- GIVEN el usuario ejecuta `scripts/install_test.sh`
- AND existen exactamente 15 comandos en `examples/opencode/commands/`
- AND existen exactamente 15 skills en `~/.config/opencode/skills/sdd-*/`
- WHEN el script procesa la validación
- THEN DEBE pasar todas las validaciones de conteo
- AND DEBE mostrar mensaje de éxito

#### Escenario: Conteo de Comandos Menor a 15

- GIVEN el usuario ejecuta `scripts/install_test.sh`
- AND existen menos de 15 comandos en `examples/opencode/commands/`
- WHEN el script procesa la validación
- THEN DEBE fallar en el assert de comandos
- AND DEBE indicar cuántos comandos faltan

#### Escenario: Conteo de Skills Mayor a Comandos

- GIVEN el usuario ejecuta `scripts/install_test.sh`
- AND existen 15 skills pero solo 12 comandos
- WHEN el script procesa la validación
- THEN DEBE fallar indicando la desincronización
- AND DEBE sugerir qué comandos faltan crear

### Requisito: Arrays de Validación

El script DEBE mantener arrays separados para commands y skills, cada uno con el valor correcto de 15.

#### Escenario: Arrays con Valores Correctos

- GIVEN el script define `EXPECTED_COMMANDS=15` y `EXPECTED_SKILLS=15`
- WHEN el script procesa los conteos
- THEN DEBE usar ambos valores en sus respective validaciones
- AND DEBE fallar si cualquier conteo no coincide con su valor esperado

### Requisito: Integridad de la Instalación

El script DEBE verificar que cada comando nuevo tiene su correspondiente skill.

#### Escenario: mapeo Commands a Skills

- GIVEN el script valida los archivos
- WHEN procesa el mapeo comando → skill
- THEN cada archivo en `examples/opencode/commands/sdd-*.md` DEBE corresponderse con una skill `sdd-*` en el directorio de skills
- AND DEBE fallar si encuentra un comando sin skill correspondiente

## Requisitos MODIFICADOS

### Requisito: Conteo de EXPECTED_COMMANDS

**Anteriormente:** El valor de `EXPECTED_COMMANDS` era 12

**Nueva descripción:** El valor de `EXPECTED_COMMANDS` DEBE ser 15

#### Escenario: Validación del Nuevo Conteo

- GIVEN el script define `EXPECTED_COMMANDS=15`
- WHEN el script cuenta los archivos en `examples/opencode/commands/`
- THEN DEBE esperar exactamente 15 archivos `.md`
- AND DEBE fallar si el conteo real es diferente