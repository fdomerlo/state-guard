# Delta para BDD Syntax

## Propósito

Este delta especifica las reglas AGREGADAS a la skill `sdd-spec` para mantener la integridad de la sintaxis Gherkin en los escenarios BDD, evitando el uso de variantes no estándar como "GAND".

## Requisitos AGREGADOS

### Requisito: Sintaxis Gherkin Inmutable

El sub-agente de spec DEBE garantizar que todos los escenarios usen exclusivamente las palabras clave Gherkin estándar (GIVEN, WHEN, THEN, AND, BUT). El sistema NO DEBE permitir el uso de variantes no estándar como "GAND" (Given-And), "WAND" (When-And), o cualquier otra combinación no autorizada.

#### Escenario: Escenario con sintaxis Gherkin estándar

- GIVEN un escenario de spec que usa palabras clave estándar
- WHEN el sub-agente valida la sintaxis
- THEN el sistema DEBE aceptar el escenario como válido
- AND DEBE registrar en los logs que la validación fue exitosa

#### Escenario: Escenario con variante no estándar (GAND)

- GIVEN un escenario de spec que usa "GAND" en lugar de "GIVEN"
- WHEN el sub-agente ejecuta la validación de sintaxis
- THEN el sistema DEBE rechazar el escenario
- AND DEBE mostrar un error indicando que "GAND no es una palabra clave Gherkin válida"

#### Escenario: Escenario con múltiples variantes no estándar

- GIVEN un escenario que combina "GAND", "WAND" y otras variantes
- WHEN el sub-agente detecta múltiples violaciones de sintaxis
- THEN el sistema DEBE reportar cada violación individualmente
- AND DEBE sugerir el uso de las palabras clave estándar correspondientes

### Requisito: Validación de Palabras Clave

El sistema DEBE incluir una lista de palabras clave Gherkin válidas que incluya: GIVEN, WHEN, THEN, AND, BUT, Feature, Background, Scenario, Scenario Outline, Examples. Cualquier palabra fuera de esta lista DEBE ser marcada como inválida.

#### Escenario: Verificación de lista de palabras válidas

- GIVEN la lista de palabras clave Gherkin válidas
- WHEN una palabra clave de escenario es evaluada
- THEN el sistema DEBE verificar contra la lista de palabras válidas
- AND DEBE retornar verdadero solo si la palabra está en la lista

## Requisitos MODIFICADOS

(No aplica para este hotfix)

## Requisitos ELIMINADOS

(No aplica para este hotfix)
