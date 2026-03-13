# Manual de Uso y Buenas Prácticas: Agentify SDD

Este manual está diseñado para que cualquier desarrollador pueda entender y utilizar la metodología de desarrollo basado en agentes de este repositorio en pocos minutos.

---

## Lección 1: La Filosofía "Especificación Primero"

Agentify no es solo un asistente de chat; es un sistema de **Desarrollo Basado en Especificaciones (SDD)**.

### El Problema
Cuando pides a una IA "hazme un sistema de login", la IA empieza a escribir código inmediatamente. A mitad de camino, olvida un requisito, alucina una base de datos o introduce un bug porque el contexto es demasiado grande.

### La Solución: SDD
En este repositorio, el trabajo se divide en fases claras. Antes de tocar una sola línea de código, el equipo de agentes debe:
1. **Entender** el código actual.
2. **Proponer** qué va a hacer.
3. **Especificar** detalladamente el comportamiento (Specs).
4. **Diseñar** la solución técnica.
5. **Planificar** las tareas.

**Regla de Oro:** El código es la última consecuencia de una buena especificación.

---

## Lección 2: El Ciclo de Vida de un Cambio

Un "Cambio" (Change) es la unidad de trabajo. Sigue este flujo usando los comandos del orquestador:

1.  **`/sdd-init`**: Prepara el terreno. Hazlo una vez por proyecto.
2.  **`/sdd-new <nombre-del-cambio>`**: El punto de partida. Lanza un explorador y crea una propuesta (`proposal.md`).
3.  **`/sdd-continue`**: La "tecla mágica". Ejecuta la siguiente fase pendiente (Specs -> Diseño -> Tareas).
4.  **`/sdd-apply`**: Implementación. El agente escribe el código siguiendo el plan.
5.  **`/sdd-verify`**: Control de calidad. Valida que el código hace lo que dicen las specs.
6.  **`/sdd-archive`**: Cierre. Mezcla las specs del cambio con las globales y limpia.

---

## Lección 3: Tu Rol como "Piloto" Humano

Tú no eres un espectador, eres el **arquitecto y revisor**. Los agentes son tus "operadores".

### Puntos de Control Críticos
No dejes que los agentes avancen si no estás de acuerdo con los artefactos en `openspec/changes/<tu-cambio>/`:

*   **Revisión de la Propuesta (`proposal.md`):** ¿El alcance es correcto? ¿Es demasiado grande el cambio? (Si es muy grande, divídelo).
*   **Revisión de Specs (`specs/`):** ¿Los escenarios (GIVEN/WHEN/THEN) cubren los casos de error?
*   **Revisión de Diseño (`design.md`):** ¿Te gusta la arquitectura propuesta? ¿Sigue los estándares del equipo?

**Consejo:** Si algo no te gusta, simplemente dile al orquestador: *"No me gusta el diseño, usa una Composition Pattern en lugar de herencia"* y pide un `/sdd-continue`.

---

## Buenas Prácticas (El Decálogo)

1.  **Cambios Atómicos:** Un cambio debe hacer una sola cosa bien. Evita `sdd-new feature-gigante`. Prefiere `sdd-new auth-base`, luego `sdd-new auth-google`.
2.  **Confía en la Carpeta `openspec/`:** Es la "Caja Negra" de tu avión. Si el agente se pierde o la sesión de chat se corta, los archivos ahí guardados permiten que cualquier otro agente (o tú) retome el trabajo exactamente donde quedó.
3.  **No Edites `openspec/` a Mano (si puedes evitarlo):** Deja que los agentes lo hagan. Si necesitas un cambio, pídeselo al agente.
4.  **Usa `/sdd-verify` Siempre:** No asumas que el código funciona porque el agente dice "listo". La verificación ejecuta tests reales.
5.  **El Idioma Importa:** Este sistema está optimizado para **Castellano**. Mantén las descripciones y requisitos en español para que todo el equipo humano pueda auditarlos fácilmente.
6.  **Revisión de Git:** Los artefactos de `openspec` **se suben al repositorio**. Esto permite que en un Pull Request, tus compañeros vean no solo el código, sino también el diseño y las tareas que se siguieron.
7.  **Fallback de Emergencia:** Si un agente se bloquea o entra en un bucle, borra el archivo de tareas (`tasks.md`) o el de diseño (`design.md`) y pide un `/sdd-continue` para regenerarlo.
8.  **Contexto Fresco:** Una de las mayores ventajas es que cada sub-agente (el que diseña, el que especifica) empieza con "contexto limpio". Esto evita los errores por cansancio de la IA.
9.  **Specs como Documentación:** Al final del día, tu carpeta `openspec/specs/` será la documentación más actualizada y fiel de tu sistema.
10. **Itera la Propuesta:** Si al llegar al diseño te das cuenta de que la propuesta era errónea, no tengas miedo de pedir al proponente que la ajuste.

---

## ¿Cómo empezar ahora mismo?

1. Elige una tarea pequeña (ej: "Añadir validación de email").
2. Ejecuta `/sdd-new validacion-email`.
3. Lee `proposal.md`.
4. Si te gusta, `/sdd-continue` hasta llegar a `/sdd-apply`.
5. ¡Felicidades, has completado tu primer ciclo SDD!
