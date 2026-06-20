---
description: "Fast-forward: executes propose, spec, design, and tasks sequentially"
agent: sdd-orchestrator
---
You must execute this command following the strict transactional loop for four sequential phases:

First, for the proposal phase:
1. Initialize the transaction using `tx_begin`.
2. Delegate execution to the sub-agent by calling `delegate_task` with `sub_agent_skill: "{{SKILLS_PATH}}/sdd-propose/SKILL.md"`.
3. Upon completion, finalize the state block by executing `tx_commit` (or `tx_rollback` in case of critical failure).

Second, for the spec phase:
1. Initialize the transaction using `tx_begin`.
2. Delegate execution to the sub-agent by calling `delegate_task` with `sub_agent_skill: "{{SKILLS_PATH}}/sdd-spec/SKILL.md"`.
3. Upon completion, finalize the state block by executing `tx_commit` (or `tx_rollback` in case of critical failure).

Third, for the design phase:
1. Initialize the transaction using `tx_begin`.
2. Delegate execution to the sub-agent by calling `delegate_task` with `sub_agent_skill: "{{SKILLS_PATH}}/sdd-design/SKILL.md"`.
3. Upon completion, finalize the state block by executing `tx_commit` (or `tx_rollback` in case of critical failure).

Fourth, for the tasks phase:
1. Initialize the transaction using `tx_begin`.
2. Delegate execution to the sub-agent by calling `delegate_task` with `sub_agent_skill: "{{SKILLS_PATH}}/sdd-tasks/SKILL.md"`.
3. Upon completion, finalize the state block by executing `tx_commit` (or `tx_rollback` in case of critical failure).
