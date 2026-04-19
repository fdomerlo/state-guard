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

## Execution and Persistence Contract


- Lee las convenciones base referenciadas en `skills/_shared/execution-contract.md` antes de proceder.


## Qué Hacer

### Paso 1: Crear el Directorio del Cambio

Crea la estructura de carpetas del cambio:

```text
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

- SIEMPRE crear el archivo `proposal.md`
- Si el directorio del cambio ya existe con una propuesta, LEERLA primero y ACTUALIZARLA
- Mantener la propuesta CONCISA — es una herramienta de pensamiento, no una novela
- Toda propuesta DEBE tener un plan de rollback
- Toda propuesta DEBE tener criterios de éxito
- Usar rutas de archivos concretas en "Áreas Afectadas" cuando sea posible
- Aplicar cualquier `rules.proposal` de `openspec/config.yaml`
- **VALIDAR el nombre del cambio contra la regla `change_naming` (kebab-case)** si está configurada en config.yaml

- ### Presupuesto de Tamaño

  - Tu output NO DEBE exceder 400 palabras.
