# Diseño: Aniquilación del Concepto de Modos de Almacenamiento

## Enfoque Técnico
La estrategia técnica consiste en la **Consolidación de Persistencia Implícita**. Pasaremos de un modelo donde el orquestador "elige" y "fuerza" un modo (`artifact_store.mode: openspec`), a un modelo donde la capacidad de persistencia es una propiedad intrínseca del framework. Esto elimina la necesidad de variables de configuración, condicionales en las skills y explicaciones redundantes en los contratos de los agentes.

## Decisiones de Arquitectura

### Decisión: Eliminación de la Clave `artifact_store.mode`
**Elección**: Eliminar totalmente la entrada del archivo de configuración `config.yaml` y de los esquemas de inicialización.
**Alternativas consideradas**: Mantener la clave como "deprecated" o fija en `openspec`.
**Justificación**: Mantenerla perpetúa la confusión. Al eliminarla, obligamos a que cualquier lógica futura asuma el File System como único destino, reduciendo la superficie de error.

### Decisión: Redacción de Afirmaciones Directas en Skills
**Elección**: Transformar frases condicionales ("En modo openspec, haz X") en instrucciones directas ("Haz X").
**Alternativas consideradas**: Reemplazar "modo openspec" por "sistema de archivos".
**Justificación**: "Haz X" es más corto y potente para un sub-agente (ahorro de tokens). El contexto de que se opera en el sistema de archivos ya está dado por la disponibilidad de herramientas de I/O.

## Flujo de Datos (Simplificado)

    Orquestador ──(Ruta/Nombre Cambio)──→ Sub-agente
          │                                  │
          │                                  ▼
          └─────── (Persistencia Directa) ── openspec/changes/

## Cambios de Archivos

| Archivo | Acción | Descripción |
| :--- | :--- | :--- |
| `openspec/specs/persistencia/spec.md` | Modificar | Aplicar los deltas: eliminar resolución y forzamiento de modo. |
| `skills/_shared/orchestrator-core.md` | Modificar | Eliminar sección "Política de Almacenamiento". |
| `skills/_shared/persistence-contract.md` | Modificar | Eliminar tablas de modos y centralizar reglas en persistencia directa. |
| `skills/sdd-init/SKILL.md` | Modificar | Eliminar lógica de detección y forzado de modo en la fase de inicialización. |
| `skills/sdd-verify/SKILL.md` | Modificar | Eliminar dependencia de la variable `mode` para generar reportes. |
| `integrations/opencode/commands/*.md` | Modificar | Eliminar inyecciones hardcodeadas de "Modo: openspec". |

## Interfaces / Contratos
El contrato de persistencia se simplifica. Los sub-agentes ya no reciben:
```json
{
  "artifact_store": { "mode": "openspec" }
}
```
Sino simplemente las rutas absolutas donde deben operar, asumiendo que el acceso al disco es el comportamiento por defecto.

## Estrategia de Testing

| Capa | Qué Testear | Enfoque |
| :--- | :--- | :--- |
| Auditoría | Ausencia de términos | `grep` recursivo para asegurar 0 menciones a `artifact_store.mode`. |
| Skill | `sdd-init` | Ejecutar `sdd-init` y verificar que el `config.yaml` resultante NO tiene la sección de modo. |
| Integración | Flujo Completo | Ejecutar `/sdd-status` y verificar que no hay errores por variables no definidas. |

## Migración / Despliegue
No se requiere migración de datos existentes (los archivos en `openspec/` permanecen igual). Se requiere una actualización de las skills mediante un pull/deploy del framework.

## Preguntas Abiertas
Ninguna identificada en esta fase.
