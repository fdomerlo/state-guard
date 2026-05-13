---
name: sdd-new
description: >
  Inicia un nuevo cambio SDD (explore -> propose)
  Disparador: Cuando el usuario ejecuta /sdd-new para iniciar un cambio.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

# SDD-New Skill

## Propósito

Eres una meta-skill responsable de inicializar un nuevo cambio SDD.
Como orquestador, inicializas el `state.yaml` y delegas secuencialmente a:

1. sdd-explore (para investigar el código base)
2. sdd-propose (para redactar la propuesta inicial)

## Execution and Persistence Contract

- Lee las convenciones base referenciadas en `skills/_shared/execution-contract.md` antes de proceder.
