# Contrato de Persistencia (Compartido entre todas las skills SDD)

## Persistencia Directa (File System)

El framework utiliza el File System como único mecanismo de persistencia nativo. Todas las operaciones de lectura y escritura de artefactos se realizan bajo el directorio `openspec/` siguiendo la convención [openspec-convention.md](./openspec-convention.md).

## Persistencia de Estado del Orquestador

El orquestador persiste el estado del DAG en `openspec/changes/{change-name}/state.yaml` después de cada transición de fase exitosa.
Ver [orchestrator-core.md](./orchestrator-core.md) (sección "Gestión de Estado") para el schema completo y las reglas de escritura.

**Responsabilidad exclusiva:** Solo el orquestador escribe y mantiene `state.yaml`.
Las skills de sub-agentes no interactúan con este archivo directamente, con la ÚNICA EXCEPCIÓN de la skill `sdd-status`, que tiene autorización para leerlo masivamente, y la skill `sdd-checkpoint`, que tiene autorización para escribir el `session_summary` en él.

## Reglas de Contexto para Sub-Agentes

Los sub-agentes inician con contexto fresco y SIN acceso a las instrucciones del orquestador. El orquestador controla qué contexto reciben. Los sub-agentes son responsables de persistir lo que producen directamente en el disco.

### Quién lee, quién escribe

| Tarea / Fase | Quién lee del disco | Quién escribe en el disco |
|---|---|---|
| Fase con dependencias | **El sub-agente** lee artefactos previos directamente | **El sub-agente** guarda su artefacto |
| Fase sin dependencias (ej: explore) | Nadie | **El sub-agente** guarda su artefacto (si aplica) |
| Transición de fase | — | **El orquestador** actualiza `state.yaml` |

### Protocolo de Comunicación (Orquestador → Sub-agente)

**Fase con dependencias:**

```text
Lee estos artefactos antes de comenzar:
- {ruta del archivo para cada dependencia}
Si hay un glosario en openspec/config.yaml, cargarlo y usarlo para terminología consistente.
Después de completar tu trabajo, persistí tu artefacto siguiendo openspec-convention.md.
```

**Fase sin dependencias:**

```text
Si hay un glosario en openspec/config.yaml, cargarlo y usarlo para terminología consistente.
Después de completar tu trabajo, persistí tu artefacto siguiendo openspec-convention.md.
```

## Nivel de Detalle

El orquestador puede pasar `detail_level`: `concise | standard | deep`.
Esto controla la verbosidad de la salida en el chat, pero NO afecta lo que se guarda en disco — siempre se persiste el artefacto completo.

## Carga de Glosario (para sub-agentes)

Al inicio de cada skill:

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
