# Delta para glosario

## Propósito

Esta especificación define los requisitos para el Glosario de Dominio del proyecto Agentify-SDD. El glosario permite que el proyecto defina y comparta terminología consistente entre todos los sub-agentes, evitando inconsistencias semánticas en las especificaciones y diseños.

## Requisitos AGREGADOS

### Requisito: Estructura del Glosario en Configuración

El archivo `openspec/config.yaml` DEBE incluir un bloque `glossary:` con ejemplos comentados que muestren el formato esperado.

- GIVEN que se ejecuta la skill `sdd-init` en un proyecto nuevo
- WHEN se genera el archivo `openspec/config.yaml`
- THEN DEBE incluir una sección `glossary:` comentada
- AND los ejemplos DEBEN mostrar el formato YAML de términos y definiciones

#### Escenario: Estructura de Glosario con Múltiples Términos

- GIVEN el bloque `glossary:` en `config.yaml` con el formato correcto
- WHEN un sub-agente carga el glosario
- THEN DEBE parsear correctamente una estructura como:
```yaml
# glossary:
#   terms:
#     - term: "Estado"
#       definition: "Condición actual de un cambio en el DAG de SDD"
#       aliases: ["phase", "status"]
#     - term: "Artefacto"
#       definition: "Archivo generado por una skill SDD"
#       aliases: ["artifact"]
```

### Requisito: Carga del Glosario por Sub-agentes

Las skills de propuesta, especificación y diseño DEBEN cargar el glosario si existe en `openspec/config.yaml`.

- GIVEN que existe `openspec/config.yaml` con una sección `glossary:` válida
- WHEN la skill `sdd-propose` es ejecutada
- THEN DEBE cargar y parsear el glosario antes de generar la propuesta
- AND DEBE almacenar los términos en memoria para referencia

- GIVEN que existe `openspec/config.yaml` con una sección `glossary:` válida
- WHEN la skill `sdd-spec` es ejecutada
- THEN DEBE cargar y parsear el glosario antes de generar las especificaciones
- AND DEBE usar los términos definidos consistentemente

- GIVEN que existe `openspec/config.yaml` con una sección `glossary:` válida
- WHEN la skill `sdd-design` es ejecutada
- THEN DEBE cargar y parsear el glosario antes de generar el diseño
- AND DEBE consultar el glosario para terminología consistente

### Requisito: Uso Consistente de Términos

Los sub-agentes DEBEN usar los términos del glosario de manera consistente en todos los artefactos que generen.

- GIVEN que el glosario define el término "Estado" con alias "phase"
- WHEN la skill genera una propuesta
- THEN DEBE usar "Estado" en textos visibles al usuario
- AND puede usar "phase" internamente si es necesario

- GIVEN que el glosario define un término con la flag `preferred: true`
- WHEN la skill genera artefactos
- THEN DEBE preferir el término marcado como preferido

### Requisito: Graceful Degradation

Si el glosario no existe, los sub-agentes DEBEN funcionar correctamente sin él.

- GIVEN que NO existe el archivo `openspec/config.yaml`
- WHEN cualquier skill SDD es ejecutada
- THEN DEBE funcionar normalmente sin errores
- AND DEBE proseguir con la generación de artefactos

- GIVEN que existe `config.yaml` pero NO incluye la sección `glossary:`
- WHEN la skill intenta cargar el glosario
- THEN DEBE detectar la ausencia
- AND DEBE continuar sin el glosario (no debe fallar)

- GIVEN que existe `glossary:` pero está vacío o malformado
- WHEN la skill intenta parsearlo
- THEN DEBE manejar el error gracefully
- AND DEBE continuar sin el glosario mostrando una advertencia opcional

### Requisito: Actualización del Contrato de Persistencia

El archivo `skills/_shared/persistence-contract.md` DEBE incluir instrucciones claras para que los sub-agentes carguen y respeten los términos del glosario.

- GIVEN un nuevo sub-agente que sigue el `persistence-contract.md`
- WHEN lee el contrato antes de ejecutarse
- THEN DEBE encontrar instrucciones sobre cómo cargar el glosario
- AND DEBE encontrar instrucciones sobre cómo usar los términos definidos

#### Escenario: Instrucciones en Persistence Contract

- GIVEN que el `persistence-contract.md` se actualiza con reglas del glosario
- WHEN un sub-agente lee el contrato
- THEN DEBE encontrar una sección que indique:
  - Dónde buscar el glosario (`openspec/config.yaml`)
  - Cómo cargarlo (parsear YAML del bloque `glossary:`)
  - Cómo usarlo (consultar términos antes de generar artefactos)
  - Qué hacer si no existe (continuar sin él)

## Requisitos MODIFICADOS

### Requisito: Generación de Configuración en sdd-init

El requisito existente de generación de `config.yaml` se MODIFICA para incluir el bloque de glosario comentado.

- GIVEN que se ejecuta `sdd-init` en un proyecto
- WHEN se genera `openspec/config.yaml`
- THEN DEBE incluir la sección `glossary:` con ejemplos comentados
- AND los ejemplos DEBEN ser claros y útiles como referencia

(Anteriormente: El config.yaml se generaba sin bloque de glosario)

## Notas de Implementación

- El glosario es un mecanismo OPTIONAL - no debe bloquear la funcionalidad si no existe
- Los aliases permiten flexibilidad mientras se mantiene consistencia visual
- La ubicación en `config.yaml` centraliza la configuración del proyecto
- Las advertencias sobre glosario faltante deben ser informativas, no blocking
