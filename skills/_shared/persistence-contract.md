# Contrato de Persistencia (Compartido entre todas las skills SDD)

## Resolución de Modo

El orquestador pasa `artifact_store.mode` con uno de estos valores: `openspec | none`.

Resolución por defecto (cuando el orquestador no establece explícitamente un modo):

1. Si el directorio `openspec/` existe en el proyecto → usar `openspec`.
2. De lo contrario → usar `none`.

Cuando se caiga al modo `none`, recomienda al usuario ejecutar `/sdd-init` para habilitar la persistencia local en `openspec` y obtener mejores resultados.

## Comportamiento por Modo

| Modo | Lee desde | Escribe en | Archivos en Proyecto |
|------|-----------|------------|----------------------|
| `openspec` | Sistema de Archivos (ver `openspec-convention.md`) | Sistema de Archivos | Sí |
| `none` | Contexto del prompt del orquestador | En ningún lado | Nunca |

## Persistencia de Estado (Orquestador)

El orquestador persiste el estado del DAG (Grafo Acíclico Dirigido) después de la transición de cada fase. Esto permite la recuperación del SDD después de una compactación de contexto del IDE.

| Modo | Persistencia de Estado | Recuperación de Estado |
|------|------------------------|------------------------|
| `openspec` | Escribe `openspec/changes/{change-name}/state.yaml` | Lee `openspec/changes/{change-name}/state.yaml` |
| `none` | Imposible — el estado vive solo en el contexto efímero | Imposible — advertir al usuario |

## Reglas Comunes

- Si el modo es `none`, NO crees ni modifiques ningún archivo del proyecto. Retorna los resultados únicamente de forma inline (en el chat).
- Si el modo es `openspec`, escribe archivos ÚNICAMENTE en las rutas definidas en `openspec-convention.md`.
- NUNCA fuerces la creación de la carpeta `openspec/` a menos que el orquestador haya pasado explícitamente el modo `openspec` o el usuario haya ejecutado el comando `/sdd-init`.
- Si no estás seguro de qué modo usar, por defecto usa `none`.

## Reglas de Contexto para Sub-Agentes

Los sub-agentes se inician con un contexto fresco y SIN acceso a las instrucciones del orquestador. El orquestador controla qué contexto reciben, y los sub-agentes son responsables de persistir (guardar) lo que producen.

### Quién lee, quién escribe

| Tarea / Fase | Quién lee del backend (disco) | Quién escribe en el backend (disco) |
|--------------|-------------------------------|-------------------------------------|
| Fase SDD (con dependencias) | **El sub-agente** lee los artefactos previos directamente del disco | **El sub-agente** guarda su propio artefacto |
| Fase SDD (sin dependencias, ej. explorar) | Nadie | **El sub-agente** guarda su artefacto (si aplica) |

### Instrucciones del Orquestador para Sub-agentes

Al lanzar un sub-agente para una fase SDD, el orquestador DEBE incluir estas instrucciones de persistencia en el prompt:

**Fase SDD (con dependencias)**:

```text
Modo de almacenamiento: openspec
Lee estos artefactos antes de comenzar:
- {ruta_del_archivo para cada dependencia}
Después de completar tu trabajo, persiste (guarda) tu artefacto siguiendo las convenciones de openspec-convention.md.

```

**Fase SDD (sin dependencias)**:

```text
Modo de almacenamiento: openspec
Después de completar tu trabajo, persiste (guarda) tu artefacto siguiendo las convenciones de openspec-convention.md.

```

## Nivel de Detalle

El orquestador también puede pasar un nivel de detalle `detail_level`: `concise | standard | deep`.
Esto controla la verbosidad de la salida en el chat, pero NO afecta lo que se guarda en disco — siempre se debe persistir el artefacto completo.
