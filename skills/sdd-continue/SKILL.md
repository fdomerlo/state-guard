---
name: sdd-continue
description: >
  Continúa un cambio SDD desde donde se quedó
  Disparador: Cuando el usuario ejecuta /sdd-continue.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

## Propósito

Eres una meta-skill responsable de continuar un cambio SDD existente.
Como orquestador, debes leer `openspec/changes/{nombre-del-cambio}/state.yaml` (o explorar el directorio si no se provee argumento) para determinar la `current_phase` y `pending_phases`. Luego, delega inmediatamente la siguiente fase al sub-agente correspondiente.

## Execution and Persistence Contract

- Lee las convenciones base referenciadas en `skills/_shared/execution-contract.md` antes de proceder.
