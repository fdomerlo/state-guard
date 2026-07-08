# Protocolo de Contexto para Fases

Cada fase del agente tiene reglas de lectura y escritura. Cuando ejecutás una fase inline, leés los artefactos directamente del filesystem (`.memex/`). Cuando delegás a un sub-agente, le pasás las **rutas** (no el contenido).

## Dependencias de Contexto por Fase

| Fase | Lee dependencias de (OpenSpec) | Escribe artefacto |
| --- | --- | --- |
| `mmx-explore` | Nada | Opcional (`exploration.md`) |
| `mmx-propose` | Exploración (si existe) | Sí (`proposal.md`) |
| `mmx-spec` | Propuesta (requerido) | Sí (`specs/`) |
| `mmx-design` | Propuesta (requerido) | Sí (`design.md`) |
| `mmx-tasks` | Spec + Design (requeridos) | Sí (`tasks.md`) |
| `mmx-apply` | Tasks + Spec + Design | Actualiza `tasks.md` |
| `mmx-verify` | Spec + Tasks | Sí (`verify-report.md`) |
| `mmx-archive` | Todos los artefactos | Archiva la carpeta |

## Secuencia de Ejecución por Fase

```text
Inline:   Cargá SKILL.md → Leé dependencias del disco → Ejecutá → Persistí artefacto → COMMIT vía `mmx_state_manager.py` → Reportá al usuario
Delegada: Pasá rutas → Sub-agente ejecuta y persiste artefacto → Recibís resumen → COMMIT vía `mmx_state_manager.py` → Reportá al usuario
```

## Contrato de Resultados (para fases delegadas)

Cuando delegás a un sub-agente, éste debe retornarte: `status`, `executive_summary`, `artifacts`, `risks`.

El sub-agente NO actualiza `state.ini` — eso es responsabilidad exclusiva del Memory Guard.

Cuando ejecutás inline, no hay "retorno" — vos mismo persistís el artefacto y invocás `mmx_state_manager.py commit` para avanzar la transacción.
