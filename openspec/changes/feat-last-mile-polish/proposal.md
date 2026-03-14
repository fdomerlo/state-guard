# Propuesta: feat-last-mile-polish

## Intención

Implementar mejoras finales de calidad para el proyecto agentify-sdd: validación de seguridad en el archivo (verificación de git), soporte nativo para Windows mediante PowerShell, autogeneración de changelogs, y reglas estrictas de naming para prevenir errores. Estas mejoras abordan deuda técnica y gaps de funcionalidad identificados durante la exploración.

## Alcance

### Dentro del Alcance

1. **Seguridad en sdd-archive**: Modificar `skills/sdd-archive/SKILL.md` para verificar el estado del repositorio con `git status --porcelain` antes de mover la carpeta del cambio a `archive/`. Si existen archivos modificados sin commitear que pertenezcan a la feature, BLOQUEAR el archivado y exigir al usuario que haga commit primero.

2. **Soporte Nativo Windows (install.ps1)**: Leer exhaustivamente `scripts/install.sh` y crear un archivo equivalente en `scripts/install.ps1` escrito en PowerShell idiomático. Implementar la misma lógica exacta de "Compilación Estática" para inyectar `orchestrator-core.md` y resolver las variables `{{TOOL_NAME}}` y `{{SKILLS_PATH}}` usando cmdlets PowerShell equivalentes.

3. **Autogeneración de Changelog (sdd-changelog)**:
   - Crear `skills/sdd-changelog/SKILL.md` para leer carpetas en `openspec/changes/archive/` y generar/actualizar `CHANGELOG.md` en raíz
   - Registrar el comando `/sdd-changelog` en `skills/_shared/orchestrator-core.md`
   - Crear el comando OpenCode en `examples/opencode/commands/sdd-changelog.md`
   - Actualizar el contador de skills en `scripts/install_test.sh` de 12 a 13

4. **Naming y Errores Comunes**:
   - Modificar `skills/sdd-init/SKILL.md` para que el `config.yaml` generado incluya regla estricta: `change_naming: kebab-case`
   - Actualizar `skills/_shared/openspec-convention.md` para reflejar esta regla de nomenclatura
   - Agregar sección `## Errores Comunes` en `skills/sdd-propose/SKILL.md` y `skills/sdd-apply/SKILL.md`

### Fuera del Alcance

- Modificación de otros skills de la suite SDD no mencionados
- Implementación de funcionalidades adicionales de changelog más allá de la generación básica
- Soporte para otras plataformas no mencionadas

## Enfoque

Se implementarán las 4 tareas de forma secuencial e independiente:

1. **Verificación git en archive**: Agregar paso de validación con `git status --porcelain` antes del move, bloqueando si hay cambios sin commit en el directorio del cambio.

2. **Script PowerShell**: Replicar lógica exacta de `install.sh` usando cmdlets PowerShell (`-replace` para variables, detección de SO con `$PSVersionTable.OS`).

3. **Skill sdd-changelog**: Crear skill que itere sobre `openspec/changes/archive/`, extraiga metadatos de cada cambio archivado, y genere/actualice `CHANGELOG.md` con formato estándar.

4. **Naming y errores**: Actualizar templates y documentación para imponer `kebab-case` y agregar advertencias sobre alucinaciones de contexto.

## Áreas Afectadas

| Área                        | Impacto      | Descripción                                                              |
|-----------------------------|--------------|--------------------------------------------------------------------------|
| `skills/sdd-archive/SKILL.md` | Modificado   | Agregar verificación git antes de archivar                              |
| `scripts/install.ps1`      | Nuevo        | Equivalente PowerShell de install.sh                                    |
| `scripts/install.sh`        | Leído        | Referencia para implementación de install.ps1                          |
| `skills/sdd-changelog/SKILL.md` | Nuevo     | Skill para generar changelog desde archive                              |
| `examples/opencode/commands/sdd-changelog.md` | Nuevo | Comando OpenCode para sdd-changelog                                    |
| `skills/_shared/orchestrator-core.md` | Modificado | Registrar comando /sdd-changelog                              |
| `scripts/install_test.sh`   | Modificado   | Actualizar contador de 12 a 13                                         |
| `skills/sdd-init/SKILL.md`  | Modificado   | Incluir `change_naming: kebab-case` en config.yaml generado             |
| `skills/_shared/openspec-convention.md` | Modificado | Documentar regla de nomenclatura kebab-case              |
| `skills/sdd-propose/SKILL.md` | Modificado   | Agregar sección Errores Comunes                                         |
| `skills/sdd-apply/SKILL.md` | Modificado   | Agregar sección Errores Comunes                                         |

## Riesgos

| Riesgo                                   | Probabilidad | Mitigación                                                                 |
|------------------------------------------|--------------|-----------------------------------------------------------------------------|
| Falsos positivos en verificación git    | Media        | Verificar que los archivos modificados estén dentro del directorio del cambio |
| Compatibilidad PowerShell en Windows antiguos | Media   | Usar cmdlets compatibles con PowerShell 5.1 (Windows 10+)                  |
| Contador de tests desactualizado         | Alta         | Actualizar `install_test.sh` de 12 a 13 al crear sdd-changelog            |

## Plan de Rollback

1. **Seguridad archive**: Si la verificación git bloquea incorrectamente, el usuario puede hacer commit vacío o eliminar la verificación del skill temporalmente.

2. **PowerShell**: Si `install.ps1` falla, el usuario puede continuar usando `install.sh` (Git Bash).

3. **Changelog**: Si el skill falla, el archivo `CHANGELOG.md` puede regenerarse manualmente o eliminarse.

4. **Naming**: Si la regla `kebab-case` es muy restrictiva, modificarla en `config.yaml` generado.

## Dependencias

- Ninguna dependencia externa requerida
- Todos los archivos a modificar ya existen en el proyecto

## Criterios de Éxito

- [ ] La verificación git en sdd-archive bloquea archivos sin commitear belonging al cambio
- [ ] El script install.ps1 se ejecuta correctamente en Windows nativo y genera los mismos archivos que install.sh
- [ ] El comando /sdd-changelog genera un CHANGELOG.md válido desde los archivos archive
- [ ] El contador en install_test.sh es 13 después de la implementación
- [ ] El config.yaml generado por sdd-init incluye `change_naming: kebab-case`
- [ ] Los skills sdd-propose y sdd-apply tienen sección de Errores Comunes
- [ ] La convención de nomenclatura está documentada en openspec-convention.md
