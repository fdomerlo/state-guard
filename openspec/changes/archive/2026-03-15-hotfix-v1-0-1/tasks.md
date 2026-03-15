# Tareas: hotfix-v1-0-1

## Resumen

Este hotfix de documentación agrega reglas de sintaxis BDD y clarifica el procesamiento de meta-comandos en las skills del orquestador SDD. Solo implica插入 texto en archivos existentes.

## Fase 1: Modificación de sdd-spec/SKILL.md

- [x] 1.1 Abrir el archivo `~/.config/opencode/skills/sdd-spec/SKILL.md`
- [x] 1.2 Ubicar la sección "Reglas" (línea 144)
- [x] 1.3 Insertar la regla de "Sintaxis Gherkin/BDD Inmutable" después de la regla sobre palabras clave RFC 2119
- [x] 1.4 Verificar que la regla sea visible y correctamente formateada

## Fase 2: Modificación de orchestrator-core.md

- [x] 2.1 Abrir el archivo `~/.config/opencode/skills/_shared/orchestrator-core.md`
- [x] 2.2 Ubicar después de la línea 57 (nota sobre meta-comandos)
- [x] 2.3 Insertar la directiva de "META-COMANDOS VS SKILLS" con la tabla de mapeo
- [x] 2.4 Verificar que la directiva sea visible y correctamente formateada

## Fase 3: Verificación Final

- [x] 3.1 Confirmar que la regla BDD es visible en la sección Reglas de sdd-spec
- [x] 3.2 Confirmar que la directiva de meta-comandos es visible en orchestrator-core
- [x] 3.3 Verificar que no se modificó ninguna funcionalidad existente del orquestador
- [x] 3.4 Verificar que el formato es consistente con el resto de cada archivo

## Orden de Implementación

Las tareas deben ejecutarse en el orden enumerado (Fase 1 → Fase 2 → Fase 3). Las tareas dentro de cada fase son secuenciales.

## Notas de Implementación

- Este es un hotfix de documentación: NO hay código que ejecutar, NO hay tests que correr
- Las tareas son de inserción de texto puro
- Verificar que las comillas, asteriscos y formato markdown se mantengan correctamente
- No eliminar ningún contenido existente, solo agregar las nuevas reglas

## Criterios de Éxito

- [x] Regla BDD visible en sdd-spec/SKILL.md
- [x] Directiva de meta-comandos visible en orchestrator-core.md
- [x] Formato consistente con el estilo existente
- [x] Sin ruptura de funcionalidad existente
