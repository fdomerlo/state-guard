# Especificación de Documentación - MANUAL

## Propósito

Este documento define las especificaciones para el archivo MANUAL.md del proyecto Agentify SDD. El MANUAL sirve como guía técnica profunda para usuarios que necesitan comprender la arquitectura, configuración avanzada y flujos de trabajo complejos del sistema.

## Requisitos

### Requisito: Explicación de Arquitectura DRY

El MANUAL **DEBE** explicar la arquitectura DRY (Don't Repeat Yourself) del sistema.

El sistema **DEBE** describir:
- Cómo funciona la compilación dinámica del orquestador
- El mecanismo de carga de skills y commands
- La reutilización de código a través del sistema de herencia de skills

#### Escenario: Arquitectura DRY

- GIVEN Un usuario que quiere entender cómo funciona la arquitectura
- WHEN Lee la sección de arquitectura DRY del MANUAL
- THEN Encuentra explicación de la compilación dinámica del orquestador
- AND Entiende cómo se reutiliza el código mediante skills

### Requisito: Explicación del State Machine ACID

El MANUAL **DEBE** explicar el sistema de State Machine ACID implementado en el orquestador.

El sistema **DEBE** describir:
- El archivo state.yaml y su estructura
- La prevención de colisiones en cambios concurrentes
- Las propiedades ACID (Atomicidad, Consistencia, Isolation, Durabilidad) del sistema de estados

#### Escenario: State Machine ACID

- GIVEN Un usuario que quiere entender la gestión de estados
- WHEN Lee la sección de State Machine del MANUAL
- THEN Encuentra explicación de state.yaml y su estructura
- AND Entiende cómo se previenen las colisiones en cambios concurrentes

### Requisito: Documentación de config.yaml

El MANUAL **DEBE** detallar el uso del archivo config.yaml.

El sistema **DEBE** incluir:
- Glosario de configuraciones disponibles
- Convenciones de nomenclatura (kebab-case)
- Descripción del parámetro test_command
- Ejemplos de configuración

#### Escenario: Configuración con config.yaml

- GIVEN Un usuario que quiere configurar el proyecto
- WHEN Lee la sección de config.yaml del MANUAL
- THEN Encuentra el glosario de configuraciones
- AND Aprende las convenciones de kebab-case
- AND Entiende el uso de test_command

### Requisito: Cobertura de Flujos Avanzados

El MANUAL **DEBE** cubrir los flujos avanzados del orquestador.

El sistema **DEBE** documentar:
- /sdd-split: División de proposals monolíticas en sub-cambios
- /sdd-review: Auditoría estática de código contra especificaciones
- /sdd-fix: Reparación de problemas comunes

#### Escenario: Flujo sdd-split

- GIVEN Un usuario con una proposal grande que necesita dividir
- WHEN Lee la documentación de /sdd-split
- THEN Entiende cómo dividir proposals en sub-cambios manejables

#### Escenario: Flujo sdd-review

- GIVEN Un usuario que quiere auditar su código contra specs
- WHEN Lee la documentación de /sdd-review
- THEN Entiende cómo realizar auditoría estática de código

#### Escenario: Flujo sdd-fix

- GIVEN Un usuario que tiene problemas comunes con el sistema
- WHEN Lee la documentación de /sdd-fix
- THEN Encuentra soluciones a problemas comunes

### Requisito: Tono Profesional y Técnico

El MANUAL **DEBE** mantener un tono profesional, pragmático y directo con orientación técnica.

El sistema **DEBE**:
- Ser directo en las explicaciones
- Asumir conocimiento técnico del lector
- Incluir ejemplos prácticos cuando sea necesario

#### Escenario: Tono Técnico del MANUAL

- GIVEN Un usuario técnico leyendo el MANUAL
- WHEN Lee el contenido del documento
- THEN El tono es profesional y directo
- AND Las explicaciones asumen conocimiento técnico previo

### Requisito: Eliminación de Contenido Obsoleto

El MANUAL **DEBE** eliminar contenido obsoleto y redundante.

El sistema **DEBE**:
- Remover información que ya no aplica al proyecto
- Eliminar redundancias con el README
- Actualizar comandos y características que cambiaron

#### Escenario: Contenido Actualizado

- GIVEN Un usuario leyendo el MANUAL
- WHEN Encuentra información técnica
- THEN La información está actualizada y no es obsoleta
- AND No hay redundancia con el README

## Criterios de Verificación

- Arquitectura DRY explicada (compilación dinámica del orquestador)
- State Machine ACID documentada (state.yaml y prevención de colisiones)
- config.yaml detallado (glosario, kebab-case, test_command)
- Flujos avanzados cubiertos (/sdd-split, /sdd-review, /sdd-fix)
- Tono profesional, pragmático y directo
- Contenido obsoleto y redundante eliminado
