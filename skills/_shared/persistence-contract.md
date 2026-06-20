# CORE PERSISTENCE & EXECUTION CONTRACT

## 1. PRIMARY DISK PERSISTENCE LAYER
This framework treats the host filesystem as its single, absolute source of truth. All structural read and write sequences targeting artifacts must execute strictly within the boundaries of the `openspec/` root directory, abiding by the conventions mapped out in `openspec-convention.md`.

## 2. CONTEXTUAL BOUNDARIES FOR DELEGATED SKILLS
Specialized sub-agents always spin up with a clean memory context and have zero visibility into the historical message ledger of the main orchestrator session.
- **ORCHESTRATOR COMPLIANCE:** You are strictly bound to provide only the explicit paths and context records that you pull from the local directory ledger. Do not pass unrestricted environment blocks.
- **SUB-AGENT COMPLIANCE:** Sub-agents must read past phase outputs (`explore`, `proposal`, `spec`, `design`, `tasks`) as dependencies using the precise relative paths injected by the orchestrator. They bear sole responsibility for writing their phase outputs directly to disk.

## 3. DATA PERSISTENCE RESPONSIBILITY MATRIX

| Operation Block | File Read Authority | File Write Authority |
|---|---|---|
| Dependency-Driven Phase | Sub-agent loads upstream files directly. | Sub-agent commits output artifact to disk. |
| Independent Phase (e.g., Explore) | None. | Sub-agent commits artifact to disk if generated. |
| Transaction Phase Transition | None. | Orchestrator commits updated `state.yaml`. |

## 4. COMMUNICATIONS PROTOCOL PACKAGING (Orchestrator → Sub-Agent)
When invoking a sub-agent execution block, you must structure the initialization payload using this exact text block format:
```text
Load and analyze these specific tracking artifacts before beginning execution:
- {Injected relative file paths for each required dependency}
IF a domain glossary exists at openspec/config.yaml, you must load it and enforce strict terminology consistency.
Upon task completion, persist your resulting artifact following the explicit definitions in openspec-convention.md.
```

## 5. REVERSIBILITY AND VERBOSITY CONTROL (`detail_level`)

The orchestrator may pass an operational parameter defined as `detail_level: concise | standard | deep`. This variable controls the verbosidad of the summary outputs printed to the chat interface. It has **zero** effect on filesystem persistence; sub-agents must always generate and write the complete technical artifact to disk regardless of this setting.

## 6. PROJECT DOMAIN GLOSSARY ENFORCEMENT & GRACEFUL DEGRADATION

Every spawned skill context must process project terms using these guidelines at launch:

1. Attempt to parse `openspec/config.yaml` searching for the root `glossary:` key.
2. If found, load the key-value dictionary and map synonyms to the canon definitions provided, ensuring perfect semantic cohesion across `proposal.md`, `specs/`, and `design.md`.
3. **GRACEFUL DEGRADATION PATTERN:** If `openspec/config.yaml` is absent, or if the `glossary:` section is blank, missing, or structurally corrupted, the sub-agent must suppress errors, bypass the lookup sequence gracefully, and proceed with standard generation without halting execution.
