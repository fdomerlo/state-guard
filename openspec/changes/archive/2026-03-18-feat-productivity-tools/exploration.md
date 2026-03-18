# Exploración: feat-productivity-tools

## Tema
Crear las skills de productividad `/sdd-review` para auditoría de código contra especificaciones y `/sdd-split` para dividir propuestas monolíticas en iteraciones manejables.

---

## Estado Actual

### Skills Existentes (10 en total)
El proyecto actualmente cuenta con 10 skills SDD:

| Skill | Propósito |
|-------|-----------|
| `sdd-apply` | Implementa tareas de un cambio |
| `sdd-archive` | Sincroniza specs delta y archiva cambios |
| `sdd-design` | Crea documento de diseño técnico |
| `sdd-explore` | Explora e investiga ideas antes de comprometerse |
| `sdd-init` | Inicializa el contexto SDD en un proyecto |
| `sdd-propose` | Crea propuesta de cambio con intención y alcance |
| `sdd-spec` | Escribe especificaciones con requisitos y escenarios |
| `sdd-status` | Muestra el estado de todos los cambios activos |
| `sdd-tasks` | Desglosa un cambio en tareas de implementación |
| `sdd-verify` | Valida que la implementación coincida con specs, diseño y tareas |

### Estructura de Archivos

**Skills:** `skills/sdd-*/SKILL.md` — Cada skill es un archivo Markdown autocontenido

**Scripts de instalación:**
- `scripts/install.sh` — Instala skills a diferentes agentes (Claude Code, OpenCode, etc.)
- `scripts/install_test.sh` — Tests automatizados para el instalador

**Configuración:**
- `openspec/config.yaml` — Configuración del proyecto (rules, context, glossary commented)

---

## Áreas Afectadas

### Objetivo 1: Crear skill `sdd-review`
- **Ruta:** `skills/sdd-review/SKILL.md` (nuevo archivo)
- **Propósito:** Auditar código implementado contra especificaciones
- **Dependencias:** Carpeta `specs/` y `design.md` del cambio actual
- **Enfoque:** Análisis estático comparando código contra specs

### Objetivo 2: Crear skill `sdd-split`
- **Ruta:** `skills/sdd-split/SKILL.md` (nuevo archivo)
- **Propósito:** Dividir propuesta gigante en partes pequeñas
- **Dependencias:** `proposal.md` existente
- **Output:** Lista de sub-cambios a inicializar

### Objetivo 3: Actualización del Ecosistema
- **`skills/_shared/orchestrator-core.md`:** Agregar `/sdd-review` y `/sdd-split` a la lista de comandos
- **`scripts/install.sh`:** Actualizar contador de 10 a 12 skills
- **`scripts/install_test.sh`:** Actualizar `EXPECTED_SKILLS` array y verificaciones de contador

---

## Enfoques

### Enfoque 1: Basarse en sdd-verify para sdd-review
- **Ventajas:**
  - Código existente bien estructurado como referencia
  - Patrón de lectura de specs ya definido
  - La diferencia es clara: review = análisis estático, verify = análisis dinámico (con tests)
- **Desventajas:**
  - Riesgo de duplicar funcionalidad si no se define bien el alcance
- **Esfuerzo:** Bajo

### Enfoque 2: Crear sdd-split desde cero
- **Ventajas:**
  - Flexibilidad total para diseñar el formato de salida
  - No hay código existente que limiter opciones
- **Desventajas:**
  - Requiere definir el formato de partición desde cero
- **Esfuerzo:** Medio

### Enfoque 3: Integrar sdd-split como extensión de sdd-propose
- **Ventajas:**
  - Mantiene coherencia con workflow existente
- **Desventajas:**
  - Mezcla responsabilidades
- **Esfuerzo:** Alto

---

## Recomendación

1. **Para `sdd-review`:** Usar `sdd-verify` como plantilla pero con análisis estático puro (sin ejecución de código). El output debe ser un reporte de auditoría objetivo: aprobado/advertencias/bloqueado.

2. **Para `sdd-split`:** Crear desde cero con un formato simple: leer proposal.md → identificar áreas de拆分 → generar lista de `/sdd-new` commands.

3. **Para el ecosistema:**
   - Agregar `/sdd-review [change]` y `/sdd-split [change]` a `orchestrator-core.md` (sección "Comandos de Orquestación")
   - Actualizar `EXPECTED_SKILLS` en `install_test.sh` de 10 a 12
   - Actualizar verificaciones de contador en `install.sh` (líneas con "10 skills installed")

---

## Riesgos

1. **Riesgo de duplicación:** sdd-review y sdd-verify podrían confundirse. Deben tener propósitos distintos y bien documentados.
2. **Riesgo de complejidad:** sdd-split podría generar particiones no óptimas si la heurística no es clara.
3. **Riesgo de tests:** Los tests en `install_test.sh` esperan exactamente 10 skills. Actualizar a 12 podría afectar otros tests que asumen ese número.

---

## Listo para Propuesta

**Sí.** La exploración es suficiente para pasar a la fase de propuesta.

La fase `proposal` debe definir:
- Propósito exacto de cada nueva skill
- Diferenciación clara entre sdd-review y sdd-verify
- Formato de output para sdd-split
- Comandos exactos a registrar en orchestrator-core.md
