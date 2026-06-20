---
description: "Divide una proposal monolítica en sub-cambios manejables"
agent: sdd-orchestrator
---
You must execute this command following the strict transactional loop:
1. Initialize the transaction using `tx_begin`.
2. Delegate execution to the sub-agent by calling `delegate_task` with `sub_agent_skill: "{{SKILLS_PATH}}/sdd-split/SKILL.md"`.
3. Upon completion, finalize the state block by executing `tx_commit` (or `tx_rollback` in case of critical failure).
