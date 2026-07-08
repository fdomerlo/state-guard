---
name: hotfix
description: >
  Inicia un flujo directo (Bypass / Fast-Track) saltando las fases de diseño. 
  Ideal para cambios menores o hotfixes. El cambio comienza directamente en la fase apply.
  Disparador: Cuando el usuario ejecuta /hotfix para un cambio directo.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "2.0"
---

# Hotfix Skill

## Propósito

Esta skill proporciona un modo Bypass / Fast-Track para evitar la burocracia de las 8 fases en cambios menores o hotfixes. Inicializa un flujo directo `apply -> verify -> archive`, saltando la planificación y el diseño.

## Requisitos del Usuario

**OBLIGATORIO**: El usuario DEBE proveer las instrucciones directas de código en su prompt. Como se saltan las fases de diseño y tareas, no existirán documentos previos como `design.md` o `tasks.md`.

## Protocolo de Ejecución (ACID)

### Paso 1: Inicialización del Estado (Bypass)

1. Crea el directorio si es un ticket nuevo: `mkdir -p .state-guard/changes/{nombre-del-cambio}`

2. Usa `write_file` para crear un archivo base `.state-guard/changes/{nombre-del-cambio}/state.ini` con este contenido exacto:

```ini
[Transaction]
txn_status = idle

[Graph]
current_phase = hotfix
lock_phase = apply
completed_phases = explore, propose, spec, design, tasks
pending_phases = apply, verify, archive
```

3. Inicia la transacción obligatoria en la terminal:
`python3 scripts/state_manager.py begin --change {nombre-del-cambio} --phase apply`

### Paso 2: Ejecución del Código (Apply)

Aplica los cambios de código solicitados por el usuario directamente en los archivos fuente del proyecto.

### Paso 3: Commit y Avance

Una vez aplicados los cambios con éxito, avanza la transacción hacia la fase de verificación ejecutando:
`python3 scripts/state_manager.py commit --change {nombre-del-cambio} --next-phase verify`
