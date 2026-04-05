# Tareas: Actualizar Suite de Pruebas de Instalación

## Fase 1: Actualización del Array EXPECTED_SKILLS

- [x] 1.1 Agregar `sdd-checkpoint` al array EXPECTED_SKILLS en `scripts/install_test.sh` (mantener orden alfabético, después de sdd-changelog)
- [x] 1.2 Agregar `sdd-rollback` al array EXPECTED_SKILLS en `scripts/install_test.sh` (mantener orden alfabético, después de sdd-review)

## Fase 2: Actualización de Conteos de Skills (15 → 17)

- [x] 2.1 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` para Claude Code (línea ~195)
- [x] 2.2 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` para OpenCode (línea ~211)
- [x] 2.3 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` para Gemini CLI (línea ~248)
- [x] 2.4 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` para Codex (línea ~264)
- [x] 2.5 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` para VS Code (línea ~284)
- [x] 2.6 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` para Antigravity (línea ~300)
- [x] 2.7 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` para Cursor (línea ~316)
- [x] 2.8 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` para Project-local (línea ~336)
- [x] 2.9 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` para Custom Path (línea ~354)

## Fase 3: Actualización de Conteos de Comandos OpenCode (17 → 19)

- [x] 3.1 Actualizar `assert_eq "17"` a `assert_eq "19"` para conteo de comandos OpenCode (línea ~232)
- [x] 3.2 Actualizar `assert_eq "17"` a `assert_eq "19"` para conteo de comandos en verificación total (línea ~399)
- [x] 3.3 Actualizar `assert_eq "17"` a `assert_eq "19"` para conteo de comandos en verificación final (línea ~424)

## Fase 4: Actualización de Total All-Global (75 → 85)

- [x] 4.1 Actualizar `assert_eq "15" "$count"` a `assert_eq "17" "$count"` dentro del loop de verificación total (línea ~387)
- [x] 4.2 Actualizar `assert_eq "75" "$total"` a `assert_eq "85" "$total"` para el total acumulado (línea ~390)

## Fase 5: Actualización de Mensaje de Output (15 → 17)

- [x] 5.1 Cambiar grep de `"15 skills installed"` a `"17 skills installed"` en verificación de output (línea ~505)

## Fase 6: Verificación

- [x] 6.1 Ejecutar `bash scripts/install_test.sh` y verificar que todas las pruebas pasen exitosamente
- [x] 6.2 Verificar con `grep -c "15" scripts/install_test.sh` que no queden instancias del valor antiguo
- [x] 6.3 Confirmar que el output muestra "17 skills installed" tras ejecutar el instalador

## Fase 7: Documentación (Opcional)

- [x] 7.1 Actualizar comentario en línea ~377 que dice "5 targets × 15 skills = 75 SKILL.md files" para reflejar el nuevo cálculo (opcional)
