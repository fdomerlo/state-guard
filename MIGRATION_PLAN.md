# MIGRATION_PLAN.md — Consolidación context-guard → state-guard

**Repo objetivo (donde se ejecuta todo este plan):** `state-guard`
**Repo fuente (de donde se extraen piezas, luego se archiva):** `context-guard`
**Estado de este documento:** vive en la raíz de `state-guard`, versionado en git. Es la única fuente de verdad sobre progreso — no la memoria de ninguna sesión de chat.

---

## 0. Cómo retomar este trabajo si se corta la sesión

Instrucción literal para pegarle a cualquier agente nuevo (Claude Code, OpenCode, etc.) que arranque de cero:

```
Leé MIGRATION_PLAN.md completo de punta a punta antes de tocar nada.
Buscá el primer checkbox [ ] sin marcar, en orden, de arriba hacia abajo.
Antes de ejecutar ese paso, corré el comando de "Verificación" del ÚLTIMO
paso marcado como [x] para confirmar que el estado real del repo coincide
con lo que dice el checklist. Si no coincide, PARÁ y reportá la discrepancia
en vez de asumir y seguir.
Ejecutá SOLO el paso siguiente sin marcar. No hagas dos pasos en el mismo turno.
Al terminar el paso: corré su "Verificación", marcá el checkbox [x] en este
archivo, hacé el commit indicado, y detenete. No sigas al paso siguiente
en el mismo turno salvo que se indique explícitamente "atómico con el anterior".
```

### Reglas duras (no negociables durante todo el plan)

1. **No se avanza de Fase sin que la Fase anterior tenga su tag de cierre en git.** Los tags son el checkpoint real; los checkboxes son solo para lectura rápida humana.
2. **No se modifica el schema de `state.ini` v2, ni la superficie de comandos de `sg.py` (`begin/commit/rollback/checkpoint/status/...`), ni `phases/_shared/transaction-protocol.md`.** Este plan importa piezas de `context-guard`, no rediseña `state-guard`.
3. **Todo lo que se porta desde `context-guard` se adapta a las convenciones de `state-guard`** (nombres de función, formato de exit codes, idioma de mensajes en español donde `state-guard` ya usa español). No se pega código verbatim salvo que el paso lo diga explícitamente.
4. Cada paso que toca código termina con: tests en verde → commit → (si cierra fase) tag.
5. Si un paso requiere una decisión de diseño no cubierta acá, el agente PARA y pregunta. No improvisa arquitectura.

---

## Fase 0 — Preparación del entorno de migración

### [x] 0.1 — Traer context-guard como referencia de solo lectura

```bash
cd <ruta-al-repo-state-guard>
mkdir -p .ref
# copiar el contenido completo del repo context-guard (sin .git) a .ref/context-guard/
cp -r <ruta-al-repo-context-guard>/* .ref/context-guard/
rm -rf .ref/context-guard/**/__pycache__
```

**Reglas sobre `.ref/`:**
- Se commitea al repo (da trazabilidad de qué se copió y desde dónde).
- **Nunca se referencia desde código de producción** (`scripts/`, `phases/`, `skills/`) — ni imports, ni paths hardcodeados. Es material de consulta para el agente durante la migración, nada más.
- Se borra por completo al cerrar la Fase 3 (paso 3.6).

**Verificación:** `test -d .ref/context-guard/scripts/guard && echo OK`

**Commit:** `chore: snapshot context-guard as migration reference (.ref/)`

---

### [x] 0.2 — Baseline: estado actual documentado

Correr y **guardar la salida tal cual** en un comentario del commit (no hace falta archivo aparte):

```bash
python3 tests/concurrency_test.py
bash tests/install_test.sh
```

**Resultado esperado en baseline (antes de tocar nada):** `concurrency_test.py` falla en el TEST que ejercita `sg plan-approve`/`hotfix-init` con `NO_TTY` si se corre sin terminal de control real. Esto es *esperado* en este punto — se arregla en el paso 1.3. No es un bug a investigar ahora.

**Verificación:** que el comando corra sin excepciones de Python no capturadas (los `assert` fallando con traceback es el comportamiento esperado del baseline).

---

### [x] 0.3 — Commitear este plan

```bash
git add MIGRATION_PLAN.md .ref/
git commit -m "docs: add MIGRATION_PLAN.md, snapshot context-guard reference"
```

### [x] 0.4 — Tag de baseline

```bash
git tag pre-migration-baseline
```

**Verificación de cierre de Fase 0:** `git tag | grep pre-migration-baseline`

---

## Fase 1 — Integración (traer lo que sirve de context-guard)

Objetivo: dos mejoras aisladas y de bajo riesgo, sin tocar contratos públicos.

### [x] 1.1 — Detección de write-lock huérfano (fix de deadlock real)

**Problema que resuelve:** `scripts/_lock_utils.py::with_write_lock` hoy reintenta 40×50ms y si no consigue el lock tira `RuntimeError`. Si un proceso muere sosteniendo `.write-lock`, el change queda bloqueado para siempre — no hay recuperación automática. `context-guard` sí la tiene (`scripts/guard/locking.py::_is_write_lock_stale`).

**Referencia:** `.ref/context-guard/scripts/guard/locking.py` — función `_is_write_lock_stale` y su uso dentro de `with_write_lock`.

**Cambios concretos en `scripts/_lock_utils.py`:**

1. `try_acquire_lockfile` debe escribir contenido al lockfile (hoy lo deja vacío):
   ```python
   fd = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
   os.write(fd, f"{os.getpid()}\n{time.time()}\n".encode())
   os.close(fd)
   ```
2. Agregar función nueva `_is_write_lock_stale(lock_path, max_age_seconds=30)` — puerto adaptado de `_is_write_lock_stale` de context-guard: lee PID de la primera línea, `os.kill(pid, 0)` para detectar proceso muerto, segunda línea como timestamp para detectar antigüedad excesiva.
3. `with_write_lock` — dentro del loop de reintentos, si `try_acquire_lockfile` falla, verificar `_is_write_lock_stale`; si es stale, `os.remove` y reintentar inmediatamente sin esperar el `delay`. Si no es stale, seguir el retry normal hasta agotar `retries`.
4. **No tocar** la lógica del lock de sesión (`.lock`, `is_stale`, `check_lock_status`) — ese ya tiene su propio manejo de ACTIVE/STALE/FREE y está bien como está.

**Test nuevo:** `tests/unit/test_lock_utils_stale.py` (crear ahora, sirve también de base para 1.2):
```python
# Simula: crear .write-lock con un PID que no existe (ej. 999999) y
# timestamp viejo, luego confirmar que with_write_lock lo reclama
# y ejecuta la función pasada sin lanzar RuntimeError.
```

**Verificación:**
```bash
python3 -m pytest tests/unit/test_lock_utils_stale.py -q
python3 tests/concurrency_test.py   # TEST 2 (commit+checkpoint concurrentes) debe seguir en PASS
```

**Commit:** `fix: add stale write-lock detection to _lock_utils.py (ported from context-guard)`

---

### [x] 1.2 — Suite de tests unitarios granular (pytest)

**Problema que resuelve:** `state-guard` solo tiene `concurrency_test.py` (un script de asserts manuales) e `install_test.sh`. No hay tests unitarios aislados de `state_manager.py`. `context-guard` tiene 111 tests pytest, uno por módulo/comando.

**Referencia de estructura (no de contenido):** `.ref/context-guard/tests/` — un archivo por área funcional.

**Crear `tests/unit/` con estos archivos como mínimo** (adaptar cada uno a la API real de `state_manager.py`, no inventar comandos que no existen):

| Archivo | Cubre |
|---|---|
| `test_begin.py` | `cmd_begin`: fase válida/inválida, lock ya activo, TTL stale, migración automática v1→v2 disparada desde `begin` |
| `test_commit.py` | `cmd_commit`: transición válida, transición fuera del DAG, gate requerido sin token (`EXIT_GATE_REQUIRED`), auto-summary generado |
| `test_rollback.py` | `cmd_rollback`: transacción activa vs sin transacción |
| `test_checkpoint.py` | `cmd_checkpoint`: guardado normal, límite de `MAX_SUMMARY_CHARS` |
| `test_migration.py` | `_migrate_v1_to_v2`: los 3 casos de mapeo de fases (parcial, completo, sin avanzar) |
| `test_mark_task.py` | `cmd_mark_task`: tarea existente, inexistente, ya completada (idempotencia) |
| `test_next_task.py` | `cmd_next_task`: hay pendientes, todas completas, sin `tasks.md` |
| `test_verify_gate.py` | `cmd_verify_gate`: fase autorizada vs no autorizada |
| `test_lock_utils_stale.py` | ya creado en 1.1 |
| `test_sg_gate_pty.py` | `sg plan-approve` + `sg plan-confirm` usando **pty real** (ver snippet en Apéndice B) — token correcto, token incorrecto, gate ya usado |
| `test_sg_hotfix_pty.py` | `sg hotfix-init` + `sg hotfix-confirm` con pty real — mismo patrón que gate de plan |

**Regla de oro para estos tests:** cualquier test que ejercite `sg plan-approve`, `sg plan-confirm`, `sg hotfix-init` o `sg hotfix-confirm` **tiene que usar `pty.fork()`**, nunca `subprocess.run(..., capture_output=True)` con pipes puros — esos comandos abren `/dev/tty` explícitamente y fallan con `NO_TTY` sin una terminal de control real. Ver Apéndice B para el snippet ya verificado.

**Verificación:**
```bash
python3 -m pytest tests/unit -q
# Piso aceptable: 0 fallos, mínimo 35-40 tests reales (no placeholders).
```

**Commit:** `test: add granular pytest suite for state_manager.py and sg.py gate mechanism`

---

### [x] 1.3 — Arreglar el harness de `concurrency_test.py` (bug de TTY, no de lógica)

**Problema que resuelve:** el TEST que ejercita `sg plan-approve`/`hotfix-init` falla en `concurrency_test.py` porque usa `subprocess.run` con pipes, sin terminal de control. **Ya está verificado que el código de producción funciona bien** — el problema es 100% del harness de test. Esto es además un bloqueador explícito documentado en `phases/FASE_C_MCP_PENDIENTE.md` ("Fase A está mergeada y los tests de concurrencia pasan en CI").

**Cambio concreto:** en `tests/concurrency_test.py`, reemplazar el/los `subprocess.run` que invocan `sg.py plan-approve` / `sg.py hotfix-init` por el patrón `pty.fork()` del Apéndice B. El resto del archivo (TEST 1, 1b, 2, 3) no se toca — ya pasan.

**Verificación:**
```bash
python3 tests/concurrency_test.py
# TODOS los tests deben imprimir PASS, exit code 0.
# Repetir corriendo el comando dentro de un entorno explícitamente sin ctty
# para confirmar que pty.fork() resuelve el problema y no depende de la
# shell interactiva del desarrollador:
setsid python3 tests/concurrency_test.py < /dev/null
```

**Commit:** `test: fix concurrency_test.py TTY-dependent harness using pty.fork()`

---

### [x] 1.4 — Cierre de Fase 1

```bash
python3 -m pytest tests/unit -q
python3 tests/concurrency_test.py
bash tests/install_test.sh
git add -A
git commit -m "chore: close Phase 1 (Integración) — stale-lock fix + granular test suite"
git tag phase-1-integration-complete
```

**Verificación de cierre:** los tres comandos de arriba en verde, y `git tag | grep phase-1-integration-complete`.

---

## Fase 2 — Mejora (hacia el MCP)

Esta fase implementa exactamente lo que ya está especificado en `phases/FASE_C_MCP_PENDIENTE.md` — no hay que rediseñar nada, hay que ejecutar ese documento. Usar `.ref/context-guard/scripts/mcp_server.py` como plantilla **estructural** (patrón `FastMCP`, `@mcp.tool()`, docstrings como schema, wrapper `_format_result`), pero la lógica de negocio sale de `sg.py`, nunca de `state_manager.py` directo.

### [x] 2.1 — Confirmar precondiciones de Fase C

Antes de escribir código, verificar contra `phases/FASE_C_MCP_PENDIENTE.md` → sección "Criterios de aceptación para Fase C":
- [x] Fase A (tests de concurrencia) pasa — cerrado en 1.3/1.4.
- [x] Fase B (`sg.py` funciona con todos los comandos JSON) — ya existe, no requiere trabajo nuevo.
- [x] `next-task`, `verify-gate`, `mark-task` tienen tests de integración — cubierto en 1.2 (`test_next_task.py`, `test_verify_gate.py`, `test_mark_task.py`).

Si alguno de estos no está realmente verde en este punto, **parar y volver a Fase 1** — no seguir a 2.2.

---

### [x] 2.2 — Agregar `pyproject.toml` (state-guard hoy no tiene empaquetado Python)

**Hallazgo relevante:** `state-guard` no tiene `pyproject.toml`/`setup.py`. Se distribuye copiando archivos vía `scripts/install.sh`. Para exponer un servidor MCP instalable vía `uvx` (como ya funciona en `context-guard`), hace falta empaquetarlo.

Crear `pyproject.toml` en la raíz, análogo al de `context-guard` pero con nombre de paquete no genérico (a diferencia de `context-guard`, que usa `scripts` como nombre de paquete top-level — **no repetir ese error acá**, usar `state_guard` como nombre de paquete):

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "state-guard"
version = "2.0.0"
description = "Framework de memoria transaccional para agentes LLM (MCP)"
readme = "README.md"
requires-python = ">=3.9"
dependencies = ["mcp>=1.0.0"]

[project.scripts]
state-guard-mcp = "scripts.mcp_server:main"

[tool.hatch.build.targets.wheel]
packages = ["scripts"]
```

Nota: dejamos `packages = ["scripts"]` por consistencia con el layout actual del repo, pero si en algún momento se empaqueta para publicar en PyPI, renombrar el directorio interno a `state_guard_mcp/` para evitar la colisión de namespace que tiene `context-guard`.

**Verificación:** `python3 -c "import tomllib; tomllib.load(open('pyproject.toml','rb'))"` no tira error.

**Commit:** `build: add pyproject.toml for MCP packaging`

---

### [x] 2.3 — Implementar `scripts/mcp_server.py`

Implementar **exactamente** los 3 tools especificados en `phases/FASE_C_MCP_PENDIENTE.md`, ni más ni menos:

- `get_next_task(change: str)`
- `verify_phase_gate(change: str, phase: str)`
- `mark_task_completed(change: str, task_id: str)`

**Restricción explícita de diseño (no es negociable, ya está decidida en el propio repo):**
- El servidor MCP llama a `sg.py` (subprocess), **nunca** importa ni llama a `state_manager.py` directo.
- `begin`, `commit`, `rollback`, `checkpoint` **NO se exponen como tools MCP**. Estos siguen siendo invocados por el agente escribiendo `sg begin/commit/...` en la terminal, tal como ya describe `skills/_shared/memory-guard.md`. Esto es intencional y distinto de cómo lo resolvió `context-guard` (que sí expone begin/commit por MCP) — **no copiar ese patrón acá**, el diseño de `state-guard` separa a propósito el canal de control transaccional del canal MCP.
- `plan-approve`, `plan-confirm`, `hotfix-init`, `hotfix-confirm` tampoco se exponen — son exclusivamente humanos (ya documentado en el comentario de cabecera de `sg.py`).

Estructura sugerida (usar el patrón de `_format_result`/docstring-as-schema de `.ref/context-guard/scripts/mcp_server.py` como referencia de estilo, no copiar literal):

```python
#!/usr/bin/env python3
import json, os, subprocess, sys
from mcp.server.fastmcp import FastMCP

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SG = os.path.join(SCRIPT_DIR, "sg.py")

mcp = FastMCP("state-guard")

def _sg(*args):
    r = subprocess.run([sys.executable, SG] + list(args),
                        capture_output=True, text=True)
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

def main():
    mcp.run(transport="stdio")

if __name__ == "__main__":
    main()
```

**Verificación:**
```bash
pip install -e . --break-system-packages
python3 scripts/mcp_server.py &  # o probar el handshake como en el paso 2.4
```

**Commit:** `feat: implement scripts/mcp_server.py per FASE_C spec (get_next_task, verify_phase_gate, mark_task_completed)`

---

### [x] 2.4 — Verificación de protocolo real (no confiar solo en tests unitarios)

Igual que se hizo en la auditoría previa: probar el handshake MCP real por stdio, no solo invocar las funciones Python directamente.

```bash
python3 - <<'EOF'
import subprocess, json, time
proc = subprocess.Popen(['python3','scripts/mcp_server.py'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
    text=True, bufsize=1)
def send(msg):
    proc.stdin.write(json.dumps(msg)+'\n'); proc.stdin.flush()
send({'jsonrpc':'2.0','id':1,'method':'initialize',
      'params':{'protocolVersion':'2024-11-05','capabilities':{},
                'clientInfo':{'name':'t','version':'0.1'}}})
time.sleep(0.3); print(proc.stdout.readline())
send({'jsonrpc':'2.0','method':'notifications/initialized'})
time.sleep(0.2)
send({'jsonrpc':'2.0','id':2,'method':'tools/list','params':{}})
time.sleep(0.3); print(proc.stdout.readline())
proc.terminate()
EOF
```

**Criterio de aceptación:** la respuesta a `tools/list` debe listar exactamente 3 tools (`get_next_task`, `verify_phase_gate`, `mark_task_completed`), ni más ni menos.

**Commit:** ninguno (esto es verificación, no cambia código). Si falla, volver a 2.3.

---

### [x] 2.5 — Test de integración del servidor MCP

Crear `tests/unit/test_mcp_server.py` (invocando las funciones Python directas, como hace `context-guard`) **más** un test que reproduzca el handshake del paso 2.4 dentro de pytest (no solo a mano).

**Verificación:** `python3 -m pytest tests/unit/test_mcp_server.py -q`

**Commit:** `test: add MCP server tests (function-level + real stdio handshake)`

---

### [x] 2.6 — Cierre de Fase 2

```bash
python3 -m pytest tests/unit -q
python3 tests/concurrency_test.py
git add -A
git commit -m "chore: close Phase 2 (Mejora — MCP)"
git tag phase-2-mcp-complete
```

---

## Fase 3 — Documentación y distribución

### [x] 3.1 — Arreglar `scripts/install.sh` (bug real de distribución)

**Hallazgo de la auditoría:** `install.sh` copia `state_manager.py` y `_lock_utils.py` a `~/.agents/skills/state-guard/bin/`, y el texto de bootstrap inyectado en `GEMINI.md`/`opencode.jsonc` le dice al agente que llame **directo** a `state_manager.py begin|commit|rollback|checkpoint|status`. **`sg.py` nunca se copia ni se menciona.** Esto significa que, tal como está hoy, un agente recién instalado va a pegar contra `EXIT_GATE_REQUIRED` al intentar comitear la fase `plan` (porque `cmd_commit` exige un gate humano) sin que el bootstrap le explique que existe `sg plan-approve` / `sg plan-confirm`. El gate humano y el hotfix bypass, hoy, están desconectados del flujo real de instalación.

**Cambios concretos en `scripts/install.sh`:**
1. Agregar `sg.py` a la copia de binarios: `cp "$SCRIPT_DIR/sg.py" "$TARGET_DIR/bin/"` junto a `state_manager.py` y `_lock_utils.py`.
2. Actualizar `BOOTSTRAP_TEXT` para que instruya usar `sg` (no `state_manager.py` directo) para todo lo que no sea gate/hotfix, y agregar el flujo de gate humano explícitamente:
   ```
   3. State manager: $TARGET_DIR/bin/sg.py
      Subcomandos operativos (agente): begin | commit | rollback | checkpoint | status
                                        | next-task | verify-gate | mark-task
      Subcomandos EXCLUSIVOS DE HUMANO (el agente nunca los ejecuta):
                                        plan-approve | plan-confirm | hotfix-init | hotfix-confirm
      Si 'commit' devuelve EXIT_GATE_REQUIRED (5): DETENÉ el ciclo y pedile
      al usuario que corra 'sg plan-approve --change <nombre>' en su propia
      terminal, y luego 'sg plan-confirm --change <nombre> --token <CODIGO>'.
   ```
3. Opcional pero recomendado: al final del instalador, ofrecer correr `sg install-hooks` automáticamente (o al menos imprimir el comando sugerido) para que el hook de `post-commit` quede activo desde el primer uso.

**Verificación:**
```bash
bash tests/install_test.sh
grep -q "sg.py" scripts/install.sh && echo OK
```

**Commit:** `fix: wire sg.py (not state_manager.py directly) into install.sh bootstrap, document human gate flow`

---

### [x] 3.2 — `MANUAL.md`: sección nueva "Capa `sg.py` — CLI, Gate Humano y Hotfix"

Hoy `MANUAL.md` no menciona `sg.py`, `plan-approve`, `hotfix-init` ni `install-hooks` en absoluto (verificado: cero coincidencias). Agregar sección nueva después de "### Migración v1 → v2" (línea ~169) con:
- Qué es `sg.py` y por qué existe (JSON puro, wrapper sobre `state_manager.py`, único punto de entrada válido para mutar el manifiesto).
- El mecanismo de gate humano out-of-band: por qué el token solo se muestra por `/dev/tty`, por qué se guarda solo el hash, por qué requiere 2 pasos en 2 invocaciones distintas.
- El flujo de `hotfix-init`/`hotfix-confirm` y cuándo usarlo legítimamente (con la razón quedando registrada en `state.ini[Gate]`).
- `sg install-hooks`: qué instala (`post-commit` → `sg status`), y que es informativo, no bloqueante (a diferencia del gate de `commit`, que sí bloquea).
- Tabla de exit codes de `sg.py`/`state_manager.py` (ya existen como constantes `EXIT_*` en `state_manager.py` — documentarlas tal como están, no inventar nuevas).

**Commit:** `docs: document sg.py, human gate mechanism, and hotfix bypass in MANUAL.md`

---

### [x] 3.3 — `MANUAL.md`: sección nueva "Servidor MCP"

Agregar sección documentando:
- Los 3 tools expuestos y su contrato de I/O (copiar la tabla de `phases/FASE_C_MCP_PENDIENTE.md`, ya que ahora está implementada).
- Por qué `begin/commit/rollback/checkpoint` y los comandos de gate **no** son tools MCP (decisión de diseño, no limitación técnica).
- Instrucciones de configuración para clientes MCP (`claude_desktop_config.json` / equivalente), siguiendo el mismo formato que ya usa `context-guard/README.md` (Opción A: `uvx`, Opción B: instalación local con venv).

**Commit:** `docs: document MCP server usage in MANUAL.md`

---

### [x] 3.4 — `README.md`: instrucciones de instalación MCP

Agregar al `README.md` de `state-guard` una sección "Instalación (MCP)" con el mismo formato de bloques JSON que tiene `context-guard/README.md` (Opción A `uvx`, Opción B instalación local), adaptada al nuevo `pyproject.toml` del paso 2.2 y al entry point `state-guard-mcp`.

**Commit:** `docs: add MCP installation instructions to README.md`

---

### [x] 3.5 — `CHANGELOG.md`

Agregar entrada nueva siguiendo el formato ya usado (ver entradas `[1.1.0]`/`[1.0.0]` de `context-guard` como referencia de tono, adaptado a las convenciones ya usadas en el `CHANGELOG.md` de `state-guard`):

```markdown
## [2.1.0] - <fecha>

### Integración (Fase 1)
- Detección de write-lock huérfano (PID + antigüedad), portada desde context-guard.
- Suite de tests unitarios granular (tests/unit/), ~N tests.
- Fix de harness de concurrency_test.py (pty.fork en vez de subprocess.PIPE).

### Servidor MCP (Fase 2)
- Implementación de Fase C: scripts/mcp_server.py con 3 tools
  (get_next_task, verify_phase_gate, mark_task_completed).
- pyproject.toml para instalación vía uvx / pip.

### Documentación y distribución (Fase 3)
- install.sh ahora bootstrapea sg.py (antes usaba state_manager.py directo,
  dejando el gate humano desconectado del flujo real).
- MANUAL.md: secciones nuevas sobre sg.py, gate humano, hotfix bypass y MCP.
- context-guard queda deprecado; sus features útiles fueron consolidadas acá.
```

**Commit:** `docs: update CHANGELOG.md for 2.1.0`

---

### [x] 3.6 — Deprecar `context-guard` y limpiar `.ref/`

1. En el repo `context-guard` (el otro repo, no este): agregar al tope de su `README.md`:
   ```markdown
   > ⚠️ **Proyecto archivado.** Sus features fueron consolidadas en
   > [state-guard](<url-del-repo-state-guard>). Este repo se mantiene
   > solo como referencia histórica y no recibe más desarrollo.
   ```
   Commitear ese cambio en el repo `context-guard`, no acá.

2. En `state-guard`, borrar la carpeta de referencia ya usada:
   ```bash
   git rm -r .ref/
   git commit -m "chore: remove .ref/context-guard, migration complete"
   ```

**Verificación:** `test ! -d .ref/context-guard && echo OK`

---

### [x] 3.7 — Cierre de Fase 3 y release

```bash
python3 -m pytest tests/unit -q
python3 tests/concurrency_test.py
bash tests/install_test.sh
git add -A
git commit -m "chore: close Phase 3 (Documentación) — v2.1.0"
git tag v2.1.0
```

## Fase 4 — Spec-Driven Coding parity + Agent Hooks (paridad con Kiro Code)

**Contexto y alcance de esta fase:** dos features de Kiro Code, tratadas como dos sub-fases independientes porque tienen perfiles de riesgo distintos.

- **4A (Spec-Driven Coding)**: extiende artefactos y agrega validación de contenido real en código. Riesgo bajo, no toca locking ni concurrencia.
- **4B (Agent Hooks)**: componente nuevo (daemon de filesystem + executor de agentes headless). Riesgo medio — es la primera vez que algo en este repo dispara un agente sin que un humano lo pida en el momento.

### Nota de decisión — por qué se reversa la regla de `plan.md` único

`phases/plan.md` (línea 193 en la versión actual) dice explícitamente: *"El único archivo de propuesta es `plan.md`; NO crear `proposal.md`, `design.md` separados bajo el nuevo esquema"*. Esa regla fue correcta cuando el objetivo era colapsar 8 fases en 3 y reducir ceremonia. Fase 4A la revierte **parcialmente y a propósito**: separa `plan.md` en `objective.md` + `design.md` porque es precisamente lo que hace falta para paridad con Kiro (documento de diseño y flujo de datos como artefactos de primera clase, no secciones enterradas en un archivo consolidado). No es un rebote hacia el esquema v1 de 8 fases — siguen siendo 3 fases, solo que la fase `plan` ahora produce 2 artefactos en vez de 1.

**Regla dura de esta fase:** no tocar el DAG de 3 fases, no tocar el schema `state.ini`, no agregar una fase nueva. Todo pasa dentro de lo que ya produce/consume la fase `plan`.

---

## Fase 4A — Spec-Driven Coding

### [x] 4.1 — Definir el split de contenido entre `objective.md` y `design.md`

No es ambigüedad de implementación, es una decisión de contenido que hay que fijar antes de tocar código:

**`objective.md`** (el qué y el por qué — lo que hoy son las secciones 1.3 de `phases/plan.md`):
```markdown
# Objective: {Título del Cambio}

## Intención
{Qué problema resuelve y por qué}

## Alcance
### Dentro del Alcance
- {entregable}
### Fuera del Alcance
- {diferido}

## Criterios de Éxito
- [ ] {resultado medible 1}

## Preguntas Abiertas
- [ ] {pregunta no resuelta — si bloquea, marcá con [!]}
```

**`design.md`** (el cómo y el impacto — hoy secciones 1.5 de `phases/plan.md`):
```markdown
# Design: {Título del Cambio}

## Enfoque Técnico
{Estrategia general}

## Áreas Afectadas
| Área | Impacto | Descripción |
|------|---------|-------------|

## Decisiones de Arquitectura
### Decisión: {Título}
**Elección**: {qué elegimos}
**Alternativas**: {qué descartamos}
**Justificación**: {por qué}

## Flujo de Datos
{diagrama ASCII o Mermaid}

## Archivos Afectados
| Archivo | Acción | Descripción |
|---------|--------|-------------|

## Estrategia de Testing
| Capa | Qué testear | Enfoque |
|------|-------------|---------|

## Riesgos
| Riesgo | Probabilidad | Mitigación |
|--------|-------------|-----------|

## Plan de Rollback
{Cómo revertir si algo sale mal}
```

`tasks.md` no cambia — sigue siendo artefacto de la fase `execute`, sin modificaciones.

**Verificación:** ninguna (paso de definición, no de código). Sirve de contrato para 4.2-4.4.

---

### [x] 4.2 — Reescribir `phases/plan.md` para producir los dos artefactos

Cambios concretos:
1. Sub-paso 1.6 ("Persistir el DRAFT") pasa a crear `objective.md` **y** `design.md`, no `plan.md`.
2. Eliminar la línea 193 completa ("El único archivo de propuesta es `plan.md`...") y reemplazarla por:
   ```
   - Los artefactos de propuesta son `objective.md` y `design.md`, cada uno con su
     propósito específico (ver plantillas). NO fusionarlos en un solo archivo.
   ```
3. Sub-paso 2 (GATE), punto 1: "Presentar el `plan.md`" → "Presentar `objective.md` y `design.md`".
4. Sub-paso 2, punto 3: **antes** de ejecutar `plan-approve`, agregar una validación previa (ver 4.3):
   ```bash
   python3 scripts/sg.py validate-spec --change {change-name}
   ```
   Si esto devuelve `ok: false`, el modelo NO ejecuta `plan-approve` — corrige el/los artefacto(s) señalados y reintenta. Esto es intencional: la validación estructural se resuelve sola, sin interrumpir al humano; el gate humano se reserva para cuando el spec ya está completo.
5. Actualizar el árbol de archivos de la sección 1.6:
   ```
   .state-guard/changes/{change-name}/
   ├── objective.md         ← qué y por qué
   ├── design.md             ← cómo, arquitectura, flujo de datos
   └── specs/
       └── {dominio}/
           └── spec.md
   ```

**Verificación:** `grep -c "plan.md" phases/plan.md` debe dar `0` (todas las referencias migradas a `objective.md`/`design.md`), salvo comentarios históricos que decidas dejar explícitamente marcados como tal.

**Commit:** `feat: split plan.md into objective.md + design.md in PLAN phase`

---

### [x] 4.3 — Validación de contenido real en código (`validate-spec`)

**Esto es lo que hoy NO existe.** El único gate real de `plan` es el token humano (`cmd_commit`, líneas ~224-242 de `state_manager.py`) — cero validación de contenido de los artefactos.

**Agregar a `scripts/state_manager.py`:**

```python
def cmd_validate_spec(args):
    """Valida objective.md y design.md antes de habilitar el gate humano.
    No muta estado — solo lee y reporta. Exit 0 siempre (el resultado va en JSON)."""
    change_dir = Path(f".state-guard/changes/{args.change}")
    objective_path = change_dir / "objective.md"
    design_path = change_dir / "design.md"

    issues = []

    for label, path, required_sections in [
        ("objective.md", objective_path, ["## Intención", "## Alcance", "## Criterios de Éxito"]),
        ("design.md", design_path, ["## Decisiones de Arquitectura", "## Flujo de Datos", "## Archivos Afectados"]),
    ]:
        if not path.exists():
            issues.append({"file": label, "issue": "MISSING_FILE"})
            continue
        content = path.read_text(encoding="utf-8")
        if "[!]" in content:
            issues.append({"file": label, "issue": "BLOCKING_OPEN_QUESTION",
                            "detail": "Hay preguntas abiertas marcadas [!] sin resolver."})
        for section in required_sections:
            if section not in content:
                issues.append({"file": label, "issue": "MISSING_SECTION", "detail": section})
        # placeholders de plantilla sin completar, ej. "{Qué problema resuelve y por qué}"
        import re
        unresolved = re.findall(r"\{[A-ZÁÉÍÓÚa-záéíóú][^}]{3,80}\}", content)
        if unresolved:
            issues.append({"file": label, "issue": "UNRESOLVED_PLACEHOLDER",
                            "detail": unresolved[:5]})

    result = {"ok": len(issues) == 0, "change": args.change, "issues": issues}
    print(json.dumps(result, ensure_ascii=False))
    sys.exit(EXIT_OK if not issues else EXIT_VALIDATION)
```

Registrar el subcomando `validate-spec --change` en el parser de `state_manager.py`, y agregar el wrapper correspondiente en `sg.py` (`cmd_validate_spec`, delegando igual que los demás — no duplicar lógica, tal como indica el docstring de `sg.py`).

**Decisión de diseño explícita:** `validate-spec` es de solo lectura, no requiere lock de escritura (no llama `with_write_lock`) porque no muta `state.ini`. Es seguro llamarlo cuantas veces haga falta mientras se itera el draft.

**No conectarlo dentro de `cmd_plan_approve` como bloqueo forzado todavía** — dejalo como paso explícito que el propio `phases/plan.md` instruye ejecutar antes de `plan-approve` (ya lo agregaste en 4.2, punto 4). Forzarlo dentro de `plan-approve` es un endurecimiento razonable a futuro, pero acoplaría el gate humano a la validación estructural de una forma que hoy no necesitás — mantenelo como dos pasos separados y auditables por separado.

**Verificación:**
```bash
# Caso negativo: crear un change con objective.md incompleto (sin ## Criterios de Éxito)
# y confirmar que validate-spec reporta MISSING_SECTION.
python3 scripts/sg.py validate-spec --change <change-de-prueba>
```

**Commit:** `feat: add sg validate-spec — structural validation of objective.md/design.md`

---

### [x] 4.4 — Actualizar referencias obsoletas a `plan.md` en el resto del repo

Hallazgo de la auditoría: estos archivos ya referencian `design.md` como si existiera (estaban adelantados a esta fase) o referencian `plan.md` como archivo único (quedan obsoletos). Alinear todos a `objective.md` + `design.md`:

- `phases/execute.md` (líneas 16, 29)
- `phases/verify.md` (líneas 17, 56)
- `phases/_shared/context-injection.md` (líneas 9-10 — la tabla de dependencias por fase)
- `skills/_shared/convention.md` (líneas 17, 21, 36, 95, 97)
- `skills/review/SKILL.md` (línea 44 — ya decía `design.md`, ahora es consistente)
- `skills/checkpoint/SKILL.md` (líneas 51, 53 — ya asumía `design.md` existente; verificar que la extracción de "Decisiones de Arquitectura" siga apuntando a la sección correcta ahora que vive en `design.md` en vez de en `plan.md`)
- `skills/continue/SKILL.md` (línea 53)
- `skills/ff/SKILL.md` (línea 46)
- `skills/new/SKILL.md` (línea 29)
- `skills/hotfix/SKILL.md` (línea 25 — el hotfix salta PLAN, así que dice "no existirá `plan.md`"; actualizar a "no existirán `objective.md` ni `design.md`")

**Verificación:**
```bash
grep -rn "plan\.md" phases/ skills/ --include="*.md" | grep -v "objective.md\|design.md"
# Debe devolver 0 líneas, o solo líneas donde "plan.md" sea intencional
# (ninguna debería serlo tras este paso).
```

**Commit:** `docs: update all plan.md references to objective.md/design.md across phases/ and skills/`

---

### [x] 4.5 — Tests

Crear `tests/unit/test_validate_spec.py`:
- `objective.md` y `design.md` completos → `ok: true`, `issues: []`
- Falta `design.md` → `MISSING_FILE`
- `objective.md` con `[!]` → `BLOCKING_OPEN_QUESTION`
- `design.md` sin sección `## Flujo de Datos` → `MISSING_SECTION`
- Placeholder de plantilla sin completar (ej. `{Qué problema resuelve...}` textual) → `UNRESOLVED_PLACEHOLDER`

**Verificación:** `python3 -m pytest tests/unit/test_validate_spec.py -q`

**Commit:** `test: add validate-spec unit tests`

---

### [x] 4.6 — Cierre de Fase 4A

```bash
python3 -m pytest tests/unit -q
python3 tests/concurrency_test.py
git add -A
git commit -m "chore: close Phase 4A (Spec-Driven Coding parity)"
git tag phase-4a-spec-driven-complete
```

---

## Fase 4B — Agent Hooks

### [ ] 4.7 — Modelo de confianza (fijado por decisión tuya, no rediscutir)

Regla explícita, documentada acá para que ningún agente la reinterprete:

| Acción | Quién la dispara | Gate humano |
|---|---|---|
| `plan-approve` / `plan-confirm` (aprobar objective.md/design.md) | Solo humano, siempre | Sí — sin cambios |
| `hotfix-init` / `hotfix-confirm` | Solo humano, siempre | Sí — sin cambios |
| Actualizar tests derivados de un cambio | Hook automático permitido | **No** |
| Sincronizar documentación (README/MANUAL secciones autogeneradas) | Hook automático permitido | **No** |
| `mark_task_completed` en `tasks.md` | Hook automático permitido | **No** |
| Cualquier escritura dentro de `.state-guard/changes/*/objective.md` o `design.md` | **Prohibido para hooks** | N/A — un hook nunca toca estos dos archivos, ni para "arreglarlos" |

La distinción no es "riesgo alto vs bajo" en abstracto — es específicamente **arquitectura vs derivados**. Un hook puede regenerar tests o sincronizar docs porque son consecuencia mecánica de un `tasks.md` ya aprobado; un hook nunca decide ni ajusta intención o diseño, eso quedó reservado para el humano en 4A.

**Verificación:** ninguna (es una tabla de política, se aplica en 4.9-4.10).

---

### [ ] 4.8 — `scripts/hook_daemon.py`: watcher de filesystem

Agregar dependencia opcional en `pyproject.toml`:
```toml
[project.optional-dependencies]
hooks = ["watchdog>=4.0,<5.0"]
```

Crear `scripts/hook_daemon.py`:

```python
#!/usr/bin/env python3
"""Agent Hooks daemon — observa el filesystem y dispara acciones declaradas
en .state-guard/hooks.yaml. Solo ejecuta acciones de la categoría "derivada"
(ver Fase 4B, paso 4.7) — nunca toca objective.md/design.md ni el gate humano."""
import json
import subprocess
import sys
import time
from pathlib import Path

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import yaml

REPO_ROOT = Path.cwd()
RULES_FILE = REPO_ROOT / ".state-guard" / "hooks.yaml"
LOG_FILE = REPO_ROOT / ".state-guard" / "hooks.log.jsonl"
EXCLUDED_PREFIXES = (".state-guard/", ".git/")  # nunca reaccionar a sus propios efectos
FORBIDDEN_PATTERNS = ("objective.md", "design.md")  # nunca disparar sobre estos, pase lo que pase


def _log(entry: dict):
    entry["ts"] = time.time()
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


def _load_rules():
    if not RULES_FILE.exists():
        return []
    with open(RULES_FILE, encoding="utf-8") as f:
        return yaml.safe_load(f).get("hooks", [])


class HookHandler(FileSystemEventHandler):
    def __init__(self, rules):
        self.rules = rules
        self._debounce = {}  # path -> last_trigger_ts

    def _should_skip(self, path: str) -> bool:
        rel = str(Path(path).relative_to(REPO_ROOT))
        if any(rel.startswith(p) for p in EXCLUDED_PREFIXES):
            return True
        if any(f in rel for f in FORBIDDEN_PATTERNS):
            return True
        now = time.time()
        last = self._debounce.get(rel, 0)
        if now - last < 2.0:  # debounce de 2s por archivo
            return True
        self._debounce[rel] = now
        return False

    def on_modified(self, event):
        if event.is_directory or self._should_skip(event.src_path):
            return
        rel = str(Path(event.src_path).relative_to(REPO_ROOT))
        for rule in self.rules:
            if Path(rel).match(rule["pattern"]) and "on_save" in rule["events"]:
                self._fire(rule, rel)

    def _fire(self, rule, path):
        prompt = rule["prompt"].format(path=path)
        _log({"rule": rule["name"], "path": path, "status": "triggered"})
        try:
            result = subprocess.run(
                rule["agent_command"] + [prompt],
                cwd=str(REPO_ROOT), capture_output=True, text=True, timeout=rule.get("timeout", 120),
            )
            _log({"rule": rule["name"], "path": path, "status": "done",
                  "returncode": result.returncode})
        except Exception as e:
            _log({"rule": rule["name"], "path": path, "status": "error", "error": str(e)})


def main():
    rules = _load_rules()
    if not rules:
        print("No hay reglas en .state-guard/hooks.yaml. Nada que observar.")
        return
    observer = Observer()
    observer.schedule(HookHandler(rules), str(REPO_ROOT), recursive=True)
    observer.start()
    print(f"Agent Hooks daemon activo. {len(rules)} reglas cargadas. Log: {LOG_FILE}")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()


if __name__ == "__main__":
    main()
```

**Decisiones de diseño no negociables acá:**
- `FORBIDDEN_PATTERNS` está hardcodeado en el daemon, no en `hooks.yaml` — que la lista de "archivos que un hook nunca puede tocar" viva en el YAML significa que alguien podría editarla sin darse cuenta de la implicancia. Vive en código a propósito.
- El daemon **nunca** llama `sg plan-approve`, `sg plan-confirm`, `sg hotfix-init` ni `sg hotfix-confirm` — ni directa ni indirectamente vía el `agent_command` que ejecuta (eso lo controla `hooks.yaml`, ver 4.9, pero la restricción de fondo es de diseño, no de config).

**Verificación:** `pip install -e ".[hooks]" --break-system-packages` instala sin error.

**Commit:** `feat: add scripts/hook_daemon.py (filesystem watcher, no dependency on state_manager.py)`

---

### [ ] 4.9 — `.state-guard/hooks.yaml` — reglas declarativas

Crear `.state-guard/hooks.yaml.example` (versionado, se copia a `hooks.yaml` real en la instalación — `hooks.yaml` sin `.example` va a `.gitignore` porque puede tener paths locales):

```yaml
hooks:
  - name: sync-tests-on-save
    pattern: "**/scripts/**/*.py"
    events: ["on_save"]
    prompt: >
      Se modificó {path}. Revisá si los tests unitarios correspondientes en
      tests/unit/ siguen reflejando el comportamiento actual. Si hace falta
      actualizar un assert o agregar un caso, hacelo. No toques la lógica de
      producción, solo tests.
    agent_command: ["claude", "-p", "--dangerously-skip-permissions"]
    timeout: 180

  - name: sync-docs-on-save
    pattern: "phases/*.md"
    events: ["on_save"]
    prompt: >
      Se modificó la fase {path}. Revisá si MANUAL.md tiene una sección
      desactualizada respecto a este archivo y sincronizala. No modifiques
      la fase en sí.
    agent_command: ["claude", "-p", "--dangerously-skip-permissions"]
    timeout: 120
```

Agregar `.state-guard/hooks.yaml` a `.gitignore` (el `.example` sí se commitea).

**Nota importante para vos:** `agent_command` es configurable por regla — podés apuntar a `claude -p`, a un comando de OpenCode en modo no interactivo, o a un script propio. El flag exacto de "sin confirmación interactiva" depende de qué CLI uses y de su versión — confirmalo contra la ayuda de tu CLI (`--help`) antes de dejarlo así en producción, no asumas que el flag de arriba es válido en tu versión instalada.

**Verificación:** `python3 -c "import yaml; yaml.safe_load(open('.state-guard/hooks.yaml.example'))"` no tira error.

**Commit:** `feat: add .state-guard/hooks.yaml.example with declarative rule schema`

---

### [ ] 4.10 — Auditoría: todo lo que hace un hook queda logueado

Ya cubierto por `_log()` en 4.8 (`hooks.log.jsonl`). Confirmar en este paso:
- Cada disparo queda registrado con `rule`, `path`, `status` (`triggered`/`done`/`error`) y timestamp.
- El log es append-only, nunca se sobreescribe.
- Agregar a `MANUAL.md` (paso 4.14) que este log es la fuente para auditar qué hizo un agente en background sin supervisión en el momento — es el mecanismo de trazabilidad que reemplaza al gate humano en estas acciones derivadas.

**Verificación:** disparar un hook manualmente (tocar un archivo que matchee un `pattern`) y confirmar una línea nueva en `.state-guard/hooks.log.jsonl`.

**Commit:** ninguno (ya cubierto en 4.8, este paso es solo de verificación).

---

### [ ] 4.11 — Wiring en `sg.py`

Agregar subcomandos delgados (delegan al daemon, no reimplementan nada):

```python
def cmd_hooks_start(args):
    import subprocess as sp
    daemon = SCRIPT_DIR / "hook_daemon.py"
    proc = sp.Popen([sys.executable, str(daemon)], cwd=str(REPO_ROOT))
    (SG_DIR / "hooks.pid").write_text(str(proc.pid))
    _emit({"ok": True, "pid": proc.pid, "message": "Agent Hooks daemon iniciado en background."})

def cmd_hooks_stop(args):
    import signal
    pid_file = SG_DIR / "hooks.pid"
    if not pid_file.exists():
        _emit({"ok": False, "message": "No hay daemon corriendo (no se encontró hooks.pid)."}, 1)
    pid = int(pid_file.read_text())
    try:
        os.kill(pid, signal.SIGTERM)
    except ProcessLookupError:
        pass
    pid_file.unlink()
    _emit({"ok": True, "message": f"Daemon (pid {pid}) detenido."})

def cmd_hooks_status(args):
    pid_file = SG_DIR / "hooks.pid"
    if not pid_file.exists():
        _emit({"ok": True, "running": False})
    pid = int(pid_file.read_text())
    try:
        os.kill(pid, 0)
        _emit({"ok": True, "running": True, "pid": pid})
    except ProcessLookupError:
        pid_file.unlink()
        _emit({"ok": True, "running": False, "stale_pid_removed": True})
```

Registrar `hooks-start`, `hooks-stop`, `hooks-status` en el parser y en el `dispatch` de `main()`.

**Verificación:**
```bash
sg hooks-start   # -> {"ok": true, "pid": ...}
sg hooks-status  # -> {"ok": true, "running": true, "pid": ...}
sg hooks-stop    # -> {"ok": true, ...}
sg hooks-status  # -> {"ok": true, "running": false}
```

**Commit:** `feat: wire hooks-start/stop/status into sg.py`

---

### [ ] 4.12 — Tests (modo dry-run, sin invocar un agente real)

Crear `tests/unit/test_hook_daemon.py`:
- `_should_skip` devuelve `True` para paths bajo `.state-guard/` y `.git/`.
- `_should_skip` devuelve `True` para cualquier path que contenga `objective.md` o `design.md`, sin excepción.
- Debounce: dos eventos sobre el mismo archivo en menos de 2s → solo el primero dispara.
- `_load_rules` con un `hooks.yaml` malformado no crashea el proceso (devuelve lista vacía o error controlado).
- Mockear `subprocess.run` en `_fire` para no depender de tener un agente real instalado en el entorno de test.

**Verificación:** `python3 -m pytest tests/unit/test_hook_daemon.py -q`

**Commit:** `test: add hook_daemon unit tests (dry-run, no real agent invocation)`

---

### [ ] 4.13 — Documentación

- `MANUAL.md`: sección nueva "Agent Hooks" — modelo de confianza (tabla del paso 4.7), cómo se arma `hooks.yaml`, dónde queda el log, cómo levantar/bajar el daemon.
- `MANUAL.md`: actualizar la sección de `sg.py` (agregada en la Fase 3 de la migración anterior) con `validate-spec`, `hooks-start`, `hooks-stop`, `hooks-status`.
- `README.md`: mención breve de "instalación opcional: `pip install -e '.[hooks]'`" para quien quiera Agent Hooks.
- `CHANGELOG.md`: entrada nueva `[2.6.0]` resumiendo 4A y 4B.

**Commit:** `docs: document Spec-Driven Coding split and Agent Hooks in MANUAL.md/README.md/CHANGELOG.md`

---

### [ ] 4.14 — Cierre de Fase 4B y release

```bash
python3 -m pytest tests/unit -q
python3 tests/concurrency_test.py
git add -A
git commit -m "chore: close Phase 4B (Agent Hooks) — v2.6.0"
git tag v2.6.0
```

---

## Apéndice A — Checklist resumido (para vista rápida de progreso)

```
Fase 0 — Preparación
  [x] 0.1 .ref/context-guard/
  [x] 0.2 baseline documentado
  [x] 0.3 plan commiteado
  [x] 0.4 tag pre-migration-baseline

Fase 1 — Integración
  [x] 1.1 stale write-lock detection
  [x] 1.2 suite pytest granular
  [x] 1.3 fix harness TTY de concurrency_test.py
  [x] 1.4 tag phase-1-integration-complete

Fase 2 — Mejora (MCP)
  [x] 2.1 precondiciones de Fase C confirmadas
  [x] 2.2 pyproject.toml
  [x] 2.3 scripts/mcp_server.py (3 tools)
  [x] 2.4 verificación de handshake real
  [x] 2.5 tests del servidor MCP
  [x] 2.6 tag phase-2-mcp-complete

Fase 3 — Documentación
  [x] 3.1 fix install.sh (bootstrap real de sg.py)
  [x] 3.2 MANUAL.md — sección sg.py / gate / hotfix
  [x] 3.3 MANUAL.md — sección MCP
  [x] 3.4 README.md — instalación MCP
  [x] 3.5 CHANGELOG.md
  [x] 3.6 deprecar context-guard + borrar .ref/
  [x] 3.7 tag v2.5.0 (cierre)
  
Fase 4A — Spec-Driven Coding
  [x] 4.1 split objective.md/design.md definido
  [x] 4.2 phases/plan.md reescrito
  [x] 4.3 sg validate-spec implementado
  [x] 4.4 referencias obsoletas actualizadas
  [x] 4.5 tests de validate-spec
  [x] 4.6 tag phase-4a-spec-driven-complete

Fase 4B — Agent Hooks
  [ ] 4.7 modelo de confianza documentado (tabla arquitectura vs derivados)
  [ ] 4.8 scripts/hook_daemon.py
  [ ] 4.9 .state-guard/hooks.yaml.example
  [ ] 4.10 verificación de logging
  [ ] 4.11 sg hooks-start/stop/status
  [ ] 4.12 tests de hook_daemon (dry-run)
  [ ] 4.13 documentación
  [ ] 4.14 tag v2.6.0 (cierre)
```

---

## Apéndice B — Snippet verificado para tests con TTY real (`pty.fork()`)

Usar este patrón en **cualquier** test que invoque `sg plan-approve`, `sg plan-confirm`, `sg hotfix-init` o `sg hotfix-confirm`. Ya fue probado y confirmado funcional durante la auditoría de este plan:

```python
import pty, os, sys, time

def run_with_pty(argv, timeout=2.0):
    """Corre argv (lista) con una terminal de control real.
    Retorna el output combinado (stdout+stderr mezclado, como en una tty real)."""
    pid, fd = pty.fork()
    if pid == 0:
        os.execvp(argv[0], argv)
    else:
        time.sleep(timeout)
        try:
            data = os.read(fd, 8192)
        except OSError:
            data = b""
        os.waitpid(pid, 0)
        return data.decode(errors="replace")

# Ejemplo de uso:
output = run_with_pty([sys.executable, "scripts/sg.py", "plan-approve", "--change", "test-change"])
assert "GATE PREPARADO" in output
```

**Por qué NO alcanza con `subprocess.Popen(..., stdin=pty_fd)`:** `/dev/tty` se resuelve contra la terminal de control del *proceso*, no contra su stdin. Pasar un pty solo como stdin no es suficiente — hace falta que el proceso hijo sea session leader de una terminal real, que es lo que `pty.fork()` garantiza y `subprocess.Popen` con pipes no.

---

## Apéndice C — Decisiones de diseño ya tomadas (no volver a discutir)

- `state-guard` es el proyecto que sobrevive. `context-guard` se archiva, no se borra.
- El schema `state.ini` v2 (3 fases) no cambia en este plan.
- El servidor MCP expone solo 3 tools de solo lectura/utilidad (`get_next_task`, `verify_phase_gate`, `mark_task_completed`). El control transaccional (`begin/commit/rollback`) y los gates humanos siguen siendo exclusivamente CLI/terminal — esto es intencional, no un recorte de alcance.
- El nombre de paquete Python es `state_guard`/`scripts` (mismo layout que ya existe), no se renombra el árbol de directorios del repo.
- Redacción: Gemini 3.6 Flash. Revisión de 1.1 y 2.3/2.4: obligatoria, con modelo distinto al que redactó.
- `objective.md`/`design.md` reemplazan a `plan.md`. Esto reversa deliberadamente la regla previa de "un solo archivo de propuesta" — no es un error, está documentado en la nota de decisión al inicio de esta fase.
- `validate-spec` es de solo lectura, no bloquea por código dentro de `plan-approve` — es un paso separado que `phases/plan.md` instruye ejecutar antes.
- Agent Hooks nunca tocan `objective.md` ni `design.md`, sin excepción, sin importar la regla que se agregue a `hooks.yaml` — la restricción vive hardcodeada en `hook_daemon.py`, no en configuración editable.
- El gate humano (`plan-approve`/`plan-confirm`, `hotfix-init`/`hotfix-confirm`) no se toca en esta fase. Se mantiene tal como quedó cerrado en la migración anterior.

