#!/usr/bin/env python3
import argparse
import configparser
import os
import re
import sys
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _lock_utils import (
    try_acquire_lockfile,
    release_lockfile,
    is_stale,
    check_lock_status,
    with_write_lock,
)

STATE_FILE = ".agentify/changes/{change}/state.ini"
LOCK_FILE = ".agentify/changes/{change}/.lock"
WRITE_LOCK_FILE = ".agentify/changes/{change}/.write-lock"
TASKS_FILE = ".agentify/changes/{change}/tasks.md"
DEFAULT_TTL = 1800
MAX_SUMMARY_CHARS = 2000  # ~500 tokens ≈ 2000 chars

# Exit codes diferenciados para que modelos débiles (free-tier) puedan
# distinguir categorías de error por código numérico, sin depender del
# parseo correcto del texto de stderr/stdout.
EXIT_OK = 0
EXIT_GENERIC = 1        # state.ini no encontrado, error inesperado
EXIT_LOCK_CONFLICT = 2  # lock activo (otra sesión), reintentable
EXIT_BAD_TRANSITION = 3 # transición inválida en el DAG, no reintentar
EXIT_VALIDATION = 4     # datos de entrada inválidos (summary muy largo, etc.)

# Matchea: "- [ ] [T003] Descripción" o "- [x] Descripción" (ID opcional entre corchetes)
TASK_LINE_RE = re.compile(r"^\s*-\s*\[( |x|X)\]\s*(?:\[([^\]]+)\]\s*)?(.*)$")

TRANSITIONS = {
    "explore": "propose",
    "propose": "spec",
    "spec": "design",
    "design": "tasks",
    "tasks": "apply",
    "hotfix": "apply",
    "apply": "verify",
    "verify": "archive",
}


def load_state(change_name):
    path = STATE_FILE.format(change=change_name)
    config = configparser.ConfigParser()
    if not os.path.exists(path):
        print(f"ERROR: No se encontró el state.ini para '{change_name}'")
        sys.exit(1)
    config.read(path, encoding="utf-8")
    return config, path


def save_state(config, path):
    if not config.has_section("Metadata"):
        config.add_section("Metadata")
    config.set("Metadata", "last_updated", datetime.now().isoformat())
    with open(path, "w", encoding="utf-8") as f:
        config.write(f)


def get_list(config, section, option):
    val = config.get(section, option, fallback="").strip()
    return [x.strip() for x in val.split(",")] if val else []


def set_list(config, section, option, lst):
    config.set(section, option, ", ".join(lst))


def cmd_begin(args):
    lock_path = LOCK_FILE.format(change=args.change)

    def _do():
        config, path = load_state(args.change)
        status = config.get("Transaction", "txn_status", fallback="idle")
        started_at = config.get("Transaction", "txn_started_at", fallback=None)

        if status == "in_progress" and not is_stale(started_at, args.ttl):
            print("ERROR: Ya hay una transacción en progreso.")
            sys.exit(EXIT_LOCK_CONFLICT)

        if status == "in_progress" and is_stale(started_at, args.ttl):
            release_lockfile(lock_path)

        if not try_acquire_lockfile(lock_path):
            print("ERROR: Ya hay una transacción en progreso (lock activo).")
            sys.exit(EXIT_LOCK_CONFLICT)

        config.set("Transaction", "txn_status", "in_progress")
        config.set("Transaction", "txn_phase", args.phase)
        config.set("Transaction", "txn_started_at", datetime.now().isoformat())
        save_state(config, path)
        print(f"SUCCESS|BEGIN transaccional iniciado para fase: {args.phase}")

    with_write_lock(WRITE_LOCK_FILE.format(change=args.change), _do)


def cmd_commit(args):
    def _do():
        config, path = load_state(args.change)
        if config.get("Transaction", "txn_status", fallback="idle") != "in_progress":
            print("ERROR: No hay transacción en progreso para hacer commit.")
            sys.exit(EXIT_GENERIC)

        phase = config.get("Transaction", "txn_phase")
        expected_next = TRANSITIONS.get(phase)
        if expected_next != args.next_phase:
            print(
                f"ERROR: Transición inválida. Desde '{phase}' el DAG solo permite "
                f"'{expected_next}', no '{args.next_phase}'."
            )
            sys.exit(EXIT_BAD_TRANSITION)

        config.set("Graph", "current_phase", phase)
        config.set("Graph", "lock_phase", args.next_phase)

        completed = get_list(config, "Graph", "completed_phases")
        if phase not in completed:
            completed.append(phase)
            set_list(config, "Graph", "completed_phases", completed)

        pending = get_list(config, "Graph", "pending_phases")
        if phase in pending:
            pending.remove(phase)
            set_list(config, "Graph", "pending_phases", pending)

        config.set("Transaction", "txn_status", "idle")
        config.set("Transaction", "txn_phase", "None")

        # Auto-checkpoint determinístico: genera un session_summary mínimo
        # con el estado real del DAG post-commit. Esto garantiza que siempre
        # exista un checkpoint para warm-boot, sin depender de que el modelo
        # ejecute /agentify-checkpoint manualmente.
        auto_summary = (
            f"fase_completada={phase}\n"
            f"siguiente_fase={args.next_phase}\n"
            f"completadas={', '.join(completed)}\n"
            f"pendientes={', '.join(pending)}"
        )
        if not config.has_section("Session"):
            config.add_section("Session")
        config.set("Session", "session_summary", auto_summary)

        save_state(config, path)
        release_lockfile(LOCK_FILE.format(change=args.change))
        print(f"SUCCESS|COMMIT exitoso. lock_phase={args.next_phase}")
        print(f"⚠️ FASE {phase} COMPLETADA — sus instrucciones ya no aplican.")

    with_write_lock(WRITE_LOCK_FILE.format(change=args.change), _do)


def cmd_rollback(args):
    def _do():
        config, path = load_state(args.change)
        if config.get("Transaction", "txn_status", fallback="idle") != "in_progress":
            print("ERROR: No hay transacción en progreso para revertir.")
            sys.exit(EXIT_GENERIC)
        config.set("Transaction", "txn_status", "idle")
        config.set("Transaction", "txn_phase", "None")
        save_state(config, path)
        release_lockfile(LOCK_FILE.format(change=args.change))
        print("SUCCESS|ROLLBACK ejecutado. txn_status restaurado a idle.")

    with_write_lock(WRITE_LOCK_FILE.format(change=args.change), _do)


def cmd_checkpoint(args):
    def _do():
        if len(args.summary) > MAX_SUMMARY_CHARS:
            print(
                f"ERROR: session_summary excede el límite "
                f"({len(args.summary)}/{MAX_SUMMARY_CHARS} chars). "
                f"Resumí el contenido y reintentá."
            )
            sys.exit(EXIT_VALIDATION)
        config, path = load_state(args.change)
        if not config.has_section("Session"):
            config.add_section("Session")
        config.set("Session", "session_summary", args.summary)
        save_state(config, path)
        print("SUCCESS|CHECKPOINT guardado en session_summary.")

    with_write_lock(WRITE_LOCK_FILE.format(change=args.change), _do)


def cmd_check_completion(args):
    """Parser determinista de tasks.md — reemplaza el conteo manual que antes
    le pedíamos al LLM (Paso 3a de agentify-checkpoint). Un modelo débil cuenta mal
    checkboxes en markdown; una regex no."""
    path = TASKS_FILE.format(change=args.change)
    if not os.path.exists(path):
        print("estado_tareas=N/A")
        print("total=0")
        print("completed=0")
        print("all_complete=false")
        print("last_completed_id=None")
        print("last_completed_desc=None")
        return

    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    total = 0
    completed = 0
    last_completed_id = None
    last_completed_desc = None

    for line in lines:
        m = TASK_LINE_RE.match(line)
        if not m:
            continue
        total += 1
        checked = m.group(1).lower() == "x"
        task_id = m.group(2) or ""
        desc = m.group(3).strip()
        if checked:
            completed += 1
            last_completed_id = task_id if task_id else last_completed_id
            last_completed_desc = desc[:100] if desc else last_completed_desc

    all_complete = total > 0 and completed == total
    estado = f"{completed}/{total}"
    if last_completed_id:
        estado += f" — última: [{last_completed_id}] {last_completed_desc}"
    elif last_completed_desc:
        estado += f" — última: {last_completed_desc}"

    print(f"estado_tareas={estado}")
    print(f"total={total}")
    print(f"completed={completed}")
    print(f"all_complete={'true' if all_complete else 'false'}")
    print(f"last_completed_id={last_completed_id or 'None'}")
    print(f"last_completed_desc={last_completed_desc or 'None'}")


def cmd_status(args):
    config, _ = load_state(args.change)
    txn_status = config.get("Transaction", "txn_status", fallback="idle")
    txn_phase = config.get("Transaction", "txn_phase", fallback="None")
    started_at = config.get("Transaction", "txn_started_at", fallback=None)
    lock_phase = config.get("Graph", "lock_phase", fallback="None")

    lock_path = LOCK_FILE.format(change=args.change)
    lock_state = check_lock_status(lock_path, started_at, args.ttl)

    print(f"txn_status={txn_status}")
    print(f"txn_phase={txn_phase}")
    print(f"lock_phase={lock_phase}")
    print(f"lock_state={lock_state}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="State Manager (INI Format - Zero Dependencies)")
    subparsers = parser.add_subparsers(dest="command", required=True)

    p_begin = subparsers.add_parser("begin")
    p_begin.add_argument("--change", required=True)
    p_begin.add_argument("--phase", required=True)
    p_begin.add_argument("--ttl", type=int, default=DEFAULT_TTL)

    p_commit = subparsers.add_parser("commit")
    p_commit.add_argument("--change", required=True)
    p_commit.add_argument("--next-phase", required=True)

    p_rollback = subparsers.add_parser("rollback")
    p_rollback.add_argument("--change", required=True)

    p_checkpoint = subparsers.add_parser("checkpoint")
    p_checkpoint.add_argument("--change", required=True)
    p_checkpoint.add_argument("--summary", required=True)

    p_status = subparsers.add_parser("status")
    p_status.add_argument("--change", required=True)
    p_status.add_argument("--ttl", type=int, default=DEFAULT_TTL)

    p_check = subparsers.add_parser("check-completion")
    p_check.add_argument("--change", required=True)

    args = parser.parse_args()
    if args.command == "begin":
        cmd_begin(args)
    elif args.command == "commit":
        cmd_commit(args)
    elif args.command == "rollback":
        cmd_rollback(args)
    elif args.command == "checkpoint":
        cmd_checkpoint(args)
    elif args.command == "status":
        cmd_status(args)
    elif args.command == "check-completion":
        cmd_check_completion(args)
