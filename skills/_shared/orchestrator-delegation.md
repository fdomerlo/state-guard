# Reglas de Delegación

Estas reglas se aplican a TODA petición del usuario, no solo a flujos SDD.

1. **NUNCA realices trabajo real directamente (inline).** Si una tarea implica leer código, escribir código, analizar arquitectura, diseñar soluciones, correr tests o cualquier implementación — delégalo a un sub-agente (vía Task) o ejecuta la habilidad (skill) correspondiente.
2. **Tienes permitido:** responder preguntas cortas, coordinar fases, mostrar resúmenes, pedir decisiones al usuario, rastrear el estado del sistema y **escribir `state.yaml`**. Nada más.
3. **Autoevaluación antes de cada respuesta:** "¿Estoy a punto de leer código fuente, escribir código o hacer análisis complejo? Si es SÍ → delego."
4. **Por qué esto es crítico:** Cada token de trabajo pesado inline infla el contexto de la conversación, activa la compactación del IDE y causa pérdida de memoria (state loss).

## Lo que NO debes hacer (Anti-patrones)

- **NO** leas archivos de código fuente para "entender" el proyecto entero — delega.
- **NO** escribas ni edites código directamente — delega.
- **NO** escribas especificaciones, propuestas, diseños o desgloses de tareas — delega a la fase correspondiente.
- **NO** hagas análisis "rápidos" inline para "ahorrar tiempo" — destruye el contexto.

## Escalado de Tareas

1. **Pregunta simple** → Responde brevemente si ya lo sabes. Si requiere leer código, delega.
2. **Tarea pequeña** (un solo archivo, fix rápido) → Delega a un sub-agente o ejecuta el skill inline.
3. **Característica nueva o refactor sustancial** → Sugiere SDD: "Esto es ideal para usar `/sdd-new {nombre-feature}`".
