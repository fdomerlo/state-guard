#!/usr/bin/env python3
"""
sg — State Guard CLI
====================
Wrapper de alto nivel sobre state_manager.py. JSON puro en stdout siempre.
El LLM solo puede invocar los comandos que el servidor MCP (Fase C) expone
como tools — plan-approve y hotfix-init NO son tools MCP, son comandos
exclusivamente humanos.

Regla de oro: sg.py no duplica lógica de negocio. Delega todo a state_manager.py.
"""
import argparse
import configparser
import json
import os
import subprocess
import sys
from pathlib import Path

# ─── Resolución del entorno ──────────────────────────────────────────────────

def _find_repo_root():
    cwd = Path.cwd()
    for parent in [cwd, *cwd.parents]:
        if (parent / ".state-guard").exists() or (parent / ".git").exists():
            return parent
    return cwd


REPO_ROOT = _find_repo_root()
SCRIPT_DIR = Path(__file__).parent
STATE_MANAGER = SCRIPT_DIR / "state_manager.py"
SG_DIR = REPO_ROOT / ".state-guard"
CHANGES_DIR = SG_DIR / "changes"


# ─── Helpers ─────────────────────────────────────────────────────────────────

def _call_sm(args_list, check_json=False):
    """Llama a state_manager.py y retorna (returncode, parsed_or_raw, stderr)."""
    result = subprocess.run(
        [sys.executable, str(STATE_MANAGER)] + args_list,
        cwd=str(REPO_ROOT),
        capture_output=True,
        text=True,
    )
    raw = result.stdout.strip()
    err = result.stderr.strip()

    if check_json:
        try:
            return result.returncode, json.loads(raw), err
        except json.JSONDecodeError:
            return result.returncode, {"raw": raw, "stderr": err}, err
    return result.returncode, raw, err


def _emit(obj, exit_code=0):
    """Emite JSON en stdout y sale con el código dado."""
    print(json.dumps(obj, ensure_ascii=False, indent=2))
    sys.exit(exit_code)


def _active_change():
    if not CHANGES_DIR.exists():
        return None
    for entry in sorted(CHANGES_DIR.iterdir()):
        if entry.is_dir() and entry.name != "archive":
            state_file = entry / "state.ini"
            if state_file.exists():
                return entry.name
    return None


# ─── Comandos sg ──────────────────────────────────────────────────────────────

def cmd_status(args):
    rc, obj, err = _call_sm(["status", "--change", args.change, "--json"],
                             check_json=True)
    _emit({"ok": rc == 0, "change": args.change, "state": obj}, rc)


def cmd_begin(args):
    rc, raw, err = _call_sm(["begin", "--change", args.change, "--phase", args.phase])
    ok = rc == 0 and "SUCCESS" in raw
    _emit({
        "ok": ok,
        "change": args.change,
        "phase": args.phase,
        "message": raw,
        "stderr": err or None,
    }, rc)


def cmd_commit(args):
    rc, raw, err = _call_sm(["commit", "--change", args.change,
                              "--next-phase", args.next_phase])
    ok = rc == 0 and "SUCCESS" in raw
    _emit({
        "ok": ok,
        "change": args.change,
        "next_phase": args.next_phase,
        "message": raw,
        "stderr": err or None,
    }, rc)


def cmd_rollback(args):
    rc, raw, err = _call_sm(["rollback", "--change", args.change])
    ok = rc == 0 and "SUCCESS" in raw
    _emit({
        "ok": ok,
        "change": args.change,
        "message": raw,
        "stderr": err or None,
    }, rc)


def cmd_checkpoint(args):
    rc, raw, err = _call_sm(["checkpoint", "--change", args.change,
                              "--summary", args.summary])
    ok = rc == 0 and "SUCCESS" in raw
    _emit({
        "ok": ok,
        "change": args.change,
        "message": raw,
        "stderr": err or None,
    }, rc)


def cmd_check_completion(args):
    rc, obj, _ = _call_sm(["check-completion", "--change", args.change, "--json"],
                           check_json=True)
    _emit({"ok": rc == 0, "change": args.change, **obj}, rc)


def cmd_mark_task(args):
    rc, obj, _ = _call_sm(["mark-task", "--change", args.change,
                            "--task-id", args.task_id], check_json=True)
    _emit({"ok": rc == 0, **obj}, rc)


def cmd_next_task(args):
    rc, obj, _ = _call_sm(["next-task", "--change", args.change], check_json=True)
    _emit({"ok": rc == 0, **obj}, rc)


def cmd_verify_gate(args):
    rc, obj, _ = _call_sm(["verify-gate", "--change", args.change,
                            "--phase", args.phase], check_json=True)
    _emit({"ok": rc == 0, **obj}, rc)


def cmd_migrate(args):
    rc, obj, _ = _call_sm(["migrate", "--change", args.change], check_json=True)
    _emit({"ok": rc == 0, **obj}, rc)


def cmd_init_change(args):
    change_dir = CHANGES_DIR / args.change
    state_file = change_dir / "state.ini"

    if state_file.exists():
        _emit({
            "ok": False,
            "message": f"El change '{args.change}' ya existe.",
        }, 1)

    change_dir.mkdir(parents=True, exist_ok=True)
    with open(state_file, "w", encoding="utf-8") as f:
        f.write(
            "[Metadata]\n"
            "last_updated = \n"
            "schema_version = 2\n\n"
            "[Transaction]\n"
            "txn_status = idle\n"
            "txn_phase = None\n"
            "txn_started_at = None\n\n"
            "[Graph]\n"
            "current_phase = none\n"
            "lock_phase = plan\n"
            "completed_phases = \n"
            "pending_phases = plan, execute, verify\n"
        )
    _emit({
        "ok": True,
        "change": args.change,
        "state_file": str(state_file),
        "message": f"Change '{args.change}' inicializado. lock_phase=plan",
    })


def cmd_list_changes(args):
    if not CHANGES_DIR.exists():
        _emit({"ok": True, "changes": []})

    changes = []
    for entry in sorted(CHANGES_DIR.iterdir()):
        if entry.is_dir() and entry.name != "archive":
            state_file = entry / "state.ini"
            if state_file.exists():
                cfg = configparser.ConfigParser()
                cfg.read(state_file)
                changes.append({
                    "name": entry.name,
                    "lock_phase": cfg.get("Graph", "lock_phase", fallback="?"),
                    "txn_status": cfg.get("Transaction", "txn_status", fallback="?"),
                    "schema_version": cfg.get("Metadata", "schema_version", fallback="1"),
                })

    _emit({"ok": True, "changes": changes})


# ─── Instalación de git hooks ─────────────────────────────────────────────────

HOOK_TEMPLATE = """\
#!/bin/sh
# State Guard git hook: {hook_name}
# Instalado por: sg install-hooks

SG_BIN="$(dirname "$0")/../../scripts/sg.py"
if [ ! -f "$SG_BIN" ]; then
    SG_BIN="scripts/sg.py"
fi

CHANGE=$(python3 "$SG_BIN" list-changes 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
changes = data.get('changes', [])
if changes:
    print(changes[0]['name'])
" 2>/dev/null)

if [ -z "$CHANGE" ]; then
    exit 0
fi

python3 "$SG_BIN" {hook_action} --change "$CHANGE"
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
    echo "State Guard: hook {hook_name} falló (exit $EXIT_CODE)."
    exit $EXIT_CODE
fi
exit 0
"""


def cmd_install_hooks(args):
    git_dir = REPO_ROOT / ".git"
    if not git_dir.exists():
        _emit({"ok": False, "message": "No se encontró .git/ en la raíz del repo."}, 1)

    hooks_dir = git_dir / "hooks"
    hooks_dir.mkdir(exist_ok=True)

    installed = []
    hook_defs = [("post-commit", "status")]

    for hook_name, hook_action in hook_defs:
        hook_path = hooks_dir / hook_name
        content = HOOK_TEMPLATE.format(hook_name=hook_name, hook_action=hook_action)
        if hook_path.exists() and not args.force:
            _emit({
                "ok": False,
                "message": f"El hook '{hook_name}' ya existe. Usá --force para sobreescribir.",
            }, 1)
        with open(hook_path, "w") as f:
            f.write(content)
        os.chmod(hook_path, 0o755)
        installed.append(str(hook_path))

    _emit({
        "ok": True,
        "installed_hooks": installed,
        "message": "Hooks instalados.",
    })


# ---- Gate de aprobacion humana out-of-band (2 pasos) -------------------------
#
# El gate de aprobacion (plan-approve / hotfix-init) genera un token aleatorio y
# lo escribe UNICAMENTE a un archivo fuera del working directory del agente:
# ~/.state-guard-gate/<change>.token.
# NO se imprime el token en stdout ni stderr de la sesion donde corre el agente.
#
# El humano confirma en un segundo paso independiente ejecutando en su propia shell:
# sg plan-confirm --change X (o sg hotfix-confirm --change X).
# Este comando consume el token del archivo y efectua la aprobacion/inicializacion.
#
# Por que esto funciona contra auto-aprobacion accidental (modelo single-user):
#
#   1. Aislamiento de path: Ningun comando del agente (sg.py o state_manager.py)
#      puede leer ni aceptar paths fuera de .state-guard/changes/ o .state-guard/specs/.
#      Por diseno, el agente no tiene tools para inspeccionar ~/.state-guard-gate/.
#
#   2. Asincronicidad y 2 pasos: plan-approve prepara el token pero no bloquea
#      ni muta el estado de aprobacion en state.ini. El agente detiene su ciclo
#      y reporta al usuario que debe confirmar en su propia terminal.
#
#   3. Capa arquitectonica (Fase C): el servidor MCP NO expone los comandos de
#      gate (plan-approve, plan-confirm, hotfix-init, hotfix-confirm) como tools.


def _prepare_gate_token(change, gate_type, **extra_data):
    """Genera token, muestra en /dev/tty y guarda SOLO EL HASH en ~/.state-guard-gate/<change>.token."""
    import secrets
    import hashlib
    from datetime import datetime

    gate_dir = Path.home() / ".state-guard-gate"
    gate_dir.mkdir(parents=True, exist_ok=True)
    token_file = gate_dir / f"{change}.token"

    token = secrets.token_hex(4).upper()
    token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()

    try:
        with open("/dev/tty", "w", encoding="utf-8") as tty:
            tty.write(f"\n[STATE-GUARD GATE] Codigo de confirmacion para '{change}': {token}\n\n")
            tty.flush()
    except OSError:
        if token_file.exists():
            try:
                token_file.unlink()
            except Exception:
                pass
        _emit({
            "ok": False,
            "error": "NO_TTY",
            "message": "No se pudo mostrar el token: no hay terminal de control disponible. Este gate requiere ejecutarse desde una sesion con TTY real."
        }, 1)

    gate_data = {
        "token_hash": token_hash,
        "type": gate_type,
        "change": change,
        "created_at": datetime.now().isoformat(),
        **extra_data
    }
    with open(token_file, "w", encoding="utf-8") as f:
        json.dump(gate_data, f, indent=2)

    try:
        os.chmod(token_file, 0o600)
    except Exception:
        pass

    return token_file


def cmd_plan_approve(args):
    """Paso 1 del gate de aprobacion: prepara token out-of-band en ~/.state-guard-gate/."""
    change = args.change
    token_file = _prepare_gate_token(change, "plan")

    print("")
    print(f"  [GATE PREPARADO] Token de aprobacion generado para el change '{change}'.")
    print(f"  El codigo de confirmacion fue mostrado en tu terminal (/dev/tty).")
    print(f"  Archivo out-of-band (contiene solo el hash): {token_file}")
    print(f"  Para confirmar la aprobacion, abri una terminal separada y ejecuta:")
    print(f"    sg plan-confirm --change {change} --token <CODIGO>")
    print("")

    _emit({
        "ok": True,
        "change": change,
        "gate_prepared": True,
        "token_file": str(token_file),
        "message": f"Gate preparado en {token_file}. Ejecuta 'sg plan-confirm --change {change} --token <CODIGO>' en terminal humana para confirmar."
    })


def cmd_plan_confirm(args):
    """Paso 2 del gate de aprobacion: verifica hash de token y aprueba el plan."""
    import hashlib
    import hmac

    change = args.change
    gate_dir = Path.home() / ".state-guard-gate"
    token_file = gate_dir / f"{change}.token"

    if not token_file.exists():
        _emit({
            "ok": False,
            "error": "NO_PENDING_GATE",
            "message": f"No hay un gate pendiente de confirmacion para '{change}' ({token_file} no encontrado). Ejecuta primero 'sg plan-approve --change {change}'."
        }, 1)

    try:
        with open(token_file, "r", encoding="utf-8") as f:
            gate_data = json.load(f)
    except Exception:
        _emit({"ok": False, "error": "CORRUPT_TOKEN_FILE", "message": "El archivo de token esta corrupto."}, 1)

    if gate_data.get("type") != "plan":
        _emit({
            "ok": False,
            "error": "GATE_TYPE_MISMATCH",
            "message": f"El token en {token_file} es de tipo '{gate_data.get('type')}', no 'plan'."
        }, 1)

    stored_hash = gate_data.get("token_hash", "")
    received_hash = hashlib.sha256(args.token.strip().upper().encode("utf-8")).hexdigest()

    if not hmac.compare_digest(stored_hash, received_hash):
        _emit({
            "ok": False,
            "error": "WRONG_TOKEN",
            "message": "El token de confirmacion es incorrecto. Intenta nuevamente con el token correcto."
        }, 5)

    # Consumir el archivo de token
    token_file.unlink()

    rc, obj, err = _call_sm(
        ["plan-approve", "--change", change, "--approved-by", "human"],
        check_json=True,
    )
    if rc == 0:
        print("")
        print(f"  Plan aprobado para '{change}'. Proximo paso:")
        print(f"    sg begin --change {change} --phase execute")
        print("")
    _emit({"ok": rc == 0, **obj}, rc)


def cmd_hotfix_init(args):
    """Paso 1 del hotfix bypass: prepara token out-of-band con razon en ~/.state-guard-gate/."""
    change = args.change
    reason = args.reason

    change_dir = CHANGES_DIR / change
    if (change_dir / "state.ini").exists():
        _emit({
            "ok": False,
            "message": f"El change '{change}' ya existe.",
        }, 1)

    token_file = _prepare_gate_token(change, "hotfix", reason=reason)

    print("")
    print(f"  [HOTFIX PREPARADO] Token de bypass generado para el change '{change}'.")
    print(f"  Razon registrada: {reason}")
    print(f"  El codigo de confirmacion fue mostrado en tu terminal (/dev/tty).")
    print(f"  Archivo out-of-band (contiene solo el hash): {token_file}")
    print(f"  Para confirmar e inicializar el hotfix, abri una terminal separada y ejecuta:")
    print(f"    sg hotfix-confirm --change {change} --token <CODIGO>")
    print("")

    _emit({
        "ok": True,
        "change": change,
        "hotfix_prepared": True,
        "reason": reason,
        "token_file": str(token_file),
        "message": f"Hotfix preparado en {token_file}. Ejecuta 'sg hotfix-confirm --change {change} --token <CODIGO>' en terminal humana para confirmar."
    })


def cmd_hotfix_confirm(args):
    """Paso 2 del hotfix bypass: verifica hash de token e inicializa el change."""
    import hashlib
    import hmac

    change = args.change
    gate_dir = Path.home() / ".state-guard-gate"
    token_file = gate_dir / f"{change}.token"

    if not token_file.exists():
        _emit({
            "ok": False,
            "error": "NO_PENDING_GATE",
            "message": f"No hay un hotfix pendiente de confirmacion para '{change}' ({token_file} no encontrado). Ejecuta primero 'sg hotfix-init --change {change} --reason \"...\"'."
        }, 1)

    try:
        with open(token_file, "r", encoding="utf-8") as f:
            gate_data = json.load(f)
    except Exception:
        _emit({"ok": False, "error": "CORRUPT_TOKEN_FILE", "message": "El archivo de token esta corrupto."}, 1)

    if gate_data.get("type") != "hotfix":
        _emit({
            "ok": False,
            "error": "GATE_TYPE_MISMATCH",
            "message": f"El token en {token_file} es de tipo '{gate_data.get('type')}', no 'hotfix'."
        }, 1)

    stored_hash = gate_data.get("token_hash", "")
    received_hash = hashlib.sha256(args.token.strip().upper().encode("utf-8")).hexdigest()

    if not hmac.compare_digest(stored_hash, received_hash):
        _emit({
            "ok": False,
            "error": "WRONG_TOKEN",
            "message": "El token de confirmacion es incorrecto. Intenta nuevamente con el token correcto."
        }, 5)

    reason = gate_data.get("reason", "sin razon")

    change_dir = CHANGES_DIR / change
    state_file = change_dir / "state.ini"
    if state_file.exists():
        _emit({"ok": False, "message": f"El change '{change}' ya existe."}, 1)

    # Consumir el token
    token_file.unlink()

    change_dir.mkdir(parents=True, exist_ok=True)
    with open(state_file, "w", encoding="utf-8") as f:
        f.write(
            "[Metadata]\n"
            "last_updated = \n"
            "schema_version = 2\n\n"
            "[Transaction]\n"
            "txn_status = idle\n"
            "txn_phase = None\n"
            "txn_started_at = None\n\n"
            "[Graph]\n"
            "current_phase = none\n"
            "lock_phase = plan\n"
            "completed_phases = \n"
            "pending_phases = plan, execute, verify\n"
        )

    rc, obj, err = _call_sm(
        ["plan-approve", "--change", change,
         "--approved-by", "hotfix-init",
         "--bypass-reason", reason],
        check_json=True,
    )
    if rc != 0:
        _emit({"ok": False, "error": "PLAN_APPROVE_FAILED", **obj}, rc)

    rc2, raw2, _ = _call_sm(["begin", "--change", change, "--phase", "plan"])
    if rc2 != 0:
        _emit({"ok": False, "error": "BEGIN_FAILED", "message": raw2}, rc2)

    rc3, raw3, _ = _call_sm(["commit", "--change", change, "--next-phase", "execute"])
    if rc3 != 0:
        _emit({"ok": False, "error": "COMMIT_FAILED", "message": raw3}, rc3)

    print(f"  Hotfix '{change}' confirmado e inicializado. lock_phase=execute")
    print(f"  Proximo paso: sg begin --change {change} --phase execute")
    print()
    _emit({
        "ok": True,
        "change": change,
        "lock_phase": "execute",
        "hotfix_bypass": True,
        "bypass_reason": reason,
        "message": f"Hotfix '{change}' confirmado e inicializado con bypass registrado.",
    })


# ─── CLI entry point ──────────────────────────────────────────────────────────

def build_parser():
    parser = argparse.ArgumentParser(
        prog="sg",
        description=(
            "State Guard CLI -- Todos los comandos emiten JSON puro.\n"
            "Unico mecanismo valido para mutar el manifiesto de estado."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command", required=True)

    # status
    p = sub.add_parser("status", help="Estado actual del change")
    p.add_argument("--change", required=True)

    # begin
    p = sub.add_parser("begin", help="Inicia una transaccion para una fase")
    p.add_argument("--change", required=True)
    p.add_argument("--phase", required=True, choices=["plan", "execute", "verify", "hotfix"])

    # commit
    p = sub.add_parser("commit", help="Hace commit de la fase y avanza el DAG")
    p.add_argument("--change", required=True)
    p.add_argument("--next-phase", required=True,
                   choices=["execute", "verify"],
                   dest="next_phase")

    # rollback
    p = sub.add_parser("rollback", help="Revierte la transaccion en curso")
    p.add_argument("--change", required=True)

    # checkpoint
    p = sub.add_parser("checkpoint", help="Guarda un checkpoint de sesion")
    p.add_argument("--change", required=True)
    p.add_argument("--summary", required=True)

    # check-completion
    p = sub.add_parser("check-completion", help="Conteo de tareas completadas (JSON)")
    p.add_argument("--change", required=True)

    # mark-task
    p = sub.add_parser("mark-task", help="Marca una tarea como completada por ID (JSON)")
    p.add_argument("--change", required=True)
    p.add_argument("--task-id", required=True, dest="task_id")

    # next-task
    p = sub.add_parser("next-task", help="Proxima tarea pendiente (JSON)")
    p.add_argument("--change", required=True)

    # verify-gate
    p = sub.add_parser("verify-gate",
                       help="Verifica si una fase esta autorizada por el DAG (JSON)")
    p.add_argument("--change", required=True)
    p.add_argument("--phase", required=True)

    # migrate
    p = sub.add_parser("migrate", help="Migra state.ini v1 (8 fases) a v2 (3 fases)")
    p.add_argument("--change", required=True)

    # init-change
    p = sub.add_parser("init-change", help="Inicializa un nuevo change")
    p.add_argument("--change", required=True)

    # list-changes
    sub.add_parser("list-changes", help="Lista todos los changes activos")

    # install-hooks
    p = sub.add_parser("install-hooks", help="Instala git hooks de State Guard")
    p.add_argument("--force", action="store_true",
                   help="Sobreescribir hooks existentes")

    # plan-approve (paso 1: prepara token out-of-band)
    p = sub.add_parser(
        "plan-approve",
        help="Gate de aprobacion humana del plan (paso 1: prepara token out-of-band)"
    )
    p.add_argument("--change", required=True)

    # plan-confirm (paso 2: consume token y aprueba)
    p = sub.add_parser(
        "plan-confirm",
        help="Gate de aprobacion humana del plan (paso 2: consume token y aprueba)"
    )
    p.add_argument("--change", required=True)
    p.add_argument("--token", required=True, help="Codigo de confirmacion mostrado por plan-approve en /dev/tty")

    # hotfix-init (paso 1: prepara token out-of-band con razon)
    p = sub.add_parser(
        "hotfix-init",
        help="Inicializa un hotfix con bypass de gate (paso 1: prepara token con razon)"
    )
    p.add_argument("--change", required=True)
    p.add_argument("--reason", required=True,
                   help="Razon del bypass (ej: 'regression critica en prod')")

    # hotfix-confirm (paso 2: consume token e inicializa)
    p = sub.add_parser(
        "hotfix-confirm",
        help="Inicializa un hotfix con bypass de gate (paso 2: consume token e inicializa)"
    )
    p.add_argument("--change", required=True)
    p.add_argument("--token", required=True, help="Codigo de confirmacion mostrado por hotfix-init en /dev/tty")

    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()

    dispatch = {
        "status": cmd_status,
        "begin": cmd_begin,
        "commit": cmd_commit,
        "rollback": cmd_rollback,
        "checkpoint": cmd_checkpoint,
        "check-completion": cmd_check_completion,
        "mark-task": cmd_mark_task,
        "next-task": cmd_next_task,
        "verify-gate": cmd_verify_gate,
        "migrate": cmd_migrate,
        "init-change": cmd_init_change,
        "list-changes": cmd_list_changes,
        "install-hooks": cmd_install_hooks,
        "plan-approve": cmd_plan_approve,
        "plan-confirm": cmd_plan_confirm,
        "hotfix-init": cmd_hotfix_init,
        "hotfix-confirm": cmd_hotfix_confirm,
    }
    dispatch[args.command](args)


if __name__ == "__main__":
    main()
