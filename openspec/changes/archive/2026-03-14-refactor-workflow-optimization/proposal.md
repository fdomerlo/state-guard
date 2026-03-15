# Propuesta: refactor-workflow-optimization

## Intención

Optimizar el flujo de trabajo del orquestador SDD para: (1) manejar concurrencia de forma segura requiriendo especificación explícita de cambio cuando hay múltiples activos, (2) reducir latencia mediante paralelismo condicional en fases compatibles, (3) prevenir alucinaciones en propuestas exigiendo validación de contexto de exploración, y (4) cerrar el ciclo de feedback de verificación agregando un comando de corrección automática.

## Alcance

### Dentro del Alcance

- **Regla de Concurrencia (Stateless)**: Modificar `orchestrator-core.md` para detectar múltiples cambios activos y pedir selección explícita.
- **Regla de Paralelismo Condicional**: Agregar lógica para ejecutar fases `spec` y `design` en paralelo solo cuando la herramienta soporte sub-agentes nativos.
- **Regla del Loop de Fix**: Agregar comando `/sdd-fix [change]` que lea `verify-report.md` y re-ejecute `sdd-apply` con errores.
- **Regla de Contexto Estricto en sdd-propose**: Validar existencia de exploración previa y mostrar advertencia si no existe.
- Actualizar `sdd-apply/SKILL.md` para aceptar errores del verify como entrada.
- Actualizar `sdd-verify/SKILL.md` para generar reporte estructurado que pueda ser consumido por `/sdd-fix`.

### Fuera del Alcance

- Modificación del sistema de almacenamiento de artefactos (permanece en `openspec`).
- Cambios en la estructura de `state.yaml` para rastrear reintentos de fix (queda como trabajo futuro).
- Implementación de detección avanzada de herramientas más allá de `{{TOOL_NAME}}`.

## Enfoque

Se seguirá la implementación estricta (Enfoque 1 de la exploración) porque los requisitos son claros y específicos. La detección de herramienta se realizará mediante la variable `{{TOOL_NAME}}` que ya existe en el prompt del orquestador, evaluando si el valor corresponde a herramientas con soporte nativo de sub-agentes (Claude Code, OpenCode) versus herramientas inline (Gemini CLI, Codex).

## Áreas Afectadas

| Área                              | Impacto     | Descripción                                                              |
|-----------------------------------|-------------|--------------------------------------------------------------------------|
| `skills/_shared/orchestrator-core.md` | Modificado  | Agregar 3 reglas de negocio: concurrencia, paralelismo condicional, loop de fix |
| `skills/sdd-propose/SKILL.md`     | Modificado  | Validar contexto de exploración y mostrar advertencia si no existe        |
| `skills/sdd-apply/SKILL.md`       | Modificado  | Aceptar errores del verify como entrada adicional para correcciones      |
| `skills/sdd-verify/SKILL.md`      | Modificado  | Generar `verify-report.md` estructurado para consumo por `/sdd-fix`       |

## Riesgos

| Riesgo                                                      | Probabilidad | Mitigación                                                               |
|-------------------------------------------------------------|--------------|--------------------------------------------------------------------------|
| La regla de concurrencia causa fricción con muchos cambios | Media        | Documentar claramente el comportamiento; el usuario puede archivar cambios |
| Detección de herramienta mediante `{{TOOL_NAME}}` no es confiable | Alta      | Definir lista explícita de herramientas soportadas; fallback a secuencial |
| El loop de fix puede entrar en ciclo infinito              | Baja         | Limitar reintentos en `state.yaml` (implementación futura si es necesario) |
| Advertencia de exploración puede ser ignorada              | Media        | Incluir la advertencia en sección visible de riesgos de la propuesta      |

## Plan de Rollback

1. Revertir cambios en `orchestrator-core.md` eliminando las 3 nuevas reglas de negocio.
2. Revertir cambios en `sdd-propose/SKILL.md` eliminando la validación de contexto.
3. Revertir cambios en `sdd-apply/SKILL.md` removiendo la aceptación de errores del verify.
4. Revertir cambios en `sdd-verify/SKILL.md` si el formato de reporte cambió.
5. No se requiere migración de datos ya que los cambios son en lógica de prompts, no en estructura de archivos.

## Dependencias

- Ninguna dependencia externa. Todos los archivos a modificar existen en el repositorio actual.
- La implementación depende del orden: primero `sdd-propose` y `sdd-verify`, luego `sdd-apply` y finalmente `orchestrator-core`.

## Criterios de Éxito

- [ ] El orquestador se detiene y pide especificación de cambio cuando hay más de un cambio activo y no se especifica `[change]`.
- [ ] Las fases `spec` y `design` se ejecutan en paralelo solo cuando `{{TOOL_NAME}}` indica herramienta con sub-agentes.
- [ ] El comando `/sdd-fix [change]` lee `verify-report.md` y re-ejecuta `sdd-apply` con los errores.
- [ ] La propuesta muestra advertencia severa cuando no existe `exploration.md` previo.
- [ ] Los tests existentes (si existen) siguen pasando tras los cambios.
