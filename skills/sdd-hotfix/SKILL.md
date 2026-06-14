---
name: sdd-hotfix
description: >
  Inicia un flujo directo (Bypass / Fast-Track) saltando las fases de diseño. 
  Ideal para cambios menores o hotfixes. Inicializa o actualiza el state.yaml para que el cambio comience directamente en la fase apply.
  Disparador: Cuando el usuario ejecuta /sdd-hotfix para un cambio directo.
license: MIT
metadata:
  author: fdomerlo-steve
  version: "1.0"
---

# SDD-Hotfix Skill

## Propósito

Esta skill proporciona un modo Bypass / Fast-Track para evitar la burocracia de las 8 fases en cambios menores o hotfixes. Inicializa un flujo directo `apply -> verify -> archive`, saltando `explore`, `propose`, `spec`, `design` y `tasks`.

## Requisitos del Usuario

**OBLIGATORIO**: El usuario DEBE proveer las instrucciones directas de código en su prompt. Como se saltan las fases de diseño y tareas, no existirán documentos previos como `design.md` o `tasks.md`.

## Transacción

Seguí el protocolo de transacción definido en `skills/_shared/transaction-protocol.md`:

- **BEGIN**: `txn_status: in_progress`, `txn_phase: hotfix`
- **COMMIT**: Al crear o modificar `state.yaml` exitosamente, establecer `current_phase: tasks`, `lock_phase: apply`.
- **ROLLBACK**: Si falla, restaurar `txn_status: failed`.

## Qué Hacer

### Paso 1: Configurar el state.yaml para Fast-Track

Crea o modifica el archivo `openspec/changes/{nombre-del-cambio}/state.yaml`. Si es un cambio nuevo, inicialízalo con `schema_version: 2`. Si ya existe, modifícalo.

Asegúrate de establecer:
- `current_phase: hotfix` (No uses 'tasks')
- `lock_phase: apply`
- Ajusta `completed_phases` para incluir `hotfix`
- Ajusta `pending_phases` para que comience desde `apply`.

### Paso 2: Confirmación

Reporta al usuario que el entorno Bypass está activo y la `lock_phase` es `apply`. Puedes sugerir o iniciar automáticamente la aplicación de cambios usando el contexto provisto por el usuario.
