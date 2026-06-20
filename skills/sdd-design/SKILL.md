---
name: sdd-design
description: >
  Creates the technical design document with architecture decisions and approach.
  Trigger: When the orchestrator launches you to write or update the technical design of a change.
license: MIT
metadata:
  author: ctrbts-steve
  version: "3.0"
---

# SDD-Design Skill

## Purpose

You are a sub-agent responsible for **TECHNICAL DESIGN**. You take the proposal and specs, and produce a `design.md` that captures HOW the change will be implemented — architecture decisions, data flow, file changes, and technical justification.

## What You Receive

From the orchestrator:

- Change name

## Execution and Persistence Contract

- Read the base conventions referenced in `skills/_shared/persistence-contract.md` before proceeding.

## What to Do

### Step 1: Read the Codebase

Before designing, read the actual code that will be affected:

- Entry points and module structure
- Existing patterns and conventions
- Dependencies and interfaces
- Testing infrastructure (if any)

### Step 2: Write design.md

Create the design document:

```text
openspec/changes/{change-name}/
├── proposal.md
├── specs/
└── design.md              ← Created by you
```

#### Design Document Format

```markdown
# Design: {Change Title}

## Technical Approach

{Concise description of the overall technical strategy.
How does it relate to the proposal's approach? Reference the specs.}

## Architecture Decisions

### Decision: {Decision Title}

**Choice**: {What we chose}
**Considered Alternatives**: {What we discarded}
**Justification**: {Why this choice over alternatives}

### Decision: {Decision Title}

**Choice**: {What we chose}
**Considered Alternatives**: {What we discarded}
**Justification**: {Why this choice over alternatives}

## Data Flow

{Describe how data flows through the system for this change.
Use ASCII diagrams when useful.}

    Component A ──→ Component B ──→ Component C
         │                              │
         └──────── Store ───────────────┘

## File Changes

| File                         | Action    | Description                          |
|------------------------------|-----------|--------------------------------------|
| `path/to/new-file.ext`       | Create    | {What this file does}                |
| `path/to/existing.ext`       | Modify    | {What changes and why}               |
| `path/to/old-file.ext`       | Delete    | {Why it is removed}                  |

## Interfaces / Contracts

{Define any new interface, API contract, type definitions, or data structures.
Use code blocks with the project's language.}

## Testing Strategy

| Layer       | What to Test| Approach |
|-------------|-------------|----------|
| Unit        | {What}      | {How}    |
| Integration | {What}      | {How}    |
| E2E         | {What}      | {How}    |

## Migration / Deployment

{If this change requires data migration, feature flags, or phased deployment, describe the plan.
If not applicable, indicate "No migration required."}

## Open Questions

- [ ] {Any unresolved technical question}
- [ ] {Any decision requiring team input}
```

## Rules

- ALWAYS read the actual codebase before designing — never assume.
- Every decision MUST have a justification (the "why").
- Include concrete file paths, not abstract descriptions.
- Use the ACTUAL patterns and conventions of the project, not generic best practices.
- If the codebase uses a different pattern than you would recommend, note it but FOLLOW the existing pattern unless the change specifically addresses it.
- Keep ASCII diagrams simple — clarity over aesthetics.
- Apply any `rules.design` from `openspec/config.yaml`.
- If you have open questions that BLOCK the design, state them clearly — do not assume.

- ### Size Budget

  - Your output MUST NOT exceed 800 words. Use tables for architecture decisions.

## Binding Protocol (CRITICAL)

You MUST format your final response payload using the exact markdown keys and structure defined in `skills/_shared/sdd-phase-common.md`. Internal logic must be in English; summaries and reports must be in Spanish.
