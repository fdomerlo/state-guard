# Propuesta: feat-estado-y-seguridad

## Intención de Negocio

Implementar mecanismos de seguridad ante fallos y optimizar la recuperación de sesión para el orquestador SDD, evitando tener que releer todo el histórico de artefactos tras una recarga del IDE.

## Alcance

1. **Checkpoint de Sesión**: Agregar campo `session_summary` al schema de `state.yaml` (máximo 5 líneas) para almacenar resumen del estado actual del cambio.

2. **Comando Checkpoint**: Crear skill `/sdd-checkpoint` que resuma el estado del cambio activo y lo guarde en `session_summary`.

3. **Rollback de Emergencia**: Crear skill `/sdd-rollback` que purgue la carpeta del cambio y use `git checkout -- .` y `git clean -fd` para restaurar el entorno.

4. **Registro en Orquestador**: Actualizar `orchestrator-commands.md` con los nuevos comandos.

## Archivos a Modificar/Crear

| Archivo | Acción |
|---------|--------|
| `skills/_shared/openspec-convention.md` | Modificar (agregar campo `session_summary`) |
| `skills/sdd-checkpoint/SKILL.md` | **CREAR** |
| `skills/sdd-rollback/SKILL.md` | **CREAR** |
| `skills/_shared/orchestrator-commands.md` | Modificar (agregar comandos) |

## Criterios de Éxito

- [ ] Campo `session_summary` agregado al schema de state.yaml
- [ ] Skill sdd-checkpoint creada con funcionalidad
- [ ] Skill sdd-rollback creada con funcionalidad
- [ ] Comandos registrados en orquestador

## Plan de Rollback

```bash
git checkout -- skills/ openspec/
```
