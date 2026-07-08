---
name: mmx-ff
description: >
  Ejecuta propose, spec, design y tasks en secuencia
  Disparador: Cuando el usuario ejecuta /mmx-ff.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "3.0"
---

# Mmx-FF Skill

## Propósito

Meta-skill responsable del avance rápido (Fast-Forward) de un cambio transaccional. Ejecuta secuencialmente hasta 4 fases de planificación, cada una como una transacción independiente.

## Qué Hacer

### Secuencia de Fases

Ejecuta en orden, saltando las fases ya completadas:

2. mmx-spec
3. mmx-design
4. mmx-tasks

### Guard de Lock Semántico (OBLIGATORIO — antes de CADA fase)

```text
PARA CADA fase en la secuencia (propose → spec → design → tasks):
│   ERROR: Transición inválida de lock semántico.
│     Fase solicitada : {fase_solicitada}
│     STOP — Reportá el error al usuario para que decida manualmente.
```

### Ejecución por Fase

Para cada fase que pase el guard:

1. Cargá el SKILL.md correspondiente
2. Ejecutá inline — la skill maneja su propio BEGIN/COMMIT
3. Verificá que el COMMIT fue exitoso antes de continuar a la siguiente fase

### Resultado
