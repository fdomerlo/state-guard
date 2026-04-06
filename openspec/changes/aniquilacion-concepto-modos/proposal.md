# Propuesta: Aniquilación del Concepto de Modos de Almacenamiento

## Intención
El framework Agentify-SDD ha evolucionado hacia un modelo 100% Agent-First/CLI-First. La distinción entre modos de almacenamiento (`openspec` vs `none`) es una deuda técnica de la era de los editores pasivos. Mantener esta lógica en las especificaciones y contratos de los agentes consume tokens innecesarios, aumenta la complejidad cognitiva y ralentiza la delegación. Esta propuesta busca eliminar totalmente el concepto de "modo" y consolidar la persistencia en el File System como el único comportamiento natural del sistema.

## Alcance

### Dentro del Alcance
- **Eliminación de Variables**: Suprimir `artifact_store.mode` de `openspec/config.yaml`.
- **Refactorización de Specs**: Reescribir `openspec/specs/persistencia/spec.md` para eliminar la sección de "Resolución de Modo".
- **Limpieza de Contratos**: Actualizar `skills/_shared/persistence-contract.md` eliminando tablas comparativas de modos.
- **Purga de Skills**: Eliminar frases como "En modo openspec..." de todos los archivos `SKILL.md`.
- **Simplificación del Orquestador**: Eliminar la inyección de la variable de modo en las delegaciones a sub-agentes.

### Fuera del Alcance
- Cambiar la estructura de directorios de `openspec/`.
- Modificar la lógica interna de cómo se escriben los archivos (solo se cambia el *por qué* y la *configuración*).

## Enfoque
Se adoptará un enfoque de "Persistencia Implícita". En lugar de que el orquestador diga "Usa el modo openspec", el contrato de persistencia establecerá que "Los artefactos se escriben en el File System siguiendo la convención OpenSpec". Se eliminarán los condicionales en las skills que preguntan por el modo.

## Áreas Afectadas

| Área | Impacto | Descripción |
| :--- | :--- | :--- |
| `openspec/config.yaml` | Modificado | Eliminar clave `artifact_store.mode`. |
| `openspec/specs/persistencia/spec.md` | Modificado | Eliminar requisitos de "Modo Válido" y "Forzamiento". |
| `skills/_shared/persistence-contract.md` | Modificado | Eliminar tablas de comparación y referencias a `mode`. |
| `skills/*/SKILL.md` | Modificado | Eliminar menciones condicionales al modo. |
| `skills/_shared/orchestrator-core.md` | Modificado | Eliminar configuración por defecto del modo. |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
| :--- | :--- | :--- |
| Ruptura de integraciones externas | Media | Auditar scripts en `scripts/` que usen `yq` o `grep` sobre el config para buscar el modo. |
| Inconsistencia en sub-agentes legacy | Baja | Los sub-agentes actuales ya usan openspec por defecto; la eliminación de la variable no debería afectar su lógica de escritura si siguen el contrato de rutas. |

## Plan de Rollback
1. Ejecutar `/sdd-rollback aniquilacion-concepto-modos`.
2. Restaurar archivos mediante `git checkout openspec/ specs/ skills/`.

## Criterios de Éxito
- [ ] `grep -ri "artifact_store.mode" .` devuelve 0 resultados.
- [ ] `sdd-init` genera un `config.yaml` sin la clave de modo.
- [ ] Un flujo `/sdd-new` completo funciona correctamente sin inyectar variables de modo.
