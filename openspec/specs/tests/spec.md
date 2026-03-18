# Especificación de tests

## Propósito

Este dominio define los requisitos para la suite de tests de instalación que verifica la correcta instalación de los slash commands de OpenCode. Los tests garantizan que el número de comandos instalados coincida con el esperado y que cada comando sea correctamente copiado al directorio de configuración del usuario.

## Requisitos

### Requisito: Verificación de Conteo de Comandos

La suite de tests DEBE verificar que existan exactamente 11 comandos instalados en el directorio de comandos de OpenCode. El sistema DEBE actualizar las assertions que actualmente verifican "8" comandos para que verifiquen "11" comandos.

#### Escenario: Conteo correcto de comandos tras instalación

- GIVEN Los 3 nuevos comandos (sdd-status.md, sdd-review.md, sdd-split.md) han sido creados
- WHEN Se ejecuta el test `test_opencode_commands()`
- THEN El conteo DEBE ser igual a 11
- AND El mensaje de error DEBE indicar "Expected 11 OpenCode commands"

#### Escenario: Actualización de assertion en línea 225

- GIVEN El archivo scripts/install_test.sh contiene la verificación en línea 225
- WHEN El test valida el número de archivos sdd-*.md
- THEN La comparación DEBE usar el valor "11" en lugar de "8"
- AND El mensaje DEBE reflejar correctamente el número esperado

#### Escenario: Actualización de assertion en línea 392

- GIVEN El archivo scripts/install_test.sh contiene la verificación en línea 392 para all-global
- WHEN El test valida el número de archivos sdd-*.md con el agente all-global
- THEN La comparación DEBE usar el valor "11" en lugar de "8"
- AND El mensaje DEBE indicar "Expected 11 OpenCode commands with all-global"

#### Escenario: Actualización de assertion en línea 417

- GIVEN El archivo scripts/install_test.sh contiene la verificación de idempotencia en línea 417
- WHEN El test valida el número de comandos tras instalación doble
- THEN La comparación DEBE usar el valor "11" en lugar de "8"
- AND El mensaje DEBE indicar "Expected exactly 11 commands after double install"

### Requisito: Verificación de Archivos Individuales

El test `test_opencode_commands()` DEBE verificar la existencia de cada uno de los 11 archivos de comando. El sistema DEBE agregar verificaciones explícitas para los 3 nuevos comandos: sdd-status.md, sdd-review.md y sdd-split.md.

#### Escenario: Verificación de sdd-status.md

- GIVEN El archivo sdd-status.md ha sido creado en examples/opencode/commands/
- WHEN Se ejecuta el test de instalación
- THEN La función DEBE verificar que $commands_dir/sdd-status.md existe
- AND La aserción DEBE usar assert_file_exists para validar

#### Escenario: Verificación de sdd-review.md

- GIVEN El archivo sdd-review.md ha sido creado en examples/opencode/commands/
- WHEN Se ejecuta el test de instalación
- THEN La función DEBE verificar que $commands_dir/sdd-review.md existe
- AND La aserción DEBE usar assert_file_exists para validar

#### Escenario: Verificación de sdd-split.md

- GIVEN El archivo sdd-split.md ha sido creado en examples/opencode/commands/
- WHEN Se ejecuta el test de instalación
- THEN La función DEBE verificar que $commands_dir/sdd-split.md existe
- AND La aserción DEBE usar assert_file_exists para validar

#### Escenario: Verificación de comandos existentes

- GIVEN Los 8 comandos originales siguen existiendo
- WHEN Se ejecuta el test de instalación
- THEN Las verificaciones para sdd-init.md, sdd-apply.md, sdd-explore.md, sdd-verify.md, sdd-archive.md, sdd-new.md, sdd-ff.md y sdd-continue.md DEBEN pasar
- AND El conteo total DEBE ser 11

### Requisito: Mensajes de Error Claros

Los mensajes de error en las assertions DEBEN reflejar con precisión el número de comandos esperados y encontrados. El sistema NO DEBE mostrar mensajes confusos como "10 vs 8" cuando el test muestra un valor incorrecto.

#### Escenario: Mensaje de error con conteo incorrecto

- GIVEN El test encuentra un número diferente de comandos al esperado
- WHEN La aserción falla
- THEN El mensaje DEBE mostrar el valor esperado (11) y el valor encontrado
- AND El mensaje DEBE ser claro y no confuso

## Requisitos MODIFICADOS

### Requisito: Conteo de Comandos (Modificado)

El requisito existente que verificaba "8" comandos ha sido actualizado para verificar "11" comandos. Anteriormente, el test esperaba exactamente 8 archivos de comando; ahora el test DEBE esperar 11 archivos de comando para reflejar la adición de los 3 nuevos comandos.

#### Escenario: Test pasa con 11 comandos

- GIVEN Los 11 comandos están correctamente instalados
- WHEN Se ejecuta el test `test_opencode_commands()`
- THEN El test DEBE pasar exitosamente
- AND Las 3 assertions actualizadas DEBEN pasar

## Requisitos ELIMINADOS

(No aplica para este cambio)
