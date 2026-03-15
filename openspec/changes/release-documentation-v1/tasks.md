# Tareas: release-documentation-v1

## Fase 1: Análisis y Preparación

- [x] 1.1 Verificar que scripts/install.sh existe y es ejecutable (Unix)
- [x] 1.2 Verificar que scripts/install.ps1 existe (Windows)
- [x] 1.3 Verificar archivos en examples/opencode/commands/ para confirmar los 15 comandos
- [x] 1.4 Revisar skills en skills/_shared/ para arquitectura DRY
- [x] 1.5 Revisar openspec-convention.md para schema de state.yaml
- [x] 1.6 Revisar estado actual de README.md y MANUAL.md existentes
- [x] 1.7 Crear carpeta docs/legacy/ para backup si es necesario

## Fase 2: Reescribir README.md

- [x] 2.1 Escribir propuesta de valor en las primeras 3 líneas (qué es, para quién, por qué usarlo)
- [x] 2.2 Agregar sección de instalación Unix: `bash scripts/install.sh`
- [x] 2.3 Agregar sección de instalación Windows: `powershell .\scripts\install.ps1`
- [x] 2.4 Crear tabla con los 15 comandos del orquestador SDD
- [x] 2.5 Incluir diagramas Mermaid esenciales (simples, no complejos)
- [x] 2.6 Aplicar tono profesional, pragmático y directo
- [x] 2.7 Eliminar contenido obsoleto y redundante del README actual

## Fase 3: Reescribir MANUAL.md

- [x] 3.1 Explicar arquitectura DRY (compilación dinámica del orquestador, carga de skills, herencia de skills)
- [x] 3.2 Documentar State Machine ACID (estructura de state.yaml, prevención de colisiones, propiedades ACID)
- [x] 3.3 Detallar config.yaml (glosario de configuraciones, convenciones kebab-case, test_command, ejemplos)
- [x] 3.4 Cubrir flujo /sdd-split (división de proposals en sub-cambios)
- [x] 3.5 Cubrir flujo /sdd-review (auditoría estática contra especificaciones)
- [x] 3.6 Cubrir flujo /sdd-fix (reparación de problemas comunes)
- [x] 3.7 Aplicar tono profesional, técnico y directo
- [x] 3.8 Eliminar contenido obsoleto y redundante

## Fase 4: Verificación

- [x] 4.1 Verificar que las primeras 3 líneas del README contienen propuesta de valor clara
- [x] 4.2 Verificar comandos de instalación coinciden con scripts reales
- [x] 4.3 Verificar tabla de 15 comandos coincide con ejemplos/opencode/commands/
- [x] 4.4 Verificar que no hay redundancias entre README y MANUAL
- [x] 4.5 Verificar que arquitectura DRY coincide con skills/_shared/
- [x] 4.6 Verificar que state.yaml sigue el schema de openspec-convention.md
- [x] 4.7 Verificar que config.yaml usa convenciones kebab-case correctas
- [x] 4.8 Revisión final de tono y estilo en ambos documentos

---

## Notas de Implementación

- Los archivos legacy en docs/legacy/ solo se crean si es necesario para rollback
- La verificación debe comparar contra código real (scripts, skills, archivos de convenciones)
- El orden de implementación es importante: primero analizar el código real, luego reescribir documentación
