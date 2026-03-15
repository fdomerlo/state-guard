# Propuesta: feat-status-and-glossary

## Intención

Este cambio implementa dos características complementarias para mejorar la visibilidad y consistencia del proyecto Agentify-SDD:

1. **Skill `sdd-status`**: Un comando para que el orquestador pueda mostrar visualmente el estado de todos los cambios activos del DAG sin necesidad de consultar manualmente cada archivo `state.yaml`. Esto mejora la experiencia del usuario y facilita el seguimiento del progreso.

2. **Glosario de Dominio**: Un mecanismo para que el proyecto defina y comparta terminología consistente entre todos los sub-agentes, evitando inconsistencias semánticas en las especificaciones y diseños.

## Alcance

### Dentro del Alcance

**Objetivo 1 - Crear la Skill `sdd-status`:**
- Crear una nueva skill en `skills/sdd-status/SKILL.md`
- Propósito: Leer todos los archivos `state.yaml` dentro de `openspec/changes/` (ignorando los archivados)
- Output: Tablero/tabla en Markdown con columnas: [Cambio, Fase Actual, Tiempo Transcurrido, Estado]
- Usar emojis de semáforo (🟢🟡🔴) para el estado:
  - 🟢 Activo: phase != blocked y pending_phases no vacío
  - 🟡 Bloqueado: phase == blocked
  - 🔴 Completado: phase == done
- Actualizar `skills/_shared/orchestrator-core.md` para enseñar al orquestador que `/sdd-status` delega a esta skill
- Actualizar `scripts/install.sh` (ya soporta dinámicamente nuevas skills — no requiere cambios)
- Actualizar `scripts/install_test.sh` para actualizar EXPECTED_SKILLS de 9 a 10

**Objetivo 2 - Implementación del Glosario de Dominio:**
- Modificar `skills/sdd-init/SKILL.md` para que `openspec/config.yaml` incluya bloque `glossary:` con ejemplos comentados
- Modificar `skills/_shared/persistence-contract.md` para instruir a sub-agentes (propose, spec, design) que deben cargar y respetar los términos del glosario si existe

### Fuera del Alcance
- No se implementará historial de cambios ni métricas avanzadas
- No se creará interfaz visual más allá de la tabla Markdown
- No se modificará el flujo de trabajo SDD existente

## Enfoque

**Para sdd-status:**
Se seguirá el mismo patrón de las skills existentes. La skill será de solo lectura (no modifica archivos) y generará un reporte visual parseando los archivos `state.yaml` existentes. El cálculo de tiempo transcurrido usará el campo `started_at` con formato ISO 8601.

**Para el Glosario:**
El glosario será un bloque YAML dentro de `openspec/config.yaml`, inicialmente comentado como ejemplo. Las skills de propuesta, especificación y diseño deberán buscar y cargar este glosario antes de generar sus artefactos. Si no existe el glosario, las skills deben funcionar igual (es opcional).

## Áreas Afectadas

| Área | Impacto | Descripción |
|------|---------|-------------|
| `skills/sdd-status/SKILL.md` | **NUEVO** | Skill para reportar estado del DAG |
| `skills/_shared/orchestrator-core.md` | **MODIFICADO** | Agregar `/sdd-status` a la lista de comandos |
| `scripts/install_test.sh` | **MODIFICADO** | Actualizar EXPECTED_SKILLS de 9 a 10 y asserts correspondientes |
| `skills/sdd-init/SKILL.md` | **MODIFICADO** | Agregar bloque `glossary:` en config.yaml |
| `skills/_shared/persistence-contract.md` | **MODIFICADO** | Reforzar carga obligatoria del glosario en sub-agentes |
| `openspec/config.yaml` | **MODIFICADO** | Incluir ejemplos de glosario |

## Riesgos

| Riesgo | Probabilidad | Mitigación |
|--------|--------------|------------|
| Tests fallan al agregar skill 10 | Alta | Actualizar `install_test.sh` junto con la implementación — actualizar `EXPECTED_SKILLS`, arrays y todos los `assert_eq "9"` a `"10"` |
| Glosario vacío/no existe | Baja | Las skills deben manejar gracefulmente la ausencia del glosario — es opcional |
| Formato de tiempo incorrecto | Media | Usar librería de parsing de fechas o formato simple (diff en segundos convertido a formato legible) |
| Comandos duplicados en orchestrator | Baja | El comando `/sdd-status` es nuevo, no existe conflicto |

## Plan de Rollback

Para revertir este cambio:

1. Eliminar la carpeta `skills/sdd-status/`
2. Revertir los cambios en `orchestrator-core.md` (quitar la línea de `/sdd-status`)
3. Revertir `install_test.sh` cambiando 10 a 9 en todos los lugares
4. Revertir cambios en `sdd-init/SKILL.md` y `persistence-contract.md`
5. Eliminar el bloque `glossary:` de `openspec/config.yaml` si se añadió

## Criterios de Éxito

- [ ] La skill `sdd-status` se instala correctamente y aparece en el listado de skills
- [ ] El comando `/sdd-status` muestra una tabla con todos los cambios activos
- [ ] Los emojis de semáforo reflejan correctamente el estado de cada cambio
- [ ] El cálculo de tiempo transcurrido muestra valores legibles (ej: "2h 30m")
- [ ] Todos los tests en `install_test.sh` pasan con 10 skills
- [ ] El glosario en `config.yaml` está documentado con ejemplos
- [ ] Las skills propose, spec y design cargan el glosario cuando existe
