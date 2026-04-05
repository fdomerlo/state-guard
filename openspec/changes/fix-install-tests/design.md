# Diseño: Actualizar Suite de Pruebas de Instalación

## Enfoque Técnico

Este cambio actualiza los valores hardcodeados en el archivo de pruebas `scripts/install_test.sh` para reflejar el nuevo estado del proyecto tras la adición de los skills `sdd-checkpoint` y `sdd-rollback`. El enfoque es de **sustitución literal de cadena sin alterar la lógica de las pruebas**, garantizando que la suite de tests continúe validando correctamente la instalación del proyecto.

## Decisiones de Arquitectura

### Decisión 1: Actualización del Array EXPECTED_SKILLS

**Elección**: Agregar los dos nuevos skills al array `EXPECTED_SKILLS` manteniendo el orden alfabético para consistencia con el resto del array.

**Alternativas consideradas**:
- Agregar los skills al final del array (simpler pero rompe el orden alfabético)
- Modificar solo los conteos sin actualizar el array (inconsistente con la lógica de `assert_all_skills_installed`)

**Justificación**: El array `EXPECTED_SKILLS` es utilizado por la función `assert_all_skills_installed` (línea 114-122) para verificar que cada skill tenga su directorio y archivo SKILL.md correspondiente. Si no se actualiza el array, las pruebas que llaman a esta función fallarán al no encontrar los nuevos skills instalados.

---

### Decisión 2: Conteo de Skills (15 → 17) en 9 Ubicaciones

**Elección**: Actualizar las 9 instancias de `assert_eq "15"` a `assert_eq "17"` para todos los agentes (Claude Code, OpenCode, Gemini CLI, Codex, VS Code, Antigravity, Cursor, Project-local y Custom Path).

**Alternativas consideradas**:
- Crear una variable `EXPECTED_SKILL_COUNT` y usarla en todos los asserts (requiere refactorización de la lógica de pruebas)
- Dejar algunos valores en 15 y modificar solo los tests de conteo (inconsistente y propenso a errores)

**Justificación**: Las pruebas verifican el número de archivos SKILL.md instalados usando `find` y `wc -l`. Al incrementarse el número real de skills de 15 a 17, las aserciones deben reflejar este nuevo conteo para que las pruebas pasen. El cambio en las 9 ubicaciones asegura consistencia total.

---

### Decisión 3: Conteo de Comandos OpenCode (17 → 19)

**Elección**: Actualizar las 3 instancias de `assert_eq "17"` a `assert_eq "19"` para verificar el número de archivos de comandos en el directorio `~/.config/opencode/commands/`.

**Alternativas consideradas**:
- Usar el conteo dinámico del array `EXPECTED_SKILLS` para calcular el número de comandos (invalidaría la filosofía de valores hardcodeados)
- Dejar solo 2 de las 3 instancias actualizadas (inconsistencia)

**Justificación**: Los comandos de OpenCode se crean a partir de los archivos en `integrations/opencode/commands/`. Con la adición de dos nuevos skills, se espera que el instalador cree 2 comandos adicionales (sdd-checkpoint y sdd-rollback), elevando el total de 17 a 19.

---

### Decisión 4: Total All-Global (75 → 85)

**Elección**: Actualizar el valor esperado de 75 a 85 en las 2 ubicaciones que verifican el total de archivos SKILL.md instalados en todos los destinos globales.

**Alternativas consideradas**:
- Calcular dinámicamente: 5 × `$${#EXPECTED_SKILLS[@]}` (requiere cambiar la lógica de las pruebas)
- Usar un comentario que explique el cálculo (no resuelve el fallo de la prueba)

**Justificación**: El cálculo 5 × 15 = 75 debe actualizarse a 5 × 17 = 85. Las dos ubicaciones son:
- Línea 390: `assert_eq "75" "$total"`
- Línea 387: `assert_eq "15" "$count"` (dentro del loop, se debe cambiar a 17 en cada iteración)

---

### Decisión 5: Mensaje de Output (15 → 17)

**Elección**: Cambiar el grep que busca `"15 skills installed"` a `"17 skills installed"` en la verificación de salida del instalador.

**Alternativas consideradas**:
- Eliminar la verificación del mensaje (pierde cobertura de testing)
- Usar una expresión regular flexible como `"[0-9]+ skills installed"` (reduce la especificidad de la prueba)

**Justificación**: El test `test_output_shows_install_count` verifica que el mensaje de output del instalador refleje correctamente la cantidad de skills instalados. Al cambiar el mensaje de "15" a "17" en el output real, el grep debe actualizarse para seguir validando esta funcionalidad.

---

## Flujo de Datos

El flujo de ejecución de las pruebas no se ve afectado por los cambios de valores. La secuencia es:

```
install.sh → Instala 17 skills → install_test.sh → find + wc -l → assert_eq "17"
                                         ↓
                              EXPECTED_SKILLS (17 elementos)
                                         ↓
                              assert_all_skills_installed valida cada uno
```

## Cambios de Archivos

| Archivo                         | Acción   | Descripción                                                                                         |
|---------------------------------|----------|------------------------------------------------------------------------------------------------------|
| `scripts/install_test.sh`       | Modificar | Actualizar 5 grupos de valores hardcodeados para reflejar 17 skills y 19 comandos de OpenCode     |
| `skills/sdd-checkpoint/SKILL.md` | Existir  | Skill existente a incluir en las pruebas (pre-requisito del cambio)                               |
| `skills/sdd-rollback/SKILL.md`   | Existir  | Skill existente a incluir en las pruebas (pre-requisito del cambio)                               |

### Detalle de Modificaciones en install_test.sh

| Grupo | Cambios | Líneas Afectadas                          |
|-------|---------|-------------------------------------------|
| 1. Array EXPECTED_SKILLS | Agregar 2 elements | 31-47 (agregar sdd-checkpoint, sdd-rollback) |
| 2. Conteo de skills por agente | 9 cambios "15" → "17" | 195, 211, 248, 264, 284, 300, 316, 336, 354 |
| 3. Conteo de comandos OpenCode | 3 cambios "17" → "19" | 232, 399, 424 |
| 4. Total all-global | 2 cambios "75" → "15" (en loop) | 387, 390 |
| 5. Mensaje de output | 1 cambio "15" → "17" | 505 |

**Total de cambios**: 15 sustituciones de cadena + 2 adiciones al array.

---

## Interfaces / Contratos

### Contrato de Skills Esperados

```bash
# Después del cambio, EXPECTED_SKILLS debe contener:
EXPECTED_SKILLS=(
    sdd-apply
    sdd-archive
    sdd-changelog
    sdd-checkpoint   # ← Nuevo
    sdd-design
    sdd-explore
    sdd-fix
    sdd-init
    sdd-propose
    sdd-review
    sdd-rollback     # ← Nuevo
    sdd-spec
    sdd-split
    sdd-status
    sdd-tasks
    sdd-verify
    skill-registry
)
```

### Contrato de Conteos

| Tipo de Conteo | Valor Anterior | Valor Nuevo |
|----------------|----------------|-------------|
| Skills por agente | 15 | 17 |
| Comandos OpenCode | 17 | 19 |
| Total all-global (5×17) | 75 | 85 |
| Mensaje de output | "15 skills installed" | "17 skills installed" |

---

## Estrategia de Testing

| Capa          | Qué Testear                                              | Enfoque                                        |
|---------------|----------------------------------------------------------|-----------------------------------------------|
| Unitario      | Los 5 grupos de cambios en valores hardcodeados         | Ejecución directa de install_test.sh          |
| Integración   | La suite completa de pruebas de instalación             | Verificar que todas las pruebas pasen        |
| E2E           | El script de instalación con los nuevos skills         | bash scripts/install_test.sh                 |

### Validación Post-Implementación

1. Ejecutar `bash scripts/install_test.sh` y verificar que todas las pruebas pasen
2. Verificar que el output del instalador muestre "17 skills installed"
3. Confirmar que los 17 skills están instalados en cada destino

---

## Migración / Despliegue

No se requiere migración. Este cambio:
- No altera la lógica de las pruebas
- No modifica el comportamiento del script de instalación
- Solo actualiza valores esperados para reflejar el estado actual del proyecto

---

## Preguntas Abiertas

- [ ] ¿Se requiere actualizar también el comentario en la línea 377 que dice "5 targets × 15 skills = 75 SKILL.md files"? (Recomendado para consistencia)

---

## Notas de Implementación

1. **Orden de cambios**: Se recomienda seguir el orden de los grupos documentados para evitar errores de omisión.
2. **Verificación de completitud**: Después de realizar los cambios, usar `grep -c "15" scripts/install_test.sh` para confirmar que no quedan instancias del valor antiguo.
3. **No alterar la lógica**: Cada cambio es una sustitución literal. No modificar condiciones, ciclos ni funciones.