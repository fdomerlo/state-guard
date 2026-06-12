# Agentify SDD — AGENTS.md

## What this is

Agentify SDD is a Meta-Framework for Spec-Driven Development with transactional memory, consumed by AI coding agents. This repo ships the framework itself (skills, integrations, installer) — not an end-user project.

## Tech stack

Shell (Bash/PowerShell), Markdown, YAML — no compiled code, no package manager.

## Key structure

| Path | Purpose |
|------|---------|
| `skills/` | 20 SDD skills (1 dir per `/sdd-*` command) |
| `skills/_shared/` | 8 shared contracts loaded by the Memory Guard |
| `integrations/` | Host-specific stubs (Claude Code, OpenCode, Gemini CLI, Antigravity) + canonical `system-prompt.md` |
| `scripts/` | `install.sh`, `install.ps1`, `install_test.sh`, `cleanup.sh` |
| `openspec/` | Config, specs, and change persistence |
| `openspec/changes/` | Active changes — **gitignored** (see `.gitignore` for the quirk) |
| `openspec/changes/archive/` | Archived changes — **tracked** in git |
| `.agentify/` | Auto-generated skill registry |

## Language

All SDD artifacts (proposals, specs, designs, tasks) **MUST** be written in **Spanish (Castellano)**. Skills are authored in Spanish too. `integrations/` and README may be bilingual.

## Naming

kebab-case for change names, skill directories, and config keys.

## Commands

```
Install: bash scripts/install.sh                     # interactive
Install: bash scripts/install.sh --agent opencode     # non-interactive
Uninstall: bash scripts/cleanup.sh                    # --hard to purge history
Test: bash scripts/install_test.sh
```

No standard test framework — `install_test.sh` is a standalone bash test suite.

## SDD Phase flow (strict DAG)

```
explore → propose → spec → design → tasks → apply → verify → archive
```

Each phase executes as a **single atomic transaction** (BEGIN → COMMIT/ROLLBACK). Anti-batching by protocol: `txn_phase` is scalar, not a list. `/sdd-ff` runs 4 sequential transactions, not 1.

## Specs format

GIVEN/WHEN/THEN scenarios. RFC 2119 keywords (MUST/SHALL/SHOULD/MAY).

## Key conventions

- `state.yaml` (v2) at `openspec/changes/{change-name}/` — fields: `txn_status`, `txn_phase`, `txn_started_at`, `session_summary`
- Recovery: `/sdd-fix` repairs corrupt state and migrates v1→v2
- Archive: **requires a git commit** of all changes before `/sdd-archive`
- Rollback: `/sdd-rollback` purges the change dir and restores from git
- `.gitignore` quirk: `openspec/changes/*` is ignored, **except** `openspec/changes/archive/` — active changes are ephemeral, only archived ones are tracked
- Custom skills go in `$HOME/.skills-custom/` (global) or `./skills-custom/` (local), registered via `/sdd-skill-registry`
- markdownlint configured with `MD041` (h1 at top) and `MD013` (line length) disabled

## Integration quirks

- `integrations/opencode/opencode.json` defines the `sdd-orchestrator` agent with read/write/edit/bash tools — the `prompt` field is a `{SKILLS_PATH}` placeholder resolved at install time by `install.sh`
- `integrations/system-prompt.md` is the canonical prompt template that all integrations compile (substituting `{SKILLS_PATH}`) — injected via `<!-- BEGIN/END SDD MEMORY GUARD -->` markers
- Delegation to sub-agents only occurs when `apply` has > 10 pending tasks AND the host supports it
