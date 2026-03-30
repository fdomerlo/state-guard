# Tareas: Auditoría Integral del Repositorio agentify-sdd

## Fase 1: Documentación (Errores Críticos)

- [x] 1.1 Editar `README.md` líneas 25-42: Agregar fila `/sdd-propose` en la tabla de comandos entre `/sdd-review` y `/sdd-spec` con descripción "Crea o itera sobre una propuesta de cambio de manera independiente."
- [x] 1.2 Editar `scripts/install.sh` línea 311: Reemplazar placeholder `TU-USUARIO` con la URL canónica `https://github.com/ctrbts/agentify-sdd.git` o variable `$REPO_URL`

## Fase 2: Coherencia de Contratos

- [x] 2.1 Editar `skills/_shared/orchestrator-core.md` líneas 45-59: Crear dos subsecciones - "Meta-comandos de Orquestación" para `/sdd-new`, `/sdd-continue`, `/sdd-ff` y "Skills Directos" para comandos restantes, o usar emoji/badge visual diferenciador
- [x] 2.2 Editar `skills/_shared/openspec-convention.md` líneas 172-179: Agregar en sección "Estructura del Archivo Histórico" la oración "Al archivar, los specs delta en `specs/{dominio}/` se fusionan automáticamente con los specs principales" para coherencia con tabla líneas 40-41

## Fase 3: Verificación

- [x] 3.1 Ejecutar `bash scripts/install_test.sh` para validar que install.sh funciona correctamente tras las modificaciones
- [x] 3.2 Verificar coherencia: confirmar que README.md incluye `/sdd-propose`, orchestrator-core.md diferencia visualmente meta-comandos, y openspec-convention.md menciona fusión de deltas
