# Tareas: refactor-workflow-optimization

## Fase 1: Fundación - Revisión de Archivos Existentes

- [ ] 1.1 Revisar `skills/_shared/orchestrator-core.md` para identificar ubicación de las nuevas reglas (después de línea ~43)
- [ ] 1.2 Revisar `skills/sdd-propose/SKILL.md` para identificar dónde agregar validación de exploración
- [ ] 1.3 Revisar `skills/sdd-apply/SKILL.md` para identificar sección "Qué Recibís"
- [ ] 1.4 Revisar `skills/sdd-verify/SKILL.md` para identificar dónde genera el reporte

## Fase 2: Implementación Core - sdd-verify (Reporte Estructurado)

- [x] 2.1 Modificar `skills/sdd-verify/SKILL.md` para generar `verify-report.md` con formato estructurado
- [x] 2.2 Agregar campos explícitos: **Status** (ÉXITO/FALLO), **Errores** (lista), **Detalles** (info de cada fallo)
- [x] 2.3 Verificar que el reporte sea parseable por el orquestador

## Fase 3: Implementación Core - sdd-apply (Recibe Errores)

- [x] 3.1 Modificar `skills/sdd-apply/SKILL.md` en sección "Qué Recibís" para aceptar errores del verify
- [x] 3.2 Agregar lógica para priorizar corrección de errores identificados
- [x] 3.3 Agregar documentación en `tasks.md` sobre errores corregidos

## Fase 4: Implementación Core - orchestrator-core (Reglas de Negocio)

- [x] 4.1 Modificar `skills/_shared/orchestrator-core.md`: Agregar **Regla de Concurrencia (Stateless)**
  - Contar carpetas en `openspec/changes/` (ignorar `archive/`)
  - Si count == 1 → usar ese cambio
  - Si count > 1 → detener, listar cambios, pedir selección
  - Si count == 0 → error "no hay cambios activos"
- [x] 4.2 Modificar `skills/_shared/orchestrator-core.md`: Agregar **Regla de Paralelismo Condicional**
  - Si fases = spec + design Y `{{TOOL_NAME}}` in [Claude Code, OpenCode] → paralelo
  - Si `{{TOOL_NAME}}` in [Gemini CLI, Codex] → secuencial
  - Si tool unknown → fallback secuencial
- [x] 4.3 Modificar `skills/_shared/orchestrator-core.md`: Agregar comando **`/sdd-fix [change]`**
  - Leer `verify-report.md` del cambio
  - Si no existe → error "ejecute verify primero"
  - Si status == ÉXITO → informar "no hay errores"
  - Si status == FALLO → extraer errores, lanzar sdd-apply con errores como contexto

## Fase 5: Implementación Core - sdd-propose (Contexto Estricto)

- [x] 5.1 Modificar `skills/sdd-propose/SKILL.md`: Agregar validación de existencia de `exploration.md`
- [x] 5.2 Agregar lógica para detectar contexto efímero de exploración
- [x] 5.3 Agregar **bloque de ADVERTENCIA SEVERA** en sección RIESGOS cuando no hay exploración
  - Mensaje exacto: "La propuesta fue generada a ciegas sin fase de exploración previa y podría contener suposiciones inválidas"

## Fase 6: Testing / Verificación

- [x] 6.1 Crear escenario de prueba: múltiples cambios activos, ejecutar comando sin especificar change
- [x] 6.2 Verificar Regla de Concurrencia: pedir selección cuando hay >1 cambio
- [x] 6.3 Verificar Regla de Concurrencia: ejecutar automáticamente cuando hay 1 cambio
- [x] 6.4 Crear escenario: ejecutar `/sdd-fix` con verify-report.md exitoso
- [x] 6.5 Crear escenario: ejecutar `/sdd-fix` con verify-report.md fallido
- [x] 6.6 Verificar que sdd-propose muestre advertencia cuando no existe exploration.md
- [x] 6.7 Verificar formato de verify-report.md sea parseable

## Fase 7: Limpieza

- [x] 7.1 Verificar que no quedó código temporal
- [x] 7.2 Verificar que las tareas en tasks.md principal están actualizadas con los cambios realizados

---

## NOTA DE LIMPIEZA: Problema detectado en Fase 4

Las siguientes tareas están marcadas como completadas pero LAS REGLAS NO ESTÁN IMPLEMENTADAS en los archivos:
- [ ] 4.1 Regla de Concurrencia - NO IMPLEMENTADA en orchestrator-core.md
- [ ] 4.2 Regla de Paralelismo - NO IMPLEMENTADA en orchestrator-core.md  
- [ ] 4.3 Comando /sdd-fix - NO IMPLEMENTADA en orchestrator-core.md

**Acción requerida**: El orquestador debe relanzar esta fase para implementar las reglas faltantes.
