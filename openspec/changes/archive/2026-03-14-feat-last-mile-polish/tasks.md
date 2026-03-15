# Tareas: feat-last-mile-polish

## Fase 1: Seguridad Git en Archive

- [x] 1.1 Modificar `skills/sdd-archive/SKILL.md` para agregar función `verify_git_clean_for_change()` que ejecute `git status --porcelain` antes de mover la carpeta al archive
- [x] 1.2 Implementar filtrado de archivos modificados dentro del directorio del cambio (prefix matching)
- [x] 1.3 Agregar lógica de BLOQUEO si se detectan cambios sin commitear belonging al directorio del cambio
- [x] 1.4 Agregar manejo de casos edge: repositorio sin git (`.git/` no existe), git no disponible en PATH
- [x] 1.5 Agregar mensajes informativos/warnings según el escenario (skipped verification vs blocked)

## Fase 2: Instalador PowerShell (install.ps1)

- [x] 2.1 Crear `scripts/install.ps1` con estructura modular similar a `install.sh`
- [x] 2.2 Implementar detección de SO usando `$PSVersionTable.OS` (Windows, WSL, PowerShell Core)
- [x] 2.3 Implementar función de colores compatible con PowerShell 5.1
- [x] 2.4 Implementar `Get-ToolPath` con equivalentes PowerShell para rutas (`$env:USERPROFILE`)
- [x] 2.5 Implementar función `Test-SourceValid` para validar que skills existen en `skills/sdd-*/`
- [x] 2.6 Implementar función `Install-Skill` para copiar skills al destino
- [x] 2.7 Implementar función `Compile-CoreFile` para reemplazar `{{TOOL_NAME}}` y `{{SKILLS_PATH}}`
- [x] 2.8 Implementar función `Update-ConfigFile` para inyectar bloque orquestador (purga de bloques anteriores)
- [x] 2.9 Soportar parámetro `-Agent` para especificar herramienta (opencode, claude-code, etc.)
- [ ] 2.10 Probar equivalencia con `install.sh` ejecutando ambos en mismo entorno

## Fase 3: Skill sdd-changelog

- [x] 3.1 Crear `skills/sdd-changelog/SKILL.md` con lógica de lectura de carpetas en `openspec/changes/archive/`
- [x] 3.2 Implementar extracción de metadatos de cada `proposal.md` archivado (título, intención, alcance)
- [x] 3.3 Implementar generación de `CHANGELOG.md` en raíz con formato:
  - Encabezado con título, descripción, fecha de generación
  - Entradas por cambio con formato: `## [{Fecha}] {Nombre}`, **Intención**, **Alcance**
- [x] 3.4 Ordenar cambios por fecha (más reciente primero) desde nombre de carpeta
- [x] 3.5 Manejar caso edge: archive vacío (generar CHANGELOG con encabezado pero sin cambios)
- [x] 3.6 Crear `examples/opencode/commands/sdd-changelog.md` como comando OpenCode
- [x] 3.7 Registrar comando `/sdd-changelog` en `skills/_shared/orchestrator-core.md`
- [x] 3.8 Actualizar contador en `scripts/install_test.sh` de 12 a 13

## Fase 4: Naming y Errores Comunes

- [x] 4.1 Modificar `skills/sdd-init/SKILL.md` para incluir `change_naming: kebab-case` en el template de `config.yaml` generado
- [x] 4.2 Actualizar `skills/_shared/openspec-convention.md` para documentar regla de nomenclatura kebab-case con ejemplos válidos/inválidos
- [x] 4.3 Agregar función de validación `validate_change_name()` en `skills/sdd-propose/SKILL.md` con regex `^[a-z0-9]+(-[a-z0-9]+)*$`
- [x] 4.4 Agregar sección "## Errores Comunes" en `skills/sdd-propose/SKILL.md` cubriendo: alucinaciones de contexto, olvidar plan de rollback, scope creep, no seguir naming
- [x] 4.5 Agregar sección "## Errores Comunes" en `skills/sdd-apply/SKILL.md` cubriendo: modificar specs/design sin actualizar proposal, ignorar checklist de tareas, no seguir patrones existentes, dejar tareas incompletas

## Fase 5: Testing y Verificación

- [ ] 5.1 Testear verificación git en sdd-archive: crear cambio, modificar archivo sin commitear, ejecutar /sdd-archive y verificar BLOQUEO
- [ ] 5.2 Testear verificación git: hacer commit de cambios, ejecutar /sdd-archive y verificar que procede
- [ ] 5.3 Testear install.ps1 en Windows PowerShell 5.1 (Windows 10)
- [ ] 5.4 Testear install.ps1 en PowerShell Core (pwsh 7+)
- [ ] 5.5 Testear install.ps1 con flag `-Agent opencode` y verificar instalación correcta
- [ ] 5.6 Testear sdd-changelog con archive vacío
- [ ] 5.7 Testear sdd-changelog con cambios archivados (crear carpetas de prueba)
- [ ] 5.8 Testear validación de naming: intentar crear cambio con camelCase, PascalCase, espacios y verificar RECHAZO
- [ ] 5.9 Testear validación de naming: crear cambio con kebab-case válido y verificar aceptación
- [x] 5.10 Ejecutar `scripts/install_test.sh` y verificar contador es 13
- [ ] 5.11 Verificar que CHANGELOG.md se genera correctamente y tiene formato válido
