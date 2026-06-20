# COMMON RETURN ENVELOPE CONTRACT — SDD PHASES

## 1. PURPOSE
This specification defines the universal, rigid exchange format that ALL specialized SDD phase sub-agents must use when returning execution results to the main orchestrator thread. Centralizing this envelope contract ensures programmatic parsability and removes duplication across skill sets.

## 2. RETURN ENVELOPE SCHEMA SPECIFICATION
Every executing skill must structure its final response payload utilizing the exact markdown blocks and keys detailed below. 

| Key Field | Data Type | Mandatory | Description / Content Localization Rule |
|---|---|---|---|
| `status` | Enum: `ok` \| `warning` \| `error` | YES | The final technical exit state of the phase execution. |
| `executive_summary` | String | YES | Brief execution synopsis **written strictly in SPANISH** (Max 3 lines). |
| `artifacts` | Markdown List | YES | Array of relative filesystem paths modified or created during runtime. |
| `next_recommended`| String (Phase Name) | YES | The next sequential DAG phase candidate (`sdd-design`, `sdd-tasks`, etc.). |
| `risks` | Markdown List | YES | Identified engineering blockers, debts, or system risks **written in SPANISH**. |
| `detailed_report` | String (Markdown) | NO | Extensive audit tables, technical logs, or analysis **written in SPANISH**. |

## 3. COMPLIANT ENVELOPE MARKDOWN TEMPLATE
Sub-agents must output their exit data using the following literal markdown markers:

```markdown
## Phase Execution Result

**status**: ok

### executive_summary
{Insert concise synopsis here. Written in Spanish. Strict maximum ceiling of 3 lines.}

### artifacts
- `relative/path/to/generated_file1.md` — Created
- `relative/path/to/mutated_file2.md` — Modified

### next_recommended
{sdd-spec | sdd-design | sdd-tasks | sdd-apply | sdd-verify | sdd-archive | none}

### risks
- {Technical risk entry 1 typed in Spanish}
- {Technical risk entry 2 typed in Spanish}

### detailed_report
{Optional comprehensive section. Insert markdown tables, configuration diffs, or deep analysis strings here in Spanish. Omit this key entirely if the executive summary provides sufficient coverage.}
```
