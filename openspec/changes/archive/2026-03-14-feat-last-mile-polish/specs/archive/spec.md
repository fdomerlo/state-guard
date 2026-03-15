# Delta para Archive

## Propósito

Esta especificación agrega seguridad al proceso de archivado, verificando que el repositorio git no tenga cambios sin commitear belonging al cambio que se está archivando. Esto previene la pérdida de trabajo no persistido.

## Requisitos AGREGADOS

### Requisito: Verificación de Estado Git Antes de Archivar

El sistema DEBE verificar el estado del repositorio git antes de mover la carpeta del cambio al archivo. SIEMPRE DEBE ejecutar `git status --porcelain` y analizar los archivos modificados.

#### Escenario: Archivado con Repositorio Limpio

- GIVEN el usuario ejecuta `/sdd-archive` para un cambio
- AND el repositorio git está limpio (sin archivos modificados)
- WHEN el skill `sdd-archive` procesa el archivado
- THEN DEBE proceder con la sincronización de specs y movimiento al archivo
- AND DEBE mostrar mensaje de éxito

#### Escenario: Archivado con Cambios Sin Commitear del Cambio

- GIVEN el usuario ejecuta `/sdd-archive` para un cambio llamado "mi-feature"
- AND el repositorio tiene archivos modificados sin commitear
- AND los archivos modificados están dentro del directorio `openspec/changes/mi-feature/`
- WHEN el skill `sdd-archive` ejecuta `git status --porcelain`
- THEN DEBE detectar los archivos modificados
- AND DEBE BLOQUEAR el archivado inmediatamente
- AND DEBE mostrar mensaje de error indicando qué archivos están sin commitear
- AND DEBE sugerir al usuario hacer commit antes de continuar

#### Escenario: Archivado con Cambios Sin Commitear de Otros Directorios

- GIVEN el usuario ejecuta `/sdd-archive` para un cambio llamado "mi-feature"
- AND el repositorio tiene archivos modificados sin commitear
- AND los archivos modificados están en otros directorios (no en `openspec/changes/mi-feature/`)
- WHEN el skill `sdd-archive` ejecuta `git status --porcelain`
- AND filtra solo los archivos dentro del directorio del cambio
- THEN DEBE proceder con el archivado (los cambios son de otros directorios)
- AND DEBE mostrar advertencia opcional sobre otros cambios en el repositorio

#### Escenario: Repositorio Sin Git

- GIVEN el usuario ejecuta `/sdd-archive` para un cambio
- AND el directorio del proyecto NO es un repositorio git (no existe `.git/`)
- WHEN el skill intenta ejecutar `git status --porcelain`
- THEN DEBE continuar con el archivado sin verificación git
- AND DEBE mostrar информационное сообщение que la verificación fue omitida

#### Escenario: Git No Disponible en el Sistema

- GIVEN el usuario ejecuta `/sdd-archive` para un cambio
- AND el comando `git` no está disponible en el PATH
- WHEN el skill intenta ejecutar `git status --porcelain`
- THEN DEBE continuar con el archivado sin verificación git
- AND DEBE mostrar advertencia que git no está disponible
