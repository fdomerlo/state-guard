# Especificación de opencode-commands

## Propósito

Este dominio define los requisitos para los slash commands de OpenCode que permiten invocar los skills SDD desde la línea de comandos. Los comandos son archivos Markdown que el orquestador utiliza para delegar tareas a sub-agentes especializados.

## Requisitos

### Requisito: Estructura de Archivo de Comando

Cada archivo de comando DEBE seguir la estructura de plantilla existente (sdd-verify.md, sdd-archive.md). El archivo DEBE contener:

- Frontmatter YAML con `description`, `agent` y `subtask`
- Una instrucción clara para el orquestador
- Sección CONTEXT con los placeholders `{workdir}` y `{project}`
- Sección TASK con la descripción de la tarea a realizar

El sistema DEBE garantizar que cada comando siga esta estructura exacta para ser reconocido por el orquestador.

#### Escenario: Comando con argumento de cambio

- GIVEN Un skill SDD que requiere un argumento de cambio (como `[change]`)
- WHEN Se crea el archivo de comando en `examples/opencode/commands/`
- THEN El archivo DEBE incluir el placeholder `{argument}` en la sección TASK
- AND El archivo DEBE documentar el uso del argumento en la descripción

#### Escenario: Comando sin argumentos

- GIVEN Un skill SDD que no requiere argumentos (como sdd-status)
- WHEN Se crea el archivo de comando en `examples/opencode/commands/`
- THEN El archivo DEBE tener `subtask: true` en el frontmatter
- AND La sección TASK DEBE indicar claramente que no se requieren argumentos

### Requisito: Archivo sdd-status.md

El archivo `examples/opencode/commands/sdd-status.md` DEBE ser creado y DEBE invocar el skill `sdd-status`. El sistema DEBE permitir al usuario ejecutar este comando para obtener el estado actual del proyecto SDD.

#### Escenario: Invocación exitosa de sdd-status

- GIVEN El archivo sdd-status.md existe en examples/opencode/commands/
- WHEN El orquestador recibe el comando `sdd-status`
- THEN El skill sdd-status DEBE ser cargado y ejecutado
- AND El resultado DEBE incluir información sobre cambios activos, fases completadas y estado actual

### Requisito: Archivo sdd-review.md

El archivo `examples/opencode/commands/sdd-review.md` DEBE ser creado y DEBE invocar el skill `sdd-review`. El sistema DEBE permitir al usuario ejecutar este comando con un argumento de cambio opcional para revisar el estado de un cambio específico.

#### Escenario: Revisión de cambio específico

- GIVEN El archivo sdd-review.md existe y el usuario proporciona un nombre de cambio
- WHEN El orquestador recibe el comando `sdd-review [nombre-del-cambio]`
- THEN El skill sdd-review DEBE ser cargado con el argumento proporcionado
- AND El resultado DEBE incluir el análisis del cambio especificado

#### Escenario: Revisión sin argumento (listar cambios)

- GIVEN El archivo sdd-review.md existe pero el usuario no proporciona argumento
- WHEN El orquestador recibe el comando `sdd-review` sin argumento
- THEN El skill DEBE listar todos los cambios disponibles en openspec/changes/
- AND Cada cambio DEBE incluir su fase actual y porcentaje de completitud

### Requisito: Archivo sdd-split.md

El archivo `examples/opencode/commands/sdd-split.md` DEBE ser creado y DEBE invocar el skill `sdd-split`. El sistema DEBE permitir al usuario ejecutar este comando con un argumento de cambio para dividir un cambio grande en subtareas.

#### Escenario: División de cambio en subtareas

- GIVEN El archivo sdd-split.md existe y el usuario proporciona un nombre de cambio
- WHEN El orquestador recibe el comando `sdd-split [nombre-del-cambio]`
- THEN El skill sdd-split DEBE ser cargado con el argumento proporcionado
- AND El resultado DEBE incluir las subtareas generadas para el cambio

### Requisito: Formato Markdown

Todos los archivos de comando DEBEN estar en formato Markdown (.md). El sistema DEBE reconocer únicamente archivos con extensión .md como comandos válidos.

#### Escenario: Archivo con extensión incorrecta

- GIVEN Un archivo de comando con extensión diferente a .md
- WHEN El instalador o el orquestador intenta procesarlo
- THEN El archivo NO DEBE ser reconocido como un comando válido
- AND NO DEBE ser copiado al directorio de comandos del usuario

## Requisitos MODIFICADOS

(No aplica para este dominio - es una especificación nueva)

## Requisitos ELIMINADOS

(No aplica para este cambio)
