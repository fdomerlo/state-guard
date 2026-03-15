# Exploración: refactor-workflow-optimization

## Estado Actual

El orquestador SDD actual (`orchestrator-core.md`) tiene las siguientes características:
- Maneja comandos: `/sdd-init`, `/sdd-explore`, `/sdd-new`, `/sdd-continue`, `/sdd-ff`, `/sdd-apply`, `/sdd-verify`, `/sdd-archive`
- No tiene regla para detectar múltiples cambios activos cuando no se especifica `[change]`
- No tiene lógica de paralelismo condicional basada en la herramienta de ejecución
- No existe el comando `/sdd-fix`

El skill `sdd-propose` actual:
- Lee `exploration.md` si existe (vía contrato de persistencia)
- NO tiene validación explícita de si la exploración fue realizada
- NO incluye advertencia cuando se genera sin exploración previa

## Áreas Afectadas

- `skills/_shared/orchestrator-core.md` — Necesita 3 nuevas reglas de negocio
- `skills/sdd-propose/SKILL.md` — Necesita validación de contexto y advertencia
- `skills/sdd-apply/SKILL.md` — Necesita aceptar errores del verify para el loop de fix
- `skills/sdd-verify/SKILL.md` — Genera `verify-report.md` que será leído por `/sdd-fix`

## Enfoques

### 1. Implementación Estricta de Reglas en Orchestrator
- **Ventajas:** Cumple exactamente con los requisitos, código limpio
- **Desventajas:** Requiere modificar prompts existentes
- **Esfuerzo:** Medio

### 2. Implementación con Variables de Entorno para Detección de Herramienta
- **Ventajas:** Más flexible, permite agregar más herramientas
- **Desventajas:** Requiere coordinación con las herramientas
- **Esfuerzo:** Alto

## Recomendación

Seguir el enfoque 1 (Implementación Estricta) ya que los requisitos son claros y específicos. La detección de herramienta puede hacerse mediante la variable `{{TOOL_NAME}}` que ya existe en el prompt del orquestador.

## Riesgos

- La regla de concurrencia podría causar fricción si el usuario tiene muchos cambios activos
- La detección de herramienta mediante `{{TOOL_NAME}}` puede no ser confiable para todas las herramientas
- El loop de fix requiere que `sdd-apply` acepte entrada de errores adicional

## Listo para Propuesta

**Sí.** La exploración identifica claramente:
1. Archivos a modificar
2. Reglas de negocio a agregar
3. Dependencias entre skills (`sdd-fix` → `sdd-apply` + `sdd-verify`)
4. Necesidad de actualizar el schema de `state.yaml` para rastrear reintentos de fix
