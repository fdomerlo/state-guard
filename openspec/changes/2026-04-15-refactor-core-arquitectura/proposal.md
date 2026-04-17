# Propuesta: Refactor Core Arquitectura

## Intención

Estabilizar el esquema de estado ACID, unificar contratos de delegación y corregir bugs de infraestructura según la auditoría técnica.

## Alcance

### Dentro del Alcance
- Eliminar el uso del campo dictotómico `blocked` en `orchestrator-state.md`, plantillas `state.yaml` de nuevos cambios y `sdd-fix/SKILL.md`.
- Normalizar el campo `status` para que soporte de manera inclusiva los estados `active | done | blocked`.
- Actualizar `skills/sdd-status/SKILL.md` para filtrar en base a `status` en lugar de `current_phase`.
- Modificar `skills/sdd-apply/SKILL.md` para establecer explícitamente que el SUB-AGENTE es quien marca las tareas completadas en `tasks.md`, y no el orquestador.
- Modificar `skills/sdd-archive/SKILL.md` agregando un Paso 0 obligatorio: Leer reports y abortar si hay CRITICAL.
- Ajustar `scripts/install.sh` para soportar la invocación obligatoria a `compile_and_append_config` para Antigravity cuando se usa `--all-global`.
- Limitar el scope del clean en `skills/sdd-rollback/SKILL.md`, removiendo `git clean -fd` global para afectar únicamente al scope del cambio.

### Fuera del Alcance
- Refactorización de tests u otros flujos del framework no listados.
- Cambios a otras skills no mencionadas.

## Enfoque

Refactorización focalizada en las especificaciones del orquestador y los SKILLs respectivos. El manejo del campo `blocked` se abordará respetando la retrocompatibilidad: es decir, `sdd-fix` debe poder interpretar o limpiar limpiamente los archivos `state.yaml` que aún tengan dicho campo legado sin causar errores en tiempo de ejecución. 

## Áreas Afectadas

| Área | Impacto | Descripción |
|---|---|---|
| `skills/_shared/orchestrator-state.md` | Modificado | Remover el campo dictotómico `blocked` |
| `skills/sdd-fix/SKILL.md` | Modificado | Remover requerimiento de bloque y añadir corrección de retrocompatibilidad |
| `skills/sdd-status/SKILL.md` | Modificado | Usar `status` en el filtrado de estado general |
| `skills/sdd-apply/SKILL.md` | Modificado | Aclaración sobre responsabilidades del sub-agente frente a tasks |
| `skills/sdd-archive/SKILL.md` | Modificado | Paso 0 de validación de bloqueos antes de iniciar el archivado |
| `scripts/install.sh` | Modificado | Compilar configuración para Antigravity de forma obligatoria en un entorno all-global |
| `skills/sdd-rollback/SKILL.md` | Modificado | Restauración segura de scope del cambio sin clean global |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|---|---|---|
| Pérdida de retrocompatibilidad en cambios legacy | Alta | Asegurar en `sdd-fix` que ignores adecuadamente el campo boolean si se halla, y dependas del literal en `status`. |
| Falla en la instalación con Antigravity | Media | Validar sintácticamente los ajustes del script shell para el paso de compilación global. |

## Plan de Rollback

Descartar los cambios vía reposición de git del árbol de las skills utilizando el comando `git restore` sobre el directorio local y borrar el estado local del cambio actual.

## Dependencias

- Ninguna

## Criterios de Éxito

- [ ] Todos los archivos que establecían el campo `blocked` booleano ahora lo utilizan integradamente con el estado general.
- [ ] La nueva gestión no emite errores o excepciones al cargar `state.yaml` anteriores.
- [ ] La opción `all-global` compila con éxito para Antigravity en Bash de prueba o según las especificaciones.
