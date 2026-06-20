# AUTOMATED TEST RUNNER DETECTION ENGINE

## 1. PURPOSE
This core utility module exposes the shared heuristic sequence utilized by operational skills to auto-detect and call the target project's active test runner utility during execution gates.

## 2. INTERPRETATION PSEUDOCODE FLOW
The detection logic must evaluate the system workspace matching patterns in the following strict hierarchical sequence:
1. Check `openspec/config.yaml` → Read `rules.{active_phase}.test_command` (Absolute priority ceiling).
2. Inspect root `package.json` → Search for `scripts.test` presence.
3. Inspect root workspace for Python configurations → Check `pyproject.toml` or `pytest.ini` keys to invoke `pytest`.
4. Inspect root workspace for build automations → Search for `Makefile` presence to call `make test`.
5. **FALLBACK RULE:** If all directory matches fail, abort auto-execution, halt phase progression, and log an issue to the orchestrator indicating that tests must be validated manually by the developer.

## 3. REUSE CORE MAPPINGS
- **Within `sdd-apply` implementation:** Bind system triggers to the `rules.apply.test_command` configuration node.
- **Within `sdd-verify` implementation:** Bind verification gating hooks to the `rules.verify.test_command` configuration node.
