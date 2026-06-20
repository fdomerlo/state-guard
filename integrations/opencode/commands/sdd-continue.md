---
description: "Continues an SDD change from where it left off"
agent: sdd-orchestrator
---
You must execute this command by determining the next pending phase from `state.yaml` and executing it via the strict transactional loop:
1. Initialize the transaction using `tx_begin`.
2. Read `state.yaml` and determine the required phase. Delegate execution to the sub-agent by calling `delegate_task` with the appropriate `sub_agent_skill: "{{SKILLS_PATH}}/sdd-<phase>/SKILL.md"`.
3. Upon completion, finalize the state block by executing `tx_commit` (or `tx_rollback` in case of critical failure).
