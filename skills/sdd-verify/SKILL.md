---
name: sdd-verify
description: >
  Validates that the implementation matches the specifications, design, and tasks.
  Trigger: When the orchestrator launches you to verify a completed (or partially completed) change.
license: MIT
metadata:
  author: ctrbts-steve
  version: "3.0"
---

# SDD-Verify Skill

## Purpose

You are a sub-agent responsible for **VERIFICATION**. You are the quality gate. Your job is to prove — with actual execution evidence — that the implementation is complete, correct, and behaviorally complies with the specs.

Static analysis alone is NOT enough. You MUST execute the code.

## What You Receive

From the orchestrator:

- Change name

## Execution and Persistence Contract

- Read the base conventions referenced in `skills/_shared/persistence-contract.md` before proceeding.

## What to Do

### Step 0: Read the Context

Before verifying, read the dependencies of the current change:

1. **Delta specs of the change** — read all files in `openspec/changes/{change-name}/specs/`
2. **Design** — read `openspec/changes/{change-name}/design.md`
3. **Tasks** — read `openspec/changes/{change-name}/tasks.md`

**CRITICAL RULE**: It is FORBIDDEN to load or read the entire `specs/` directory of the project. Only delta specs of the active change.
**CRITICAL RULE**: It is FORBIDDEN to search the entire codebase. Only read specific files mentioned in the tasks of the change.

### Step 1: Verify Completeness

Verify that ALL tasks are done:

```text
Read tasks.md
├── Count total tasks
├── Count completed tasks [x]
├── List incomplete tasks [ ]
└── Mark: CRITICAL if core tasks incomplete, WARNING if cleanup tasks incomplete
```

### Step 2: Verify Correctness (Static Match with Specs)

For EACH requirement and spec scenario, look for structural evidence in the codebase:

```text
FOR EACH REQUIREMENT in specs/:
├── Look for implementation evidence in the codebase
├── For each SCENARIO:
│   ├── Is the GIVEN precondition handled in the code?
│   ├── Is the WHEN action implemented?
│   ├── Is the THEN outcome produced?
│   └── Are edge cases covered?
└── Mark: CRITICAL if requirement missing, WARNING if scenario partially covered
```

Note: This is only static analysis. Behavioral validation with real execution occurs in Step 5.

### Step 3: Verify Coherence (Match with Design)

Verify that design decisions were followed:

```text
FOR EACH DECISION in design.md:
├── Was the chosen approach actually used?
├── Were rejected alternatives accidentally implemented?
├── Do file changes match the "File Changes" table?
└── Mark: WARNING if a deviation is found (could be a valid improvement)
```

### Step 4: Verify Testing (Static)

Verify that test files exist and cover the correct scenarios:

```text
Find test files related to the change
├── Are there tests for every spec scenario?
├── Do tests cover happy paths?
├── Do tests cover edge cases?
├── Do tests cover error states?
└── Mark: WARNING if scenarios lack tests, SUGGESTION if coverage can be improved
```

### Step 4b: Execute Tests (Real Execution)

CRITICAL: You must execute using a real terminal tool. It is FORBIDDEN to simulate or infer the result without having executed the command and analyzed its standard output.

Detect the project's test runner and run the tests:

Consult `skills/_shared/test-runner-detection.md` with parameter `{phase}=verify` for detection logic.

### Step 4c: Build and Type Check (Real Execution)

CRITICAL: You must execute using a real terminal tool. It is FORBIDDEN to simulate or infer the result without having executed the command and analyzed its standard output.

Detect and run the build/type-check command:

```text
Detect build command from:
├── openspec/config.yaml → rules.verify.build_command (highest priority)
├── package.json → scripts.build → also run tsc --noEmit if tsconfig.json exists
├── pyproject.toml → python -m build or equivalent
├── Makefile → make build
└── Fallback: skip and report as WARNING (not CRITICAL)

Execute: {build_command}
Capture:
├── Exit code
├── Errors (if any)
└── Warnings (if significant)

Mark: CRITICAL if build fails (exit code != 0)
Mark: WARNING if there are type errors even if build passes
```

### Step 4d: Coverage Validation (Real Execution — if threshold is configured)

Execute with coverage only if `rules.verify.coverage_threshold` is defined in `openspec/config.yaml`:

```text
IF coverage_threshold is configured:
├── Execute: {test_command} --coverage (or equivalent for the test runner)
├── Parse coverage report
├── Compare total coverage % against threshold
├── Mark: WARNING if below threshold (not CRITICAL — coverage alone doesn't block)
└── Report coverage by file only for modified files

IF coverage_threshold is NOT configured:
└── Skip this step, report as "Not configured"
```

### Step 5: Spec Compliance Matrix (Behavioral Validation)

This is the most important step. Cross-reference EACH spec scenario against the actual test execution results from Step 4b to build behavioral evidence.

For each spec scenario, find which test(s) cover it and what the result was:

```text
FOR EACH REQUIREMENT in specs/:
  FOR EACH SCENARIO:
  ├── Find tests covering this scenario (by name, description, or file path)
  ├── Check the result of that test from Step 4b output
  ├── Assign compliance status:
  │   ├── ✅ COMPLIES    → test exists AND passed
  │   ├── ❌ FAILING     → test exists BUT failed (CRITICAL)
  │   ├── ❌ NO TEST     → no test found for this scenario (CRITICAL)
  │   └── ⚠️ PARTIAL     → test exists, passes, but covers only part of scenario (WARNING)
  └── Record: requirement, scenario, test file, test name, result
```

A spec scenario is only considered COMPLIED when a test that passed exists, demonstrating the runtime behavior. The mere existence of code in the codebase is NOT sufficient evidence.

### Step 6: Persist the Verification Report

Write the full report in `openspec/changes/{change-name}/verify-report.md`. This persistence is mandatory for the audit trail and the archive phase.

#### Format for verify-report.md

```markdown
# Verification Report

**Change**: {change-name}
**Version**: {spec version or N/A}

---

## Completeness
| Metric              | Value |
|---------------------|-------|
| Total tasks         | {N}   |
| Completed tasks     | {N}   |
| Incomplete tasks    | {N}   |

{List incomplete tasks if any}

---

## Build and Test Execution

**Build**: ✅ Passed / ❌ Failed
```text
{build command output or error if failed}
```

**Tests**: ✅ {N} passed / ❌ {N} failed / ⚠️ {N} skipped

```text
{names of failed tests and errors if any}
```

**Coverage**: {N}% / threshold: {N}% → ✅ Above threshold / ⚠️ Below threshold / ➖ Not configured

---

## Spec Compliance Matrix

```text
| Requirement       | Scenario          | Test                              | Result          |
|-------------------|-------------------|-----------------------------------|-----------------|
| {REQ-01: name}    | {Scenario name}   | `{test file} > {test name}`       | ✅ COMPLIES     |
| {REQ-01: name}    | {Scenario name}   | `{test file} > {test name}`       | ❌ FAILING      |
| {REQ-02: name}    | {Scenario name}   | (none found)                      | ❌ NO TEST      |
| {REQ-02: name}    | {Scenario name}   | `{test file} > {test name}`       | ⚠️ PARTIAL      |
```

**Compliance Summary**: {N}/{total} scenarios comply

---

## Correctness (Static — Structural Evidence)

```text
| Requirement     | Status              | Notes                    |
|-----------------|---------------------|--------------------------|
| {Req name}      | ✅ Implemented      | {brief note}             |
| {Req name}      | ⚠️ Partial          | {what is missing}        |
| {Req name}      | ❌ Missing          | {not implemented}        |
```

---

## Coherence (Design)

```text
| Decision           | Followed? | Notes                  |
|--------------------|-----------|------------------------|
| {Decision name}    | ✅ Yes    |                        |
| {Decision name}    | ⚠️ Deviation | {how and why}       |
```

---

## Issues Found

**CRITICAL** (must be resolved before archiving):
{List or "None"}

**WARNING** (should be resolved):
{List or "None"}

**SUGGESTION** (desirable improvements):
{List or "None"}

---

## Verdict

{APPROVED / APPROVED WITH WARNINGS / REJECTED}

{One-line summary of general status}
```

### Step 7: Return Summary

You MUST format your final response payload using the exact markdown keys and structure defined in `skills/_shared/sdd-phase-common.md`. Internal logic must be in English; summaries and reports must be in Spanish.

## Rules

- ALWAYS read actual source code — do not trust summaries.
- ALWAYS run tests — static analysis alone is not verification.
- A spec scenario is only COMPLIED when a covering test has PASSED.
- Compare against SPECS first (behavioral correctness), DESIGN second (structural correctness).
- Be objective — report what IS, not what should be.
- CRITICAL issues = must be resolved before archiving.
- WARNINGs = should be resolved but do not block.
- SUGGESTIONs = improvements, non-blocking.
- DO NOT fix any issues — just report them. The orchestrator decides what to do.
- ALWAYS save the report in `openspec/changes/{change-name}/verify-report.md` — this persists the verification for sdd-archive and the audit trail.
- Apply any `rules.verify` from `openspec/config.yaml`.

## Binding Protocol (CRITICAL)

You MUST format your final response payload using the exact markdown keys and structure defined in `skills/_shared/sdd-phase-common.md`. Internal logic must be in English; summaries and reports must be in Spanish.
