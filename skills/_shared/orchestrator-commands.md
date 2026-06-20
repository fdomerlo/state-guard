# ORCHESTRATOR COMMANDS AND LIFECYCLE HOOKS

## 1. STATE INTERACTION COMMANDS

### `get_state`
- **Purpose:** Retrieves the current system state and transaction ledger from `.agentify/state.yaml`.
- **Usage Constraints:** Must be run during initialization and immediately prior to checking phase transition requirements.

### `update_state`
- **Purpose:** Flushes changes to `.agentify/state.yaml`.
- **Payload Requirements:** Requires a valid YAML/JSON payload mapping exactly to the schema specified in `orchestrator-state.md`.

## 2. TRANSACTIONAL LIFECYCLE UTILITIES

### `tx_begin`
- **Purpose:** Initiates an atomic transaction block.
- **Internal Actions:**
  1. Verifies current state is not locked (`status != "in_progress"`).
  2. Sets `transaction.status = "in_progress"`.
  3. Records `started_at` timestamp.
  4. Appends expected target outputs into the tracking array with a `"pending"` status.

### `tx_commit`
- **Purpose:** Finalizes the active transaction after successful sub-agent completion.
- **Internal Actions:**
  1. Scans workspace to verify the exact existence of files declared in the artifacts ledger.
  2. Generates cryptographic checksums for verified files.
  3. Sets `transaction.status = "committed"`.
  4. Cleanses volatile execution memory buffers.

### `tx_rollback`
- **Purpose:** Emergency cleanup utility to revert workspace to the last known stable state.
- **Internal Actions:**
  1. Sets `transaction.status = "failed"`.
  2. Purges any unverified or partial files from the filesystem listed under the active transaction artifacts.
  3. Resets execution pointers to the last committed state block.

## 3. DELEGATION ENGINE

### `delegate_task`
- **Purpose:** Spawns an ephemeral sub-agent shell execution context.
- **Parameters:**
  - `sub_agent_skill`: Path to the targeted `SKILL.md` (e.g., `skills/sdd-spec/SKILL.md`).
  - `context_payload`: Restricted subset of data/files required for execution.
- **Constraint:** This command is strictly blocked if `transaction.status` is not set to `"in_progress"`.
