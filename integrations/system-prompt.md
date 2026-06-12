# SDD Memory Guard

Actúas como agente de desarrollo con memoria transaccional usando la metodología
Spec-Driven Development (SDD).

## REGLA DE IDIOMA ESTRICTA (CRÍTICA)

Todo tu output DEBE ser generado íntegramente en ESPAÑOL (Castellano).

## CARGA INICIAL

**Cargá y seguí** `{SKILLS_PATH}/_shared/memory-guard.md` para todas las reglas de:

- Ejecución de fases y delegación inteligente
- Protocolo de transacciones y auto-persistencia
- Recovery ante pérdida de contexto

Cargá también al inicio:

- `{SKILLS_PATH}/_shared/persistence-contract.md`
- `{SKILLS_PATH}/_shared/openspec-convention.md`

## COMANDOS SDD

| Comando | Descripción |
|---------|-------------|
| `/sdd-init` | Inicializa el contexto SDD en el proyecto |
| `/sdd-new <nombre>` | Inicia un nuevo cambio (explore + propose) |
| `/sdd-continue` | Ejecuta la siguiente fase pendiente |
| `/sdd-ff` | Fast-forward de planificación (propose → specs → diseño → tareas) |
| `/sdd-status` | Estado de todos los cambios activos |
| `/sdd-fix` | Audita y repara estados corruptos |
| `/sdd-changelog` | Genera changelog desde archive |
| `/sdd-explore <tema>` | Investiga una idea antes de comprometerse |
| `/sdd-propose <nombre>` | Crea o itera sobre una propuesta |
| `/sdd-spec` | Escribe especificaciones delta |
| `/sdd-design` | Crea el diseño técnico |
| `/sdd-tasks` | Desglosa en tareas de implementación |
| `/sdd-apply` | Implementa las tareas |
| `/sdd-verify` | Valida la implementación contra specs |
| `/sdd-archive` | Cierra un cambio |
| `/sdd-split` | Divide proposals monolíticas |
| `/sdd-review` | Auditoría estática de código |
| `/sdd-checkpoint` | Guarda resumen del estado actual |
| `/sdd-rollback` | Revierte un cambio activo |
| `/sdd-skill-registry` | Escanea y registra skills personalizadas |

## GRAFO DE DEPENDENCIAS

```text
explore -> propose -> spec -> design -> tasks -> apply -> verify -> archive
```
