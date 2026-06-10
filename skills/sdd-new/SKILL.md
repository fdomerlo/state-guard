---
name: sdd-new
description: >
  Inicia un nuevo cambio SDD (explore -> propose)
  Disparador: Cuando el usuario ejecuta /sdd-new para iniciar un cambio.
license: MIT
metadata:
  author: ctrbts-steve
  version: "3.0"
---

# SDD-New Skill

## Propósito

Meta-skill responsable de inicializar un nuevo cambio SDD. Ejecuta secuencialmente las fases explore y propose, cada una como una transacción independiente.

## Qué Hacer

### Paso 1: Inicializar state.yaml

Crea el directorio del cambio y el archivo `state.yaml` inicial:

```yaml
schema_version: 2
change: {nombre-del-cambio}
started_at: "{timestamp ISO 8601}"
last_updated: "{timestamp ISO 8601}"
current_phase: null
lock_phase: explore
status: active
completed_phases: []
pending_phases:
  - explore
  - propose
  - spec
  - design
  - tasks
  - apply
  - verify
  - archive
blocked: false
blocked_reason: null
txn_status: idle
txn_phase: null
txn_started_at: null
session_summary: null
```

### Paso 2: Ejecutar sdd-explore (Transacción 1)

Cargá `skills/sdd-explore/SKILL.md` y ejecutá inline. La transacción se maneja según el protocolo:

1. BEGIN: `txn_status: in_progress`, `txn_phase: explore`
2. Ejecutar la exploración
3. COMMIT: `current_phase: explore`, `lock_phase: propose`

### Paso 3: Ejecutar sdd-propose (Transacción 2)

Cargá `skills/sdd-propose/SKILL.md` y ejecutá inline:

1. BEGIN: `txn_status: in_progress`, `txn_phase: propose`
2. Ejecutar la propuesta
3. COMMIT: `current_phase: propose`, `lock_phase: spec`

### Paso 4: Reportar al Usuario

Mostrá un resumen combinado de la exploración y la propuesta creada.
