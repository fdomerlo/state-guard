#!/usr/bin/env python3
"""Agent Hooks daemon — observa el filesystem y dispara acciones declaradas
en .state-guard/hooks.yaml. Solo ejecuta acciones de la categoría "derivada"
(ver Fase 4B, paso 4.7) — nunca toca objective.md/design.md ni el gate humano."""
import json
import subprocess
import sys
import time
from pathlib import Path

try:
    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler
    import yaml
except ImportError as e:
    print(f"Error: falta dependencia opcional para Agent Hooks ({e}).", file=sys.stderr)
    print("Instalá con: pip install -e '.[hooks]'", file=sys.stderr)
    sys.exit(1)

REPO_ROOT = Path.cwd()
RULES_FILE = REPO_ROOT / ".state-guard" / "hooks.yaml"
LOG_FILE = REPO_ROOT / ".state-guard" / "hooks.log.jsonl"
EXCLUDED_PREFIXES = (".state-guard/", ".git/")  # nunca reaccionar a sus propios efectos
FORBIDDEN_PATTERNS = ("objective.md", "design.md")  # nunca disparar sobre estos, pase lo que pase


def _log(entry: dict):
    entry["ts"] = time.time()
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


def _load_rules():
    if not RULES_FILE.exists():
        return []
    with open(RULES_FILE, encoding="utf-8") as f:
        data = yaml.safe_load(f)
        return data.get("hooks", []) if data else []


class HookHandler(FileSystemEventHandler):
    def __init__(self, rules):
        self.rules = rules
        self._debounce = {}  # path -> last_trigger_ts

    def _should_skip(self, path: str) -> bool:
        try:
            rel = str(Path(path).relative_to(REPO_ROOT))
        except ValueError:
            return True
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
        try:
            rel = str(Path(event.src_path).relative_to(REPO_ROOT))
        except ValueError:
            return
        for rule in self.rules:
            if Path(rel).match(rule["pattern"]) and "on_save" in rule.get("events", []):
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
