import subprocess
import sys
import os
import configparser
from concurrent.futures import ThreadPoolExecutor

CHANGE = "test-change"
SCRIPT = os.path.join(os.path.dirname(__file__), "scripts", "state_manager.py")
STATE_PATH = f".agentify/changes/{CHANGE}/state.ini"


def run(args):
    result = subprocess.run(
        [sys.executable, SCRIPT] + args,
        cwd=os.path.dirname(__file__),
        capture_output=True,
        text=True,
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def reset_state():
    with open(STATE_PATH, "w") as f:
        f.write(
            "[Metadata]\nlast_updated = 2026-07-02T10:00:00\n\n"
            "[Transaction]\ntxn_status = idle\ntxn_phase = None\ntxn_started_at = None\n\n"
            "[Graph]\ncurrent_phase = propose\nlock_phase = spec\n"
            "completed_phases = explore, propose\n"
            "pending_phases = spec, design, tasks, apply, verify, archive\n"
        )
    for f in [".lock", ".write-lock"]:
        p = os.path.join(os.path.dirname(__file__), f".agentify/changes/{CHANGE}/{f}")
        if os.path.exists(p):
            os.remove(p)


print("=" * 60)
print("TEST 1: dos BEGIN simultáneos, mismo --change")
print("=" * 60)
reset_state()
with ThreadPoolExecutor(max_workers=2) as ex:
    futures = [
        ex.submit(run, ["begin", "--change", CHANGE, "--phase", "spec"]),
        ex.submit(run, ["begin", "--change", CHANGE, "--phase", "spec"]),
    ]
    results = [f.result() for f in futures]

for i, (rc, out, err) in enumerate(results):
    print(f"  proceso {i}: rc={rc} stdout={out!r} stderr={err!r}")

successes = [r for r in results if "SUCCESS" in r[1]]
errors = [r for r in results if "ERROR" in r[1]]
print(f"  -> {len(successes)} éxito(s), {len(errors)} rechazo(s)")
assert len(successes) == 1, "FALLO: debería ganar exactamente uno de los dos BEGIN"
assert len(errors) == 1, "FALLO: el otro debería ser rechazado con ERROR"
print("  PASS: exactamente un BEGIN ganó, el otro fue rechazado correctamente.\n")


print("=" * 60)
print("TEST 2: COMMIT + CHECKPOINT simultáneos (mismo momento, campos distintos)")
print("=" * 60)
# ya tenemos una transacción in_progress del BEGIN ganador del test 1
with ThreadPoolExecutor(max_workers=2) as ex:
    futures = [
        ex.submit(run, ["commit", "--change", CHANGE, "--next-phase", "design"]),
        ex.submit(run, ["checkpoint", "--change", CHANGE, "--summary", "checkpoint concurrente de prueba"]),
    ]
    results = [f.result() for f in futures]

for i, (rc, out, err) in enumerate(results):
    label = "commit" if i == 0 else "checkpoint"
    print(f"  {label}: rc={rc} stdout={out!r} stderr={err!r}")

config = configparser.ConfigParser()
config.read(os.path.join(os.path.dirname(__file__), STATE_PATH))
print("\n  Estado final del state.ini:")
for section in config.sections():
    for k, v in config.items(section):
        print(f"    [{section}] {k} = {v}")

lock_phase = config.get("Graph", "lock_phase", fallback=None)
has_summary = config.has_option("Session", "session_summary")
print(f"\n  lock_phase == 'design': {lock_phase == 'design'}")
print(f"  session_summary presente: {has_summary}")
assert lock_phase == "design", "FALLO: el commit se perdió (lost update)"
assert has_summary, "FALLO: el checkpoint se perdió (lost update)"
print("  PASS: ambas escrituras sobrevivieron, no hubo lost-update.\n")

print("=" * 60)
print("TEST 3: COMMIT con transición inválida (fuera del DAG)")
print("=" * 60)
run(["begin", "--change", CHANGE, "--phase", "design"])
rc, out, err = run(["commit", "--change", CHANGE, "--next-phase", "apply"])
print(f"  rc={rc} stdout={out!r}")
assert "Transición inválida" in out, "FALLO: debería rechazar apply después de design (debe ser tasks)"
print("  PASS: transición fuera del DAG fue rechazada por el código, no confiada al prompt.\n")

print("TODOS LOS TESTS PASARON")
