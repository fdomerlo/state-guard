---
name: ff
description: >
  Ejecuta propose, spec, design y tasks en secuencia
  Disparador: Cuando el usuario ejecuta /ff.
license: MIT
metadata:
  author: fdomerlo@gmail.com (136bits)
  version: "3.0"
---

# FF Skill

## Propósito

Meta-skill responsable del avance rápido (Fast-Forward) de un cambio transaccional. Ejecuta secuencialmente hasta 4 fases de planificación, cada una como una transacción independiente para preservar la integridad del State Guard.

## Qué Hacer

### Secuencia de Fases

Ejecuta en orden estricto, saltando las fases que ya estén registradas en `completed_phases` dentro de `state.ini`:

1. propose
2. spec
3. design
4. tasks

### Guard de Lock Semántico (OBLIGATORIO — antes de CADA fase)

Antes de iniciar cada fase de la secuencia, debes evaluar el estado actual del proyecto:

```text
PARA CADA fase en la secuencia (propose → spec → design → tasks):
  SI fase_solicitada NO ES IGUAL A state.lock_phase:
    IMPRIMIR:
    │   ERROR: Transición inválida de lock semántico.
    │     Fase esperada por state.ini: {state.lock_phase}
    │     Fase solicitada: {fase_solicitada}
    │     STOP — Reportá el error al usuario para que decida manualmente.
    ABORTAR la secuencia de /ff.
```

### Ejecución por Fase

Para cada fase que pase el guard semántico exitosamente:

1. **Cargar:** Leé el archivo `.md` correspondiente a la fase (ej. `phases/spec.md`).
2. **Transaccionar:** Ejecutá inline respetando ESTRICTAMENTE el ciclo del Framework de Memoria Transaccional:
* **BEGIN**: Reclamar y setear el estado en `state.ini` como `in_progress`.
* **TRABAJO**: Generar los artefactos Markdown.
* **COMMIT**: Guardar el estado exitoso, actualizando `completed_phases` y el nuevo `lock_phase`.


3. **Verificar:** Validá que el COMMIT fue exitoso (el lock avanzó) antes de iniciar la iteración de la siguiente fase en la secuencia.

### Resultado

Al finalizar la secuencia de Fast-Forward (o detenerse de forma segura):

1. Reportá al usuario un resumen de las fases que se completaron con éxito.
2. Imprimí el estado transaccional resultante (ejecutando `/status` o leyendo `state.ini`).
3. Indicá cuál es el próximo paso habilitado. Si la secuencia finalizó hasta el paso 4 (`tasks`), sugiere al usuario ejecutar `/apply` para iniciar el desarrollo.
