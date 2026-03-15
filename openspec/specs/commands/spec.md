# Especificación de Commands

## Propósito

Esta especificación define el comportamiento de los comandos disponibles en OpenCode para invocar las skills del orquestador SDD. Los comandos son la interfaz principal mediante la cual los usuarios interactúan con el sistema de Desarrollo Guiado por Especificaciones.

## Requisitos

### Requisito: Catálogo de Comandos Completos

El sistema DEBE mantener un catálogo de 15 comandos que correspondan directamente a las 15 skills disponibles del orquestador.

#### Escenario: Verificar количество de comandos

- GIVEN el usuario consulta el directorio `examples/opencode/commands/`
- WHEN el sistema procesa la consulta
- THEN DEBE encontrar exactamente 15 archivos `.md` que representen comandos válidos
- AND cada archivo DEBE corresponderse con una skill del orquestador

#### Escenario: Cobertura de Comandos por Skill

- GIVEN existe una skill configurada en el orquestador
- WHEN el sistema verifica la cobertura
- THEN DEBE existir un comando para cada skill
- AND el nombre del comando DEBE coincidir con el nombre de la skill (prefijo `sdd-`)

### Requisito: Estructura de Comando

Cada archivo de comando DEBE contener: título del comando, descripción breve de su propósito, y al menos un ejemplo de uso.

#### Escenario: Estructura Válida de Comando

- GIVEN el usuario crea un nuevo archivo de comando en `examples/opencode/commands/`
- AND el archivo contiene: título (línea 1), descripción (1-2 oraciones), ejemplo de uso
- WHEN el sistema valida el comando
- THEN DEBE aceptar el comando como válido

#### Escenario: Comando con Nombre Incorrecto

- GIVEN el usuario crea un archivo de comando con nombre que no sigue el patrón `sdd-{nombre}.md`
- WHEN el sistema procesa el archivo
- THEN DEBE rechazarlo como comando inválido
- AND DEBE indicar el formato correcto esperado

### Requisito: Comandos SDD de Fases Específicas

Los comandos `sdd-spec`, `sdd-design` y `sdd-tasks` DEBEN invocar directamente las fases correspondientes del flujo SDD.

#### Escenario: Invocación de sdd-spec

- GIVEN el usuario ejecuta el comando `sdd-spec` desde OpenCode
- WHEN el orquestador recibe la invocación
- THEN DEBE ejecutar la skill de especificación (`sdd-spec`)
- AND DEBE pasar el contexto del cambio activo si existe

#### Escenario: Invocación de sdd-design

- GIVEN el usuario ejecuta el comando `sdd-design` desde OpenCode
- WHEN el orquestador recibe la invocación
- THEN DEBE ejecutar la skill de diseño técnico (`sdd-design`)
- AND DEBE pasar el contexto del cambio activo si existe

#### Escenario: Invocación de sdd-tasks

- GIVEN el usuario ejecuta el comando `sdd-tasks` desde OpenCode
- WHEN el orquestador recibe la invocación
- THEN DEBE ejecutar la skill de desglose de tareas (`sdd-tasks`)
- AND DEBE pasar el contexto del cambio activo si existe

### Requisito: Diferenciación con sdd-new

Los comandos `sdd-spec`, `sdd-design` y `sdd-tasks` DEBEN ser atajos directos a fases específicas, no deben duplicar la funcionalidad de `sdd-new`.

#### Escenario: Comparación de Funcionalidad

- GIVEN el usuario ejecuta `sdd-new` con argumento de fase
- AND el usuario ejecuta `sdd-spec` directamente
- WHEN el orquestador procesa ambos comandos
- THEN `sdd-new` DEBE orquestar múltiples fases si es necesario
- AND `sdd-spec` DEBE ejecutar solo la fase de especificación
- AND ambos DEBEN producir resultados equivalentes para esa fase específica

### Requisito: Sincronización Commands-Skills

El número de comandos DEBE ser igual al número de skills configuradas en el orquestador.

#### Escenario: Sincronización en Install

- GIVEN el usuario ejecuta `scripts/install_test.sh`
- WHEN el script valida la instalación
- THEN DEBE verificar que EXPECTED_COMMANDS == EXPECTED_SKILLS
- AND DEBE fallar si los conteos no coinciden

#### Escenario: Detección de Desincronización

- GIVEN el sistema tiene 13 skills pero solo 12 comandos
- WHEN se ejecuta la validación
- THEN DEBE indicar explícitamente qué comando falta
- AND DEBE sugerir el comando a crear para alcanzar la sincronización
