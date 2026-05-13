# Protocolo de Contexto para Sub-agentes

Cada fase SDD tiene reglas estrictas de lectura y escritura. Los sub-agentes leen los artefactos directamente del sistema de archivos (`openspec/`). **Tú (el orquestador) solo les pasas las referencias (rutas), NO el contenido completo.** Al invocar a un sub-agente, ERES RESPONSABLE de pasarle las rutas exactas de los archivos que debe leer y dónde debe escribir su output, sin obligarlos a leer las convenciones completas del proyecto. Envíales solo el contexto estrictamente necesario.

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

**Secuencia del orquestador por fase:** Delegá → recibís el resultado → escribís `state.yaml` → mostrás resumen al usuario.

## Contrato de Resultados

Cada fase que delegues debe retornarte estrictamente esta estructura: `status`, `executive_summary`, `artifacts`, `next_recommended`, `risks`. Opcionalmente, una fase puede incluir `detailed_report` con un análisis extenso cuando el resumen ejecutivo no sea suficiente.
