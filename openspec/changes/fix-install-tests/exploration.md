# Exploración: fix-install-tests

## Resumen Ejecutivo

Se investigó el archivo `scripts/install_test.sh` para identificar los cambios necesarios que reflejen la adición de dos nuevas skills (`sdd-checkpoint` y `sdd-rollback`). El análisis revela que el script contiene **múltiples valores hardcodeados** que deben actualizarse de forma sistemática:

- **15 skills** → **17 skills** (EXPECTED_SKILLS + contadores)
- **17 comandos OpenCode** → **19 comandos** (sdd-checkpoint y sdd-rollback generan comandos adicionales)
- **75 total** → **85 total** (5 destinos × 17 skills)
- **"15 skills installed"** → **"17 skills installed"** (mensaje de salida)

## Hallazgos del Código Base

### Archivo Analizado
- **Ruta**: `scripts/install_test.sh`
- **Total de líneas**: 688
- **Cantidad de tests**: 40+

### Valores Actuales Identificados

| Categoría | Valor Actual | Valor Nuevo | Cantidad de Cambios |
|-----------|--------------|-------------|---------------------|
| Skills por agente | 15 | 17 | 9 assert_eq |
| Comandos OpenCode | 17 | 19 | 3 assert_eq |
| Total all-global | 75 | 85 | 2 assert_eq |
| Mensaje de salida | "15 skills installed" | "17 skills installed" | 1 grep |

### Ubicaciones Específicas

#### 1. EXPECTED_SKILLS (líneas 31-47)
Array con 15 skills. Debe agregar:
- `sdd-checkpoint`
- `sdd-rollback`

#### 2. Conteo de skills por agente (assert_eq "15" → "17")
- Línea 195: `test_claude_code_skill_count`
- Línea 211: `test_opencode_skill_count`
- Línea 248: `test_gemini_cli_skill_count`
- Línea 264: `test_codex_skill_count`
- Línea 284: `test_vscode_skill_count`
- Línea 300: `test_antigravity_skill_count`
- Línea 316: `test_cursor_skill_count`
- Línea 336: `test_project_local_skill_count`
- Línea 354: `test_custom_path_skill_count`

#### 3. Comandos OpenCode (assert_eq "17" → "19")
- Línea 232: `test_opencode_commands`
- Línea 399: `test_all_global_opencode_commands`
- Línea 424: `test_idempotent_opencode`

#### 4. Total all-global
- Línea 387: Verificación por directorio (15 → 17)
- Línea 390: Total acumulado (75 → 85)

#### 5. Mensaje de salida
- Línea 505: `test_output_shows_install_count` - grep "15 skills installed"

## Áreas de Riesgo

1. **Mensajes de test**: Los mensajes descriptivos en los assert_eq también mencionan los números (ej: "Expected exactly 15 skills..."). Estos pueden actualizarse o mantenerse según criterio del equipo.

2. **Textos de interfaz** (líneas 597-645): Los mensajes que se打印an durante los tests (ej: "Installs all 15 skills to..."). Aunque son labels de UI y no afectan la lógica, sería inconsistente no actualizarlos.

3. **Idempotency tests**: Los tests de idempotencia también verifican contadores específicos y deben actualizarse al mismo tiempo.

## Enfoque Recomendado

**Opción A: Actualización manual línea por línea**
- Ventaja: Control total sobre cada cambio
- Desventaja: Propenso a omitir alguna línea

**Opción B: Reemplazo sistemático con replaceAll**
- Ventaja: Cubrir todos los casos automáticamente
- Desventaja: Requiere verificar que no haya otros 15/17/75 que no sean de conteo

**Recomendación**: Usar **Opción B** con validaciones manuales posteriores para confirmar que los cambios fueron correctos.

## Siguiente Fase

Preparar **propuesta de cambio (proposal)** documentando:
- Intención: Actualizar recuentos de skills/commands en tests de instalación
- Alcance: Solo `scripts/install_test.sh`, sin modificar lógica de instalación
- Enfoque: Reemplazo sistemático de valores hardcodeados
