# Persistence Contract (shared across all SDD skills)

## Mode Resolution

The orchestrator passes `artifact_store.mode` with one of: `openspec | none`.

Default resolution (when orchestrator does not explicitly set a mode):

1. If `.openspec/` directory exists in the project → use `openspec`
2. Otherwise → use `none`

When falling back to `none`, recommend the user run `sdd init` to enable `openspec` for better results.

## Behavior Per Mode

| Mode       | Read from                                    | Write to   | Project files |
|------------|----------------------------------------------|------------|---------------|
| `openspec` | Filesystem (see `openspec-convention.md`)    | Filesystem | Yes           |
| `none`     | Orchestrator prompt context                  | Nowhere    | Never         |

## State Persistence (Orchestrator)

The orchestrator persists DAG state after each phase transition. This enables SDD recovery after context compaction.

| Mode       | Persist State                                            | Recover State                                    |
|------------|----------------------------------------------------------|--------------------------------------------------|
| `openspec` | Write `.openspec/changes/{change-name}/state.yaml`       | Read `.openspec/changes/{change-name}/state.yaml` |
| `none`     | Not possible — state lives only in context               | Not possible — warn user                         |

## Common Rules

- If mode is `none`, do NOT create or modify any project files. Return results inline only.
- If mode is `openspec`, write files ONLY to the paths defined in `openspec-convention.md`.
- NEVER force `.openspec/` creation unless the orchestrator explicitly passed `openspec` mode or the user ran `sdd init`.
- If you are unsure which mode to use, default to `none`.

## Detail Level

The orchestrator may also pass `detail_level`: `concise | standard | deep`.
This controls output verbosity but does NOT affect what gets persisted — always persist the full artifact.
