# Especificación de Docs

## Propósito

Esta especificación define los requisitos para la documentación del proyecto, específicamente la tabla de comandos disponibles en el archivo README.md.

## Requisitos

### Requisito: Tabla de Comandos en README

El archivo `README.md` DEBE contener una tabla que liste todos los comandos SDD disponibles, con sus descripciones.

#### Escenario: Tabla con 15 Comandos

- GIVEN el usuario consulta el README.md del proyecto
- WHEN la tabla de comandos es renderizada
- THEN DEBE mostrar exactamente 15 comandos
- AND cada fila DEBE contener: nombre del comando y descripción breve

#### Escenario: Completitud de la Tabla

- GIVEN existen 15 archivos de comando en `examples/opencode/commands/`
- WHEN el README es regenerado o actualizado
- THEN la tabla DEBE incluir todos los 15 comandos
- AND NO DEBE omitir ningún comando

### Requisito: Sincronización README-Commands

El contenido de la tabla en README.md DEBE reflejar exactamente los comandos existentes en el directorio `examples/opencode/commands/`.

#### Escenario: Verificación de Sincronización

- GIVEN el usuario ejecuta una verificación de documentación
- AND existen 15 archivos de comando
- WHEN el sistema compara con el README
- THEN la tabla DEBE tener exactamente 15 entradas
- AND cada entrada DEBE corresponderse con un archivo existente

#### Escenario: Comando Faltante en Tabla

- GIVEN existe un archivo de comando `sdd-spec.md` en el directorio
- AND la tabla en README.md no incluye `sdd-spec`
- WHEN el sistema detecta la discrepancia
- THEN DEBE indicar que la tabla está desactualizada
- AND DEBE sugerir agregar el comando faltante

### Requisito: Formato de la Tabla

La tabla de comandos DEBE mantener un formato consistente: nombre del comando en una columna, descripción en otra.

#### Escenario: Formato Consistente

- GIVEN la tabla de comandos está bien formada
- WHEN se visualiza en un lector de Markdown
- THEN las columnas DEBEN estar alineadas
- AND los nombres de comandos DEBEN usar el prefijo `sdd-`
- AND las descripciones DEBEN ser concisas (máximo 2 oraciones)

### Requisito: Comandos Nuevos Incluidos

Los comandos `sdd-spec`, `sdd-design` y `sdd-tasks` DEBEN aparecer en la tabla del README.md.

#### Escenario: Inclusion de sdd-spec

- GIVEN el proyecto tiene el comando `sdd-spec` disponible
- WHEN el usuario consulta el README
- THEN DEBE encontrar `sdd-spec` en la tabla de comandos
- AND la descripción DEBE indicar que invoca la skill de especificación

#### Escenario: Inclusion de sdd-design

- GIVEN el proyecto tiene el comando `sdd-design` disponible
- WHEN el usuario consulta el README
- THEN DEBE encontrar `sdd-design` en la tabla de comandos
- AND la descripción DEBE indicar que invoca la skill de diseño técnico

#### Escenario: Inclusion de sdd-tasks

- GIVEN el proyecto tiene el comando `sdd-tasks` disponible
- WHEN el usuario consulta el README
- THEN DEBE encontrar `sdd-tasks` en la tabla de comandos
- AND la descripción DEBE indicar que invoca la skill de desglose de tareas