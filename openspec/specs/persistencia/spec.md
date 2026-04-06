# Spec: Persistencia y Ejecución

## Propósito

Esta especificación define el modelo de persistencia y ejecución del framework Agentify SDD. El framework asume por diseño que el 100% de los sub-agentes tienen acceso a herramientas nativas de I/O (filesystem, ejecución de comandos).

## Requisitos

### Requisito: Modo de Persistencia Válido

El sistema DEBE soportar únicamente el modo de persistencia `openspec`. Cualquier otro valor DEBE ser rechazado en fase de inicialización.

#### Escenario: Inicialización con Openspec

- GIVEN un usuario ejecuta SDD con un agente CLI (Claude Code, OpenCode, Gemini CLI, Antigravity)
- WHEN el orquestador inicializa el contexto
- THEN el sistema DEBE crear la estructura de carpetas en `openspec/changes/`
- AND el sistema DEBE escribir el archivo `state.yaml` con `artifact_store.mode: openspec`

#### Escenario: Inicialización con Modo Inválido

- GIVEN un usuario configura un valor diferente a `openspec` en `artifact_store.mode`
- WHEN el orquestador inicializa
- THEN el sistema DEBE rechazar la configuración
- AND el sistema DEBE mostrar un error indicando que solo `openspec` es válido

### Requisito: Verificación de Implementación

La verificación de implementación DEBE asumir exclusivamente el modo `openspec`. La skill sdd-verify DEBE eliminar cualquier referencia al modo `none` y fallar si detecta menciones a este modo en código.

#### Escenario: Verificación Encuentra Menciones a Modo None

- GIVEN sdd-review se ejecuta contra el código
- WHEN el análisis detecta referencias al modo `none` en archivos de skills
- THEN el sistema DEBE marcar la verificación como fallida
- AND el sistema DEBE reportar las ubicaciones exactas de las menciones

### Requisito: Skills de Fases Sin Menciones a Modo None

Las skills de todas las fases SDD DEBEN eliminar cualquier mención al modo `none`. La documentación DEBE indicar exclusivamente `openspec` como modo válido.

#### Escenario: Skill Contiene Referencia a Modo None

- GIVEN una skill (sdd-verify, sdd-review, sdd-fix, sdd-split) contiene texto mencionando el modo `none`
- WHEN el usuario ejecuta la skill
- THEN el sistema DEBE identificar la referencia como obsoleta
- AND el sistema DEBE sugerir eliminación de dicha referencia

### Requisito: Forzamiento de Artifact Store Mode

El orquestador DEBE forzar `artifact_store.mode: openspec` en todas las inicializaciones, sin importar la configuración proporcionada por el usuario.

#### Escenario: Configuración Ignora Valor del Usuario

- GIVEN un usuario intenta inicializar SDD con cualquier configuración de modo
- WHEN el orquestador procesa la inicialización
- THEN el sistema DEBE sobrescribir cualquier valor con `openspec`
- AND el sistema DEBE registrar esta sobrescritura en los logs

### Requisito: Documentación de Capacidades Requeridas

El framework DEBE documentar claramente que requiere agentes con capacidades nativas de I/O.

#### Escenario: Usuario Consulta Capacidades Requeridas

- GIVEN un usuario consulta la documentación del framework
- WHEN el usuario revisa los requisitos de ejecución
- THEN el documento DEBE indicar que se requieren agentes CLI con acceso a filesystem y herramientas
- AND el documento DEBE listar los agentes compatibles: Claude Code, OpenCode, Gemini CLI, Antigravity

---

## Historia del Cambio

### Cambio: purga-compatibilidad-inline-core (2026-04-06)

Este requisito fue añadido como un cambio para eliminar el soporte del modo `none` (fallback para editores inline/pasivos) del framework Agentify SDD.

**Requisitos ELIMINADOS por este cambio:**
- Soporte de Modo None en Persistencia (REQ-01)
- Fallback de Registry para Editores Inline (REQ-02)

**Requisitos MODIFICADOS por este cambio:**
- Modo de Persistencia Válido (anteriormente soportaba múltiples modos)
- Verificación de Implementación (anteriormente incluía lógica condicional para modo `none`)
- Skills de Fases Sin Menciones a Modo None (anteriormente contenía menciones históricas)

---

## Criterios de Verificación

1. Solo el modo `openspec` es aceptado en inicialización
2. Referencias al modo `none` son detectadas por sdd-review
3. Todas las skills mencionan exclusivamente `openspec`
4. La documentación indica agentes CLI como requisito
