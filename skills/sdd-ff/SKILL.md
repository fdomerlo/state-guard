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

2. sdd-spec
3. sdd-design
4. sdd-tasks

### Guard de Lock Semántico (OBLIGATORIO — antes de CADA fase)

```text
PARA CADA fase en la secuencia (propose → spec → design → tasks):
│   ERROR: Transición inválida de lock semántico.
│     Fase solicitada : {fase_solicitada}
│     Ejecuta /sdd-fix para auditar y reparar el estado.
    Ejecuta /sdd-fix para migrar el estado.
```

### Ejecución por Fase

Para cada fase que pase el guard:

1. Cargá el SKILL.md correspondiente
2. Ejecutá inline — la skill maneja su propio BEGIN/COMMIT
3. Verificá que el COMMIT fue exitoso antes de continuar a la siguiente fase

### Resultado
