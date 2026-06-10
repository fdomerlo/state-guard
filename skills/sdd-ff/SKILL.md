---
name: sdd-ff
description: >
  Ejecuta propose, spec, design y tasks en secuencia
  Disparador: Cuando el usuario ejecuta /sdd-ff.
license: MIT
metadata:
  author: fdomerlo-steve
  version: "3.0"
---

# SDD-FF Skill

## Propósito

Meta-skill responsable del avance rápido (Fast-Forward) de un cambio SDD. Ejecuta secuencialmente hasta 4 fases de planificación, cada una como una transacción independiente.

## Qué Hacer

### Secuencia de Fases

Ejecuta en orden, saltando las fases ya completadas:

1. sdd-propose (si no está en `completed_phases`)
2. sdd-spec
3. sdd-design
4. sdd-tasks

### Guard de Lock Semántico (OBLIGATORIO — antes de CADA fase)

```text
PARA CADA fase en la secuencia (propose → spec → design → tasks):
├─ 1. Leer `lock_phase` del `state.yaml` del cambio
├─ 2. SI la fase a ejecutar ya está en `completed_phases` → SALTARLA
├─ 3. SI la fase a ejecutar == `lock_phase` → PROCEDER
├─ 4. SI la fase a ejecutar != `lock_phase` Y no es fase completada → STOP:
│   ERROR: Transición inválida de lock semántico.
│     Fase solicitada : {fase_solicitada}
│     lock_phase actual: {lock_phase}
│     Ejecuta /sdd-fix para auditar y reparar el estado.
└─ 5. SI `lock_phase` no existe → STOP:
    ERROR: Campo `lock_phase` ausente en state.yaml.
    Ejecuta /sdd-fix para migrar el estado.
```

### Ejecución por Fase

Para cada fase que pase el guard:

1. Cargá el SKILL.md correspondiente
2. Ejecutá inline — la skill maneja su propio BEGIN/COMMIT
3. Verificá que el COMMIT fue exitoso antes de continuar a la siguiente fase

**El anti-batching se garantiza por el protocolo de transacción**: cada fase tiene su propio ciclo BEGIN → COMMIT. Si el agente crashea entre fases, el Recovery Protocol (ver `memory-guard.md`) continúa desde donde quedó.

### Resultado

Al completar todas las fases, reportá un resumen combinado con los artefactos creados en cada fase. La última fase (tasks) deja `lock_phase: apply`, listo para implementar.
