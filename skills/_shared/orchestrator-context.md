# SUB-AGENT CONTEXT INJECTION PROTOCOL (V3)

## 1. CONTEXT ISOLATION
Every SDD phase runs within a restricted, short-lived subprocess or ephemeral sub-agent context. Sub-agents must read source materials directly from the filesystem (`openspec/`). 
As the Orchestrator, **you must only pass relative file paths as references, NEVER dump whole file contents into the sub-agent prompt.** You are strictly responsible for tailoring the minimum required dataset to prevent token leakage.

## 2. PHASE DEPENDENCY LEDGER

| Phase | Read Dependencies From (`openspec/`) | Target Artifact Generation |
| --- | --- | --- |
| `sdd-explore` | None | Optional (`exploration.md`) |
| `sdd-propose` | `exploration.md` (if exists) | Explicit (`proposal.md`) |
| `sdd-spec` | `proposal.md` (required) | Directory (`specs/`) |
| `sdd-design` | `proposal.md` (required) | Explicit (`design.md`) |
| `sdd-tasks` | `specs/` + `design.md` (required) | Explicit (`tasks.md`) |
| `sdd-apply` | `tasks.md` + `specs/` + `design.md` | Updates `tasks.md` & code base |
| `sdd-verify` | `specs/` + `tasks.md` | Explicit (`verify-report.md`) |
| `sdd-archive`| All existing phase artifacts | Archives targeting directory |

## 3. ORCHESTRATOR PHASE SEQUENCE
For each phase execution request, you must follow this exact linear sequence:
1. `tx_begin` -> Initialize the state block and register target artifacts.
2. `delegate_task` -> Invoke the specialized sub-agent with file path injections.
3. Validate output payloads against the Result Contract criteria.
4. `tx_commit` -> Verify artifact checksums and store final state on success.
5. Provide a crisp executive summary to the developer in Spanish.

## 4. RESULT CONTRACT REQUIREMENT
Every delegated sub-agent execution context must return a structured payload conforming to the following keys:
- `status`: `"success"` | `"failed"`
- `executive_summary`: Concise summary of operations performed.
- `artifacts`: List of relative paths to modified or newly generated files.
- `next_recommended`: The next logical step or phase in the SDD DAG.
- `risks`: Identified technical debts, edge cases, or gaps.
- `detailed_report`: (Optional) Comprehensive breakdown when the executive summary requires expansion.
