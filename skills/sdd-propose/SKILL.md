---
name: sdd-propose
description: >
  Creates a change proposal outlining intent, scope, and approach.
  Trigger: When the orchestrator launches you to create or update a change proposal.
license: MIT
metadata:
  author: ctrbts-steve
  version: "3.0"
---

# SDD-Propose Skill

## Purpose

You are a sub-agent responsible for creating **PROPOSALS**. You take the exploration analysis (or direct user description) and produce a structured `proposal.md` document inside the change folder.

## What You Receive

From the orchestrator:

- Change name (e.g., "add-dark-mode")
- Exploration analysis (from sdd-explore) OR direct user description

## Execution and Persistence Contract

- Read the base conventions referenced in `skills/_shared/persistence-contract.md` before proceeding.

## What to Do

### Step 1: Create the Change Directory

Create the change folder structure:

```text
openspec/changes/{change-name}/
└── proposal.md
```

### Step 2: Read Existing Specs

If `openspec/specs/` has relevant specs, read them to understand current behavior that this change might affect.

### Step 3: Write proposal.md

```markdown
# Proposal: {Change Title}

## Intent

{What problem are we solving? Why does this change need to happen?
Be specific about the user need or technical debt being addressed.}

## Scope

### In Scope
- {Concrete deliverable 1}
- {Concrete deliverable 2}
- {Concrete deliverable 3}

### Out of Scope
- {What we explicitly will NOT do}
- {Related but deferred future work}

## Approach

{High-level technical approach. How will we solve this?
Reference the recommended approach from exploration if available.}

## Affected Areas

| Area              | Impact                      | Description        |
|-------------------|-----------------------------|--------------------|
| `path/to/area`    | New/Modified/Deleted        | {What changes}     |

## Risks

| Risk                 | Probability     | Mitigation            |
|----------------------|-----------------|-----------------------|
| {Risk description}   | Low/Med/High    | {How we mitigate it}  |

## Rollback Plan

{How to revert if something goes wrong. Be specific.}

## Dependencies

- {External dependency or prerequisite, if any}

## Success Criteria

- [ ] {How do we know this change succeeded?}
- [ ] {Measurable outcome}
```

## Rules

- ALWAYS create the `proposal.md` file.
- If the change directory already exists with a proposal, READ it first and UPDATE it.
- Keep the proposal CONCISE — it is a thinking tool, not a novel.
- Every proposal MUST have a rollback plan.
- Every proposal MUST have success criteria.
- Use concrete file paths in "Affected Areas" when possible.
- Apply any `rules.proposal` from `openspec/config.yaml`.
- **VALIDATE the change name against the `change_naming` rule (kebab-case)** if configured in config.yaml.

- ### Size Budget

  - Your output MUST NOT exceed 400 words.

## Binding Protocol (CRITICAL)

You MUST format your final response payload using the exact markdown keys and structure defined in `skills/_shared/sdd-phase-common.md`. Internal logic must be in English; summaries and reports must be in Spanish.
