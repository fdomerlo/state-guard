---
name: sdd-propose
description: >
  Crea una propuesta de cambio con intención, alcance y enfoque.
  Disparador: Cuando el orquestador te lanza para crear o actualizar una propuesta de cambio.
license: MIT
metadata:
  author: ctrbts-steve
  version: "2.0"
---

## Propósito

Eres un sub-agente responsable de crear **PROPUESTAS**. Tomás el análisis de exploración (o la descripción directa del usuario) y producís un documento `proposal.md` estructurado dentro de la carpeta del cambio.

## Qué Recibís

Del orquestador:
- Nombre del cambio (ej: "agregar-modo-oscuro")
- Análisis de exploración (de sdd-explore) O descripción directa del usuario
- Modo de almacenamiento de artefactos (`openspec | none`)

## Execution and Persistence Contract

- Si el modo es `openspec`: Recupera `explore` como dependencia si está disponible usando las rutas proporcionadas.
- Si el modo es `none`: Devuelve solo el resultado. Nunca crear ni modificar archivos del proyecto.

## Qué Hacer

### Paso 1: Crear el Directorio del Cambio

Crea la estructura de carpetas del cambio:

```
openspec/changes/{nombre-del-cambio}/
└── proposal.md
```

### Paso 2: Leer Specs Existentes

Si `openspec/specs/` tiene specs relevantes, léelas para entender el comportamiento actual que este cambio podría afectar.

### Paso 3: Escribir proposal.md

```markdown
# Propuesta: {Título del Cambio}

## Intención

{¿Qué problema estamos resolviendo? ¿Por qué necesita ocurrir este cambio?
Sé específico sobre la necesidad del usuario o la deuda técnica que se aborda.}

## Alcance

### Dentro del Alcance
- {Entregable concreto 1}
- {Entregable concreto 2}
- {Entregable concreto 3}

### Fuera del Alcance
- {Lo que explícitamente NO vamos a hacer}
- {Trabajo futuro relacionado pero diferido}

## Enfoque

{Enfoque técnico de alto nivel. ¿Cómo resolveremos esto?
Hace referencia al enfoque recomendado de la exploración si está disponible.}

## Áreas Afectadas

| Área              | Impacto                     | Descripción        |
|-------------------|-----------------------------|--------------------|
| `ruta/al/área`    | Nuevo/Modificado/Eliminado  | {Qué cambia}       |

## Riesgos

| Riesgo               | Probabilidad    | Mitigación            |
|----------------------|-----------------|-----------------------|
| {Descripción riesgo} | Baja/Med/Alta   | {Cómo lo mitigamos}   |

## Plan de Rollback

{Cómo revertir si algo sale mal. Sé específico.}

## Dependencias

- {Dependencia externa o prerequisito, si hay}

## Criterios de Éxito

- [ ] {¿Cómo sabemos que este cambio tuvo éxito?}
- [ ] {Resultado medible}
```

### Paso 4: Devolver Resumen

Devuelve al orquestador:

```markdown
## Propuesta Creada

**Cambio**: {nombre-del-cambio}
**Ubicación**: openspec/changes/{nombre-del-cambio}/proposal.md

### Resumen
- **Intención**: {resumen en una línea}
- **Alcance**: {N entregables incluidos, M ítems diferidos}
- **Enfoque**: {enfoque en una línea}
- **Nivel de Riesgo**: {Bajo/Medio/Alto}

### Próximo Paso
Listo para specs (sdd-spec) o diseño (sdd-design).
```

## Reglas

- En modo `openspec`, SIEMPRE crear el archivo `proposal.md`
- Si el directorio del cambio ya existe con una propuesta, LEERLA primero y ACTUALIZARLA
- Mantener la propuesta CONCISA — es una herramienta de pensamiento, no una novela
- Toda propuesta DEBE tener un plan de rollback
- Toda propuesta DEBE tener criterios de éxito
- Usar rutas de archivos concretas en "Áreas Afectadas" cuando sea posible
- Aplicar cualquier `rules.proposal` de `openspec/config.yaml`
- **VALIDAR el nombre del cambio contra la regla `change_naming` (kebab-case)** si está configurada en config.yaml
- ### Presupuesto de Tamaño
  - Tu output NO DEBE exceder 400 palabras.
- RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md`

## Errores Comunes

Al crear propuestas de cambio, evitá estos errores frecuentes:

### 1. Alucinaciones de contexto
**Problema**: Inventar información no proporcionada por el usuario o asumir requisitos sin verificar.
**Solución**: Siempre verificá con el usuario antes de asumir funcionalidades o requisitos no explícitos.

### 2. Olvidar el plan de rollback
**Problema**: No incluir un plan de rollback para cambios riesgosos.
**Solución**: Toda propuesta de riesgo Medio/Alto DEBE incluir un plan de rollback específico.

### 3. Scope creep (Expansion del alcance)
**Problema**: Agregar features o tareas fuera del alcance original del cambio.
**Solución**: Mantené el alcance enfocado. Los cambios adicionales se proponen como cambios separados.

### 4. No seguir la regla de nomenclatura
**Problema**: Usar camelCase, PascalCase, snake_case o espacios en el nombre del cambio.
**Solución**: Usá siempre kebab-case (ej: `mi-feature`, `fix-bug-123`). Validá con regex: `^[a-z0-9]+(-[a-z0-9]+)*$`
