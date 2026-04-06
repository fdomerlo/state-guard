# Delta para Persistencia y Ejecución

## Propósito

Esta especificación delta documenta los cambios necesarios para eliminar el soporte del modo `none` (fallback para editores inline/pasivos) del framework Agentify SDD. El framework asume por diseño que el 100% de los sub-agentes tienen acceso a herramientas nativas de I/O (filesystem, ejecución de comandos).

## Requisitos ELIMINADOS

### Requisito: Soporte de Modo None en Persistencia

(Motivo: Los editores inline/pasivos como VS Code, Cursor o Codex no son compatibles con SDD. El framework fue diseñado para agentes CLI con capacidades nativas de I/O.)

El sistema DEJARA DE soportar el modo de persistencia `none` como fallback para editores sin acceso a disco.

#### Escenario: Intento de Usar Modo None (ELIMINADO)

- GIVEN un usuario configura `artifact_store.mode: none`
- WHEN el orquestador inicializa SDD
- THEN el sistema DEBE rechazar la configuración con un error explícito
- AND el sistema DEBE sugerir `openspec` como única opción válida

### Requisito: Fallback de Registry para Editores Inline (ELIMINADO)

(Motivo: El framework es Agent-First/CLI-First. No se provee fallback para editores pasivos.)

El sistema DEJARA DE incluir lógica de fallback en skill-registry para detectar y manejar editores como Cursor, VSCode Copilot o Codex.

#### Escenario: Registry Detecta Editor Inline (ELIMINADO)

- GIVEN skill-registry se ejecuta en un editor inline
- WHEN el agente intenta detectar capacidades de I/O
- THEN el sistema DEBE omitir cualquier lógica de fallback
- AND el sistema DEBE fallar con mensaje indicando que se requiere agente CLI

## Requisitos MODIFICADOS

### Requisito: Modo de Persistencia Válido

(Anteriormente: El sistema soportaba múltiples modos: `openspec`, `none`, y otros.)

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

(Anteriormente: sdd-verify incluía lógica condicional para el modo `none`.)

La verificación de implementación DEBE asumir exclusivamente el modo `openspec`. La skill sdd-verify DEBE eliminar cualquier referencia al modo `none` y fallar si detecta menciones a este modo en código.

#### Escenario: Verificación Encuentra Menciones a Modo None

- GIVEN sdd-review se ejecuta contra el código
- WHEN el análisis detecta referencias al modo `none` en archivos de skills
- THEN el sistema DEBE marcar la verificación como fallida
- AND el sistema DEBE reportar las ubicaciones exactas de las menciones

### Requisito: Skills de Fases Sin Menciones a Modo None

(Anteriormente: Múltiples SKILL.md contenían menciones al modo `none` como referencia histórica o documentación.)

Las skills de todas las fases SDD DEBEN eliminar cualquier mención al modo `none`. La documentación DEBE indicar exclusivamente `openspec` como modo válido.

#### Escenario: Skill Contiene Referencia a Modo None

- GIVEN una skill (sdd-verify, sdd-review, sdd-fix, sdd-split) contiene texto mencionando el modo `none`
- WHEN el usuario ejecuta la skill
- THEN el sistema DEBE identificar la referencia como obsoleta
- AND el sistema DEBE sugerir eliminación de dicha referencia

## Requisitos AGREGADOS

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
