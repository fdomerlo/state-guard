# Exploración: Duplicación en Skills SDD

## Resultado de la Fase

**status**: ok

### executive_summary

Se identificaron 3 tipos de duplicación masiva en los archivos SKILL.md: (1) Return Envelope estático en 14 archivos (~560 tokens), (2) secciones Errores Comunes en sdd-propose y sdd-apply (~360 tokens), (3) pseudocódigo de detección de test runner en sdd-verify y sdd-apply (~100 tokens). Total aproximado: 1000 tokens de duplicación.

### artifacts

- `openspec/changes/refactor-dry-skills/exploration.md` — Creado

### next_recommended

sdd-propose

### risks

- La refactorización requiere actualizar las referencias en skills que usan bloques compartidos
- Algunos bloques tienen variaciones sutiles que requieren análisis cuidadoso para consolidar

### detailed_report

## 1. Duplicación del "Return Envelope"

### Archivos con Return Envelope estático (Reglas)

| Archivo | Línea | Texto exacto |
|---------|-------|--------------|
| `skills/sdd-explore/SKILL.md` | 122 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-propose/SKILL.md` | 127 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-spec/SKILL.md` | 156 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-design/SKILL.md` | 148 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-tasks/SKILL.md` | 149 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-apply/SKILL.md` | 183 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-verify/SKILL.md` | 280 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-archive/SKILL.md` | 173 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-review/SKILL.md` | 143 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-status/SKILL.md` | 102 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-changelog/SKILL.md` | 137 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-split/SKILL.md` | 165 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-fix/SKILL.md` | 122 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |
| `skills/sdd-init/SKILL.md` | 156 | RETORNA el resultado siguiendo estrictamente el formato del Return Envelope definido en `skills/_shared/sdd-phase-common.md` |

**Nota adicional**: `skills/sdd-review/SKILL.md` tiene una sección más extensa (líneas 124-143) con explicación detallada del formato, más allá de la simple instrucción.

**Tokens aproximados**: ~560 tokens (14 archivos × ~40 tokens por instrucción)

---

## 2. Secciones "Errores Comunes" Duplicadas

### sdd-propose/SKILL.md (líneas 129-147)

```markdown
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
```

### sdd-apply/SKILL.md (líneas 185-203)

```markdown
## Errores Comunes

Al implementar tareas, evitá estos errores frecuentes:

### 1. Modificar specs/design sin actualizar proposal primero
**Problema**: Cambiar las especificaciones o el diseño sin antes actualizar la propuesta para reflejar esos cambios.
**Solución**: Siempre actualizá proposal.md primero si hay cambios en el alcance o enfoque técnico.

### 2. Ignorar el checklist de tareas
**Problema**: No seguir la lista de tareas definida o implementar funcionalidades fuera de las tareas asignadas.
**Solución**: Implementá solo las tareas asignadas. Si encontrás tareas adicionales necesarias, reportalas al orquestador.

### 3. No seguir los patrones de código existentes
**Problema**: Implementar código que no sigue las convenciones, estilos o patrones del proyecto.
**Solución**: Antes de implementar, leé los archivos existentes del proyecto para entender los patrones en uso.

### 4. Dejar tareas incompletas sin documentación
**Problema**: Marcar tareas como completadas sin haberlas terminado realmente, o sin documentar desviaciones.
**Solución**: Marcá tareas como completadas SOLO cuando estén 100% feitas. Si hay problemas, documentalos en el resumen.
```

**Análisis**: Aunque el contenido es diferente (Errores Comunes específicos de cada fase), la estructura de secciones y formato es idéntica. Esto sugiere que podría crearse un archivo compartido `skills/_shared/sdd-phase-errors.md` con estructura base.

**Tokens aproximados**: ~360 tokens (180 palabras × 2 archivos)

---

## 3. Bloque de "Detección de Test Runner" Duplicado

### sdd-apply/SKILL.md (líneas 86-95)

```markdown
Detecta el test runner para la ejecución:

Detectar test runner desde:
├── openspec/config.yaml → rules.apply.test_command (máxima prioridad)
├── package.json → scripts.test
├── pyproject.toml / pytest.ini → pytest
├── Makefile → make test
└── Fallback: reportar que los tests no pudieron ejecutarse automáticamente
```

### sdd-verify/SKILL.md (líneas 89-109)

```markdown
Detectar el test runner del proyecto y ejecutar los tests:

Detectar test runner desde:
├── openspec/config.yaml → rules.verify.test_command (máxima prioridad)
├── package.json → scripts.test
├── pyproject.toml / pytest.ini → pytest
├── Makefile → make test
└── Fallback: consultar al orquestador

Ejecutar: {test_command}
Capturar:
├── Total de tests ejecutados
├── Pasaron
├── Fallaron (listar cada uno con nombre y error)
├── Omitidos
└── Código de salida

Marcar: CRITICAL si el código de salida != 0 (algún test falló)
Marcar: WARNING si tests omitidos se relacionan con áreas modificadas
```

**Análisis**: La detección es idéntica en ambos archivos (solo cambia `rules.apply.test_command` vs `rules.verify.test_command`). La diferencia es que sdd-verify incluye la ejecución y captura de resultados mientras sdd-apply solo detecta para usarlo en el flujo TDD.

**Tokens aproximados**: ~100 tokens (duplicación parcial, solo la detección ~50 tokens × 2 archivos)

---

## Resumen de Tokens Salvables

| Tipo de Duplicación | Tokens Aproximados |
|---------------------|-------------------|
| Return Envelope (14 archivos) | ~560 |
| Errores Comunes (2 archivos) | ~360 |
| Detección test runner (2 archivos) | ~100 |
| **TOTAL** | **~1020 tokens** |

---

## Recomendaciones de Refactorización

1. **Return Envelope**: El archivo `skills/_shared/sdd-phase-common.md` ya existe y define el formato. La instrucción en cada skill podría reducirse a una referencia más breve o吾布 include el contenido completo.

2. **Errores Comunes**: Crear `skills/_shared/sdd-phase-errors.md` con estructura base y permitir herencia/especificación por fase.

3. **Detección de Test Runner**: Extraer a `skills/_shared/sdd-detect-runner.md` con parámetro de configuración (`rules.apply.test_command` vs `rules.verify.test_command`).

