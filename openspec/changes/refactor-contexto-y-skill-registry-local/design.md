# Diseño: Refactor Contexto y Skill Registry Local

## Enfoque Técnico

Refactorización en tres ejes: (1) centralizar el contrato de retorno (DRY), (2) inyectar presupuestos de contexto, (3) habilitar descubrimiento dinámico de skills. Todo opera sobre `skills/` y `.agentify/` con bash POSIX puro.

## Decisiones de Arquitectura

| Decisión | Elección | Alternativas | Justificación |
|----------|----------|-------------|---------------|
| Formato envelope | `sdd-phase-common.md` compartido | Incluir en `persistence-contract.md` | Separación de concerns: persistencia ≠ contrato de retorno. Archivo dedicado permite referencia directa sin inflar el contrato existente. |
| Presupuestos | Sub-sección `### Presupuesto de Tamaño` en `## Reglas` | Archivo externo de presupuestos | Evitar lectura adicional. El presupuesto es regla de la skill, debe vivir junto a ella. |
| `detailed_report` | Opcional en común (unifica 11/13 skills) | Mantener dos variantes | `detailed_report` opcional es compatible con sdd-review y sdd-split que no lo usan. Simplifica el contrato a UN solo formato. |
| Skill registry | Script bash `#!/bin/sh` + `.agentify/` como destino | API dinámica, JSON | Zero dependencies. `.agentify/` como directorio de artefactos generados mantiene limpio el workspace. Índice estático es suficiente para el caso de uso. |
| Descubrimiento | Escaneo `skills/` excluyendo `sdd-*` y `_` | Incluir todos los skills | Los skills `sdd-*` son fases conocidas por el orquestador. El registry descubre skills de usuario/nuevos que no son parte del core SDD. |

## Flujo de Datos

### Centralización del Envelope (DRY)

```
ANTES:                          DESPUÉS:
sdd-propose/SKILL.md ──┐       sdd-propose/SKILL.md ────┐
  "Devolver envelope..."│        "Requiere sdd-phase-    │
sdd-spec/SKILL.md ─────┤        common.md"              ├──→ sdd-phase-common.md
  "Devolver envelope..."│       sdd-spec/SKILL.md ──────┤    (contrato único)
... (13 skills)         │        "Requiere sdd-phase-   │
                        │        common.md"              │
(13 definiciones)       │       ... (13 skills)          │
                                                (13 referencias)
```

### Skill Registry

```
skills/skill-registry/SKILL.md
        │
        ▼ (script bash)
scan: ./skills/
        │ ├── ignorar: sdd-*, _shared
        │ └── parsear: SKILL.md frontmatter
        ▼
./.agentify/skill-registry.md  ← Índice generado
        │
        ▼ (al iniciar tarea)
Orquestador lee índice → delega a skill correcta
```

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `skills/_shared/sdd-phase-common.md` | Crear | Contrato del Return Envelope: `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`, `detailed_report` (opcional) |
| `skills/skill-registry/SKILL.md` | Crear | Skill con script bash POSIX para escanear `skills/` y generar índice |
| `.agentify/skill-registry.md` | Crear (generado) | Índice de skills descubiertas (nombre, descripción, trigger, ubicación) |
| `skills/_shared/orchestrator-core.md` | Modificar | Agregar instrucción: orquestador lee `.agentify/skill-registry.md` al iniciar |
| `skills/sdd-propose/SKILL.md` | Modificar | Eliminar envelope local + inyectar presupuesto < 400 palabras |
| `skills/sdd-spec/SKILL.md` | Modificar | Eliminar envelope local + inyectar presupuesto < 650 palabras |
| `skills/sdd-design/SKILL.md` | Modificar | Eliminar envelope local + inyectar presupuesto < 800 palabras |
| `skills/sdd-tasks/SKILL.md` | Modificar | Eliminar envelope local + inyectar presupuesto < 530 palabras |
| `skills/sdd-explore/SKILL.md` | Modificar | Eliminar envelope local, referenciar `sdd-phase-common.md` |
| `skills/sdd-apply/SKILL.md` | Modificar | Eliminar envelope local, referenciar `sdd-phase-common.md` |
| `skills/sdd-archive/SKILL.md` | Modificar | Eliminar envelope local, referenciar `sdd-phase-common.md` |
| `skills/sdd-init/SKILL.md` | Modificar | Eliminar envelope local, referenciar `sdd-phase-common.md` |
| `skills/sdd-changelog/SKILL.md` | Modificar | Eliminar envelope local, referenciar `sdd-phase-common.md` |
| `skills/sdd-verify/SKILL.md` | Modificar | Eliminar envelope local, referenciar `sdd-phase-common.md` |
| `skills/sdd-review/SKILL.md` | Modificar | Eliminar envelope local, referenciar `sdd-phase-common.md` |
| `skills/sdd-split/SKILL.md` | Modificar | Eliminar envelope local, referenciar `sdd-phase-common.md` |
| `skills/sdd-status/SKILL.md` | Modificar | Eliminar envelope local, referenciar `sdd-phase-common.md` |

**Total**: 3 nuevos, 16 modificados.

## Interfaces / Contratos

### Contrato del Return Envelope (`sdd-phase-common.md`)

```markdown
## Retorno al Orquestador

Toda fase DEBE retornar un envelope estructurado con:

- **status**: `ok | warning | error`
- **executive_summary**: Resumen ejecutivo (máximo 3 líneas)
- **artifacts**: Lista de archivos creados/modificados con rutas
- **next_recommended**: Fase siguiente recomendada
- **risks**: Lista de riesgos identificados
- **detailed_report**: (OPCIONAL) Reporte detallado de hallazgos, análisis o verificaciones

### Referencia en Skills

Cada skill incluye en su sección Reglas:
> Requiere y sigue el formato de `skills/_shared/sdd-phase-common.md`
```

### Script Bash del Skill Registry

```sh
#!/bin/sh
# Posición del script: skills/skill-registry/SKILL.md (inline)
# Propósito: Escanear ./skills/, generar ./.agentify/skill-registry.md
# Uso: sh skills/skill-registry/scan.sh

SKILLS_DIR="${1:-./skills}"
OUTPUT="./.agentify/skill-registry.md"

mkdir -p ./.agentify

echo "# Skill Registry" > "$OUTPUT"
echo "" >> "$OUTPUT"

for dir in "$SKILLS_DIR"/*/; do
  name=$(basename "$dir")
  # Ignorar sdd-* y _shared
  case "$name" in sdd-*|_*) continue ;; esac
  skill_file="$dir/SKILL.md"
  [ -f "$skill_file" ] || continue
  # Extraer nombre y descripción del frontmatter YAML
  # Parseo con sed/awk POSIX
  desc=$(sed -n '/^description:/,/^---/p' "$skill_file" | head -5 | tail -4 | sed 's/^  //')
  trigger=$(grep -i "disparador" "$skill_file" | head -1 | sed 's/.*Disparador: *//;s/\.$//')
  echo "- **$name**: $desc" >> "$OUTPUT"
  echo "  - Trigger: $trigger" >> "$OUTPUT"
  echo "  - Ubicación: \`$skill_file\`" >> "$OUTPUT"
done
```

## Estrategia de Testing

| Capa | Qué Testear | Enfoque |
|------|-------------|---------|
| Script bash | Escaneo correcto, exclusión de `sdd-*` y `_`, output válido | Ejecutar script en shell POSIX (`sh`) y verificar `.agentify/skill-registry.md` |
| Integración envelope | Skills referencian `sdd-phase-common.md` | Grep por línea de referencia en las 13 skills |
| Presupuestos | Límites inyectados correctamente | Verificar sección `### Presupuesto de Tamaño` en 4 skills objetivo |
| Orchestrator-core | Instrucción de lectura del registry | Verificar nueva sección en `orchestrator-core.md` |

## Migración / Despliegue

No se requiere migración. Los cambios son aditivos y referenciales. El rollback es `git checkout` directo sobre `skills/` y `rm -rf .agentify/`.

## Preguntas Abiertas

- [ ] ¿El script debe incluirse como archivo separado (`skills/skill-registry/scan.sh`) o inline en `SKILL.md`? → **Recomendación**: Archivo separado para ejecutabilidad directa.
- [ ] ¿El directorio `.agentify/` debe incluirse en `.gitignore`? → **Recomendación**: Sí, es artefacto generado.
