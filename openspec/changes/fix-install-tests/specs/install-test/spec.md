# Delta para install-test

## Propósito

Esta especificación delta documenta los cambios requeridos para actualizar los valores esperados en la suite de pruebas de instalación (`scripts/install_test.sh`) para reflejar los nuevos recuentos de skills y comandos de OpenCode.

## Requisitos MODIFICADOS

### Requisito: Actualización de Recuento de Skills en Array EXPECTED_SKILLS

El array `EXPECTED_SKILLS` en el script de pruebas DEBE incluir los nuevos skills `sdd-checkpoint` y `sdd-rollback`, elevando el total de 15 a 17 elementos.

(Anteriormente: 15 skills en el array, sin incluir sdd-checkpoint ni sdd-rollback)

#### Escenario: Verificación de skills instalados coincide con array esperado

- GIVEN el script de instalación ha instalado todos los skills disponibles
- WHEN la prueba compara el array EXPECTED_SKILLS con los skills instalados
- THEN el conteo debe ser 17 skills coincidentes
- AND ambos skills `sdd-checkpoint` y `sdd-rollback` deben estar presentes

#### Escenario: Array contiene exactamente 17 skills únicos

- GIVEN el archivo de pruebas define el array EXPECTED_SKILLS
- WHEN se cuenta la cantidad de elementos en el array
- THEN el resultado debe ser exactamente 17

### Requisito: Conteo de Skills en Aserciones de Pruebas

Todas las aserciones que verifican el número de skills en el script de pruebas DEBEN usar el valor 17 en lugar de 15.

(Anteriormente: assert_eq "15" en 9 ubicaciones)

#### Escenario: Validación de cantidad de skills en prueba de listado

- GIVEN el script de instalación ejecuta la prueba de listado de skills
- WHEN la prueba valida el número de skills retornados
- THEN el valor esperado debe ser 17
- AND la prueba debe pasar sin errores

#### Escenario: Conteo de skills en todas las aserciones de verificación

- GIVEN las 9 ubicaciones en el script que contienen assert_eq para skills
- WHEN se ejecuta la suite de pruebas
- THEN todas las aserciones deben usar el valor "17"
- AND ninguna debe usar el valor antiguo "15"

### Requisito: Conteo de Comandos OpenCode en Aserciones de Pruebas

Las pruebas que verifican la cantidad de comandos disponibles de OpenCode DEBEN usar el valor 19 en lugar de 17.

(Anteriormente: assert_eq "17" en 3 ubicaciones para comandos OpenCode)

#### Escenario: Verificación de número de comandos disponibles

- GIVEN el sistema tiene instalados los comandos de OpenCode
- WHEN la prueba ejecuta la validación de comandos
- THEN el conteo debe ser 19 comandos disponibles

#### Escenario: Las 3 aserciones de comandos usan el valor correcto

- GIVEN las 3 ubicaciones en el script que verifican comandos OpenCode
- WHEN se ejecuta la suite de pruebas
- THEN todas deben usar el valor "19"
- AND ninguna debe usar el valor antiguo "17"

### Requisito: Total All-Global en Verificaciones de Suma

El cálculo de todos los elementos globales (skills multiplicados por categorías) DEBE usar 85 en lugar de 75.

(Anteriormente: 75 en 2 lugares, representando 5 × 15)

#### Escenario: Validación de suma total de skills por categoría

- GIVEN las 5 categorías contienen sus respectivos skills
- WHEN la prueba calcula la suma total multiplicando categorías por skills
- THEN el resultado debe ser 85 (5 × 17 = 85)

#### Escenario: Verificación de los dos lugares donde se calcula el total

- GIVEN existen 2 ubicaciones en el script que calculan el total all-global
- WHEN se ejecuta la prueba de verificación de totales
- THEN ambas ubicaciones deben usar el valor "85"

### Requisito: Mensaje de Output en Verificación de Instalación

El grep que busca el mensaje de instalación DEBE buscar "17 skills installed" en lugar de "15 skills installed".

(Anteriormente: grep "15 skills installed")

#### Escenario: Verificación de mensaje de instalación

- GIVEN el script de instalación ha completado la instalación de skills
- WHEN la prueba busca el mensaje de output que indica la cantidad de skills instalados
- THEN debe encontrar "17 skills installed" en la salida
- AND el grep debe ser exitoso (exit code 0)

#### Escenario: El mensaje de output coincide con el conteo real

- GIVEN la instalación muestra un mensaje al finalizar
- WHEN la prueba verifica el mensaje con grep
- THEN el patrón debe coincidir con "17 skills installed"
- AND no debe haber discrepancia entre el mensaje y las aserciones

## Reglas de Implementación

- Las modificaciones DEBEN ser únicamente cambios de valores literales
- NO SE DEBE alterar la lógica de las pruebas
- NO SE DEBE agregar nuevas pruebas
- NO SE DEBE modificar el comportamiento del script de instalación
- Todos los cambios son sustituciones exactas de cadena sin cambio semántico