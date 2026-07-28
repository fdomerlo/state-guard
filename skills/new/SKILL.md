---
name: new
description: >
  Inicia un nuevo cambio transaccional ejecutando la fase PLAN completa
  (exploración → propuesta → spec → diseño → gate humano → lock)
  Disparador: Cuando el usuario ejecuta /new para iniciar un cambio.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "4.0"
---

# New Skill

## Propósito

Meta-skill responsable de inicializar un nuevo cambio transaccional. Crea la estructura del change e invoca la fase PLAN completa (que incluye draft + gate humano + lock).

## Qué Hacer

### Paso 1: Inicializar el change

```bash
python3 scripts/sg.py init-change --change {nombre-del-cambio}
```

### Paso 2: Ejecutar PLAN (Transacción única)

Cargá `phases/plan.md` y ejecutá inline, siguiendo los sub-pasos:

1. **Sub-paso 1 (DRAFT):** Exploración + propuesta + spec + diseño
2. **Sub-paso 2 (GATE):** Presentar al humano, esperar aprobación
3. **Sub-paso 3 (LOCK):** Solo tras aprobación, COMMIT → lock_phase = execute

### Paso 3: Reportar al Usuario

Mostrá un resumen del plan aprobado y el próximo comando:

```
✅ PLAN aprobado y bloqueado.
   Próximo paso: /execute {nombre-del-cambio}
   o directamente: python3 scripts/sg.py begin --change {nombre-del-cambio} --phase execute
```
