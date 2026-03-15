# Propuesta: sync-and-release-v1

## Intención

Sincronizar el número de comandos de OpenCode con las skills disponibles, creando los 3 comandos faltantes (sdd-spec, sdd-design, sdd-tasks) para alcanzar el objetivo de 15 comandos. Este cambio resuelve la inconsistencia entre el número de skills (13) y comandos (12), alineando la documentación y los tests con la realidad del proyecto.

## Alcance

### Dentro del Alcance

- Crear `examples/opencode/commands/sdd-spec.md` — Comando para invocar la skill de especificación
- Crear `examples/opencode/commands/sdd-design.md` — Comando para invocar la skill de diseño técnico
- Crear `examples/opencode/commands/sdd-tasks.md` — Comando para invocar la skill de desglose de tareas
- Actualizar `scripts/install_test.sh` — Modificar arrays EXPECTED_SKILLS y conteos assert_eq de 12 a 15 comandos
- Actualizar `README.md` — Agregar los 3 nuevos comandos a la tabla de comandos disponibles

### Fuera del Alcance

- Modificar MANUAL.md (ya está completo según la exploración)
- Crear nuevas funcionalidades en las skills
- Modificar la lógica de las skills existentes

## Enfoque

El enfoque recomendado (Extraído de la exploración) es crear los 3 comandos faltantes basándose en la plantilla de los comandos existentes. Cada comando seguirá el patrón simple: título, descripción breve y ejemplo de uso. Luego se actualizarán los archivos de test y documentación para reflejar el nuevo estado de 15 comandos.

## Áreas Afectadas

| Área                                      | Impacto     | Descripción                                              |
|-------------------------------------------|-------------|----------------------------------------------------------|
| `examples/opencode/commands/sdd-spec.md` | Nuevo      | Comando para invocar sdd-spec                           |
| `examples/opencode/commands/sdd-design.md` | Nuevo    | Comando para invocar sdd-design                         |
| `examples/opencode/commands/sdd-tasks.md` | Nuevo     | Comando para invocar sdd-tasks                          |
| `scripts/install_test.sh`                | Modificado | Actualizar EXPECTED_COMMANDS de 12 a 15, mantener 15 skills |
| `README.md`                              | Modificado | Agregar 3 comandos a la tabla de comandos disponibles   |

## Riesgos

| Riesgo                                      | Probabilidad | Mitigación                                         |
|---------------------------------------------|--------------|---------------------------------------------------|
| Tests quebrados si no se actualiza primero  | Alta        | Actualizar install_test.sh antes de ejecutar tests |
| Duplicación conceptual con sdd-new          | Media       | Documentar que estos comandos son atajos directos a fases específicas |
| Mantenimiento de sincronización             | Baja        | Establecer convención de crear comando junto con skill |

## Plan de Rollback

Para revertir este cambio:

1. Eliminar los 3 archivos de comando creados: `sdd-spec.md`, `sdd-design.md`, `sdd-tasks.md`
2. Revertir los cambios en `scripts/install_test.sh` — cambiar conteo de 15 a 12 comandos
3. Revertir los cambios en `README.md` — volver a la tabla de 12 comandos
4. Commit con mensaje: "Revert: sync-and-release-v1 — rollback a 12 comandos"

## Dependencias

- No hay dependencias externas
- Prerrequisito: Haber completado la fase de exploración (sdd-explore)

## Criterios de Éxito

- [ ] Los 3 archivos de comando existen en `examples/opencode/commands/`
- [ ] `scripts/install_test.sh` espera 15 comandos y 15 skills
- [ ] `README.md` muestra tabla con 15 comandos
- [ ] Tests pasan al ejecutar `scripts/install_test.sh`
- [ ] Todos los comandos nuevos son invocables desde OpenCode
