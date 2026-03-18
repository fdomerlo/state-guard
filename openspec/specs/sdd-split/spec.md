# Especificación de sdd-split

## Propósito

Nueva skill SDD para dividir propuestas monolíticas (propuestas demasiado grandes) en sub-cambios manejables aplicando el patrón "Divide y Vencerás". Analiza una proposal existente y genera un plan de partición con comandos `/sdd-new` sugeridos.

## Requisitos

### Requisito: Recepción de Proposal Existente

La skill DEBE recibir una proposal.md existente como input principal:
- DEBE aceptar la ruta a una proposal mediante parámetro del orquestador
- DEBE validar que el archivo proposal.md existe antes de procesarlo

#### Escenario: Proposal Válida Proporcionada

- GIVEN una proposal en `openspec/changes/{nombre}/proposal.md`
- WHEN el orquestador invoca `sdd-split` con el nombre del cambio
- THEN la skill DEBE cargar y parsear el contenido de la proposal
- AND DEBE identificar las secciones principales: intención, alcance, áreas afectadas

#### Escenario: Proposal No Encontrada

- GIVEN que el archivo proposal.md no existe
- WHEN el orquestador intenta invocar `sdd-split`
- THEN la skill DEBE fallar con un mensaje claro indicando que la proposal no existe
- AND NO DEBE intentar procesar nada

### Requisito: Identificación de Componentes Independientes

La skill DEBE analizar la proposal y detectar áreas de funcionalidad que puedan separarse:
- Áreas con dependencias claras (un área depende de otra)
- Áreas sin dependencias (pueden desarrollarse independientemente)
- Áreas que comparten infraestructura común

#### Escenario: Propuesta con Múltiples Áreas Funcionales

- GIVEN una proposal con tres áreas: "auth", "payments", "notifications"
- WHEN la skill analiza el contenido
- THEN DEBE identificar cada área como potencialmente separable
- AND DEBE marcar las dependencias entre ellas

#### Escenario: Propuesta Monolítica (Sin Separación Clara)

- GIVEN una proposal donde todas las áreas están entrelazadas
- WHEN la skill no puede identificar sub-cambios independientes
- THEN DEBE reportar que la proposal NO es apta para división
- AND DEBE sugerir criterios para refinar la proposal

### Requisito: Análisis de Dependencias

La skill DEBE mapear las dependencias entre componentes:
- Una dependencia existe cuando un área USA o DEPENDE de otra
- Las dependencias determinan el orden de implementación
- Áreas sin dependencias pueden implementarse en paralelo

#### Escenario: Dependencia Unidireccional

- GIVEN área "A" que usa funciones del área "B"
- WHEN la skill analiza las referencias
- THEN DEBE marcar "A" como dependiente de "B"
- AND DEBE proponer que "B" se implemente primero

#### Escenario: Dependencia Circular

- GIVEN área "A" que depende de "B" y "B" que depende de "A"
- WHEN la skill detecta circularidad
- THEN DEBE reportar esta situación como alerta
- AND DEBE sugerir fusionar estas áreas en un solo sub-cambio

### Requisito: Propuesta de Partición

La skill DEBE generar un plan de partición estructurado:
- Cada sub-cambio DEBE tener un nombre significativo
- Cada sub-cambio DEBE incluir un subconjunto de las áreas afectadas originales
- El plan DEBE respetar las dependencias identificadas

#### Escenario: partición Exitosa

- GIVEN una proposal divisible en 3 partes independientes
- WHEN la skill genera el plan de partición
- THEN DEBE generar una lista de 3 sub-cambios
- AND CADA sub-cambio DEBE incluir: nombre, áreas incluidas, dependencias, justificación

#### Formato de Salida del Plan de partición

```
## Plan de partición para {nombre-propuesta}

### Sub-cambio 1: {nombre-sub-cambio-1}
- Áreas incluidas: {lista de áreas}
- Dependencias: {ninguna | sub-cambio X}
- Justificación: {por qué es independiente}

### Sub-cambio 2: {nombre-sub-cambio-2}
- Áreas incluidas: {lista de áreas}
- Dependencias: {ninguna | sub-cambio X}
- Justificación: {por qué es independiente}

...
```

### Requisito: Generación de Comandos /sdd-new

La skill DEBE sugerir comandos concretos para crear cada sub-cambio:
- Cada sub-cambio DEBE tener un comando `/sdd-new {nombre}` sugerido
- Los comandos DEBEN estar en el orden correcto de implementación
- Los comandos DEBEN incluir una breve descripción del sub-cambio

#### Escenario: Generación de Comandos

- GIVEN un plan de partición con 3 sub-cambios
- WHEN la skill termina el análisis
- THEN DEBE generar una lista de comandos:
  ```
  ## Comandos Sugeridos
  
  # 1. Implementar base (sin dependencias)
  /sdd-new sub-cambio-1
  
  # 2. Implementar {área} (depende de sub-cambio-1)
  /sdd-new sub-cambio-2
  
  # 3. Implementar {área} (depende de sub-cambio-2)
  /sdd-new sub-cambio-3
  ```

### Requisito: Criterios de partición

La skill DEBE aplicar criterios para determinar si una partición es viable:
- Un sub-cambio DEBE poder explicarse en una oración
- Un sub-cambio DEBE tener un alcance menor a la proposal original
- Un sub-cambio DEBE ser implementable en una sesión de trabajo razonable

#### Escenario: Proposal Demasiado Grande

- GIVEN una proposal con más de 10 áreas afectadas
- WHEN la skill evalúa el tamaño
- THEN DEBE sugerir dividir en más sub-cambios
- AND DEBE indicar un máximo recomendado por sub-cambio (5-7 áreas)

#### Escenario: Proposal Adecuada (No Dividir)

- GIVEN una proposal con 2-3 áreas afectadas y dependencias claras
- WHEN la skill evalúa
- THEN DEBE indicar que la proposal NO necesita dividirse
- AND DEBE sugerir continuar con el flujo SDD normal

### Requisito: Retorno de Resultado

La skill DEBE retornar un resultado estructurado con:
- Status: "aprobado" (división viable), "advertencias" (división con caveats), "bloqueado" (no divisible)
- Plan de partición completo
- Lista de comandos sugeridos
- Recomendaciones adicionales

#### Escenario: partición Exitosa

- GIVEN una proposal divisible
- WHEN la skill completa el análisis
- THEN DEBE retornar status "aprobado"
- AND DEBE incluir el plan de partición y comandos

#### Escenario: partición No Viable

- GIVEN una proposal que no puede dividirse lógicamente
- WHEN la skill determina esto
- THEN DEBE retornar status "bloqueado"
- AND DEBE incluir la razón y sugerencias de refinamiento
