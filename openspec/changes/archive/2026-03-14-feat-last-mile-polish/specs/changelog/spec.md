# Delta para Changelog

## Propósito

Esta especificación define el comportamiento del skill `sdd-changelog` que genera automáticamente un archivo `CHANGELOG.md` en la raíz del proyecto a partir de los cambios archivados en `openspec/changes/archive/`.

## Requisitos AGREGADOS

### Requisito: Generación de Changelog desde Archive

El sistema DEBE leer todas las carpetas archivadas en `openspec/changes/archive/` y generar un `CHANGELOG.md` con formato estándar que documente todos los cambios completados.

#### Escenario: Generación Exitosa con Múltiples Cambios Archivados

- GIVEN el usuario ejecuta `/sdd-changelog`
- AND existen múltiples carpetas archivadas (ej: `2026-01-15-fix-auth-bug/`, `2026-02-01-add-dark-mode/`)
- AND cada carpeta contiene `proposal.md` con metadatos del cambio
- WHEN el skill procesa el directorio archive
- THEN DEBE leer cada `proposal.md` archivado
- AND DEBE extraer: título, intención, fecha de archivado (del nombre de carpeta)
- AND DEBE generar `CHANGELOG.md` en la raíz del proyecto
- AND DEBE ordenar los cambios por fecha (más reciente primero)

#### Escenario: Generación con Archivo Changelog Existente

- GIVEN el usuario ejecuta `/sdd-changelog`
- AND ya existe un archivo `CHANGELOG.md` en la raíz
- AND hay nuevos cambios archivados desde la última generación
- WHEN el skill procesa la generación
- THEN DEBE regenerar el archivo completo
- AND DEBE incluir todos los cambios (existentes y nuevos)
- AND DEBE actualizar la fecha de generación

#### Escenario: Archive Vacío

- GIVEN el usuario ejecuta `/sdd-changelog`
- AND NO existen carpetas en `openspec/changes/archive/`
- WHEN el skill procesa la generación
- THEN DEBE crear un `CHANGELOG.md` con encabezado pero sin cambios
- AND DEBE indicar que no hay cambios archivados

### Requisito: Formato del Changelog

El sistema DEBE generar un changelog con formato consistente que sea legible tanto por humanos como procesable por herramientas.

#### Escenario: Formato de Entrada de Cambio

- GIVEN el skill procesa un cambio archivado
- AND extrae la información de `proposal.md`
- WHEN genera la entrada en el changelog
- THEN DEBE usar el formato:

```markdown
## [{Fecha}] {Nombre-del-Cambio}

**Intención**: {resumen de la intención}

**Alcance**:
- {entre 1}
- {entre 2}
```

#### Escenario: Encabezado del Changelog

- GIVEN el skill genera un nuevo `CHANGELOG.md`
- WHEN escribe el archivo
- THEN DEBE incluir un encabezado con:
- Título "# Changelog"
- Descripción breve del proyecto
- Fecha de última generación

### Requisito: Comando OpenCode Registrado

El sistema DEBE registrar el comando `/sdd-changelog` en el orquestador para que los usuarios puedan invocarlo directamente.

#### Escenario: Ejecución via Comando OpenCode

- GIVEN el usuario ejecuta `/sdd-changelog` en OpenCode
- AND el comando está registrado en `orchestrator-core.md`
- WHEN el orquestador recibe el comando
- THEN DEBE invocar el skill `sdd-changelog`
- AND DEBE pasar el nombre del proyecto como argumento

### Requisito: Integración con install_test.sh

El sistema DEBE actualizar el contador de skills en `scripts/install_test.sh` de 12 a 13 al crear el nuevo skill.

#### Escenario: Verificación de Contador

- GIVEN el skill `sdd-changelog` ha sido creado
- AND se ejecuta el test de instalación
- WHEN `install_test.sh` cuenta los skills
- THEN DEBE encontrar 13 skills (no 12)
- AND DEBE pasar la validación del contador
