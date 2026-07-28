# FASE C — Servidor MCP (PENDIENTE — no ejecutar en esta sesión)

> **Estado:** Documentado. No implementar hasta que Fase A y Fase B estén auditadas y mergeadas.

## Visión

Un servidor MCP como wrapper delgado sobre el CLI de Fase B (`sg.py`), exponiendo las operaciones del State Guard como herramientas MCP invocables desde cualquier cliente compatible (Claude Desktop, Cursor, etc.).

## Arquitectura

```
Cliente MCP (LLM host)
        │
        │ MCP protocol
        ▼
   mcp_server.py        ← Fase C (wrapper delgado)
        │
        │ subprocess / importación directa
        ▼
     sg.py              ← Fase B (CLI JSON-pure)
        │
        ▼
  state_manager.py      ← Motor ACID (sin cambios)
```

El servidor MCP **no contiene lógica de negocio**: delega todo a `sg.py` y traduce los resultados JSON al formato de tool-response de MCP.

## Tools a exponer

### `get_next_task(change: str) → Task | None`

Retorna la próxima tarea pendiente del `tasks.md` del change activo.

**Mapeo:** `sg next-task --change {change}` → `{"status": "OK", "task": {"id": ..., "description": ...}}`

**Respuesta MCP:**
```json
{
  "task_id": "T003",
  "description": "Implementar validación en src/validator.py",
  "raw_line": "- [ ] [T003] Implementar validación en src/validator.py"
}
```
Retorna `null` si `status == "ALL_COMPLETE"` o `"NO_TASKS_FILE"`.

---

### `verify_phase_gate(change: str, phase: str) → GateResult`

Verifica si una fase está autorizada por el DAG antes de ejecutarla.

**Mapeo:** `sg verify-gate --change {change} --phase {phase}`

**Respuesta MCP:**
```json
{
  "gate_ok": true,
  "requested_phase": "execute",
  "lock_phase": "execute",
  "txn_status": "idle"
}
```
Si `gate_ok == false`, el servidor retorna un error MCP (no lanza excepción).

---

### `mark_task_completed(change: str, task_id: str) → MarkResult`

Marca una tarea como completada en `tasks.md` por ID.

**Mapeo:** `sg mark-task --change {change} --task-id {task_id}`

**Respuesta MCP:**
```json
{
  "status": "SUCCESS",
  "task_id": "T003",
  "message": "Tarea 'T003' marcada como completada"
}
```
Idempotente: si la tarea ya estaba completada, `status == "ALREADY_DONE"`.

---

## Implementación sugerida (cuando llegue el momento)

```python
# scripts/mcp_server.py
from mcp.server import Server
from mcp.server.stdio import stdio_server
import subprocess, json, sys
from pathlib import Path

SG = Path(__file__).parent / "sg.py"

def _sg(*args):
    r = subprocess.run([sys.executable, str(SG)] + list(args),
                       capture_output=True, text=True)
    return json.loads(r.stdout), r.returncode

server = Server("state-guard")

@server.tool()
def get_next_task(change: str):
    result, _ = _sg("next-task", "--change", change)
    return result.get("task")  # None si no hay tareas

@server.tool()
def verify_phase_gate(change: str, phase: str):
    result, _ = _sg("verify-gate", "--change", change, "--phase", phase)
    return result

@server.tool()
def mark_task_completed(change: str, task_id: str):
    result, _ = _sg("mark-task", "--change", change, "--task-id", task_id)
    return result

if __name__ == "__main__":
    import asyncio
    asyncio.run(stdio_server(server))
```

**Dependencia:** `pip install mcp` (SDK oficial de Anthropic).

## Criterios de aceptación para Fase C

Antes de implementar, verificar que:

- [ ] Fase A está mergeada y los tests de concurrencia pasan en CI
- [ ] Fase B está mergeada: `sg.py` funciona correctamente con todos los comandos JSON
- [ ] Los comandos `next-task`, `verify-gate`, `mark-task` de `sg.py` tienen tests de integración
- [ ] El servidor MCP usa `stdio_server` (no HTTP) para compatibilidad con Claude Desktop
- [ ] Las tools son idempotentes y no tienen efectos secundarios inesperados
- [ ] El servidor MCP NO tiene acceso directo a `state_manager.py` — solo a través de `sg.py`
