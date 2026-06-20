---
name: sdd-archive
description: >
  Synchronizes delta specs with main specs and archives a completed change.
  Trigger: When the orchestrator launches you to archive a change after implementation and verification.
license: MIT
metadata:
  author: ctrbts-steve
  version: "3.0"
---

# SDD-Archive Skill

## Purpose

You are a sub-agent responsible for **ARCHIVING**. You merge the delta specs into the main specs (source of truth), and then move the change folder to the archive. You complete the SDD cycle.

## What You Receive

From the orchestrator:

- Change name

## Execution and Persistence Contract

- Read the base conventions referenced in `skills/_shared/persistence-contract.md` before proceeding.

## What to Do

### Step 0: Check Previous Blockers

Explicitly verify in the change directory if the files `review-report.md` or `verify-report.md` contain reports classified or concluded as **CRITICAL**. If they do, **ABORT IMMEDIATELY** the execution of this skill by notifying the orchestrator. You can only archive a specification that is functional and validated according to its completeness.

### Step 1: Verify Git Status Before Archiving

Before syncing specs and moving to archive, verify the state of the git repository:

```bash
# Function to verify git status before archiving
verify_git_clean_for_change() {
    local repo_root="${1:-.}"

    # Verify if it is a git repository
    if [ ! -d "$repo_root/.git" ]; then
        echo "INFO: No git repository detected, skipping verification"
        return 0
    fi

    # Verify if git is available
    if ! command -v git &> /dev/null; then
        echo "WARN: git not available, skipping verification"
        return 0
    fi

    # Get uncommitted changes (porcelain format)
    local status
    status=$(cd "$repo_root" && git status --porcelain 2>/dev/null || echo "")

    if [ -z "$status" ]; then
        # No changes, all clean
        return 0
    fi

    if [ -n "$status" ]; then
        echo "ERROR: Uncommitted changes detected in repository:"
        echo "$status"
        echo ""
        echo "Please commit your changes before archiving."
        return 1
    fi

    return 0
}
```

**Usage in flow:**

- Call `verify_git_clean_for_change "$repo_root"` before proceeding with spec synchronization.
- If it returns 1 (error), BLOCK the archiving and display the error message.
- If it returns 0, continue normally.

**Handled cases:**

- Repository without git (no `.git/`) → continues without verification
- Git not available in PATH → continues with warning
- ANY uncommitted change in the repository → BLOCKS

### Step 2: Synchronize Delta Specs with Main Specs

For each delta spec in `openspec/changes/{change-name}/specs/`:

#### If Main Spec Exists (`openspec/specs/{domain}/spec.md`)

Read the existing main spec and apply the delta:

```text
FOR EACH SECTION in delta spec:
├── ADDED Requirements → Add to the Requirements section of the main spec
├── MODIFIED Requirements → Replace the matching requirement in the main spec
└── DELETED Requirements → Delete the matching requirement from the main spec
```

**Merge carefully:**

- Match requirements by name (e.g., "### Requirement: Session Expiration")
- Preserve ALL OTHER requirements that are not in the delta
- Maintain correct Markdown formatting and heading hierarchy

#### If Main Spec DOES NOT Exist

The delta spec IS a full spec (not a delta). Copy it directly:

```bash
# Copy new spec to main specs
openspec/changes/{change-name}/specs/{domain}/spec.md
  → openspec/specs/{domain}/spec.md
```

### Step 3: Move to Archive

Move the entire change folder to the archive with a date prefix:

```text
openspec/changes/{change-name}/
  → openspec/changes/archive/YYYY-MM-DD-{change-name}/
```

Use today's date in ISO format (e.g., `2026-02-16`).

### Step 4: Verify the Archive

Confirm:

- [ ] Main specs updated correctly
- [ ] Change folder moved to archive
- [ ] Archive contains all artifacts (proposal, specs, design, tasks)
- [ ] Active changes directory no longer has this change

## Rules

- NEVER archive if `review-report.md` OR `verify-report.md` contain CRITICAL issues. Both files must be checked if they exist.
- ALWAYS verify git status BEFORE syncing specs (see Step 1).
- If git verification detects ANY uncommitted changes in the repository, BLOCK archiving.
- ALWAYS synchronize delta specs BEFORE moving to archive.
- When merging into existing specs, PRESERVE requirements not mentioned in the delta.
- Use ISO date format (YYYY-MM-DD) as the archive folder prefix.
- If the merge would be destructive (deleting large sections), WARN the orchestrator and ask for confirmation.
- The archive is an AUDIT TRAIL — never delete or modify archived changes.
- If `openspec/changes/archive/` does not exist, create it.
- Apply any `rules.archive` from `openspec/config.yaml`.

## Binding Protocol (CRITICAL)

You MUST format your final response payload using the exact markdown keys and structure defined in `skills/_shared/sdd-phase-common.md`. Internal logic must be in English; summaries and reports must be in Spanish.
