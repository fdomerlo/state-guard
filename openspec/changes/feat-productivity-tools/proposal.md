# Propuesta: feat-productivity-tools

## Intención

Crear dos nuevas skills SDD para aumentar la productividad del flujo de trabajo: `/sdd-review` para auditoría estática de código contra especificaciones, y `/sdd-split` para dividir propuestas monolíticas en iteraciones manejables. Estas herramientas completan el ciclo de desarrollo guiado por especificaciones añadiendo capacidades de revisión rápida y refinamiento iterativo.

## Alcance

### Dentro del Alcance

- **Skill `sdd-review`**: Crear `skills/sdd-review/SKILL.md` para auditoría de código mediante análisis estático puro (sin ejecución de tests). El output será un reporte de revisión objetivo basado exclusivamente en lo que dicen los specs.
- **Skill `sdd-split`**: Crear `skills/sdd-split/SKILL.md` para detectar proposals demasiado grandes y generar un plan de partición con comandos `/sdd-new` sugeridos.
- **Actualización del ecosistema**: Registrar los nuevos comandos en `orchestrator-core.md` y actualizar los contadores en los scripts de instalación.

### Fuera del Alcance

- `sdd-review` no ejecutará código ni tests (eso es `sdd-verify`)
- No se modificará el comportamiento de skills existentes
- No se crearán herramientas adicionales de análisis más allá de las dos propuestas

## Enfoque

Para `sdd-review`, se utilizará `sdd-verify` como plantilla pero eliminando la ejecución de código. La diferenciación clave es: `sdd-verify` = análisis dinámico (corre tests), `sdd-review` = análisis estático (compara código con specs). El output será un reporte de auditoría en tres categorías: aprobado, advertencias o bloqueado.

Para `sdd-split`, se creará desde cero con una heurística simple: leer la proposal.md existente, identificar áreas de funcionalidad que puedan separarse lógicamente, y generar una lista de sub-cambios con sus respectivos comandos `/sdd-new`.

## Áreas Afectadas

| Área                        | Impacto     | Descripción                                                      |
|-----------------------------|-------------|------------------------------------------------------------------|
| `skills/sdd-review/SKILL.md`      | Nuevo       | Skill de auditoría estática contra especificaciones              |
| `skills/sdd-split/SKILL.md`       | Nuevo       | Skill para dividir proposals monolíticas                        |
| `skills/_shared/orchestrator-core.md` | Modificado  | Registrar comandos `/sdd-review` y `/sdd-split`                 |
| `scripts/install.sh`        | Modificado  | Actualizar contador de 10 a 12 skills                           |
| `scripts/install_test.sh`  | Modificado  | Actualizar EXPECTED_SKILLS de 10 a 12 y verificaciones         |

## Riesgos

| Riesgo                              | Probabilidad | Mitigación                                                      |
|-------------------------------------|--------------|-----------------------------------------------------------------|
| Duplicación de funcionalidad con sdd-review y sdd-verify | Alta | Documentar explícitamente la diferencia: review = estático, verify = dinámico |
| Particiones no óptimas generadas por sdd-split | Media | Probar con una proposal de prueba antes de producción |
| Tests fallan por cambio de contador de skills | Alta | Actualizar EXPECTED_SKILLS al inicio del cambio |

## Plan de Rollback

1. Eliminar los archivos `skills/sdd-review/SKILL.md` y `skills/sdd-split/SKILL.md`
2. Revertir los cambios en `orchestrator-core.md` (eliminar los dos nuevos comandos)
3. Revertir los cambios en `scripts/install.sh` (contador de 10)
4. Revertir los cambios en `scripts/install_test.sh` (EXPECTED_SKILLS = 10)
5. Ejecutar `scripts/install_test.sh` para verificar que el estado vuelve a ser válido

## Dependencias

- Ninguna dependencia externa. El cambio es autocontenido dentro del ecosistema SDD.

## Criterios de Éxito

- [ ] Las 12 skills están registradas y disponibles en el sistema
- [ ] `sdd-review` genera reporte de auditoría con categorías: aprobado, advertencias, bloqueado
- [ ] `sdd-split` produce lista de comandos `/sdd-new` sugeridos para sub-cambios
- [ ] Tests en `install_test.sh` pasan correctamente con el nuevo conteo
- [ ] La diferenciación entre `sdd-review` y `sdd-verify` es clara en la documentación
