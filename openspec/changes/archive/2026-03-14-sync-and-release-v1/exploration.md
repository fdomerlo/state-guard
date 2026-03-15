# Exploración: sync-and-release-v1

## Estado Actual

### Skills Existentes (13)

El proyecto tiene 13 skills en la carpeta `skills/`:

| Skill | Archivo |
|-------|---------|
| sdd-apply | skills/sdd-apply/SKILL.md |
| sdd-propose | skills/sdd-propose/SKILL.md |
| sdd-init | skills/sdd-init/SKILL.md |
| sdd-changelog | skills/sdd-changelog/SKILL.md |
| sdd-archive | skills/sdd-archive/SKILL.md |
| sdd-split | skills/sdd-split/SKILL.md |
| sdd-review | skills/sdd-review/SKILL.md |
| sdd-status | skills/sdd-status/SKILL.md |
| sdd-spec | skills/sdd-spec/SKILL.md |
| sdd-verify | skills/sdd-verify/SKILL.md |
| sdd-tasks | skills/sdd-tasks/SKILL.md |
| sdd-design | skills/sdd-design/SKILL.md |
| sdd-explore | skills/sdd-explore/SKILL.md |

### Comandos OpenCode Existentes (12)

La carpeta `examples/opencode/commands/` contiene 12 comandos:

| Comando | Archivo |
|---------|---------|
| sdd-changelog | sdd-changelog.md |
| sdd-split | sdd-split.md |
| sdd-review | sdd-review.md |
| sdd-status | sdd-status.md |
| sdd-init | sdd-init.md |
| sdd-new | sdd-new.md |
| sdd-continue | sdd-continue.md |
| sdd-apply | sdd-apply.md |
| sdd-ff | sdd-ff.md |
| sdd-archive | sdd-archive.md |
| sdd-explore | sdd-explore.md |
| sdd-verify | sdd-verify.md |

### install_test.sh (Expectativas Actuales)

El script de tests espera:
- **13 skills** (correcto - coincide con los 13 existentes)
- **12 comandos** (coincide con los 12 existentes)

Líneas clave del test:
- `EXPECTED_SKILLS` array con 13 items
- `assert_eq "13" "$count"` para skill count
- `assert_eq "12" "$count"` para command count

### Documentación Actual

**README.md** (139 líneas):
- Tabla de comandos con 12 entradas
- Instalación para Unix y Windows
- Inicio rápido en 6 pasos
- Arquitectura con diagrama Mermaid

**MANUAL.md** (288 líneas):
- Arquitectura DRY (compilación dinámica)
- State Machine ACID (state.yaml)
- Configuración con config.yaml
- Flujos avanzados (/sdd-split, /sdd-review, /sdd-fix)
- Estructura de archivos OpenSpec

---

## Áreas Afectadas

| Área | Razón |
|------|-------|
| `examples/opencode/commands/` | Crear 3 comandos faltantes (sdd-spec, sdd-design, sdd-tasks) para llegar a 15 |
| `scripts/install_test.sh` | Actualizar arrays EXPECTED_SKILLS y conteos assert_eq |
| `README.md` | Actualizar tabla de comandos a 15 entradas |
| `MANUAL.md` | Mantener (ya está completo según exploración) |
| `openspec/changes/sync-and-release-v1/` | Nuevo directorio para el cambio |

---

## Gap Identificado

### Desbalance Comandos vs Skills

**Skills que NO tienen comando counterpart:**
- sdd-spec (skill de especificación)
- sdd-design (skill de diseño)
- sdd-tasks (skill de planificación)

**Comandos que NO tienen skill counterpart:**
- Ninguno - todos los comandos tienen su skill

**Comandos adicionales existentes (no son skills directos):**
- sdd-new (delega a explore + propose)
- sdd-continue (orquestador)
- sdd-ff (orquestador)

Para llegar a 15 comandos, se necesitan crear:
1. `sdd-spec.md` (corresponde a skills/sdd-spec/SKILL.md)
2. `sdd-design.md` (corresponde a skills/sdd-design/SKILL.md)
3. `sdd-tasks.md` (corresponde a skills/sdd-tasks/SKILL.md)

---

## Enfoques

### Enfoque 1: Crear los 3 comandos faltantes

**Descripción:** Crear archivos de comandos para sdd-spec, sdd-design y sdd-tasks, basados en la plantilla de los existentes.

**Ventajas:**
- Sincronización completa entre skills y comandos
- Los usuarios pueden invocar directamente estos comandos en OpenCode
- Mantiene la consistencia 1:1

**Desventajas:**
- Requiere crear contenido nuevo para cada comando
- Posible confusión (estos comandos delegan a sub-agentes, no son ejecutables directamente)

**Esfuerzo:** Bajo

### Enfoque 2: Ignorar la regla "15 comandos"

**Descripción:** Mantener los 12 comandos actuales y documentar que el número de comandos no necesariamente equals al de skills.

**Ventajas:**
- No requiere trabajo adicional
- Los 12 comandos actuales son los más usados

**Desventajas:**
- No cumple con la regla de negocio del usuario
- Documentación inconsistency

**Esfuerzo:** N/A (no requiere trabajo)

---

## Recomendación

Se recomienda el **Enfoque 1**: Crear los 3 comandos faltantes (sdd-spec.md, sdd-design.md, sdd-tasks.md).

La plantilla de los comandos existentes sigue un patrón simple:
- Título del comando
- Descripción breve
- Ejemplo de uso

Luego actualizar:
- `install_test.sh`: Cambiar assert_eq "12" a "15" para comandos
- `README.md`: Agregar los 3 nuevos comandos a la tabla

El MANUAL.md ya está completo y no requiere modificaciones.

---

## Riesgos

1. **Duplicación conceptual:** Los comandos sdd-spec, sdd-design, sdd-tasks podrían considerarse redundantes si el usuario espera que sdd-new ya cubra estas fases.

2. **Tests quebrados:** Si no se actualiza install_test.sh antes de ejecutar los tests, fallarán al detectar 15 comandos en vez de 12.

3. **Mantenimiento:** Cada nuevo comando requiere mantener su SKILL.md y .md counterpart sincronizados.

---

## Listo para Propuesta

**Sí** — La exploración identificó:
- Estado actual: 13 skills, 12 comandos
- Gap: Faltan 3 comandos para llegar a 15
- Trabajo requerido: crear 3 archivos de comandos, actualizar tests y README

El orquestador debe comunicar al usuario que se crearán:
1. `examples/opencode/commands/sdd-spec.md`
2. `examples/opencode/commands/sdd-design.md`
3. `examples/opencode/commands/sdd-tasks.md`

Y se actualizarán:
- `scripts/install_test.sh` (15 comandos, 15 skills)
- `README.md` (tabla con 15 comandos)