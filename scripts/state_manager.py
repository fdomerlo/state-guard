#!/usr/bin/env python3
"""
state_manager.py — Motor ACID del State Guard (v2: esquema de 3 fases)

Cambios respecto a v1 (8 fases):
  - DAG colapsado a 3 fases principales: plan → execute → verify
  - Se agrega schema_version en [Metadata] para migración
  - El campo [Graph].schema_version permite detectar state.ini v1
    y migrar automáticamente (ver cmd_migrate)
  - archive ya NO es una fase del DAG; es el Paso 9 dentro de verify
  - El lock de plan solo se emite tras aprobación humana explícita
    (el CLI NO puede emitir el lock de plan autónomamente; la skill
    de PLAN es responsable de esperar la respuesta del humano antes
    de invocar 'commit')
"""
import argparse
import configparser
import json
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

STATE_FILE = ".state-guard/changes/{change}/state.ini"
LOCK_FILE = ".state-guard/changes/{change}/.lock"
WRITE_LOCK_FILE = ".state-guard/changes/{change}/.write-lock"
TASKS_FILE = ".state-guard/changes/{change}/tasks.md"
DEFAULT_TTL = 1800
MAX_SUMMARY_CHARS = 2000  # ~500 tokens ≈ 2000 chars

SCHEMA_VERSION = "2"  # v1 = 8 fases, v2 = 3 fases

# Exit codes diferenciados para que modelos débiles (free-tier) puedan
# distinguir categorías de error por código numérico, sin depender del
# parseo correcto del texto de stderr/stdout.
EXIT_OK = 0
EXIT_GENERIC = 1        # state.ini no encontrado, error inesperado
EXIT_LOCK_CONFLICT = 2  # lock activo (otra sesión), reintentable
EXIT_BAD_TRANSITION = 3 # transición inválida en el DAG, no reintentar
EXIT_VALIDATION = 4     # datos de entrada inválidos (summary muy largo, etc.)
EXIT_GATE_REQUIRED = 5  # gate humano no cumplido — el LLM no puede resolver esto

# Matchea: "- [ ] [T003] Descripción" o "- [x] Descripción" (ID opcional)
TASK_LINE_RE = re.compile(r"^\s*-\s*\[( |x|X)\]\s*(?:\[([^\]]+)\]\s*)?(.*)$")

# ─── DAG v2 (3 fases) ──────────────────────────────────────────────────────
TRANSITIONS = {
    "plan":    "execute",
    "execute": "verify",
    "hotfix":  "execute",   # hotfix bypass: saltea plan, entra directo a execute
    # verify no tiene sucesor en el DAG — archive es Paso 9 dentro de verify
}

# ─── Mapa de migración v1 → v2 ─────────────────────────────────────────────
# Fases v1 → fase v2 equivalente que debería estar activa ahora
V1_TO_V2_PHASE = {
    "explore":  "plan",
    "propose":  "plan",
    "spec":     "plan",
    "design":   "plan",
    "tasks":    "execute",
    "apply":    "execute",
    "verify":   "verify",
    "archive":  "verify",   # archive ahora es Paso 9 de verify
}


def load_state(change_name):
    path = STATE_FILE.format(change=change_name)
    config = configparser.ConfigParser()
    if not os.path.exists(path):
        print(f"ERROR: No se encontró el state.ini para '{change_name}'")
        sys.exit(EXIT_GENERIC)
    config.read(path, encoding="utf-8")
    return config, path


def save_state(config, path):
    if not config.has_section("Metadata"):
        config.add_section("Metadata")
    config.set("Metadata", "last_updated", datetime.now().isoformat())
    # Asegurar schema_version siempre presente
    config.set("Metadata", "schema_version", SCHEMA_VERSION)
    with open(path, "w", encoding="utf-8") as f:
        config.write(f)


def get_list(config, section, option):
    val = config.get(section, option, fallback="").strip()
    return [x.strip() for x in val.split(",")] if val else []


def set_list(config, section, option, lst):
    config.set(section, option, ", ".join(lst))


# ─── Detección de schema v1 ────────────────────────────────────────────────

def is_v1_state(config):
    """Retorna True si el state.ini es v1 (esquema de 8 fases)."""
    version = config.get("Metadata", "schema_version", fallback="1")
    return version == "1"


def _migrate_v1_to_v2(config, path):
    """
    Migra in-place un state.ini v1 al esquema v2.
    Reglas:
      - lock_phase se mapea a la fase v2 equivalente
      - completed_phases se agrupa: si alguna de [tasks, apply] está completa
        → execute está completo; si todo lo anterior está completo → plan
      - pending_phases = todas las fases v2 que no están completadas
    Retorna (config, path) ya guardados.
    """
    lock_phase_v1 = config.get("Graph", "lock_phase", fallback="plan")
    completed_v1 = get_list(config, "Graph", "completed_phases")
    txn_phase_v1 = config.get("Transaction", "txn_phase", fallback="None")

    # Mapear lock_phase
    lock_phase_v2 = V1_TO_V2_PHASE.get(lock_phase_v1, "plan")

    # Calcular completed_phases v2
    completed_v2 = []
    if any(p in completed_v1 for p in ["explore", "propose", "spec", "design"]):
        # Solo marcar plan como completado si YA había avanzado más allá
        if any(p in completed_v1 for p in ["tasks", "apply", "verify", "archive"]):
            completed_v2.append("plan")
    if any(p in completed_v1 for p in ["tasks", "apply"]):
        if any(p in completed_v1 for p in ["verify", "archive"]):
            completed_v2.append("execute")
    if "verify" in completed_v1 or "archive" in completed_v1:
        completed_v2.append("verify")

    # pending_phases v2
    all_phases = ["plan", "execute", "verify"]
    pending_v2 = [p for p in all_phases if p not in completed_v2]

    # Mapear txn_phase
    txn_phase_v2 = V1_TO_V2_PHASE.get(txn_phase_v1, "None") if txn_phase_v1 != "None" else "None"

    config.set("Graph", "lock_phase", lock_phase_v2)
    config.set("Graph", "current_phase", completed_v2[-1] if completed_v2 else "none")
    set_list(config, "Graph", "completed_phases", completed_v2)
    set_list(config, "Graph", "pending_phases", pending_v2)
    if txn_phase_v2 != "None":
        config.set("Transaction", "txn_phase", txn_phase_v2)

    # Añadir nota de migración en Session
    if not config.has_section("Session"):
        config.add_section("Session")
    config.set("Session", "migrated_from_schema", "v1")
    config.set("Session", "migrated_at", datetime.now().isoformat())

    save_state(config, path)
    return config, path


# ─── Comandos ───────────────────────────────────────────────────────────────

def cmd_begin(args):
    lock_path = LOCK_FILE.format(change=args.change)

    def _do():
        config, path = load_state(args.change)

        # Auto-migrar si es v1
        if is_v1_state(config):
            config, path = _migrate_v1_to_v2(config, path)
            print("INFO: state.ini v1 migrado automáticamente a v2 (3 fases).")

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

        # Auto-migrar si es v1
        if is_v1_state(config):
            config, path = _migrate_v1_to_v2(config, path)

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

        # ── GATE ENFORCEMENT ────────────────────────────────────────────────
        # Si la fase que se está cerrando es 'plan', verificar que el humano
        # haya aprobado explícitamente desde una terminal real.
        # El token es escrito EXCLUSIVAMENTE por cmd_plan_confirm / cmd_hotfix_confirm,
        # que consumen el archivo out-of-band en ~/.state-guard-gate/<change>.token.
        # Un LLM que invoque 'commit' directamente sin pasar por 'plan-confirm'
        # obtendrá EXIT_GATE_REQUIRED (5), que no es reintentable por el modelo.
        if phase == "plan":
            gate_token = config.get("Gate", "plan_gate_token", fallback=None)
            if not gate_token:
                print(
                    "ERROR: GATE — El commit de 'plan' requiere aprobación humana explícita.\n"
                    "       Ejecutá desde tu terminal: sg plan-approve --change "
                    f"{args.change}\n"
                    f"       y luego confirma con: sg plan-confirm --change {args.change}\n"
                    "       Este comando solo funciona en una terminal humana (fuera del workspace)."
                )
                sys.exit(EXIT_GATE_REQUIRED)
        # ── FIN GATE ENFORCEMENT ────────────────────────────────────────────

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

        # Limpiar el gate token post-commit para que no se reutilice
        if config.has_section("Gate"):
            config.remove_option("Gate", "plan_gate_token")

        # Auto-checkpoint determinístico
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
    le pedíamos al LLM. Un modelo débil cuenta mal checkboxes en markdown;
    una regex no."""
    path = TASKS_FILE.format(change=args.change)
    if not os.path.exists(path):
        if args.json:
            print(json.dumps({
                "estado_tareas": "N/A", "total": 0, "completed": 0,
                "all_complete": False, "last_completed_id": None,
                "last_completed_desc": None
            }))
        else:
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

    if args.json:
        print(json.dumps({
            "estado_tareas": estado,
            "total": total,
            "completed": completed,
            "all_complete": all_complete,
            "last_completed_id": last_completed_id,
            "last_completed_desc": last_completed_desc,
        }))
    else:
        print(f"estado_tareas={estado}")
        print(f"total={total}")
        print(f"completed={completed}")
        print(f"all_complete={'true' if all_complete else 'false'}")
        print(f"last_completed_id={last_completed_id or 'None'}")
        print(f"last_completed_desc={last_completed_desc or 'None'}")


def cmd_mark_task(args):
    """Marca una tarea como completada por ID en tasks.md.
    Diseñado para ser invocado desde git hooks o el servidor MCP (Fase C).
    Salida en JSON para serialización limpia."""
    path = TASKS_FILE.format(change=args.change)
    if not os.path.exists(path):
        result = {"status": "ERROR", "message": f"tasks.md no encontrado para '{args.change}'"}
        print(json.dumps(result))
        sys.exit(EXIT_GENERIC)

    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    found = False
    already_done = False
    new_lines = []
    for line in lines:
        m = TASK_LINE_RE.match(line)
        if m and m.group(2) == args.task_id:
            found = True
            if m.group(1).lower() == "x":
                already_done = True
                new_lines.append(line)
            else:
                # Reemplazar el checkbox
                new_lines.append(line.replace("[ ]", "[x]", 1))
        else:
            new_lines.append(line)

    if not found:
        result = {"status": "ERROR", "message": f"Tarea '{args.task_id}' no encontrada en tasks.md"}
        print(json.dumps(result))
        sys.exit(EXIT_VALIDATION)

    if already_done:
        result = {"status": "ALREADY_DONE", "task_id": args.task_id,
                  "message": f"Tarea '{args.task_id}' ya estaba completada"}
    else:
        with open(path, "w", encoding="utf-8") as f:
            f.writelines(new_lines)
        result = {"status": "SUCCESS", "task_id": args.task_id,
                  "message": f"Tarea '{args.task_id}' marcada como completada"}

    print(json.dumps(result))


def cmd_migrate(args):
    """Migra explícitamente un state.ini v1 a v2. Idempotente."""
    config, path = load_state(args.change)
    if not is_v1_state(config):
        print(json.dumps({
            "status": "ALREADY_V2",
            "schema_version": config.get("Metadata", "schema_version", fallback="2")
        }))
        return
    config, path = _migrate_v1_to_v2(config, path)
    lock_phase = config.get("Graph", "lock_phase", fallback="unknown")
    completed = get_list(config, "Graph", "completed_phases")
    print(json.dumps({
        "status": "SUCCESS",
        "message": "state.ini migrado de v1 (8 fases) a v2 (3 fases)",
        "lock_phase_v2": lock_phase,
        "completed_phases_v2": completed,
    }))


def cmd_status(args):
    config, _ = load_state(args.change)
    txn_status = config.get("Transaction", "txn_status", fallback="idle")
    txn_phase = config.get("Transaction", "txn_phase", fallback="None")
    started_at = config.get("Transaction", "txn_started_at", fallback=None)
    lock_phase = config.get("Graph", "lock_phase", fallback="None")
    schema_version = config.get("Metadata", "schema_version", fallback="1")

    lock_path = LOCK_FILE.format(change=args.change)
    lock_state = check_lock_status(lock_path, started_at, args.ttl)

    if args.json:
        print(json.dumps({
            "txn_status": txn_status,
            "txn_phase": txn_phase,
            "lock_phase": lock_phase,
            "lock_state": lock_state,
            "schema_version": schema_version,
        }))
    else:
        print(f"txn_status={txn_status}")
        print(f"txn_phase={txn_phase}")
        print(f"lock_phase={lock_phase}")
        print(f"lock_state={lock_state}")
        print(f"schema_version={schema_version}")


# ─── Gate de aprobación humana ─────────────────────────────────────────────

def cmd_plan_approve(args):
    """Registra la aprobación humana del plan en state.ini[Gate].

    Este comando NO verifica isatty() — esa verificación ocurre en sg.py
    ANTES de invocar este comando. La separación es intencional:
    state_manager.py es el motor ACID; sg.py es el guardián del canal.

    El token almacenado es: timestamp ISO + el texto de confirmación del humano
    (truncado). No es criptográfico — la garantía real viene de isatty() en sg.py.
    """
    def _do():
        config, path = load_state(args.change)
        if not config.has_section("Gate"):
            config.add_section("Gate")
        token = datetime.now().isoformat()
        config.set("Gate", "plan_gate_token", token)
        config.set("Gate", "plan_approved_at", token)
        config.set("Gate", "plan_approved_by", args.approved_by or "human")
        if args.bypass_reason:
            config.set("Gate", "hotfix_bypass_reason", args.bypass_reason)
            config.set("Gate", "hotfix_bypass", "true")
        save_state(config, path)
        print(json.dumps({
            "status": "APPROVED",
            "plan_gate_token": token,
            "change": args.change,
            "approved_at": token,
        }))

    with_write_lock(WRITE_LOCK_FILE.format(change=args.change), _do)


# ─── Verificación de gate de fase ───────────────────────────────────────────

def cmd_verify_gate(args):
    """Verifica si la fase solicitada es la autorizada por el DAG.
    Salida en JSON para invocación desde MCP (Fase C).
    Exit 0 si OK, EXIT_BAD_TRANSITION si inválida."""
    config, _ = load_state(args.change)
    lock_phase = config.get("Graph", "lock_phase", fallback="None")
    txn_status = config.get("Transaction", "txn_status", fallback="idle")
    schema_version = config.get("Metadata", "schema_version", fallback="1")

    ok = (lock_phase == args.phase)
    result = {
        "gate_ok": ok,
        "requested_phase": args.phase,
        "lock_phase": lock_phase,
        "txn_status": txn_status,
        "schema_version": schema_version,
    }
    if not ok:
        result["error"] = (
            f"Fase '{args.phase}' no está autorizada. "
            f"El DAG requiere '{lock_phase}'."
        )
    print(json.dumps(result))
    if not ok:
        sys.exit(EXIT_BAD_TRANSITION)


# ─── Obtener próxima tarea ───────────────────────────────────────────────────

def cmd_next_task(args):
    """Retorna la próxima tarea pendiente de tasks.md.
    Salida en JSON para invocación desde MCP (Fase C)."""
    path = TASKS_FILE.format(change=args.change)
    if not os.path.exists(path):
        print(json.dumps({"status": "NO_TASKS_FILE", "task": None}))
        return

    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    for line in lines:
        m = TASK_LINE_RE.match(line)
        if m and m.group(1) != "x" and m.group(1) != "X":
            task_id = m.group(2) or None
            desc = m.group(3).strip()
            print(json.dumps({
                "status": "OK",
                "task": {
                    "id": task_id,
                    "description": desc,
                    "raw_line": line.rstrip(),
                }
            }))
            return

    print(json.dumps({"status": "ALL_COMPLETE", "task": None}))


# ─── CLI ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="State Manager — Motor ACID del State Guard (v2: 3 fases)"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    # begin
    p_begin = subparsers.add_parser("begin")
    p_begin.add_argument("--change", required=True)
    p_begin.add_argument("--phase", required=True)
    p_begin.add_argument("--ttl", type=int, default=DEFAULT_TTL)

    # commit
    p_commit = subparsers.add_parser("commit")
    p_commit.add_argument("--change", required=True)
    p_commit.add_argument("--next-phase", required=True)

    # rollback
    p_rollback = subparsers.add_parser("rollback")
    p_rollback.add_argument("--change", required=True)

    # checkpoint
    p_checkpoint = subparsers.add_parser("checkpoint")
    p_checkpoint.add_argument("--change", required=True)
    p_checkpoint.add_argument("--summary", required=True)

    # status
    p_status = subparsers.add_parser("status")
    p_status.add_argument("--change", required=True)
    p_status.add_argument("--ttl", type=int, default=DEFAULT_TTL)
    p_status.add_argument("--json", action="store_true",
                          help="Salida en JSON (para invocación programática)")

    # check-completion
    p_check = subparsers.add_parser("check-completion")
    p_check.add_argument("--change", required=True)
    p_check.add_argument("--json", action="store_true",
                         help="Salida en JSON (para invocación programática)")

    # mark-task — nuevo en v2, para git hooks y MCP
    p_mark = subparsers.add_parser("mark-task",
                                   help="Marca una tarea como completada por ID (JSON output)")
    p_mark.add_argument("--change", required=True)
    p_mark.add_argument("--task-id", required=True,
                        help="ID de la tarea (ej: T001, T002)")

    # next-task — nuevo en v2, para MCP get_next_task()
    p_next = subparsers.add_parser("next-task",
                                   help="Retorna la próxima tarea pendiente (JSON output)")
    p_next.add_argument("--change", required=True)

    # verify-gate — nuevo en v2, para MCP verify_phase_gate()
    p_gate = subparsers.add_parser("verify-gate",
                                   help="Verifica si una fase está autorizada por el DAG (JSON output)")
    p_gate.add_argument("--change", required=True)
    p_gate.add_argument("--phase", required=True)

    # migrate — migración explícita v1 → v2
    p_migrate = subparsers.add_parser("migrate",
                                      help="Migra state.ini v1 (8 fases) a v2 (3 fases)")
    p_migrate.add_argument("--change", required=True)

    # plan-approve — registra token de aprobación humana (llamado desde sg.py plan-confirm / hotfix-confirm)
    # No invocar directamente: sg.py verifica y consume el archivo out-of-band antes de llamar a este comando.
    p_approve = subparsers.add_parser(
        "plan-approve",
        help="Registra token de aprobación humana del plan (usar sg plan-confirm / hotfix-confirm, no este comando directo)"
    )
    p_approve.add_argument("--change", required=True)
    p_approve.add_argument("--approved-by", default="human", dest="approved_by")
    p_approve.add_argument("--bypass-reason", default=None, dest="bypass_reason",
                           help="Si se provee, registra un bypass de hotfix con razón explícita")

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
    elif args.command == "mark-task":
        cmd_mark_task(args)
    elif args.command == "next-task":
        cmd_next_task(args)
    elif args.command == "verify-gate":
        cmd_verify_gate(args)
    elif args.command == "migrate":
        cmd_migrate(args)
    elif args.command == "plan-approve":
        cmd_plan_approve(args)
