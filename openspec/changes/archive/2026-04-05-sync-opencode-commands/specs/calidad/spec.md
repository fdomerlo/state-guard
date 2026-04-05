# Especificación de Calidad - Sincronización OpenCode Commands

## Propósito

Sincronizar la integración de OpenCode CLI con el core SDD refactorizado, exponiendo los nuevos comandos de seguridad (`/sdd-checkpoint`, `/sdd-rollback`) y aplicando restricciones de contexto para optimizar el rendimiento del modelo.

## Requisitos

### Requisito: Nuevos Comandos en OpenCode

El sistema DEBE incluir los comandos `sdd-checkpoint` y `sdd-rollback` en la integración de OpenCode.

#### Escenario: Comando checkpoint disponible

- GIVEN el usuario ejecuta `/sdd-checkpoint` en OpenCode
- WHEN el comando delega al skill `sdd-checkpoint`
- THEN el skill genera un checkpoint y lo guarda en el archivo de sesión
- AND retorna confirmación al usuario

#### Escenario: Comando rollback disponible

- GIVEN el usuario ejecuta `/sdd-rollback` en OpenCode
- WHEN el comando delega al skill `sdd-rollback`
- THEN el skill purga la carpeta del cambio y restaura archivos desde git
- AND retorna confirmación al usuario

### Requisito: Registro en opencode.json

El sistema DEBE registrar los nuevos comandos en el archivo de configuración de OpenCode.

#### Escenario: Comandos registrados correctamente

- GIVEN se crea un nuevo archivo de comando en `commands/`
- WHEN el archivo se agrega a `integrations/opencode/opencode.json`
- THEN el comando está disponible para ejecución via `/sdd-{nombre}`

### Requisito: Restricción de Contexto en OpenCode

El sistema DEBE indicar a los modelos de OpenCode leer solo Specs Delta.

#### Escenario: sdd-propose usa specs delta

- GIVEN `sdd-propose` se ejecuta en OpenCode
- WHEN el modelo recibe el prompt
- THEN solo lee el archivo `proposal.md` del cambio
- AND NO lee toda la carpeta `changes/`

#### Escenario: sdd-apply usa specs delta

- GIVEN `sdd-apply` se ejecuta en OpenCode
- WHEN el modelo recibe el prompt
- THEN solo lee los archivos en `openspec/changes/{nombre}/specs/`
- AND NO lee toda la carpeta `specs/` del proyecto

#### Escenario: sdd-verify usa specs delta

- GIVEN `sdd-verify` se ejecuta en OpenCode
- WHEN el modelo recibe el prompt
- THEN solo lee los archivos delta en `changes/{nombre}/specs/` y `design.md`
- AND NO lee toda la carpeta `specs/` del proyecto

### Requisito: Batching en sdd-apply

El sistema DEBE indicar al modelo esperar lote inline de tareas del orquestador.

#### Escenario: sdd-apply recibe lote inline

- GIVEN `sdd-apply` se ejecuta
- WHEN el orquestador pasa tareas inline en el prompt
- THEN el modelo procesa el lote sin leer `tasks.md` completo
- AND procesa cada tarea secuencialmente

#### Escenario: sdd-apply con batching optimiza contexto

- GIVEN múltiples tareas pending en el change
- WHEN `sdd-apply` recibe el lote
- THEN el contexto incluye solo las tareas del lote
- AND no requiere lectura adicional de archivos de tareas

## Criterios de Éxito

- [ ] `sdd-checkpoint.md` creado en `commands/`
- [ ] `sdd-rollback.md` creado en `commands/`
- [ ] `opencode.json` actualizado con nuevos comandos
- [ ] `sdd-apply.md` tiene restricción de specs delta + batching
- [ ] `sdd-propose.md` tiene restricción de specs delta
- [ ] `sdd-verify.md` tiene restricción de specs delta
