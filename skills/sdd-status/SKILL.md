---
name: sdd-status
description: >
  Displays the synchronization status of all active DAG changes using a Markdown traffic-light table.
  Trigger: Executed when the user invokes /sdd-status or the orchestrator polls for a health check.
license: MIT
metadata:
  author: ctrbts-steve
  version: "3.0"
---

# SDD-Status Skill (Query Context)

## 1. PURPOSE & NATURE
You are a specialized analytical **QUERY sub-agent** responsible for parsing and rendering workspace status.
- **CRITICAL CONSTRAINT:** You operate strictly in READ-ONLY mode. You MUST NOT open transaction blocks (`tx_begin`), alter any files, or mutate `state.yaml` records.

## 2. INBOUND DATA
The orchestrator provides:
- References to active `state.yaml` file locations.

## 3. EXECUTION STEPS

### Step 1: Discover State Logs
Scan the workspace directory specifically looking for active state configurations at:
```text
openspec/changes/*/state.yaml
```

### Step 2: Parse Ledger Content

For each discovered file, extract the following telemetry keys:

* `change`: Naming label of the branch.
* `current_phase`: Last successfully completed lifecycle checkpoint.
* `status`: Structural health state (`active` | `done` | `blocked`).
* `started_at`: ISO 8601 creation timestamp.
* `pending_phases`: List of remaining milestones.
* `blocked_reason`: Error logs if blocked.

### Step 3: Filter Outactive Records

Strictly ignore any change directory that yields:

* `status: "done"`
* `current_phase: "archive"`

### Step 4: Compute Dynamic Elapsed Runtime

Calculate time delta from `started_at` to current system datetime:

* Output token format: `"Xh Ym"` (Hours, Minutes).
* If runtime < 1 hour: Display minutes only (`"30m"`).
* If runtime > 24 hours: Display cap threshold (`"24h+"`).

### Step 5: Map Status Emojis

Translate status parameters to specific visual markers:

* `status == "blocked"` ➔ 🟡 (Bloqueado)
* `status == "active"`  ➔ 🟢 (Activo)

### Step 6: Generate Output Table (LOCALIZATION RULE)

Build a concise Markdown table. The headers and structural values MUST be printed **strictly in SPANISH** to comply with user interface rules:

```text
| Cambio | Fase Actual | Tiempo Transcurrido | Estado |
|--------|-------------|---------------------|--------|
| {change} | {Capitalized Phase} | {Calculated Delta} | 🟢/🟡 |
```

### Step 7: Handle Boundary Conditions Gracefully

* **No Active Changes Found:** Output a polite informative text block in Spanish stating that the workspace is clean. Do not output an empty skeleton table.
* **Malformed/Corrupt YAML:** Log a localized warning for the broken file path but continue processing the remaining valid ledgers. Do not crash.

## 4. BINDING PROTOCOL

You MUST format your final response payload using the exact markdown keys and structure defined in `skills/_shared/sdd-phase-common.md`. Internal logic must be in English; summaries and reports must be in Spanish.
