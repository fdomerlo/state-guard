# Delta para Orchestrator Core

## Requisitos MODIFICADOS

### Requisito: Política de Almacenamiento

**Nueva descripción:**
El sistema DEBE documentar `openspec` como el ÚNICO modo de almacenamiento válido. NO DEBE mencionar `auto`, `hybrid` ni `engram`.

(Anteriormente: mencionaba explícitamente NO usar `auto`, `hybrid` ni `engram`, lo cual implicaba que eran opciones conocidas)

#### Escenario: Documentación Limpia de Modo de Almacenamiento

- GIVEN el archivo `orchestrator-core.md` tras la purga
- WHEN se lee la sección "Política de Almacenamiento"
- THEN DEBE indicar `artifact_store.mode: openspec`
- AND DEBE contener la frase "Default: `openspec`"
- AND NO DEBE contener las palabras `auto`, `hybrid` ni `engram`
- AND DEBE mantener la justificación de ahorro de tokens y archivos `.md` locales

#### Escenario: Redacción en Español Consistente

- GIVEN el archivo `orchestrator-core.md` tras la purga
- WHEN se inspecciona todo el contenido
- THEN TODO el texto DEBE estar en español (castellano)
- AND NO DEBE haber cambios de idioma introducidos durante la purga

#### Escenario: Ausencia de Recomendaciones de Software Externo

- GIVEN el archivo `orchestrator-core.md` tras la purga
- WHEN se busca cualquier referencia a bases de datos vectoriales, servicios externos o software no incluido
- THEN NO DEBE contener menciones a `engram`, `hybrid` ni bases de datos vectoriales
- AND DEBE mantener exclusivamente herramientas del repositorio local

## Requisitos ELIMINADOS

### Requisito: Mención Explícita de Modos Prohibidos

(Motivo: Las menciones a `auto`, `hybrid` y `engram` implican que son opciones válidas conocidas. Eliminarlas refuerza que `openspec` es el único modo.)

#### Escenario: Texto de Modos Prohibidos Eliminado

- GIVEN la sección "Política de Almacenamiento" original que contenía "NO utilices el modo `auto`, `hybrid` ni `engram`"
- WHEN se aplica la purga
- THEN la frase DEBE ser reemplazada por una afirmación positiva sobre `openspec`
- AND NO DEBE permanecer ningún rastro de los términos prohibidos

## Requisitos NO MODIFICADOS

Los siguientes requisitos de orchestrator-core permanecen sin cambios:
- Regla de Idioma Estricta
- Reglas de Delegación
- Comandos de Orquestación
- Grafo de Dependencias
- Gestión de Estado (state.yaml)
- Protocolo de Contexto para Sub-agentes
- Contrato de Resultados
- Regla de Recuperación
