# Especificación de sdd-review

## Propósito

Nueva skill SDD para auditoría de código implementado mediante análisis estático. Compara el código contra las especificaciones (specs) y el diseño (design) sin ejecutar código ni tests, generando un reporte objetivo con categorías de estado.

## Diferenciación con sdd-verify

| Aspecto           | sdd-review                          | sdd-verify                          |
|-------------------|--------------------------------------|-------------------------------------|
| Tipo de análisis | Estático (lectura de código)        | Dinámico (ejecución de tests)      |
| Qué compara      | Código vs specs/design               | Tests vs comportamiento esperado   |
| Output            | Reporte de auditoría (aprobado/advertencias/bloqueado) | Resultados de tests |

## Requisitos

### Requisito: Recepción de Contexto

La skill DEBE recibir como contexto los siguientes archivos del cambio:
- Todos los archivos en `openspec/changes/{nombre-del-cambio}/specs/**/*.md`
- El archivo `openspec/changes/{nombre-del-cambio}/design.md`
- Los archivos de código fuente modificados del cambio (vía git diff o rutas específicas)

#### Escenario: Contexto Completo Proporcionado

- GIVEN un cambio con specs, design y código modificado
- WHEN el orquestador invoca `sdd-review` con el cambio
- THEN la skill DEBE cargar y analizar todos los archivos de specs y design
- AND DEBE detectar los archivos de código modificados del change

#### Escenario: Contexto Incompleto

- GIVEN un cambio sin specs o sin design
- WHEN el orquestador intenta invocar `sdd-review`
- THEN la skill DEBE fallar con un mensaje indicando qué archivos faltan
- AND NO DEBE proceder con el análisis

### Requisito: Análisis de Código Implementado

La skill DEBE analizar el código implementado usando técnicas de análisis estático:
- Leer los archivos de código modificados/creados
- Identificar funciones, clases y estructuras relevantes
- Rastrear el flujo de datos desde inputs hasta outputs

#### Escenario: Análisis de Nuevas Funciones

- GIVEN una nueva función especificada en las specs
- WHEN la skill analiza el código que implementa dicha función
- THEN DEBE verificar que la implementación existe y sigue la firma especificada
- AND DEBE reportar si la implementación está completa, parcial o ausente

#### Escenario: Detección de Código Espurio

- GIVEN que el código implementado contiene funciones no especificadas
- WHEN la skill completa el análisis
- THEN DEBE reportar estas funciones como "no especificadas" en el reporte
- AND NO DEBE considerarlas como error, solo como advertencia

### Requisito: Comparación contra Especificaciones

La skill DEBE comparar el código contra cada requisito de las specs utilizando comparación estricta:
- Cada requisito DEBE tener al menos una verificación de presencia en el código
- Las firmas de funciones DEBEN coincidir con lo especificado
- Los flujos de datos DEBEN seguir lo descrito en los escenarios

#### Escenario: Requisito Cumplido

- GIVEN un requisito que dice "El sistema DEBE validar el email"
- WHEN la skill analiza el código y encuentra validación de email
- THEN DEBE marcar el requisito como "cumplido" en el reporte

#### Escenario: Requisito Parcialmente Cumplido

- GIVEN un requisito que dice "El sistema DEBE validar email y contraseña"
- WHEN la skill encuentra solo validación de email
- THEN DEBE marcar como "parcial" con detalle de lo faltante

#### Escenario: Requisito No Cumplido

- GIVEN un requisito que dice "El sistema DEBE mostrar mensaje de error"
- WHEN la skill no encuentra implementación de mensaje de error
- THEN DEBE marcar como "no cumplido" con evidencia de ausencia

### Requisito: Generación de Reporte

La skill DEBE generar un reporte estructurado con el siguiente formato:

```
## Reporte de Revisión: {nombre-del-cambio}

### Estado General
- Estado: {aprobado | advertencias | bloqueado}
- Fecha: {ISO 8601}

### Análisis por Requisito
| Requisito | Estado | Evidencia |
|-----------|--------|-----------|
| {nombre}  | {cumplido/parcial/no_cumplido} | {detalle} |

### Hallazgos
- {lista de hallazgos categorizados}

### Recomendaciones
- {lista de recomendaciones}
```

#### Escenario: Estado Aprobado

- GIVEN que todos los requisitos están cumplidos
- WHEN la skill genera el reporte
- THEN el estado DEBE ser "aprobado"
- AND DEBE incluir un resumen de requisitos verificados

#### Escenario: Estado con Advertencias

- GIVEN que hay requisitos parcialmente cumplidos o código espurio
- WHEN la skill genera el reporte
- THEN el estado DEBE ser "advertencias"
- AND DEBE listar cada advertencia con su detalle

#### Escenario: Estado Bloqueado

- GIVEN que hay requisitos esenciales (MUST/SHALL) no cumplidos
- WHEN la skill genera el reporte
- THEN el estado DEBE ser "bloqueado"
- AND DEBE listar los requisitos faltantes como bloqueos

### Requisito: Objetividad del Análisis

La skill DEBE mantener objectivity estricta:
- NO DEBE emitir opiniones sobre estilo de código
- NO DEBE sugerir refactorizaciones no relacionadas con specs
- DEBE basarse EXCLUSIVAMENTE en lo que dicen las specs
- Los únicas métricas de evaluación son: cumplimiento de requisitos y consistencia con design

#### Escenario: Código con Estilo Diferente pero Funcional

- GIVEN código que funciona correctamente pero usa estilo diferente al esperado
- WHEN la skill analiza el código
- THEN DEBE marcarlo como aprobado (si cumple specs)
- AND NO DEBE mencionar el estilo como problema

### Requisito: Integración con Orchestrator

La skill DEBE estar registrada en el orquestador:
- El comando `/sdd-review` DEBE invocar esta skill
- DEBE seguir el protocolo de contexto estándar de SDD
- DEBE retornar el resultado en formato estructurado

#### Escenario: Invocación por Comando

- GIVEN el usuario ejecuta `/sdd-review feat-productivity-tools`
- WHEN el orquestador recibe el comando
- THEN DEBE cargar esta skill con el contexto del cambio
- AND DEBE retornar el reporte generado
