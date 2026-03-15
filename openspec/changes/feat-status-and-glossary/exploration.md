# Exploración: feat-status-and-glossary

## Estado Actual

El proyecto Agentify-SDD cuenta actualmente con 9 skills SDD que cubren todo el ciclo de vida del desarrollo guiado por especificaciones:
- sdd-apply, sdd-archive, sdd-design, sdd-explore, sdd-init, sdd-propose, sdd-spec, sdd-tasks, sdd-verify

El orquestador gestiona la ejecución de estas skills mediante comandos como `/sdd-new`, `/sdd-continue`, `/sdd-apply`, etc. Cada cambio activo tiene un archivo `state.yaml` que registra su fase actual, tiempos y estado.

**Falta existente:** No existe un comando para visualizar el estado del DAG de cambios activos, ni un glosario de dominio para mantener consistencia terminológica entre sub-agentes.

## Áreas Afectadas

- `skills/sdd-status/SKILL.md` — **NUEVO** — Skill a crear para reportar estado del DAG
- `skills/_shared/orchestrator-core.md` — **MODIFICAR** — Agregar `/sdd-status` a la lista de comandos
- `scripts/install.sh` — **MODIFICAR** — Validación de skills dinámicas (ya soporta cualquier skill en `sdd-*/`)
- `scripts/install_test.sh` — **MODIFICAR** — Actualizar EXPECTED_SKILLS de 9 a 10
- `skills/sdd-init/SKILL.md` — **MODIFICAR** — Agregar bloque `glossary:` en config.yaml
- `skills/_shared/persistence-contract.md` — **MODIFICAR** — Reforzar carga obligatoria del glosario
- `openspec/changes/feat-status-and-glossary/state.yaml` — Lee estado actual del cambio

## Enfoques

### Enfoque 1: Skill simple de solo lectura (sdd-status)

- **Descripción:** Crear una skill que lea archivos `state.yaml` y genere un reporte visual
- **Ventajas:** 
  - No modifica el flujo existente del orquestador
  - Fácil de implementar y mantener
  - Patrón consistente con otras skills
- **Desventajas:**
  - El orquestador debe aprender explícitamente a invocarla
  - No es un comando nativo del orquestador
- **Esfuerzo:** Bajo

### Enfoque 2: Integración profunda en el orquestador

- **Descripción:** Modificar orchestrator-core.md para que el orquestador calcule y muestre el estado internamente sin delegar
- **Ventajas:**
  - No requiere skill adicional
  - Más rápido (sin overhead de delegación)
- **Desventajas:**
  - Viola el principio de "el orquestador es un coordinador, no un ejecutor"
  - Más código en el orchestrator-core
  - Difícil de mantener
- **Esfuerzo:** Medio

### Recomendación para Glosario

**Enfoque 3: Glosario como bloque en config.yaml**

- Agregar `glosary:` en `sdd-init` como bloque comentado con ejemplos
- Modificar `persistence-contract.md` para que las skills de propose, spec y design **DEBAN** cargar el glosario
- El glosario es consulted por las skills, no modificado por ellas

## Análisis Técnico

### Estructura de state.yaml (disponible)

```yaml
change: feat-status-and-glossary
started_at: "2026-03-14T16:14:00"
last_updated: "2026-03-14T16:14:00"
phase: explore
completed_phases: []
pending_phases: [explore, propose, spec, design, tasks, apply, verify, archive]
blocked_reason: null
```

### Tabla de sdd-status propuesta

| Cambio | Fase Actual | Tiempo Transcurrido | Estado |
|--------|-------------|-------------------|--------|
| feat-xxx | tasks | 2h 30m | 🟢 Activo |
| feat-yyy | blocked | 5h 15m | 🔴 Bloqueado |

- **🟢 Activo:** phase != blocked y pending_phases no vacío
- **🟡 Bloqueado:** phase == blocked
- **🔴 Completado:** phase == done

### Scripts de instalación

- **install.sh:** Itera sobre `skills/sdd-*/` dinámicamente — NO requiere cambios para agregar nuevas skills
- **install_test.sh:** Array hardcodeado `EXPECTED_SKILLS=(sdd-apply sdd-archive sdd-design sdd-explore sdd-init sdd-propose sdd-spec sdd-tasks sdd-verify)` — **SÍ requiere actualización** para pasar de 9 a 10 skills
- Tests verifican conteo exacto: `assert_eq "9" "$count"`

## Riesgos

1. **Riesgo de compatibilidad:** Los tests actuales esperan exactamente 9 skills. Actualizar a 10 romperá los tests existentes hasta actualizarlos.
2. **Riesgo de Glosario vacío:** Si config.yaml no tiene glosario, las skills deben funcionar igual (es opcional). Se necesita manejar el caso "sin glosario".
3. **Riesgo de comandos duplicados:** Si el orquestador ya maneja algún mecanismo de status internamente, podría haber conflicto.
4. **Riesgo de formato de tiempo:** Calcular "tiempo transcurrido" desde `started_at` requiere parsing de fechas ISO 8601.

## Listo para Propuesta

**Sí.** La exploración ha identificado claramente:

1. Los archivos a crear y modificar
2. El patrón a seguir (basado en skills existentes)
3. Los tests que necesitan actualización
4. La estructura de datos disponible en state.yaml
5. La estructura del glosario a implementar

El siguiente paso es crear `proposal.md` con la intención, alcance y enfoque detallado de ambos objetivos (sdd-status + Glosario).
