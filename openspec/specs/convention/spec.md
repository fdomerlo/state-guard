# Delta para Convention

## Propósito

Esta especificación define las reglas de nomenclatura para nombres de cambios y documenta los errores comunes que los usuarios cometen al trabajar con SDD, para incluirlos como advertencias en los skills relevantes.

## Requisitos AGREGADOS

### Requisito: Regla de Nomenclatura kebab-case

El sistema DEBE exigir que todos los nombres de cambios usen formato kebab-case (palabras separadas por guiones, todo en minúsculas).

#### Escenario: Nombre de Cambio en kebab-case

- GIVEN el usuario crea un nuevo cambio con nombre "agregar-modo-oscuro"
- WHEN el skill valida el nombre
- THEN DEBE aceptar el nombre como válido
- AND DEBE continuar con la creación del cambio

#### Escenario: Nombre de Cambio en camelCase

- GIVEN el usuario crea un nuevo cambio con nombre "agregarModoOscuro"
- WHEN el skill valida el nombre
- THEN DEBE RECHAZAR el nombre inmediatamente
- AND DEBE mostrar error indicando que debe usar kebab-case
- AND DEBE mostrar ejemplo: "agregar-modo-oscuro"

#### Escenario: Nombre de Cambio en PascalCase

- GIVEN el usuario crea un nuevo cambio con nombre "AgregarModoOscuro"
- WHEN el skill valida el nombre
- THEN DEBE RECHAZAR el nombre inmediatamente
- AND DEBE mostrar error indicando que debe usar kebab-case
- AND DEBE mostrar ejemplo: "agregar-modo-oscuro"

#### Escenario: Nombre de Cambio con Espacios

- GIVEN el usuario crea un nuevo cambio con nombre "agregar modo oscuro"
- WHEN el skill valida el nombre
- THEN DEBE RECHAZAR el nombre inmediatamente
- AND DEBE mostrar error indicando que los espacios no son válidos
- AND DEBE sugerir usar guiones en su lugar

### Requisito: Inclusión en Config.yaml Generado

El sistema DEBE incluir la regla `change_naming: kebab-case` en el `config.yaml` generado por `sdd-init`.

#### Escenario: Config.yaml Incluye Regla de Naming

- GIVEN el usuario ejecuta `sdd-init` en un proyecto
- AND el skill genera `openspec/config.yaml`
- WHEN el archivo es escrito
- THEN DEBE incluir la sección `rules.change_naming: kebab-case`
- AND la regla DEBE ser aplicada en fases posteriores (sdd-propose, etc.)

### Requisito: Documentación en openspec-convention.md

El sistema DEBE documentar la regla de nomenclatura en `openspec-convention.md`.

#### Escenario: Convención Actualizada

- GIVEN se modifica `skills/_shared/openspec-convention.md`
- AND se agrega la regla de nomenclatura
- WHEN los usuarios consultan la convención
- THEN DEBEN encontrar:
- La regla explicada
- Ejemplos de nombres válidos e inválidos
- Referencia a la validación en `config.yaml`

### Requisito: Errores Comunes en sdd-propose

El skill DEBE incluir una sección de errores comunes para ayudar a los usuarios a evitar mistakes frecuentes.

#### Escenario: Sección Errores Comunes Presente

- GIVEN el usuario consulta `skills/sdd-propose/SKILL.md`
- WHEN lee el archivo
- THEN DEBE encontrar una sección "## Errores Comunes"
- AND la sección DEBE incluir:
- Alucinaciones de contexto (inventar información no proporcionada)
- Olvidar el plan de rollback
- Scope creep (agregar features fuera del alcance)
- No seguir la regla de nomenclatura

### Requisito: Errores Comunes en sdd-apply

El skill DEBE incluir una sección de errores comunes para ayudar a los usuarios a evitar mistakes durante la implementación.

#### Escenario: Sección Errores Comunes Presente

- GIVEN el usuario consulta `skills/sdd-apply/SKILL.md`
- WHEN lee el archivo
- THEN DEBE encontrar una sección "## Errores Comunes"
- AND la sección DEBE incluir:
- Modificar specs/design sin actualizar proposal primero
- Ignorar tareas del checklist
- No seguir patrones de código existentes del proyecto
- Dejar tareas incompletas sin documentación

## Requisitos MODIFICADOS

### Requisito: Plantilla de Proposal - Nomenclatura

**Nueva descripción:**
El nombre del cambio DEBE seguir el formato kebab-case (ej: "agregar-modo-oscuro", "fix-auth-bug"). Esta regla es obligatoria y será validada.

(Anteriormente: No había restricción de nomenclatura)

#### Escenario: Nombre Inválido en Proposal

- GIVEN el usuario intenta crear una propuesta con nombre "FixAuthBug"
- WHEN sdd-propose valida el nombre
- THEN DEBE rechazar el nombre
- AND DEBE mostrar la regla de nomenclatura con ejemplos
