# Contrato de Persistencia (Compartido entre todas las skills SDD)

## Persistencia Directa (File System)

El framework utiliza el File System como único mecanismo de persistencia nativo. Todas las operaciones de lectura y escritura de artefactos se realizan bajo el directorio `openspec/` siguiendo la convención [openspec-convention.md](./openspec-convention.md).

## Persistencia Transaccional del Estado

El Memory Guard persiste el estado del DAG en `openspec/changes/{change-name}/state.yaml` mediante el protocolo de transacciones (ver [transaction-protocol.md](./transaction-protocol.md)).

Cada transición de fase sigue el ciclo: BEGIN → EXECUTE (persistir artefacto) → COMMIT (actualizar state.yaml).

**Responsabilidad de escritura:**

| Quién | Qué escribe en state.yaml |
|-------|---------------------------|
| Memory Guard (transacción) | Todos los campos de fase y transacción |
| `sdd-checkpoint` | Solo `session_summary` y `last_updated` |
| `sdd-fix` | Todo el archivo (reparación y migración) |

## Ejecución Inline vs Delegada

### Ejecución Inline (por defecto)

Cuando ejecutás una fase inline, vos mismo sos responsable de:

1. Ejecutar BEGIN (escribir `txn_status: in_progress` en state.yaml)
2. Leer artefactos de dependencia del disco
3. Ejecutar la fase
4. Persistir el artefacto resultante en disco
5. Ejecutar COMMIT (actualizar state.yaml)

### Ejecución Delegada (fases pesadas)

Cuando delegás a un sub-agente:

| Tarea | Quién lo hace |
|-------|---------------|
| Leer artefactos de dependencia | **El sub-agente** |
| Ejecutar la fase | **El sub-agente** |
| Persistir artefacto en disco | **El sub-agente** |
| Actualizar `state.yaml` (COMMIT) | **Vos (Memory Guard)** |

El sub-agente NUNCA escribe en `state.yaml`. Solo persiste sus artefactos y retorna un resumen.

## Protocolo de Comunicación (para fases delegadas)

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

## Carga de Glosario

Al inicio de cada skill:

1. Buscar archivo `openspec/config.yaml`
2. Si existe y contiene clave `glossary`, cargar los términos
3. Usar los términos definidos para mantener consistencia en el output
4. Si no existe el glosario, continuar normalmente (es opcional)

### Graceful Degradation

- Si `openspec/config.yaml` NO existe → continuar sin glosario
- Si el archivo existe pero NO tiene sección `glossary:` → continuar sin glosario
- Si la sección `glossary:` existe pero está vacía o malformada → continuar sin glosario, sin lanzar error
