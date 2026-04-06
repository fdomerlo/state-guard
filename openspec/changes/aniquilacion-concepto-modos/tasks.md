# Tareas: Aniquilación del Concepto de Modos

## Fase 1: Specs y Contratos (Fundación)

- [ ] 1.1 Modificar `openspec/specs/persistencia/spec.md`: Eliminar sección "Modo de Persistencia Válido" y "Forzamiento". Reemplazar por "Persistencia Implícita en File System".
- [ ] 1.2 Modificar `skills/_shared/persistence-contract.md`: Eliminar tablas comparativas de modos y referencias a la variable `artifact_store.mode`.
- [ ] 1.3 Modificar `skills/_shared/orchestrator-core.md`: Eliminar la sección "Política de Almacenamiento (Forzado a OpenSpec)".

## Fase 2: Skills y Orquestador (Implementación Central)

- [ ] 2.1 Modificar `skills/sdd-init/SKILL.md`: Eliminar el "Paso 3: Generar la Configuración (modo openspec)" y cualquier lógica de forzado de modo.
- [ ] 2.2 Modificar `skills/sdd-verify/SKILL.md`: Eliminar la lectura de `artifact_store.mode` para la persistencia del reporte. Usar rutas directas.
- [ ] 2.3 Modificar `skills/_shared/orchestrator-commands.md`: Eliminar menciones al forzado de modo en las descripciones de `/sdd-init` y otros comandos.
- [ ] 2.4 Modificar `skills/_shared/orchestrator-context.md` (o similar): Asegurar que no se inyecte la variable de modo en el contexto del sub-agente.

## Fase 3: Integraciones CLI y Documentación

- [ ] 3.1 Auditar y modificar archivos en `integrations/opencode/commands/`: Eliminar cualquier texto que diga "Modo de almacenamiento: openspec".
- [ ] 3.2 Modificar `README.md`: Simplificar la sección "Modo OpenSpec" a "Persistencia de Artefactos".
- [ ] 3.3 Modificar `openspec/config.yaml` (ejemplo/default): Eliminar la clave `artifact_store`.

## Fase 4: Verificación y Limpieza

- [ ] 4.1 Ejecutar `grep -ri "artifact_store.mode" .`: Verificar que no queden resultados (excluyendo la carpeta del cambio actual).
- [ ] 4.2 Ejecutar `grep -ri "modo openspec" .`: Verificar que no queden resultados (excluyendo la carpeta del cambio actual).
- [ ] 4.3 Ejecutar `sdd-review aniquilacion-concepto-modos`: Realizar auditoría estática contra las nuevas specs.
