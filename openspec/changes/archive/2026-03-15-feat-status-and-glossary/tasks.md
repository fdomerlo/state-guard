# Tareas: feat-status-and-glossary

## Resumen del Cambio

Este cambio implementa dos características complementarias:
1. **Skill `sdd-status`**: Nueva skill de solo lectura que muestra el estado de todos los cambios activos del DAG mediante una tabla Markdown con emojis de semáforo.
2. **Glosario de Dominio**: Mecanismo para definir y compartir terminología consistente entre sub-agentes mediante un bloque YAML en `config.yaml`.

## Fase 1: Infraestructura de sdd-status

- [x] 1.1 Crear estructura de directorios para la skill `skills/sdd-status/`
- [x] 1.2 Implementar `skills/sdd-status/SKILL.md` con lógica de lectura de archivos `state.yaml`
- [x] 1.3 Implementar función de parsing de `state.yaml` extrayendo campos: `change`, `phase`, `started_at`, `pending_phases`, `blocked_reason`
- [x] 1.4 Implementar función de filtrado para ignorar cambios con `phase: done` o `phase: archive`
- [x] 1.5 Implementar cálculo de tiempo transcurrido desde `started_at` (formato ISO 8601) con salida "Xh Ym"
- [x] 1.6 Implementar lógica de semáforo: 🟢 (activo), 🟡 (bloqueado), 🔴 (completado)
- [x] 1.7 Implementar formateo de tabla Markdown con columnas: [Cambio, Fase Actual, Tiempo Transcurrido, Estado]
- [x] 1.8 Manejar caso sin cambios activos (mensaje informativo, no tabla vacía)
- [x] 1.9 Manejar archivos corruptos o malformados (continuar con advertencia)

## Fase 2: Integración con Orquestador

- [x] 2.1 Actualizar `skills/_shared/orchestrator-core.md` agregando `/sdd-status` a la lista de comandos de orquestación
- [x] 2.2 Actualizar `scripts/install.sh` para incluir la nueva skill `sdd-status` (verificar que soporta dinámicamente)
- [x] 2.3 Actualizar `scripts/install_test.sh`: cambiar `EXPECTED_SKILLS` de 9 a 10
- [x] 2.4 Actualizar todos los `assert_eq "9"` a `"10"` en `scripts/install_test.sh`
- [x] 2.5 Ejecutar `scripts/install_test.sh` para verificar que pasan todos los tests con 10 skills

## Fase 3: Glosario de Dominio

- [x] 3.1 Modificar `skills/sdd-init/SKILL.md` para incluir generación de bloque `glossary:` en `config.yaml`
- [x] 3.2 Agregar ejemplos comentados de estructura de glosario en el template de `config.yaml`
- [x] 3.3 Modificar `skills/_shared/persistence-contract.md` agregando sección de carga de glosario
- [x] 3.4 Actualizar `openspec/config.yaml` con ejemplos de glosario (comentados)
- [x] 3.5 Verificar graceful degradation: skills funcionan sin glosario existente

## Fase 4: Verificación

- [x] 4.1 Verificar que `sdd-status` muestra correctamente cambios activos (escenario: 1 cambio activo → 🟢)
- [x] 4.2 Verificar que `sdd-status` muestra correctamente cambios bloqueados (escenario: fase blocked → 🟡)
- [x] 4.3 Verificar que `sdd-status` filtra cambios completados (escenario: phase done → no aparece)
- [x] 4.4 Verificar mensaje cuando no hay cambios activos
- [x] 4.5 Verificar cálculo correcto de tiempo transcurrido (probar con diferentes `started_at`)
- [x] 4.6 Verificar formato de fase legible (primera letra mayúscula)
- [x] 4.7 Verificar integración E2E: `/sdd-status` desde el chat muestra la tabla esperada
- [x] 4.8 Verificar que skills `propose`, `spec` y `design` cargan el glosario cuando existe
- [x] 4.9 Verificar que skills funcionan correctamente cuando glosario no existe o está vacío
- [x] 4.10 Ejecutar tests de integración completos

## Fase 5: Documentación y Limpieza

- [x] 5.1 Actualizar documentación de referencias si es necesario
- [x] 5.2 Verificar que todos los criterios de éxito de la propuesta se cumplen

---

## Criterios de Éxito (de proposal.md)

- [x] La skill `sdd-status` se instala correctamente y aparece en el listado de skills
- [x] El comando `/sdd-status` muestra una tabla con todos los cambios activos
- [x] Los emojis de semáforo reflejan correctamente el estado de cada cambio
- [x] El cálculo de tiempo transcurrido muestra valores legibles (ej: "2h 30m")
- [x] Todos los tests en `install_test.sh` pasan con 10 skills
- [x] El glosario en `config.yaml` está documentado con ejemplos
- [x] Las skills propose, spec y design cargan el glosario cuando existe
