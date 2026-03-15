# Delta para Meta-Command Processing

## Propósito

Este delta especifica la directiva AGREGADA al orquestador core para clarificar el procesamiento de meta-comandos, distinguiéndolos de las skills físicas del sistema.

## Requisitos AGREGADOS

### Requisito: Definición de Meta-Comandos

El orquestador DEBE reconocer los meta-comandos como instrucciones de texto que son interpretadas internamente por el orquestador, NO como skills físicas que se delegan. Los meta-comandos incluyen: `/sdd-continue`, `/sdd-ff`, `/sdd-new`, `/sdd-split`, y cualquier otro comando que start con `/sdd-`.

#### Escenario: Usuario ejecuta un meta-comando válido

- GIVEN el usuario envía "/sdd-continue" en el chat
- WHEN el orquestador recibe el mensaje
- THEN el orquestador DEBE interpretar el comando internamente
- AND DEBE delegar a la skill apropiada según el comando
- AND NO DEBE buscar una skill física llamada "sdd-continue"

#### Escenario: Usuario ejecuta un comando que no es meta-comando

- GIVEN el usuario envía una solicitud que no start con "/sdd-"
- WHEN el orquestador recibe el mensaje
- THEN el orquestador DEBE seguir el flujo normal de delegación
- AND DEBE buscar y ejecutar la skill correspondiente si aplica

### Requisito: Procesamiento de Meta-Comandos

El orquestador DEBE mantener un mapeo interno de meta-comandos a sus acciones correspondientes. Este mapeo DEBE incluir la traducción de meta-comandos a fases SDD (explore, propose, spec, design, tasks, apply, verify, archive).

#### Escenario: Meta-comando sin argumento

- GIVEN el usuario ejecuta "/sdd-status" sin argumentos
- WHEN el orquestador procesa el comando
- THEN el orquestador DEBE ejecutar la acción asociada al comando
- AND DEBE operar sobre todos los cambios activos

#### Escenario: Meta-comando con argumento de cambio específico

- GIVEN el usuario ejecuta "/sdd-continue mi-cambio"
- WHEN el orquestador procesa el comando con argumento
- THEN el orquestador DEBE identificar el cambio específico mencionado
- AND DEBE continuar la siguiente fase faltante solo para ese cambio

### Requisito: Nota de Próximo Paso

DESPUÉS de completar cualquier fase SDD, el orquestador DEBE incluir una nota clara de "Próximo Paso" que indique al usuario cómo interactuar para continuar el flujo de trabajo. Esta nota DEBE especificar el siguiente comando o acción recomendada.

#### Escenario: Después de completar fase de spec

- GIVEN la fase "spec" se ha completado exitosamente
- WHEN el orquestador retorna el resultado al usuario
- THEN el orquestador DEBE incluir una nota de "Próximo Paso"
- AND la nota DEBE indicar qué comando ejecutar para continuar (ej: "Ejecuta /sdd-design para continuar")

#### Escenario: Después de completar todas las fases

- GIVEN todas las fases de un cambio están completas
- WHEN el orquestador retorna el resultado final
- THEN el orquestador DEBE incluir una nota de "Próximo Paso"
- AND la nota DEBE indicar cómo archivar o verificar el cambio

## Requisitos MODIFICADOS

(No aplica para este hotfix)

## Requisitos ELIMINADOS

(No aplica para este hotfix)
