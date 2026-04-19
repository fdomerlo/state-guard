---
name: sdd-ff
description: >
  Ejecuta propose, spec, design y tasks en secuencia
  Disparador: Cuando el usuario ejecuta /sdd-ff.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

## Propósito

Eres una meta-skill responsable del avance rápido (Fast-Forward) de un cambio SDD.
Como orquestador, debes delegar secuencialmente a los siguientes sub-agentes:
1. sdd-propose
2. sdd-spec
3. sdd-design
4. sdd-tasks

## Regla Estricta: Anti-Batching

**DEBES MANTENER ESTRICTAMENTE LA REGLA DE ANTI-BATCHING DEL ESTADO.**
Debes persistir el progreso fase por fase en `state.yaml` de manera secuencial. Es decir, después de completar la fase interna correspondiente a un sub-agente, actualiza inmediatamente el `state.yaml` para reflejar esa fase como `current_phase` y agregarla a `completed_phases`, y luego procede con la siguiente. No retrases las actualizaciones de estado al final de todas las fases.

## Execution and Persistence Contract

- Lee las convenciones base referenciadas en `skills/_shared/execution-contract.md` antes de proceder.
