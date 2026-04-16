# Tareas: Refactor Core Arquitectura

## Fase 1: Simplificación y estandarización del esquema de estado

- [x] 1.1 Modificar `skills/_shared/orchestrator-state.md` removiendo toda especificación, inyección por template o campo predefinido referenciado con `blocked: false` o booleanos análogos de la gestión de state.
- [x] 1.2 Actualizar `skills/sdd-fix/SKILL.md` determinando que la herramienta parsea la data pre-existente, migrando retroactivamente lógicas `blocked: true` estáticas al parámetro estricto `status: blocked` y eliminando subsecuentemente el booleano residual.

## Fase 2: Actualización de Componentes de Fase (Skills)

- [x] 2.1 Refactorizar `skills/sdd-status/SKILL.md` cambiando la comprobación condicional para que discrimine el layout de los reportes unicamente mediante la bandera principal `status` en el ciclo activo/completado/bloqueado.
- [x] 2.2 Reestructurar `skills/sdd-apply/SKILL.md` añadiendo instrucciones que indiquen explícita e inequívocamente la responsabilidad del propio SUB-AGENTE sobre la tildación de cajas dentro de `tasks.md`.
- [x] 2.3 Implementar en `skills/sdd-archive/SKILL.md` el denominado "Paso 0", cuya premisa es obligatorizar una verificación de reportes generados cortando el pipe si se descubren valores CRITICAL.

## Fase 3: Ajustes de Infraestructura (Install y Rollback)

- [x] 3.1 Actualizar `scripts/install.sh`, asegurando compilar y apendizar directrices de Antigravity si se flaggea `--all-global` usando sintaxis neutral y compatible por defecto `[ ]` y validaciones escalares simples.
- [x] 3.2 Corregir y restringir `skills/sdd-rollback/SKILL.md`, extirpando el destructivo global `git clean -fd` y limitando con precisión el repliegue de reposición al scope actual del cambio o rama relativa.
