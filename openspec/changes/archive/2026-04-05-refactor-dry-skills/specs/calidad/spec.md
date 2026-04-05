# Especificación de Calidad - Refactorización DRY de Skills SDD

## Propósito

Eliminar la duplicación masiva de texto en las skills del orquestador SDD mediante la aplicación del principio DRY (Don't Repeat Yourself). Esta refactorización afecta archivos de configuración (Markdown) y no altera el comportamiento de las skills.

## Requisitos

### Requisito: Eliminación de Duplicación de Return Envelope

El orquestador DEBE inyectar dinámicamente la referencia al Return Envelope en lugar de tener texto estático en cada skill.

#### Escenario: Skill sin Return Envelope estático
- GIVEN una skill SDD sin la instrucción estática de Return Envelope
- WHEN el orquestador invoca la skill
- THEN la skill funciona correctamente sin la instrucción duplicada

#### Escenario: Verificación de todas las skills
- GIVEN los 14 archivos de skills SDD
- WHEN se verifica que ninguno contiene la línea de Return Envelope
- THEN todos los archivos pasan la verificación

### Requisito: Eliminación de Secciones Errores Comunes

El sistema DEBE eliminar las secciones "Errores Comunes" de sdd-propose y sdd-apply.

#### Escenario: Skills sin Errores Comunes
- GIVEN los archivos sdd-propose/SKILL.md y sdd-apply/SKILL.md
- WHEN se eliminan las secciones "Errores Comunes"
- THEN las skills funcionan correctamente sin esas secciones

### Requisito: Helper de Detección de Test Runner

El sistema DEBE crear un archivo helper compartido para la detección de test runner.

#### Escenario: Helper creado correctamente
- GIVEN el archivo skills/_shared/test-runner-detection.md no existe
- WHEN se crea el archivo con el pseudocódigo de detección
- THEN el archivo existe con el contenido correcto

#### Escenario: Skills referencian al helper
- GIVEN las skills sdd-apply y sdd-verify
- WHEN reemplazan el pseudocódigo duplicado con referencia al helper
- THEN las skills funcionan correctamente referenciando al helper

## Archivos Afectados

| Acción | Archivo |
|--------|---------|
| Actualizar | skills/sdd-explore/SKILL.md |
| Actualizar | skills/sdd-propose/SKILL.md |
| Actualizar | skills/sdd-spec/SKILL.md |
| Actualizar | skills/sdd-design/SKILL.md |
| Actualizar | skills/sdd-tasks/SKILL.md |
| Actualizar | skills/sdd-apply/SKILL.md |
| Actualizar | skills/sdd-verify/SKILL.md |
| Actualizar | skills/sdd-archive/SKILL.md |
| Actualizar | skills/sdd-review/SKILL.md |
| Actualizar | skills/sdd-status/SKILL.md |
| Actualizar | skills/sdd-changelog/SKILL.md |
| Actualizar | skills/sdd-split/SKILL.md |
| Actualizar | skills/sdd-fix/SKILL.md |
| Actualizar | skills/sdd-init/SKILL.md |
| Crear | skills/_shared/test-runner-detection.md |

## Criterios de Verificación

1. Los 14 archivos SKILL.md no contienen la línea estática de Return Envelope.
2. sdd-propose/SKILL.md y sdd-apply/SKILL.md no contienen sección "Errores Comunes".
3. skills/_shared/test-runner-detection.md existe con contenido de pseudocódigo.
4. sdd-apply/SKILL.md y sdd-verify/SKILL.md referencian al helper.
5. Las skills siguen siendo invocables por el orquestador.