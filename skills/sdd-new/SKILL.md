---
name: sdd-new
description: >
  Inicia un nuevo cambio SDD (explore -> propose)
  Disparador: Cuando el usuario ejecuta /sdd-new para iniciar un cambio.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "3.0"
---

# SDD-New Skill

## Propósito

Meta-skill responsable de inicializar un nuevo cambio SDD. Ejecuta secuencialmente las fases explore y propose, cada una como una transacción independiente.

## Qué Hacer


### Paso 2: Ejecutar sdd-explore (Transacción 1)

Cargá `skills/sdd-explore/SKILL.md` y ejecutá inline:

1. Ejecutar la exploración

### Paso 3: Ejecutar sdd-propose (Transacción 2)

Cargá `skills/sdd-propose/SKILL.md` y ejecutá inline:

1. Ejecutar la propuesta

### Paso 4: Reportar al Usuario

Mostrá un resumen combinado de la exploración y la propuesta creada.
