# Contrato de Persistencia (Compartido entre todas las skills SDD)

## Resolución de Modo

El orquestador pasa `artifact_store.mode` con uno de estos valores: `openspec | none`.

Resolución por defecto (cuando el orquestador no establece explícitamente un modo):

1. Si el directorio `openspec/` existe en el proyecto → usar `openspec`.
2. De lo contrario → usar `none`.

Cuando se caiga al modo `none`, recomendar al usuario ejecutar `/sdd-init` para habilitar la persistencia local.

## Comportamiento por Modo

| Modo | Lee desde | Escribe en | Archivos en el repositorio |
|------|-----------|------------|---------------------------|
| `openspec` | Filesystem (ver `openspec-convention.md`) | Filesystem | Sí |
| `none` | Contexto del prompt del orquestador | En ningún lado | Nunca |

## Persistencia de Estado del Orquestador

El orquestador persiste el estado del DAG después de cada transición de fase exitosa.
Ver `orchestrator-core.md` (sección "Gestión de Estado") para el schema completo y las reglas de escritura.

| Modo | Persistencia de Estado | Recuperación de Estado |
|------|------------------------|------------------------|
| `openspec` | Escribe `openspec/changes/{change-name}/state.yaml` | Lee `openspec/changes/*/state.yaml` |
| `none` | Imposible — el estado vive solo en contexto efímero | Imposible — advertir al usuario |

**Responsabilidad exclusiva:** Solo el orquestador escribe y mantiene `state.yaml`.
Las skills de sub-agentes no interactúan con este archivo directamente, con la ÚNICA EXCEPCIÓN de la skill `sdd-status`, que tiene autorización para leerlo masivamente.

## Reglas Comunes

- Si el modo es `none`, NO crear ni modificar ningún archivo del proyecto. Retornar resultados únicamente de forma inline (en el chat).
- Si el modo es `openspec`, escribir archivos ÚNICAMENTE en las rutas definidas en `openspec-convention.md`.
- NUNCA forzar la creación de `openspec/` a menos que el orquestador haya pasado explícitamente `openspec` o el usuario haya ejecutado `/sdd-init`.
- Si no estás seguro de qué modo usar → por defecto `none`.

## Reglas de Contexto para Sub-Agentes

Los sub-agentes inician con contexto fresco y SIN acceso a las instrucciones del orquestador.
El orquestador controla qué contexto reciben. Los sub-agentes son responsables de persistir lo que producen.

### Quién lee, quién escribe

| Tarea / Fase | Quién lee del disco | Quién escribe en el disco |
|---|---|---|
| Fase con dependencias | **El sub-agente** lee artefactos previos directamente | **El sub-agente** guarda su artefacto |
| Fase sin dependencias (ej: explore) | Nadie | **El sub-agente** guarda su artefacto (si aplica) |
| Transición de fase | — | **El orquestador** actualiza `state.yaml` |

### Instrucciones del Orquestador al lanzar Sub-agentes

**Fase con dependencias:**

```text
Modo de almacenamiento: openspec
Lee estos artefactos antes de comenzar:
- {ruta del archivo para cada dependencia}
Si hay un glosario en openspec/config.yaml, cargarlo y usarlo para terminología consistente.
Después de completar tu trabajo, persistí tu artefacto siguiendo openspec-convention.md.
```

**Fase sin dependencias:**

```text
Modo de almacenamiento: openspec
Si hay un glosario en openspec/config.yaml, cargarlo y usarlo para terminología consistente.
Después de completar tu trabajo, persistí tu artefacto siguiendo openspec-convention.md.
```

## Nivel de Detalle

El orquestador puede pasar `detail_level`: `concise | standard | deep`.
Esto controla la verbosidad de la salida en el chat, pero NO afecta lo que se guarda en disco — siempre se persiste el artefacto completo.

## Carga de Glosario (para sub-agentes)

Al inicio de cada skill, después de determinar el modo de persistencia:

1. Buscar archivo `openspec/config.yaml`
2. Si existe y contiene clave `glossary`, cargar los términos
3. Usar los términos definidos para mantener consistencia en el output
4. Si no existe el glosario, continuar normalmente (es opcional)

Los términos del glosario deben respetarse al generar artefactos:
- Usar la terminología definida en lugar de sinónimos
- Mantener consistencia semántica en proposal.md, specs/, design.md, etc.

### Graceful Degradation

- Si `openspec/config.yaml` NO existe → continuar sin glosario
- Si el archivo existe pero NO tiene sección `glossary:` → continuar sin glosario
- Si la sección `glossary:` existe pero está vacía o malformada → continuar sin glosario, sin lanzar error

Esta estrategia permite que proyectos existentes (sin glosario) funcionen correctamente mientras nuevos proyectos pueden adoptar el glosario cuando lo necesiten.
