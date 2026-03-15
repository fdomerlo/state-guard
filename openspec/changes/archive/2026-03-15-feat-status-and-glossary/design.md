# Diseño: feat-status-and-glossary

## Enfoque Técnico

Este cambio implementa dos características ortogonales pero complementarias para mejorar la visibilidad y consistencia del proyecto Agentify-SDD:

1. **Skill `sdd-status`**: Una nueva skill de solo lectura que lee los archivos `state.yaml` de todos los cambios activos y genera una tabla Markdown con emojis de semáforo. Sigue el mismo patrón de las skills existentes (`sdd-explore`, `sdd-propose`, etc.).

2. **Glosario de Dominio**: Un bloque YAML en `openspec/config.yaml` que los sub-agentes cargan al inicio para mantener consistencia terminológica. Se implementa mediante modificaciones a `sdd-init` (generación) y `persistence-contract.md` (carga).

## Decisiones de Arquitectura

### Decisión 1: Estructura de sdd-status como Skill

**Elección**: Crear `sdd-status` como una skill completa en `skills/sdd-status/SKILL.md`, siguiendo el mismo patrón que las skills existentes.

**Alternativas consideradas**:
- Implementar como función inline dentro del orquestador
- Crear como comando slash de OpenCode (`commands/sdd-status.md`)

**Justificación**: 
- Las skills existentes siguen un patrón consistente (ubicación en `skills/sdd-*/SKILL.md`)
- El flujo SDD ya tiene precedenteyes para comandos (`/sdd-init`, `/sdd-explore`, etc.)
- Mantiene la separación de responsabilidades: el orquestador delega, la skill ejecuta
- El script `install.sh` ya soporta dinámicamente nuevas skills (recorre `skills/sdd-*/`)

### Decisión 2: Formato del Glosario

**Elección**: Usar un bloque YAML `glossary:` dentro de `openspec/config.yaml`, con estructura de términos y definiciones.

**Alternativas consideradas**:
- Archivo separado `openspec/glossary.yaml`
- Base de datos de términos en JSON
- Sección en `openspec-convention.md`

**Justificación**:
- Mantiene la configuración centralizada en un solo archivo (`config.yaml`)
- YAML permite comentarios, ideal para ejemplos documentados
- No requiere cambios en la estructura de carpetas de OpenSpec
- Los ejemplos pueden estar comentados inicialmente (como indica la propuesta)

**Estructura propuesta para config.yaml**:

```yaml
# openspec/config.yaml
version: "1.0"
artifact_store:
  mode: openspec

# Glosario de términos del dominio (opcional)
# glossary:
#   terms:
#     - term: "Artefacto"
#       definition: "Archivo generado por una fase SDD (proposal, spec, design, tasks)"
#     - term: "Cambio"
#       definition: "Una unidad de trabajo en el DAG de SDD"
```

### Decisión 3: Carga del Glosario por Sub-agentes

**Elección**: Modificar el `persistence-contract.md` para que las skills lean el glosario al inicio, pero con graceful degradation (si no existe, funcionan igual).

**Alternativas consideradas**:
- Forzar la existencia del glosario como requisito
- Cargar solo en skills específicas (propose, spec, design)

**Justificación**:
- Mantiene compatibilidad hacia atrás con proyectos existentes
- Evita bloquear la implementación si el glosario no está definido
- Las fases principales (propose, spec, design) son las que más se benefician de terminología consistente

### Decisión 4: Cálculo de Tiempo Transcurrido

**Elección**: Usar formato simple "Xh Ym" basado en la diferencia entre `started_at` y la hora actual.

**Alternativas consideradas**:
- Formato relativo ("hace 2 horas")
- Formato detallado (días, horas, minutos, segundos)

**Justificación**:
- Formato "Xh Ym" es consistente y fácil de parsear visualmente
- Las fechas tienen formato ISO 8601, fácil de convertir con herramientas estándar
- Cumple con el requisito de legibilidad humana

## Flujo de Datos

### Flujo: sdd-status

```
┌─────────────────────────────────────────────────────────────┐
│                    Orquestador SDD                         │
│  Usuario ejecuta: /sdd-status                              │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  sdd-status (skill)                                        │
│  1. Busca archivos state.yaml en openspec/changes/        │
│  2. Lee cada archivo y extrae campos                      │
│  3. Filtra cambios archivados (phase=done/archive)        │
│  4. Calcula tiempo transcurrido                           │
│  5. Aplica lógica de semáforo                             │
│  6. Genera tabla Markdown                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│  Output: Tabla Markdown con estado de cambios             │
│  | Cambio | Fase Actual | Tiempo | Estado |               │
└─────────────────────────────────────────────────────────────┘
```

### Flujo: Glosario

```
┌─────────────────────────────────────────────────────────────┐
│  sdd-init (skill)                                          │
│  1. Lee config.yaml existente                             │
│  2. Agrega bloque glossary: con ejemplos                  │
│  3. Guarda config.yaml                                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  openspec/config.yaml                                      │
│  +glossary:                                                │
│    terms:                                                  │
│      - term: "Artefacto"                                  │
│        definition: "..."                                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Sub-agentes (propose, spec, design, etc.)                 │
│  1. Carga persistence-contract.md (sección glosario)      │
│  2. Busca openspec/config.yaml                             │
│  3. Si existe glossary, lo carga y usa términos            │
│  4. Si no existe, continúa sin él (graceful degradation)  │
└─────────────────────────────────────────────────────────────┘
```

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `skills/sdd-status/SKILL.md` | Crear | Nueva skill que lee state.yaml y genera tabla de estado |
| `skills/_shared/orchestrator-core.md` | Modificar | Agregar `/sdd-status` a la lista de comandos de orquestación |
| `scripts/install_test.sh` | Modificar | Actualizar EXPECTED_SKILLS de 9 a 10; actualizar todos los `assert_eq "9"` a `"10"` |
| `skills/sdd-init/SKILL.md` | Modificar | Agregar generación de bloque `glossary:` en config.yaml |
| `skills/_shared/persistence-contract.md` | Modificar | Agregar instrucción para que sub-agentes carguen el glosario |
| `openspec/config.yaml` | Modificar | Incluir ejemplos de glosario (comentados) |

## Interfaces / Contratos

### Skill sdd-status

La skill implementa la interfaz de sub-agente estándar:

```
Input: Modo de almacenamiento (openspec|none)
Output: Tabla Markdown con columnas [Cambio, Fase Actual, Tiempo Transcurrido, Estado]
Errores: Continúa con archivos válidos si alguno falla (no lanza excepción)
```

### Glosario en config.yaml

```yaml
# Schema opcional del glosario
glossary:
  terms:
    - term: string        # Término técnico
      definition: string  # Definición del término
      # Campos opcionales:
      # aliases: [string] # Sinónimos
      # example: string   # Ejemplo de uso
```

### persistence-contract.md (adición)

```
## Carga de Glosario (para sub-agentes)

Al inicio de cada skill, después de determinar el modo de persistencia:

1. Buscar archivo `openspec/config.yaml`
2. Si existe y contiene clave `glossary`, cargar los términos
3. Usar los términos definidos para mantener consistencia en el output
4. Si no existe el glosario, continuar normalmente (es opcional)

Los términos del glosario deben respetarse al generar artefactos:
- Usar la terminología definida en lugar de sinónimos
- Mantener consistencia semántica en proposal.md, specs/, design.md, etc.
```

## Estrategia de Testing

| Capa | Qué Testear | Enfoque |
|------|-------------|---------|
| **Unitario (sdd-status)** | Funciones de parsing de state.yaml, cálculo de tiempo, lógica de semáforo | Tests unitarios en skill (si el proyecto soporta) |
| **Integración (install.sh)** | Que el script instale correctamente las 10 skills | `install_test.sh` con asserts |
| **E2E** | Flujo completo: install → /sdd-status → mostrar tabla | Test manual o automatizado |
| **Graceful degradation** | Que skills funcionen sin glosario existente | Verificación de continuidad |

### Testing de sdd-status

```
Escenarios a testear:
1. Un cambio activo → tabla con 1 fila, emoji 🟢
2. Cambio bloqueado → emoji 🟡
3. Cambio completado → NO aparece en tabla (filtrado)
4. Sin cambios activos → mensaje "No hay cambios activos"
5. Archivo corrupto → warning, continúa con los demás
6. Múltiples cambios → tabla con todas las filas
```

### Testing del Glosario

```
Escenarios a testear:
1. config.yaml SIN glossary → skills funcionan igual
2. config.yaml CON glossary → skills usan términos definidos
3. glossary vacío → skills funcionan igual
4. Términos con espacios/guiones → parsing correcto
```

## Migración / Despliegue

No se requiere migración de datos. Los cambios son additive:

1. **Nueva skill**: Solo se añade, no modifica comportamiento existente
2. **Glosario**: Es opcional y los ejemplos estarán comentados inicialmente
3. **install_test.sh**: Cambio trivially reversible (9 → 10)

**Plan de despliegue**:
1. Crear `skills/sdd-status/SKILL.md`
2. Modificar `orchestrator-core.md` para reconocer `/sdd-status`
3. Modificar `install_test.sh` para soportar 10 skills
4. Modificar `sdd-init` para generar glosario
5. Modificar `persistence-contract.md` para cargar glosario
6. Regenerar `config.yaml` con ejemplos de glosario

## Preguntas Abiertas

- [ ] ¿El glosario debe ser cargado también por skills de `apply` y `verify`? (actualmente solo propose/spec/design)
- [ ] ¿Se debe validar el formato del glosario contra un schema?
- [ ] ¿Debe existir un comando para agregar términos al glosario desde el chat?
