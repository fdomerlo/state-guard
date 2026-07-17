---
name: new
description: >
  Inicia un nuevo cambio transaccional (explore -> propose)
  Disparador: Cuando el usuario ejecuta /new para iniciar un cambio.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "3.0"
---

# New Skill

## Propósito

Meta-skill responsable de inicializar un nuevo cambio transaccional. Ejecuta secuencialmente las fases explore y propose, cada una como una transacción independiente.

## Qué Hacer


### Paso 2: Ejecutar explore (Transacción 1)

Cargá `phases/explore.md` y ejecutá inline:

1. Ejecutar la exploración

### Paso 3: Ejecutar propose (Transacción 2)

Cargá `phases/propose.md` y ejecutá inline:

1. Ejecutar la propuesta

### Paso 4: Reportar al Usuario

Mostrá un resumen combinado de la exploración y la propuesta creada.
