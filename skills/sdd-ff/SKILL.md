---
name: sdd-ff
description: >
  Ejecuta propose, spec, design y tasks en secuencia
  Disparador: Cuando el usuario ejecuta /sdd-ff.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.1"
---

# SDD-FF Skill

## Propósito

Eres una meta-skill responsable del avance rápido (Fast-Forward) de un cambio SDD.
Como orquestador, debes delegar secuencialmente a los siguientes sub-agentes:

1. sdd-propose
2. sdd-spec
3. sdd-design
4. sdd-tasks

## Guard de Lock Semántico (OBLIGATORIO — ejecutar antes de CADA delegación)

Antes de invocar cada sub-agente, DEBES verificar el `lock_phase` en `state.yaml`:

```text
PARA CADA fase en la secuencia (propose → spec → design → tasks):
├─ 1. Leer `lock_phase` del `state.yaml` del cambio
├─ 2. SI la fase a ejecutar ya está en `completed_phases` → SALTARLA (no repetir)
├─ 3. SI la fase a ejecutar == `lock_phase` → PROCEDER con la delegación
├─ 4. SI la fase a ejecutar != `lock_phase` Y no es una fase ya completada → STOP:
│   ERROR: Transición inválida de lock semántico.
│     Fase solicitada : {fase_solicitada}
│     lock_phase actual: {lock_phase}
│     Ejecuta /sdd-fix para auditar y reparar el estado antes de continuar.
└─ 5. SI `lock_phase` no existe en `state.yaml` → STOP:
    ERROR: Campo `lock_phase` ausente en state.yaml.
    Ejecuta /sdd-fix para migrar el estado antes de continuar.
```

## Protocolo de Actualización de lock_phase (Post-Delegación)

Tras completar cada sub-agente, extrae `lock_phase_next` del resumen de retorno y escribe en `state.yaml`:

```text
1. Leer la sección `### Lock Phase` del resumen retornado por el sub-agente
2. Extraer el valor de `lock_phase_next`
3. Validar que sea un valor válido del DAG (spec | design | tasks | apply | verify | archive)
4. SI es válido: escribir `lock_phase: {valor}` en state.yaml junto con current_phase y completed_phases
5. SI no viene `lock_phase_next` (sub-agente falló): NO modificar `lock_phase` — preservar el valor actual
```

## Regla Estricta: Anti-Batching

**DEBES MANTENER ESTRICTAMENTE LA REGLA DE ANTI-BATCHING DEL ESTADO.**
Debes persistir el progreso fase por fase en `state.yaml` de manera secuencial. Es decir, después de completar la fase interna correspondiente a un sub-agente, actualiza inmediatamente el `state.yaml` para reflejar esa fase como `current_phase`, agregarla a `completed_phases` y actualizar `lock_phase` al valor `lock_phase_next` reportado. No retrases las actualizaciones de estado al final de todas las fases.

## Execution and Persistence Contract

- Lee las convenciones base referenciadas en `skills/_shared/execution-contract.md` antes de proceder.
