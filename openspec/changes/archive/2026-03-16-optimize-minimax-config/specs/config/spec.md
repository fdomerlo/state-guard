# Especificación: optimize-minimax-config

## Intención

Actualizar el archivo `openspec/config.yaml` del proyecto para inyectar directivas estrictas de diseño de sistemas y codificación defensiva, optimizadas para el motor de razonamiento MiniMax M2.5.

## Áreas Afectadas

- `openspec/config.yaml` — única área de modificación

---

## Requisitos Funcionales

### RF-001: Inyección de Regla de Diagramas Mermaid en Fase Design

**Description**: Agregar regla en la fase `design` que exija diagramas Mermaid exhaustivos para flujos no triviales.

**Rules**:
- La fase `design` del archivo `config.yaml` MUST incluir una regla que indique el uso de diagramas Mermaid (State, Sequence o Class) para flujos no triviales.
- La regla MUST usar la palabra "DEBES" para indicar obligatoriedad.

**Scenarios**:

| Scenario | Given | When | Then |
|----------|-------|------|------|
| SM-001: Diagrama obligatorio para flujo no trivial | Se está creando un design para un flujo no trivial | El orquestador genera el documento design | El documento MUST incluir al menos un diagrama Mermaid (State, Sequence o Class) |
| SM-002: Diagramas exhaustivos | El flujo tiene múltiples分支 o interacciones | Se diseña la arquitectura | Los diagramas deben representar todos los estados y transiciones relevantes |

---

### RF-002: Inyección de Regla de Modularidad Extrema en Fase Design

**Description**: Agregar regla en la fase `design` que priorice la modularidad extrema para modelos de IA con contexto limitado.

**Rules**:
- La fase `design` MUST incluir una regla que indique diseñar asumiendo que el código será escrito por un modelo de IA con ventana de contexto limitada.
- La regla MUST mencionar "Interfaces claras y acoplamiento nulo".

**Scenarios**:

| Scenario | Given | When | Then |
|----------|-------|------|------|
| SM-003: Diseño para contexto limitado | Se diseña una nueva funcionalidad | El arquitecto crea el documento design | El diseño debe dividir el sistema en módulos pequeños con interfaces claras |
| SM-004: Acoplamiento nulo | Dos componentes necesitan comunicarse | Se diseña la interacción entre ellos | La comunicación debe ser mediante interfaces explícitas sin dependencias directas |

---

### RF-003: Inyección de Regla de Granularidad Atómica en Fase Tasks

**Description**: Agregar regla en la fase `tasks` que exija granularidad atómica para cada tarea.

**Rules**:
- La fase `tasks` MUST incluir una regla que indique que cada tarea debe ser lo suficientemente pequeña para implementarse en un solo archivo o módulo lógico.
- La regla MUST indicar "Evitar 'tareas monstruo'".

**Scenarios**:

| Scenario | Given | When | Then |
|----------|-------|------|------|
| SM-005: Tarea atómica | Se desglosa un cambio en tareas | El orquestador genera la lista de tareas | Cada tarea debe poder completarse en un solo archivo o módulo lógico |
| SM-006: Evitar tareas monstruo | Una tarea requiere más de 200 líneas de código | Se evalúa la granularidad | La tarea debe dividirse en subtareas más pequeñas |

---

### RF-004: Inyección de Regla de Código Defensivo en Fase Apply

**Description**: Agregar regla en la fase `apply` que exija código defensivo, principios SOLID, DRY y Early Returns.

**Rules**:
- La fase `apply` MUST incluir una regla que indique aplicar principios SOLID, DRY y Clean Code.
- La regla MUST indicar "Prefiere Early Returns (Guard Clauses)".
- La regla MUST indicar "NUNCA sobre-ingeniar".

**Scenarios**:

| Scenario | Given | When | Then |
|----------|-------|------|------|
| SM-007: Early Returns | Una función tiene múltiples condiciones de salida temprana | Se escribe el código | Se DEBEN usar guard clauses para manejar casos triviales primero |
| SM-008: Principios SOLID | Se crea una nueva clase o módulo | El desarrollador escribe el código | El código debe respetar los principios SOLID |
| SM-009: No sobre-ingeniar | Se necesita implementar una funcionalidad simple | Se decide la arquitectura | NO se deben agregar abstracciones innecesarias |

---

### RF-005: Inyección de Regla de Completitud en Fase Apply

**Description**: Agregar regla en la fase `apply` que exija completitud sin placeholders.

**Rules**:
- La fase `apply` MUST incluir una regla que indique no usar placeholders como '...código restante aquí...'.
- La regla MUST indicar que si se escribe un archivo, debe estar completo y listo para producción.

**Scenarios**:

| Scenario | Given | When | Then |
|----------|-------|------|------|
| SM-010: Sin placeholders | Se implementa un archivo completo | El desarrollador escribe código | NO debe contener texto como '...código restante aquí...' o '// TODO' |
| SM-011: Completitud total | Se crea un nuevo archivo de código | El modelo de IA termina la implementación | El archivo debe compilar/ejecutar sin errores de sintaxis por código faltante |

---

## Requisitos No Funcionales

### RNF-001: Validación YAML

**Description**: El archivo modificado debe seguir siendo YAML válido.

**Rules**:
- El archivo `config.yaml` MUST ser parseable por `yaml.safe_load()` de Python sin errores.

**Scenarios**:

| Scenario | Given | When | Then |
|----------|-------|------|------|
| SM-012: YAML válido | Se modifica el archivo config.yaml | Se ejecuta validación | El archivo debe parsearse correctamente sin excepciones |

### RNF-002: Preservación de Contexto y Glossary

**Description**: El context y glossary existentes deben preservarse sin modificaciones.

**Rules**:
- La sección `context:` del archivo MUST mantenerse sin cambios.
- La sección `glossary:` (si existe) debe mantenerse sin cambios.

**Scenarios**:

| Scenario | Given | When | Then |
|----------|-------|------|------|
| SM-013: Context preservado | Se agregan nuevas reglas | Se modifica el archivo | El contenido de `context:` debe ser idéntico al original |
| SM-014: Glossary preservado | Se agregan nuevas reglas | Se modifica el archivo | La sección `glossary:` (comentada o no) debe mantenerse igual |

### RNF-003: Idioma Español

**Description**: Todas las nuevas reglas deben estar en español.

**Rules**:
- Las nuevas reglas agregadas a las fases `design`, `tasks` y `apply` MUST estar en español.

---

## Criterios de Aceptación

- [ ] El archivo `openspec/config.yaml` sigue siendo YAML válido después de la modificación
- [ ] Las 5 nuevas reglas están correctamente insertadas en sus fases correspondientes (design: 2, tasks: 1, apply: 2)
- [ ] El `context` existente se preserva sin modificaciones
- [ ] Las nuevas reglas están en español
- [ ] Cada regla sigue el formato de lista con guiones del archivo existente
- [ ] Todas las reglas usan el estilo de texto de las reglas existentes (sin corchetes adicionales a menos que sea necesario)
