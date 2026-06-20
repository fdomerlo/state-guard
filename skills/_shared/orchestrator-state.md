# ORCHESTRATOR STATE & TRANSACTION PROTOCOL

## 1. PURPOSE
This contract enforces strict state management and fault tolerance across agent invocations using a pseudo-ACID transaction lifecycle. The orchestrator must record state changes *before* and *after* delegating execution to sub-agents to prevent data corruption or missing history during environment crashes.

## 2. STATE STORAGE SPECIFICATION
The execution state must be persisted in `.agentify/state.yaml` using the following exact structure:

```yaml
current_phase: "sdd-phase-name" # e.g., sdd-spec, sdd-design
transaction:
  id: "tx_uuid_or_timestamp"
  status: "idle" # idle | in_progress | committed | failed
  started_at: "timestamp"
  updated_at: "timestamp"
  sub_agent: "efhemeral-agent-name"
artifacts:
  - path: "relative/path/to/file"
    checksum: "sha256_hash_or_none"
    status: "pending" # pending | written | verified

```

## 3. TRANSACTION LIFECYCLE PROTOCOL

### Phase 1: TRANSACTION_BEGIN (Pre-Delegation)

Before spawning any sub-agent or issuing an external tool call:

1. Read the current `.agentify/state.yaml`.
2. Verify that `transaction.status` is `idle` or `committed`.
3. Update `transaction.status` to `in_progress`.
4. Set `transaction.started_at` to the current timestamp.
5. Define the target paths in the `artifacts` list and set their status to `pending`.
6. Flush the `state.yaml` changes to disk using the appropriate file utility.

### Phase 2: DELEGATION & TRACKING

1. Invoke the sub-agent passing only the narrow context required for its specific task.
2. Monitor the tool execution. The main orchestrator must not modify any target codebase files during this phase.

### Phase 3: TRANSACTION_COMMIT (Post-Success)

Upon successful return from the sub-agent:

1. Verify the existence and non-emptiness of all files listed in the `artifacts` array.
2. Calculate and update the `checksum` for each generated artifact.
3. Set the artifact status to `verified`.
4. Update `transaction.status` to `committed`.
5. Update `transaction.updated_at`.
6. Flush `state.yaml` to disk.

### Phase 4: TRANSACTION_ROLLBACK (On Failure)

If the sub-agent fails, returns an error, or a system timeout occurs:

1. Set `transaction.status` to `failed`.
2. For each artifact in the `artifacts` list with a status of `pending` or `written` (but unverified):
* Delete the partial or corrupted file from disk to prevent invalid state leakage.


3. Revert `current_phase` to the last known stable checkpoint if applicable.
4. Update `transaction.updated_at` and flush `state.yaml` to disk.

## 4. CRITICAL RECOVERY PROTOCOL (On Boot / Resume)

Every time the orchestrator initializes a new session, it MUST parse `.agentify/state.yaml` before accepting user input:

* **IF** `transaction.status` is `committed` or `idle`: Proceed normally.
* **IF** `transaction.status` is `in_progress`: An unhandled crash or connection drop occurred mid-execution. Trigger an automatic **ROLLBACK** sequence immediately to clean the workspace before letting the user retry.

## 5. USER INTERACTION BOUNDARY (LOCALIZATION)

* **INTERNAL LOGIC:** All internal reasoning steps (`Thought`), file parsing, state keys, and tool payloads MUST be evaluated in English to optimize token utilization and constraint adherence.
* **USER OUTPUT:** All messages, progress updates, error explanations, and interactive choices presented to the developer MUST be written strictly in Spanish.
