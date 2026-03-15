# Exploración: feat-last-mile-polish

## Tema
Implementar las mejoras de calidad finales: validación de git en el archivo, soporte nativo para Windows (PowerShell), autogeneración de changelogs y reglas de naming.

---

## Estado Actual

### 1. Seguridad en sdd-archive
El skill `sdd-archive/SKILL.md` actualmente **NO verifica el estado de git** antes de mover la carpeta del cambio a `archive/`. El flujo actual es:
- Sincronizar specs delta con specs principales
- Mover carpeta a `archive/YYYY-MM-DD-{change-name}/`
- No hay validación de archivos sin commitear

### 2. Soporte Nativo Windows
El script `scripts/install.sh` está escrita en Bash y soporta macOS, Linux, WSL y Windows (Git Bash). Sin embargo, **no existe un equivalente en PowerShell** (`install.ps1`) para usuarios que ejecutan PowerShell nativo en Windows.

### 3. Autogeneración de Changelog
**NO existe** el skill `sdd-changelog`:
- No hay `skills/sdd-changelog/SKILL.md`
- No hay comando en `examples/opencode/commands/`
- El contador en `scripts/install_test.sh` es 12 skills
- El `orchestrator-core.md` no tiene registrado el comando `/sdd-changelog`

### 4. Naming y Errores Comunes
- **Naming**: `sdd-init/SKILL.md` genera `config.yaml` pero **no incluye** regla de naming `change_naming: kebab-case`
- **openspec-convention.md**: No documenta regla de nomenclatura para nombres de cambios
- **Errores comunes**: `sdd-propose/SKILL.md` y `sdd-apply/SKILL.md` **no tienen** sección de errores comunes

---

## Áreas Afectadas

| Área | Archivo(s) | Impacto |
|------|-----------|---------|
| Seguridad Archive | `skills/sdd-archive/SKILL.md` | Modificado |
| Soporte Windows | `scripts/install.ps1` | Nuevo archivo |
| Changelog | `skills/sdd-changelog/SKILL.md` | Nuevo skill |
| Changelog comando | `examples/opencode/commands/sdd-changelog.md` | Nuevo comando |
| Registro comando | `skills/_shared/orchestrator-core.md` | Modificado |
| Contador tests | `scripts/install_test.sh` | Modificado (12→13) |
| Naming config | `skills/sdd-init/SKILL.md` | Modificado |
| Naming convention | `skills/_shared/openspec-convention.md` | Modificado |
| Errores propose | `skills/sdd-propose/SKILL.md` | Modificado |
| Errores apply | `skills/sdd-apply/SKILL.md` | Modificado |

---

## Enfoques

### 1. Seguridad en sdd-archive

| Enfoque | Ventajas | Desventajas | Complejidad |
|---------|----------|-------------|-------------|
| **Verificar git status antes de archivar** | Previene perder cambios sin commit, seguridad | Requiere ejecutar `git status --porcelain`, posible falsos positivos | Baja |
| Verificar solo en cambios con código | Menos intrusivo | Puede perder casos de seguridad | Media |

**Recomendación**: Ejecutar `git status --porcelain` antes del move. Si hay archivos modificados sin commitear que pertenezcan a la feature, **bloquear** el archivado y exigir commit.

### 2. Soporte Nativo Windows (PowerShell)

| Enfoque | Ventajas | Desventajas | Complejidad |
|---------|----------|-------------|-------------|
| **Replicar lógica exacta de install.sh en PowerShell** | Consistencia, mismo comportamiento | Requiere reescribir `sed`/`awk` con cmdlets PowerShell | Media |
| Wrapper que llama a install.sh | Menor código | Requiere Bash en Windows | Baja |

**Recomendación**: Crear `scripts/install.ps1` idiomatico con:
- Detección de SO equivalente (`$PSVersionTable.OS`)
- Resolvedores de rutas equivalentes (`$env:USERPROFILE`, `$HOME`)
- Reemplazo de variables `{{TOOL_NAME}}` y `{{SKILLS_PATH}}` usando `-replace` en lugar de `sed`
- Compilación de `orchestrator-core.md` con cmdlets PowerShell

### 3. Autogeneración de Changelog

| Enfoque | Ventajas | Desventajas | Complejidad |
|---------|----------|-------------|-------------|
| **Crear skill sdd-changelog completo** | Funcionalidad completa, registro en orchestrator | Requiere crear 3 archivos nuevos + actualizar contador | Media |
| Script standalone | Más simple | No se integra con SDD, no hay skill | Baja |

**Recomendación**: Crear skill `sdd-changelog` que:
- Lea carpetas en `openspec/changes/archive/`
- Genere/actualice `CHANGELOG.md` en raíz
- Se registre en `orchestrator-core.md`
- Cree comando OpenCode en `examples/opencode/commands/`

### 4. Naming y Errores Comunes

| Enfoque | Ventajas | Desventajas | Complejidad |
|---------|----------|-------------|-------------|
| **Agregar todas las reglas de naming y errores comunes** | Consistencia total, previene errores | Múltiples archivos a modificar | Baja |
| Solo naming | Menos cambios | Faltaría prevención de alucinaciones | Baja |

**Recomendación**: 
- Modificar `sdd-init/SKILL.md` para incluir `change_naming: kebab-case` en config.yaml
- Actualizar `openspec-convention.md` con sección de nomenclatura
- Agregar sección `## Errores Comunes` en `sdd-propose/SKILL.md` y `sdd-apply/SKILL.md`

---

## Recomendación

Ejecutar el cambio completo como un solo SDD con las 4 tareas:
1. Seguridad git en archive (bloqueo si hay cambios sin commit)
2. Soporte Windows PowerShell (`install.ps1`)
3. Autogeneración de Changelog (skill + comando + registro)
4. Naming + errores comunes (config, convention, skills)

**Esfuerzo estimado**: 2-3 horas para implementación completa.

---

## Riesgos

- **Riesgo 1**: La verificación de git status podría dar falsos positivos si hay archivos sin relación con el cambio. *Mitigación*: Verificar que los archivos modificados estén dentro del directorio del cambio.
- **Riesgo 2**: El script PowerShell podría no funcionar en versiones antiguas de Windows. *Mitigación*: Usar cmdlets compatibles con PowerShell 5.1 (Windows 10+).
- **Riesgo 3**: El contador de tests en `install_test.sh` debe actualizarse de 12 a 13 para que los tests pasen después de agregar `sdd-changelog`.

---

## Listo para Propuesta

**Sí**. La exploración está completa y lista para generar la propuesta formal (proposal.md) con:
- Intención clara de cada mejora
- Alcance definido (4 componentes)
- Enfoque técnico recomendado
- Áreas afectadas identificadas
- Plan de implementación por fases
