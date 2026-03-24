# Especificación de Skill Registry Local

## Propósito

Habilitar el descubrimiento dinámico de skills no-SDD mediante un índice generado por script bash POSIX, permitiendo al orquestador descubrir habilidades disponibles sin conocimiento estático.

## Requisitos AGREGADOS

### Requisito: Skill de Registry

El sistema DEBE crear `skills/skill-registry/SKILL.md` como skill ejecutable que contiene un script bash para descubrimiento de skills.

#### Escenario: Skill de Registry Existe

- GIVEN que se ejecuta la implementación de este cambio
- WHEN se verifica `skills/skill-registry/SKILL.md`
- THEN el archivo DEBE existir
- AND el DEBE contener un script bash con shebang `#!/bin/sh` (POSIX estricto)

### Requisito: Script de Escaneo POSIX

El script DEBE escanear el directorio `./skills/` e identificar skills no-SDD para indexar.

El script DEBE ignorar directorios que comienzan con `sdd-` y el directorio `_shared`.

#### Escenario: Escaneo de Directorio de Skills

- GIVEN que el script se ejecuta desde el root del proyecto
- WHEN escanea `./skills/`
- THEN DEBE iterar sobre cada subdirectorio de primer nivel
- AND DEBE excluir directorios cuyo nombre comienza con `sdd-`
- AND DEBE excluir el directorio `_shared`
- AND DEBE incluir cualquier otro directorio que contenga `SKILL.md`

#### Escenario: Extracción de Metadata de Skill

- GIVEN un directorio de skill válido (ej: `skills/mi-skill/SKILL.md`)
- WHEN el script parsea el archivo
- THEN DEBE extraer el nombre del skill del frontmatter YAML o primera línea `#`
- AND DEBE extraer la descripción del campo `description` del frontmatter o del primer párrafo
- AND DEBE extraer el trigger del campo `trigger` o derivarlo del nombre
- AND DEBE registrar la ubicación (`file://` o ruta relativa)

#### Escenario: Compatibilidad POSIX Estricta

- GIVEN que el script usa `#!/bin/sh`
- WHEN se ejecuta en un entorno POSIX mínimo
- THEN NO DEBE usar `[[` (bashismo)
- AND NO DEBE usar `<<<` (here-string bashismo)
- AND NO DEBE usar arrays bash (`arr=(...)`)
- AND NO DEBE usar `function` keyword (usar `fname() { }`)
- AND DEBE funcionar correctamente con `sh`, `dash`, `busybox sh`

### Requisito: Generación de Índice Markdown

El script DEBE generar el archivo `./.agentify/skill-registry.md` como índice de skills descubiertas.

Cada entrada del índice DEBE incluir: nombre, descripción, trigger y ubicación.

#### Escenario: Índice Generado Correctamente

- GIVEN que el script se ejecuta exitosamente
- WHEN se verifica `./.agentify/skill-registry.md`
- THEN el archivo DEBE existir
- AND el archivo DEBE contener encabezado `# Skill Registry`
- AND el archivo DEBE contener tabla Markdown con columnas: `Nombre`, `Descripción`, `Trigger`, `Ubicación`
- AND cada skill no-SDD descubierta DEBE tener una fila en la tabla

#### Escenario: Índice Vacío Cuando No Hay Skills No-SDD

- GIVEN que solo existen directorios `sdd-*` y `_shared` en `./skills/`
- WHEN el script se ejecuta
- THEN `./.agentify/skill-registry.md` DEBE generarse
- AND el archivo DEBE indicar que no se encontraron skills adicionales
- AND el script NO DEBE fallar con error

#### Escenario: Directorio .agentify Creado Automáticamente

- GIVEN que `./.agentify/` no existe
- WHEN el script se ejecuta
- THEN el script DEBE crear el directorio antes de escribir el índice
- AND el script NO DEBE fallar si el directorio ya existe

### Requisito: Instrucción al Orquestador

El archivo `skills/_shared/orchestrator-core.md` DEBE instruir al orquestador a leer `./.agentify/skill-registry.md` al iniciar una tarea.

#### Escenario: Orquestador Lee Skill Registry

- GIVEN que `orchestrator-core.md` fue modificado
- WHEN se lee la sección de Estado y Convenciones
- THEN DEBE contener instrucción para leer `./.agentify/skill-registry.md`
- AND la instrucción DEBE especificar que la lectura ocurre al iniciar tarea
- AND la instrucción DEBE indicar que el índice proporciona skills disponibles además de las SDD

#### Escenario: Orquestador Usa Registry para Descubrimiento

- GIVEN que el orquestador recibe una petición del usuario
- AND `./.agentify/skill-registry.md` existe y contiene entradas
- WHEN el orquestador evalúa qué skill ejecutar
- THEN DEBE consultar el registry para skills no-SDD disponibles
- AND DEBE considerar las skills del registry además de los comandos SDD conocidos

## Requisitos MODIFICADOS

### Requisito: Estructura de Estado del Orquestador

**Nueva descripción:**
El orquestador DEBE mantener referencia al skill-registry como fuente de descubrimiento de habilidades. La sección de Estado y Convenciones DEBE incluir `skill-registry.md` junto a `persistence-contract.md` y `openspec-convention.md`.

(Anteriormente: Solo se referenciaban `persistence-contract.md` y `openspec-convention.md`)

#### Escenario: Convenciones Actualizadas

- GIVEN que `orchestrator-core.md` fue modificado
- WHEN se lee la sección "Estado y Convenciones (Fuente de la Verdad)"
- THEN DEBE listar `skill-registry.md` como recurso compartido
- AND DEBE mantener las referencias existentes a `persistence-contract.md` y `openspec-convention.md`
