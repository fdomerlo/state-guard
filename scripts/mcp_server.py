#!/usr/bin/env python3
"""MCP Server for State Guard.

Exposes utility and state checking tools over stdio transport.
Transactional control commands (begin, commit, rollback, checkpoint) and
human approval gates (plan-approve, hotfix-init) are intentionally NOT exposed
as MCP tools — they remain CLI/terminal operations.

Exposed tools:
  - get_next_task(change: str) -> dict
  - verify_phase_gate(change: str, phase: str) -> dict
  - mark_task_completed(change: str, task_id: str) -> dict
  - validate_spec(change: str) -> dict
"""
import json
import os
import subprocess
import sys
from mcp.server.fastmcp import FastMCP

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SG = os.path.join(SCRIPT_DIR, "sg.py")

mcp = FastMCP("state-guard")


def _sg(*args):
    """Invoca sg.py vía subprocess y parsea la salida JSON."""
    r = subprocess.run([sys.executable, SG] + list(args), capture_output=True, text=True)
    try:
        return json.loads(r.stdout), r.returncode
    except json.JSONDecodeError:
        return {"raw": r.stdout, "stderr": r.stderr}, r.returncode


@mcp.tool()
def get_next_task(change: str) -> dict:
    """Retorna la próxima tarea pendiente de tasks.md para el change dado, o null si no hay."""
    result, _ = _sg("next-task", "--change", change)
    return result


@mcp.tool()
def verify_phase_gate(change: str, phase: str) -> dict:
    """Verifica si la fase solicitada está autorizada por el DAG antes de ejecutarla."""
    result, _ = _sg("verify-gate", "--change", change, "--phase", phase)
    return result


@mcp.tool()
def mark_task_completed(change: str, task_id: str) -> dict:
    """Marca una tarea como completada por ID. Idempotente."""
    result, _ = _sg("mark-task", "--change", change, "--task-id", task_id)
    return result


@mcp.tool()
def validate_spec(change: str) -> dict:
    """Valida estructuralmente objective.md y design.md antes del gate humano.
    Detecta secciones faltantes, placeholders sin completar y preguntas bloqueantes [!]."""
    result, _ = _sg("validate-spec", "--change", change)
    return result


def main():
    mcp.run(transport="stdio")


if __name__ == "__main__":
    main()
