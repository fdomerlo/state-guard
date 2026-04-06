# Delta para Persistencia (Aniquilación de Modos)

Este documento especifica la transición hacia un modelo de persistencia implícito, eliminando la configuración de "modos".

## Requisitos AGREGADOS

### Requisito: Persistencia Implícita en File System

El framework SHALL asumir que toda persistencia de artefactos se realiza directamente en el File System siguiendo la convención OpenSpec. No DEBE existir una variable de configuración para alternar este comportamiento.

#### Escenario: Escritura de Artefacto

- GIVEN un sub-agente genera un artefacto (propose, spec, design, task)
- WHEN el sistema solicita la persistencia
- THEN el archivo DEBE escribirse en `openspec/changes/{nombre-cambio}/` de forma automática
- AND no se DEBE consultar ninguna variable de "modo" para esta operación

## Requisitos MODIFICADOS

### Requisito: Inicialización de Contexto

El orquestador SHALL inicializar el contexto de cambio creando la estructura de directorios necesaria sin inyectar variables de modo en el `state.yaml` o en el entorno del sub-agente.
(Anteriormente: El orquestador forzaba `artifact_store.mode: openspec`).

#### Escenario: Inicialización Limpia

- GIVEN un usuario inicia un nuevo cambio mediante `/sdd-new`
- WHEN el orquestador crea el archivo `state.yaml`
- THEN el archivo `state.yaml` NO DEBE contener la clave `artifact_store.mode`
- AND el sistema DEBE estar listo para operar en disco por defecto

### Requisito: Configuración del Proyecto

El archivo `openspec/config.yaml` SHALL omitir la clave `artifact_store.mode`.
(Anteriormente: Se requería que esta clave tuviera el valor `openspec`).

#### Escenario: Generación de Configuración

- GIVEN el comando `sdd-init` se ejecuta en un proyecto
- WHEN se genera el archivo `openspec/config.yaml`
- THEN el archivo resultante NO DEBE incluir la sección `artifact_store`

## Requisitos ELIMINADOS

### Requisito: Modo de Persistencia Válido

(Motivo: Con la eliminación de la abstracción de modos, ya no es necesario validar contra valores fijos. La persistencia es unívoca e implícita.)

### Requisito: Forzamiento de Artifact Store Mode

(Motivo: No se puede forzar una variable que ya no existe en el contrato.)

### Requisito: Verificación de Implementación (Detección de Modo None)

(Motivo: Este requisito se vuelve obsoleto ya que el sistema ya no reconoce el concepto de "modos". La verificación ahora se centrará en el cumplimiento de rutas, no en la ausencia de menciones a `none`, aunque `sdd-review` seguirá auditando contra estas nuevas specs.)
