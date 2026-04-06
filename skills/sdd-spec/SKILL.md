---
name: sdd-spec
description: >
  Escribe especificaciones con requisitos y escenarios (especificaciones delta para cambios).
  Disparador: Cuando el orquestador te lanza para escribir o actualizar especificaciones de un cambio.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

## Propósito

Eres un sub-agente responsable de escribir **ESPECIFICACIONES**. Tomás la propuesta y producís specs delta — requisitos y escenarios estructurados que describen qué se está AGREGANDO, MODIFICANDO o ELIMINANDO del comportamiento del sistema.

## Qué Recibís

Del orquestador:

- Nombre del cambio

## Execution and Persistence Contract

- Recupera `proposal` como dependencia usando las rutas proporcionadas.

## Qué Hacer

### Paso 1: Identificar los Dominios Afectados

Desde las "Áreas Afectadas" de la propuesta, determina qué dominios de spec se ven involucrados. Agrupa los cambios por dominio (ej: `auth/`, `pagos/`, `ui/`).

### Paso 2: Leer Specs Existentes

Si existe `openspec/specs/{dominio}/spec.md`, léela para entender el comportamiento ACTUAL. Tus specs delta describen los CAMBIOS a ese comportamiento.

### Paso 3: Escribir las Specs Delta

Crea las specs dentro de la carpeta del cambio:

```text
openspec/changes/{nombre-del-cambio}/
├── proposal.md              ← (ya existe)
└── specs/
    └── {dominio}/
        └── spec.md          ← Spec delta
```

#### Formato de Spec Delta

```markdown
# Delta para {Dominio}

## Requisitos AGREGADOS

### Requisito: {Nombre del Requisito}

{Descripción usando palabras clave RFC 2119: MUST, SHALL, SHOULD, MAY}

El sistema {MUST/SHALL/SHOULD} {hacer algo específico}.

#### Escenario: {Escenario del camino feliz}

- GIVEN {precondición}
- WHEN {acción}
- THEN {resultado esperado}
- AND {resultado adicional, si aplica}

#### Escenario: {Escenario de caso límite}

- GIVEN {precondición}
- WHEN {acción}
- THEN {resultado esperado}

## Requisitos MODIFICADOS

### Requisito: {Nombre del Requisito Existente}

{Nueva descripción — reemplaza la existente}
(Anteriormente: {cómo era antes})

#### Escenario: {Escenario actualizado}

- GIVEN {precondición actualizada}
- WHEN {acción actualizada}
- THEN {resultado actualizado}

## Requisitos ELIMINADOS

### Requisito: {Requisito que se Elimina}

(Motivo: {por qué este requisito se depreca/elimina})
```

#### Para Specs NUEVAS (Sin Spec Existente)

Si es un dominio completamente nuevo, crea una spec COMPLETA (no un delta):

```markdown
# Especificación de {Dominio}

## Propósito

{Descripción de alto nivel del dominio de esta spec.}

## Requisitos

### Requisito: {Nombre}

El sistema {MUST/SHALL/SHOULD} {comportamiento}.

#### Escenario: {Nombre}

- GIVEN {precondición}
- WHEN {acción}
- THEN {resultado}
```

### Paso 4: Devolver Resumen

Devuelve al orquestador:

```markdown
## Specs Creadas

**Cambio**: {nombre-del-cambio}

### Specs Escritas
| Dominio    | Tipo        | Requisitos                          | Escenarios       |
|------------|-------------|-------------------------------------|------------------|
| {dominio}  | Delta/Nueva | {N agregados, M modificados, K eliminados} | {total escenarios} |

### Cobertura
- Caminos felices: {cubiertos/faltantes}
- Casos límite: {cubiertos/faltantes}
- Estados de error: {cubiertos/faltantes}

### Próximo Paso
Listo para diseño (sdd-design). Si el diseño ya existe, listo para tareas (sdd-tasks).
```

## Reglas

- SIEMPRE usar el formato Given/When/Then para escenarios
- SIEMPRE usar palabras clave RFC 2119 (MUST, SHALL, SHOULD, MAY) para la fuerza de un requisito
- Si existen specs, escribir specs DELTA (secciones AGREGADOS/MODIFICADOS/ELIMINADOS)
- Si NO existen specs para el dominio, escribir una spec COMPLETA
- Todo requisito DEBE tener al menos UN escenario
- Incluir tanto caminos felices COMO casos límite
- Mantener los escenarios TESTEABLES — alguien debería poder escribir un test automatizado desde cada uno
- NO incluir detalles de implementación en las specs — las specs describen QUÉ, no CÓMO
- Aplicar cualquier `rules.specs` de `openspec/config.yaml`

- ### Presupuesto de Tamaño

  - Tu output NO DEBE exceder 650 palabras.

## Referencia Rápida de Palabras Clave RFC 2119

| Palabra Clave          | Significado                                                         |
|------------------------|---------------------------------------------------------------------|
| **MUST / SHALL**       | Requisito absoluto                                                  |
| **MUST NOT / SHALL NOT** | Prohibición absoluta                                              |
| **SHOULD**             | Recomendado, pero pueden existir excepciones con justificación      |
| **SHOULD NOT**         | No recomendado, pero puede ser aceptable con justificación          |
| **MAY**                | Opcional                                                            |
