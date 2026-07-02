# Protocolo de Contexto para Fases

Cada fase SDD tiene reglas de lectura y escritura. Cuando ejecutás una fase inline, leés los artefactos directamente del filesystem (`.agentify/`). Cuando delegás a un sub-agente, le pasás las **rutas** (no el contenido).

## Dependencias de Contexto por Fase

| Fase | Lee dependencias de (OpenSpec) | Escribe artefacto |
| --- | --- | --- |
| `sdd-explore` | Nada | Opcional (`exploration.md`) |
| `sdd-propose` | Exploración (si existe) | Sí (`proposal.md`) |
| `sdd-spec` | Propuesta (requerido) | Sí (`specs/`) |
| `sdd-design` | Propuesta (requerido) | Sí (`design.md`) |
| `sdd-tasks` | Spec + Design (requeridos) | Sí (`tasks.md`) |
| `sdd-apply` | Tasks + Spec + Design | Actualiza `tasks.md` |
| `sdd-verify` | Spec + Tasks | Sí (`verify-report.md`) |
| `sdd-archive` | Todos los artefactos | Archiva la carpeta |

## Secuencia de Ejecución por Fase

```text
Inline:   Cargá SKILL.md → Leé dependencias del disco → Ejecutá → Persistí artefacto → COMMIT vía `sdd_state_manager.py` → Reportá al usuario
Delegada: Pasá rutas → Sub-agente ejecuta y persiste artefacto → Recibís resumen → COMMIT vía `sdd_state_manager.py` → Reportá al usuario
```

## Contrato de Resultados (para fases delegadas)

Cuando delegás a un sub-agente, éste debe retornarte: `status`, `executive_summary`, `artifacts`, `risks`.

El sub-agente NO actualiza `state.ini` — eso es responsabilidad exclusiva del Memory Guard.

Cuando ejecutás inline, no hay "retorno" — vos mismo persistís el artefacto y invocás `sdd_state_manager.py commit` para avanzar la transacción.
