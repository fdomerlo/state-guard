---
name: sdd-tasks
description: >
  Breaks down a change into an implementation task list.
  Trigger: When the orchestrator launches you to create or update the task breakdown of a change.
license: MIT
metadata:
  author: ctrbts-steve
  version: "3.0"
---

# SDD-Tasks Skill

## Purpose

You are a sub-agent responsible for creating the **TASK BREAKDOWN**. You take the proposal, specs, and design, and produce a `tasks.md` with concrete, actionable implementation steps organized by phases.

## What You Receive

From the orchestrator:

- Change name

## Execution and Persistence Contract

- Read the base conventions referenced in `skills/_shared/persistence-contract.md` before proceeding.

## What to Do

### Step 1: Analyze the Design

From the design document, identify:

- All files that need to be created/modified/deleted
- Dependency order (what must go first)
- Testing requirements per component

### Step 2: Write tasks.md

Create the tasks file:

```text
openspec/changes/{change-name}/
├── proposal.md
├── specs/
├── design.md
└── tasks.md               ← Created by you
```

#### Tasks File Format

```markdown
# Tasks: {Change Title}

## Phase 1: {Phase Name} (e.g., Infrastructure / Foundation)

- [ ] 1.1 {Concrete action — which file, what change}
- [ ] 1.2 {Concrete action}
- [ ] 1.3 {Concrete action}

## Phase 2: {Phase Name} (e.g., Core Implementation)

- [ ] 2.1 {Concrete action}
- [ ] 2.2 {Concrete action}
- [ ] 2.3 {Concrete action}
- [ ] 2.4 {Concrete action}

## Phase 3: {Phase Name} (e.g., Testing / Verification)

- [ ] 3.1 {Write tests for ...}
- [ ] 3.2 {Write tests for ...}
- [ ] 3.3 {Verify integration between ...}

## Phase 4: {Phase Name} (e.g., Cleanup / Documentation)

- [ ] 4.1 {Update docs/comments}
- [ ] 4.2 {Remove temporary code}
```

### Task Writing Rules

Each task MUST be:

| Criterion       | Good Example ✅                                               | Bad Example ❌             |
|-----------------|---------------------------------------------------------------|----------------------------|
| **Specific**    | "Create `internal/auth/middleware.go` with JWT validation"    | "Add auth"                 |
| **Actionable**  | "Add `ValidateToken()` method to `AuthService`"               | "Handle tokens"            |
| **Verifiable**  | "Test: `POST /login` returns 401 without token"               | "Make sure it works"       |
| **Small**       | One file or logical unit of work                              | "Implement the feature"    |

### Phase Organization Guidelines

```text
Phase 1: Foundation / Infrastructure
  └─ New types, interfaces, DB changes, config
  └─ Things other tasks depend on

Phase 2: Core Implementation
  └─ Main logic, business rules, core behavior
  └─ The meat of the change

Phase 3: Integration / Wiring
  └─ Connecting components, routes, UI wiring
  └─ Making it all work together

Phase 4: Testing
  └─ Unit, integration, e2e tests
  └─ Verify against spec scenarios

Phase 5: Cleanup (if necessary)
  └─ Documentation, removing dead code, polish
```

## Rules

- ALWAYS reference concrete file paths in tasks.
- Tasks MUST be ordered by dependency — Phase 1 tasks should not depend on Phase 2 tasks.
- Testing tasks must reference specific spec scenarios.
- Each task should be completable in ONE session (if a task seems too large, split it).
- Use hierarchical numbering: 1.1, 1.2, 2.1, 2.2, etc.
- NEVER include vague tasks like "implement the feature" or "add tests".
- Apply any `rules.tasks` from `openspec/config.yaml`.
- If the project uses TDD, integrate test-first tasks: RED task (write failing test) → GREEN task (make it pass) → REFACTOR task (clean up).

- ### Size Budget

  - Your output MUST NOT exceed 530 words.

## Binding Protocol (CRITICAL)

You MUST format your final response payload using the exact markdown keys and structure defined in `skills/_shared/sdd-phase-common.md`. Internal logic must be in English; summaries and reports must be in Spanish.
