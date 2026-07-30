<!--
INSTRUCCIÓN DE INTEGRACIÓN: pegar después del cierre de Fase 4B (paso 4.14)
en MIGRATION_PLAN.md, antes de los Apéndices. Fusionar los ítems de
Apéndice A/C al final de este archivo con los ya existentes.
-->

## Fase 5 — Fix de producción (hooks-start) y corrección de documentación

**Por qué esta fase existe:** la auditoría de `v2.6.0` encontró un bug bloqueante confirmado empíricamente (no teórico) y una desactualización severa del README/MANUAL que describe una arquitectura de 8 fases que ya no existe en el código. Ninguno de los dos es opcional antes de considerar el proyecto usable por otra persona.

---

### [ ] 5.1 — Fix del daemon de hooks (bug bloqueante, prioridad máxima)

**Problema confirmado:** `sg hooks-start` (en `scripts/sg.py`) lanza el daemon con `subprocess.Popen` sin redirigir `stdout`/`stderr` y sin `start_new_session=True`. El proceso hijo hereda el pipe de stdout del padre; como el daemon corre indefinidamente, ese pipe nunca se cierra. Cualquier código que invoque `sg hooks-start` capturando su salida (exactamente como lo hacen los agentes al ejecutar comandos de shell) se cuelga esperando EOF que nunca llega.

**Reproducción (para confirmar el bug ANTES del fix, y que no se repita DESPUÉS):**
```bash
mkdir -p /tmp/hooks-bug-test && cd /tmp/hooks-bug-test && git init -q
python3 <ruta-al-repo>/scripts/sg.py init-change --change bug-test >/dev/null
mkdir -p .state-guard
cat > .state-guard/hooks.yaml <<'EOF'
hooks:
  - name: noop
    pattern: "**/*.txt"
    events: ["on_save"]
    prompt: "noop {path}"
    agent_command: ["true"]
    timeout: 5
EOF
timeout 6 python3 -c "
import subprocess, sys
r = subprocess.run([sys.executable, '<ruta-al-repo>/scripts/sg.py', 'hooks-start'],
                    capture_output=True, text=True, cwd='/tmp/hooks-bug-test')
print('RETURNCODE', r.returncode)
"
echo "EXIT: \$?"
```
**Antes del fix:** `EXIT: 124` (timeout, nunca imprime RETURNCODE — el bug está presente).
**Después del fix:** debe imprimir `RETURNCODE 0` y `EXIT: 0` sin colgarse.

**Cambio concreto en `scripts/sg.py::cmd_hooks_start`:**

```python
def cmd_hooks_start(args):
    import subprocess as sp
    daemon = SCRIPT_DIR / "hook_daemon.py"
    SG_DIR.mkdir(parents=True, exist_ok=True)
    log_path = SG_DIR / "hooks.daemon.log"
    log_fh = open(log_path, "a", buffering=1)
    proc = sp.Popen(
        [sys.executable, str(daemon)],
        cwd=str(REPO_ROOT),
        stdout=log_fh,
        stderr=log_fh,
        stdin=sp.DEVNULL,
        start_new_session=True,  # equivalente a setsid: se desacopla de la
                                  # terminal de control y del grupo de procesos
                                  # del padre. Sin esto, el daemon (a) comparte
                                  # el pipe de stdout con quien invoca sg.py,
                                  # colgando a cualquiera que capture esa salida,
                                  # y (b) puede morir si la sesión que lo lanzó
                                  # termina (SIGHUP).
    )
    (SG_DIR / "hooks.pid").write_text(str(proc.pid))
    _emit({
        "ok": True,
        "pid": proc.pid,
        "log_file": str(log_path),
        "message": "Agent Hooks daemon iniciado en background (detached). Logs en el archivo indicado.",
    })
```

**No tocar `cmd_hooks_stop`/`cmd_hooks_status`** — ya funcionan correctamente porque solo leen/matan por PID, no dependen de los file descriptors heredados.

**Verificación:**
```bash
# 1. Repetir el bloque de reproducción de arriba — debe salir limpio, sin colgarse.
# 2. Confirmar que el log del daemon efectivamente recibe su output:
sg hooks-start
cat .state-guard/hooks.daemon.log   # debe tener la línea "Agent Hooks daemon activo..."
sg hooks-status                     # {"ok": true, "running": true, "pid": ...}
sg hooks-stop
```

**Commit:** `fix: detach hooks-start daemon (start_new_session + log redirection) — fixes hang when caller captures stdout`

---

### [ ] 5.2 — Reemplazar `README.md`

El `README.md` actual describe la arquitectura v1 de 8 fases (`explore→propose→spec→design→tasks→apply→verify→archive`), con un Quick Start que instruye correr `/apply` y `/archive` — ninguno de los dos existe como skill en este repo (`skills/` no tiene `apply/` ni `archive/`; el archivado es el Paso 9 dentro de `verify`, no un comando separado). Reemplazar el archivo completo por la versión ya redactada:

```bash
cp README.md README.md.bak   # por si querés diffear contra la versión vieja
# pegar el contenido de README_NUEVO.md (adjunto en esta entrega) sobre README.md
rm README.md.bak
```

**Verificación:**
```bash
grep -n "/apply\|/archive\|/explore\|/propose\|/spec\b\|/design\b\|/tasks\b" README.md
# Debe devolver 0 líneas (ninguna referencia a comandos que no existen),
# salvo la mención textual de "no hay comandos separados para..." que sí
# debe quedar, esa es intencional.
```

**Commit:** `docs: rewrite README.md to reflect actual 3-phase DAG (plan/execute/verify)`

---

### [ ] 5.3 — Corregir la sección "Arquitectura Memory Guard" de `MANUAL.md`

Mismo problema que el README, en `MANUAL.md` líneas 7-74 (sección `## Arquitectura Memory Guard` completa, incluyendo el diagrama ASCII de 8 fases en líneas 12-23 y la mención de "delega apply pesados" en línea 45).

**Reemplazar el bloque completo** (desde `## Arquitectura Memory Guard` en línea 7 hasta el separador `---` antes de `## Compilación Condicional vs Runtime` en línea 76) por:

```markdown
## Arquitectura Memory Guard

### Contrato Unificado

El Memory Guard es el contrato central que el agente carga al iniciar una sesión. En lugar de un orquestador que despacha comandos CLI a sub-agentes, el agente ejecuta fases directamente (inline) protegido por un protocolo de persistencia transaccional.

```
Memory Guard (memory-guard.md)
    │
    ├── Carga transaction-protocol.md → Protocolo BEGIN/COMMIT/ROLLBACK
    ├── Carga capabilities.md         → Detecta capacidades del host
    ├── Carga persistence-contract.md → Resuelve el modo de persistencia
    ├── Carga convention.md           → Prepara rutas y schema
    │
    ├── Ejecuta inline → plan     (draft → gate humano obligatorio → lock)
    ├── Ejecuta inline → execute  (tasks.md + implementación; delega si > 10 tareas y host soporta)
    └── Ejecuta inline → verify   (tests + archive como Paso 9)
```

### Módulos del Memory Guard

Los contratos compartidos se distribuyen en dos directorios:

**`skills/_shared/`** — Contratos globales del agente:

| Archivo | Propósito |
|---------|-----------|
| `memory-guard.md` | Contrato unificado: identidad del agente, ejecución de fases, delegación inteligente, recovery |
| `capabilities.md` | Detección de capacidades del agente host y regla de delegación inteligente |
| `convention.md` | Convención de filesystem, schema state.ini v2, tabla de transiciones de lock_phase |

**`phases/_shared/`** — Contratos específicos de fases:

| Archivo | Propósito |
|---------|-----------|
| `transaction-protocol.md` | Protocolo de transacciones: ciclo BEGIN/COMMIT/ROLLBACK, campos txn_* en state.ini, auto-checkpoint |
| `phase-common.md` | Protocolo de transacción común a todas las fases |
| `persistence-contract.md` | Contrato de persistencia: inline vs delegada, protocolo de comunicación |
| `context-injection.md` | Dependencias de contexto por fase y secuencia de ejecución |
| `test-runner-detection.md` | Pseudocódigo para la detección automática del test runner del proyecto |

### Autodetección y Delegación Inteligente

El agente determina su comportamiento en tiempo de ejecución analizando las reglas de `capabilities.md`. Detecta dinámicamente el host (por ejemplo, verificando la presencia de `.gemini` o `.config/opencode/`) y activa o desactiva capacidades según la plataforma.

El Memory Guard ejecuta fases **inline por defecto**: carga el archivo `.md` correspondiente a la fase (ej. `phases/execute.md`) y sigue sus instrucciones como propias. Delega el trabajo pesado a un sub-agente real bajo estas condiciones:

1. La fase es `execute` con más de 10 tareas pendientes en `tasks.md`, **Y**
2. El agente host detectado soporta sub-agentes reales (OpenCode o Antigravity CLI).

En la ejecución delegada, el sub-agente ejecuta las tareas e interactúa con el disco, pero **nunca** escribe en `state.ini`. El Memory Guard asume exclusivamente la responsabilidad del COMMIT transaccional al finalizar la delegación.

### Skill Registry Dinámico

El sistema incluye un **registry dinámico de skills** que permite el descubrimiento automático de herramientas:

- Script bash POSIX en `skills/skill-registry/scan.sh`
- Índice generado en `.state-guard/skill-registry.md`
- El Memory Guard lee este índice al iniciar para conocer las herramientas disponibles

El registry escanea los directorios global (`$HOME/.skills-custom`) y local (`./skills-custom`), extrayendo nombre, descripción, trigger y ubicación de cada `SKILL.md`.

---
```

Nota: se conserva intacta la explicación de Delegación Inteligente, Skill Registry y Compilación Condicional — solo se corrige el diagrama de fases y la mención de `apply` como fase separada (ahora es sub-paso de `execute`).

**Verificación:**
```bash
grep -n "explore\|propose\|design\.\|tasks\.\|archive$" MANUAL.md | grep -v "objective.md\|design.md\|tasks.md"
# Revisar manualmente cada coincidencia — no deberían quedar referencias a
# explore/propose como fases, ni a "apply" como fase separada.
```

**Commit:** `docs: correct MANUAL.md architecture section to reflect 3-phase DAG`

---

### [ ] 5.4 — Resolver la referencia colgante a `/archive` en `phases/verify.md`

`phases/verify.md` línea 167 dice que el archivado *"también puede invocarse directamente con `/archive`"* — pero no existe ningún `skills/archive/SKILL.md` ni `phases/archive.md` que respalde ese slash command. Es una referencia a algo que no está construido.

**Decisión más simple (elegir esta salvo que quieras construir el comando):** editar esa línea para que refleje la realidad — el archivado solo ocurre como Paso 9 automático dentro de `verify`, no hay invocación manual directa:

```diff
- Este paso se ejecuta automáticamente después de un veredicto APROBADO. También puede invocarse directamente con `/archive` si VERIFY ya fue ejecutado y aprobado en una sesión anterior.
+ Este paso se ejecuta automáticamente después de un veredicto APROBADO, como parte de la misma invocación de `/continue` que corrió VERIFY. No existe un comando separado para archivar manualmente.
```

Si en algún momento SÍ querés un `/archive` manual (por ejemplo, para re-archivar un cambio cuyo `verify` quedó aprobado en una sesión anterior pero el archivado falló por el check de git sin commitear), es un ítem nuevo, no un fix — no lo improvises acá.

**Verificación:** `grep -n "/archive" phases/verify.md README.md MANUAL.md` — todas las coincidencias deben ser consistentes con "Paso 9 automático, sin comando manual".

**Commit:** `docs: remove dangling /archive manual-invocation reference in phases/verify.md`

---

### [ ] 5.5 — (Opcional, bajo riesgo) Exponer `validate-spec` como 4ta tool MCP

Es de solo lectura igual que las otras 3 tools ya expuestas — no hay razón de diseño para dejarlo fuera, fue simplemente no incluido en la Fase 4.

**Agregar a `scripts/mcp_server.py`:**
```python
@mcp.tool()
def validate_spec(change: str) -> dict:
    """Valida estructuralmente objective.md y design.md antes del gate humano."""
    result, _ = _sg("validate-spec", "--change", change)
    return result
```

**Verificación:** repetir el handshake `tools/list` (ver Fase 2, paso 2.4) — debe listar 4 tools ahora.

**Commit:** `feat: expose validate_spec as 4th MCP tool for consistency with other read-only utilities`

---

### [ ] 5.6 — (Opcional, hardening menor) Lockout de intentos en `plan-confirm`/`hotfix-confirm`

Hoy `cmd_plan_confirm`/`cmd_hotfix_confirm` no limitan intentos con token incorrecto — no es explotable de forma remota (todo es local, un solo usuario), pero es una mejora barata: agregar un contador de intentos fallidos por `token_file` con backoff o borrado del token tras N intentos. **Evaluar si realmente lo necesitás antes de implementarlo** — es hardening para un modelo de amenaza que hoy no tenés (no hay multiusuario ni exposición de red), así que priorizalo bajo si el tiempo apremia.

---

### [ ] 5.7 — Cierre de Fase 5

```bash
python3 -m pytest tests/unit -q
python3 tests/concurrency_test.py
# repetir la reproducción del bug de 5.1 y confirmar que ya no cuelga
git add -A
git commit -m "chore: close Phase 5 (production fix + documentation correction) — v2.6.1"
git tag v2.6.1
```

---

## Apéndice A (actualización)

```
Fase 5 — Fix de producción y documentación
  [ ] 5.1 fix hooks-start (detach + log) — BUG BLOQUEANTE, prioridad máxima
  [ ] 5.2 README.md reemplazado
  [ ] 5.3 MANUAL.md — sección Arquitectura corregida
  [ ] 5.4 referencia colgante a /archive resuelta
  [ ] 5.5 (opcional) validate_spec como 4ta tool MCP
  [ ] 5.6 (opcional) lockout de intentos en confirm
  [ ] 5.7 tag v2.6.1 (cierre)
```

## Apéndice C (adición)

- El bug de 5.1 fue confirmado empíricamente (reproducido con `timeout` + `subprocess.run(capture_output=True)`), no es una hipótesis — cualquier fix alternativo debe pasar la misma reproducción antes de darse por cerrado.
- La corrección de documentación no agrega funcionalidad nueva — es correctiva. Si en el camino aparecen tentaciones de "mejorar" contenido más allá de corregir lo que está desactualizado, tratarlo como un ítem nuevo fuera de esta fase.
