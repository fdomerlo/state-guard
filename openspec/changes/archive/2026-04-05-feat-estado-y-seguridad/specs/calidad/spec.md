# Especificación de Calidad - Estado y Seguridad SDD

## Propósito

Establecer mecanismos de seguridad ante fallos y optimizar la recuperación de sesión para el orquestador SDD. El sistema debe permitir guardar resúmenes de estado recuperables y proporcionar habilidades de emergencia para revertir cambios problemáticos.

## Requisitos

### Requisito: Campo session_summary en state.yaml

El sistema DEBE incluir un nuevo campo `session_summary` en el schema de state.yaml.

- **Tipo de Campo**: string
- **Máximo**: 5 líneas de texto
- **Propósito**: Almacenar resumen del estado actual del cambio para recuperación rápida de sesión

#### Escenario: Estado con session_summary

- GIVEN un change activo en cualquier fase
- WHEN se ejecuta sdd-checkpoint
- THEN el campo session_summary contiene hasta 5 líneas de resumen
- AND last_updated se actualiza automáticamente

#### Escenario: Campo session_summary ausente

- GIVEN un state.yaml existente sin campo session_summary
- WHEN se requiere leer el estado del cambio
- THEN el campo session_summary puede estar vacío o ausente
- AND el sistema lo trata como null

### Requisito: Skill sdd-checkpoint

El sistema DEBE tener una skill que resuma el estado del cambio activo.

- **Trigger**: `/sdd-checkpoint`
- **Ubicación**: `skills/sdd-checkpoint/SKILL.md`
- **Fase**: checkpoint (skill directa)

#### Escenario: Checkpoint genera resumen

- GIVEN un cambio activo con state.yaml
- WHEN el usuario ejecuta /sdd-checkpoint
- THEN la skill genera un resumen de hasta 5 líneas
- AND guarda el resumen en el campo session_summary del state.yaml
- AND actualiza el campo last_updated

#### Escenario: Checkpoint sin cambio activo

- GIVEN ningún cambio activo en el workspace
- WHEN el usuario ejecuta /sdd-checkpoint
- THEN la skill muestra error indicando que no hay cambio activo
- AND no modifica ningún archivo

### Requisito: Skill sdd-rollback

El sistema DEBE tener una skill de emergencia para revertir el entorno.

- **Trigger**: `/sdd-rollback`
- **Ubicación**: `skills/sdd-rollback/SKILL.md`
- **Fase**: rollback (skill directa)

#### Escenario: Rollback purga cambios

- GIVEN un cambio activo con problemas
- WHEN el usuario ejecuta /sdd-rollback
- THEN la carpeta del cambio en openspec/changes/{nombre}/ se purga
- AND git checkout -- . restaura archivos modificados
- AND git clean -fd elimina archivos no rastreados

#### Escenario: Rollback confirma antes de ejecutar

- GIVEN un cambio activo
- WHEN el usuario ejecuta /sdd-rollback
- THEN la skill solicita confirmación antes de proceder
- AND si el usuario confirma, ejecuta las operaciones de purge
- AND si el usuario cancela, no ejecuta ninguna acción destructiva

#### Escenario: Rollback sin cambio activo

- GIVEN ningún cambio activo
- WHEN el usuario ejecuta /sdd-rollback
- THEN la skill muestra error indicando que no hay cambio para revertir
- AND no ejecuta ninguna operación de git

### Requisito: Registro en orquestador

El sistema DEBE registrar los nuevos comandos en la documentación del orquestador.

- **Archivo**: `skills/_shared/orchestrator-commands.md`
- **Acción**: Agregar entradas para /sdd-checkpoint y /sdd-rollback

#### Escenario: Comandos registrados

- GIVEN el archivo orchestrator-commands.md existe
- WHEN se crean las skills checkpoint y rollback
- THEN se agregan entradas con trigger, descripción y ubicación
- AND el índice de skills se actualiza correctamente

## Validaciones

1. El campo session_summary NO DEBE exceder 5 líneas de texto
2. La skill sdd-checkpoint DEBE actualizar last_updated al guardar el resumen
3. La skill sdd-rollback DEBE confirmar antes de ejecutar operaciones destructivas
4. Ambos comandos DEBEN estar documentados en orchestrator-commands.md

## Notas de Implementación

- El resumen en session_summary DEBE incluir: fase actual, estado, y progreso de tareas
- El rollback DEBE ejecutar git checkout -- . desde la raíz del proyecto
- El rollback DEBE ejecutar git clean -fd desde la raíz del proyecto
