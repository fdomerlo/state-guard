# OPENSPEC FILE SYSTEM & ARTIFACT CONVENTION

## 1. DIRECTORY MATRIX STRUCTURE

```text
openspec/
├── config.yaml              ← Project-specific SDD settings, engine configuration, and lint rules
├── specs/                   ← System Core Source of Truth (Current baseline specifications)
│   └── {domain}/
│       └── spec.md
└── changes/                 ← Active workspaces for transactional changesets
    ├── archive/             ← Audit trail directory for completed, immutable changes (YYYY-MM-DD-{change-name}/)
    └── {change-name}/       ← Active transactional directory (naming enforced via strict regex)
        ├── state.yaml       ← Primary transactional ledger (Maintained exclusively by the Orchestrator)
        ├── exploration.md   ← Output from sdd-explore phase (Optional)
        ├── proposal.md      ← Output from sdd-propose phase
        ├── specs/           ← Incremental specification changesets (Delta specs)
        │   └── {domain}/
        │       └── spec.md
        ├── design.md        ← Technical blueprints from sdd-design phase
        ├── tasks.md         ← Atomic engineering tasks checklist from sdd-tasks (Checked by sdd-apply)
        └── verify-report.md ← Test suites and validation matrix outputs from sdd-verify
```

## 2. ARTIFACT ROUTING MAP BY PHASE

| Phase / Skill | File System Operation | Targeted Relative Path |
| --- | --- | --- |
| `orchestrator` | Create / Update | `openspec/changes/{change-name}/state.yaml` |
| `sdd-init` | Initialize Structure | `openspec/config.yaml`, `openspec/specs/`, `openspec/changes/archive/` |
| `sdd-explore` | Optional Write | `openspec/changes/{change-name}/exploration.md` |
| `sdd-propose` | Enforced Write | `openspec/changes/{change-name}/proposal.md` |
| `sdd-spec` | Enforced Write | `openspec/changes/{change-name}/specs/{domain}/spec.md` |
| `sdd-design` | Enforced Write | `openspec/changes/{change-name}/design.md` |
| `sdd-tasks` | Enforced Write | `openspec/changes/{change-name}/tasks.md` |
| `sdd-apply` | Interactive Mutation | `openspec/changes/{change-name}/tasks.md` (updates checkpoint markers `[x]`) |
| `sdd-verify` | Enforced Write | `openspec/changes/{change-name}/verify-report.md` |
| `sdd-review` | Optional Write | `openspec/changes/{change-name}/review-report.md` |
| `sdd-fix` | System Repair | Re-evaluates and reconstructs `openspec/changes/{change-name}/state.yaml` |
| `sdd-archive` | FS Migration | Moves path to `openspec/changes/archive/YYYY-MM-DD-{change-name}/` |
| `sdd-archive` | Upstream Merge | Merges delta `specs/{domain}/spec.md` into the main `openspec/specs/{domain}/spec.md` |

## 3. STATE.YAML TRANSACTION-AWARE SCHEMA

The Orchestrator holds absolute exclusive write-access to this ledger. Sub-agents are blocked from reading or mutating this file, except for explicit analytical passes (`sdd-status`), contextual injections (`sdd-checkpoint`), or state rebuilds (`sdd-fix`).

```yaml
change: "kebab-case-change-name"
started_at: "YYYY-MM-DDTHH:MM:SS"   # ISO 8601 timestamp set on creation. Immutable.
last_updated: "YYYY-MM-DDTHH:MM:SS" # Updated automatically on every phase transition.
current_phase: "phase_name"         # Descriptively tracks the last successfully committed phase.
lock_phase: "phase_name"            # Prescriptively isolates the ONLY phase allowed to run next.
status: "active"                     # Enforced values: active | done | blocked
transaction:
  id: "tx_uuid_or_timestamp"
  status: "idle"                     # Enforced values: idle | in_progress | committed | failed
  started_at: "YYYY-MM-DDTHH:MM:SS"
  updated_at: "YYYY-MM-DDTHH:MM:SS"
  sub_agent: "sdd-phase-name"
completed_phases:
  - "explore"
  - "propose"
pending_phases:
  - "design"
  - "tasks"
blocked: false                       # Enforced true only if status is blocked and sdd-verify reports unresolved errors.
blocked_reason: null                 # Clear engineering description string or null.
session_summary:                     # Strict context block. Fixed ceiling: 500 tokens max.
  modified_files:
    - "relative/path/to/artifact.ext"
  task_status: "{X}/{Y} — Last: [{ID}] Short text description"
  key_decisions:
    - "Architectural decision string (Max 2 entries, max 100 chars per entry)"
  next_action: "/sdd-{command} {change-name}" # Fully formed executable terminal command string.
```

## 4. TOKEN CEILING CONSTRAINTS FOR SESSION_SUMMARY

The `session_summary` yaml block MUST NOT exceed 500 runtime tokens. If the data approaches this hard boundary, truncate contents following this strict prioritization sequence:

1. `modified_files`: Retain only the 10 most recent entries, slice the remainder.
2. `key_decisions`: Enforce a maximum of 2 array items, truncating each string at 100 characters.
3. `task_status` and `next_action` are mission-critical control paths; they must NEVER be truncated or altered.

## 5. NAMING CONVENTION & VALIDATION RULES

All metadata tracking parameters, directories, and change branch configurations MUST strictly conform to **kebab-case** format (lowercase alphanumeric characters isolated by single hyphens).

* **Valid Examples:** `add-dark-mode`, `fix-auth-bug`, `refactor-user-service`.
* **Invalid Examples:** `addDarkMode`, `AddDarkMode`, `add_dark_mode`, `add dark mode`.
* **Regex Enforcement Pattern:** The configuration manager and `sdd-propose` must evaluate the change label matching: `^[a-z0-9]+(-[a-z0-9]+)*$`
