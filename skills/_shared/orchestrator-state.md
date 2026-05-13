# Gestión de Estado (state.yaml)

## Obligatoriedad

**Después de CADA transición de fase**, escribí o actualizá el archivo `openspec/changes/{nombre-del-cambio}/state.yaml`. Este archivo es el único mecanismo de recuperación ante pérdida de contexto y NO es delegable a un sub-agente — es tu responsabilidad como orquestador.

## Cuándo actualizar state.yaml

| Evento | Acción |
|--------|--------|
| `/sdd-new` lanza el primer sub-agente | Crear el archivo con `started_at` = ahora |
| Sub-agente retorna `status: ok` o `warning` | Mover fase a `completed_phases`, actualizar `current_phase` y `pending_phases` |
| Una fase queda bloqueada | Setear status: blocked, escribir blocked_reason |
| sdd-archive exitoso | Setear status: done y mantener current_phase en archive, vaciar pending_phases |

## Schema

```yaml
# openspec/changes/{nombre-del-cambio}/state.yaml
change: {nombre-del-cambio}
started_at: "2026-03-14T10:00:00"    # ISO 8601 — solo al crear, nunca modificar
last_updated: "2026-03-14T12:30:00"  # ISO 8601 — actualizar en cada transición
current_phase: tasks  # explore|propose|spec|design|tasks|apply|verify|archive
status: active        # active | done | blocked (default: active)
completed_phases:
  - explore
  - propose
  - spec
  - design
pending_phases:
  - tasks
  - apply
  - verify
  - archive
blocked_reason: null   # null, o string describiendo el bloqueo
```

## Cuándo leer state.yaml

- Al ejecutar `/sdd-continue` sin argumento → leer todos los `state.yaml` activos para identificar qué cambio continuar y cuál es la siguiente fase.
- Después de una recarga del IDE → leer para recuperar el estado completo antes de responder.

---

# Regla de Recuperación (Recovery)

Si perdés el rastro del estado del SDD (ej. tras una recarga del IDE), **antes de responder cualquier otra cosa**:

1. Leé `openspec/changes/*/state.yaml` para todos los cambios presentes.
2. Usá `current_phase` para saber dónde continuar.
3. Usá `completed_phases` para saber qué NO repetir.
4. Si no existe ningún `state.yaml`, explorá el filesystem de `openspec/changes/` para inferir el estado a partir de qué archivos existen.
