#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# State Guard: Universal Install Script (OpenCode / Antigravity)
# ============================================================================

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: ./install.sh"
    echo "Instala State Guard de forma universal."
    exit 0
elif [[ $# -gt 0 ]]; then
    echo "Error: Opcion desconocida '$1'."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_SKILLS_DIR="$REPO_DIR/skills"
TARGET_DIR="$HOME/.agents/skills/state-guard"

MARKER_START="<!-- state-guard:begin -->"
MARKER_END="<!-- state-guard:end -->"

echo "Iniciando instalación universal de State Guard..."

# 1. Directorios unificados y copia de skills/binarios
mkdir -p "$TARGET_DIR/bin" "$TARGET_DIR/_shared"

echo "→ Copiando contratos y skills..."
cp -r "$SOURCE_SKILLS_DIR/_shared/"* "$TARGET_DIR/_shared/"

count=0
for skill_dir in "$SOURCE_SKILLS_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    if [[ "$skill_name" != "_shared" && -f "${skill_dir}SKILL.md" ]]; then
        mkdir -p "$TARGET_DIR/$skill_name"
        cp "${skill_dir}SKILL.md" "$TARGET_DIR/$skill_name/SKILL.md"
        count=$((count + 1))
    fi
done

cp "$SCRIPT_DIR/state_manager.py" "$SCRIPT_DIR/_lock_utils.py" "$TARGET_DIR/bin/"
chmod +x "$TARGET_DIR/bin/state_manager.py"

echo "  ✓ $count skills instaladas en $TARGET_DIR"

# 2. Texto de Bootstrap (Directiva Única)
BOOTSTRAP_TEXT=$(cat <<EOF
## ACTIVE PERSISTENCE CONTRACT: state-guard (memory-guard)
MANDATORY BOOTSTRAP — execute before responding to anything:
1. Call read_file on $TARGET_DIR/_shared/memory-guard.md.
2. Follow every instruction in that file as your absolute state contract.
3. State manager binary: $TARGET_DIR/bin/state_manager.py
   Subcomandos: begin | commit | rollback | checkpoint | status
4. Check for an active change at .state-guard/changes/*/state.ini
   and act accordingly (Cold Boot, Resume via 'status', or Recovery).
EOF
)
export BOOTSTRAP_TEXT

# 3. Inyección en Antigravity (GEMINI.md)
GEMINI_FILE="$HOME/.gemini/GEMINI.md"
mkdir -p "$(dirname "$GEMINI_FILE")"
if [[ -f "$GEMINI_FILE" ]]; then
    sed -i.bak "/$MARKER_START/,/$MARKER_END/d" "$GEMINI_FILE" && rm -f "$GEMINI_FILE.bak"
fi
{
    echo
    echo "$MARKER_START"
    echo "$BOOTSTRAP_TEXT"
    echo "$MARKER_END"
} >> "$GEMINI_FILE"
echo "  ✓ Bootstrap inyectado en $GEMINI_FILE"

# 4. Inyección nativa en OpenCode (opencode.jsonc)
echo "→ Configurando OpenCode JSONC..."
python3 - <<'PY'
import json
import os
import re

config_path = os.path.expanduser('~/.config/opencode/opencode.jsonc')
bootstrap = os.environ.get('BOOTSTRAP_TEXT', '')

if os.path.exists(config_path):
    with open(config_path, 'r', encoding='utf-8') as f:
        content = f.read()
    clean_content = re.sub(r'//.*?\n|/\*.*?\*/', '', content, flags=re.S)
    try:
        cfg = json.loads(clean_content)
    except json.JSONDecodeError:
        cfg = {'$schema': 'https://opencode.ai/config.json', 'agent': {}}
else:
    cfg = {'$schema': 'https://opencode.ai/config.json', 'agent': {}}

if 'agent' not in cfg:
    cfg['agent'] = {}

cfg['agent']['state-guard'] = {
    'mode': 'all',
    'description': 'Memory Guard — Agente con Memoria Transaccional',
    'prompt': bootstrap,
    'tools': {'read': True, 'write': True, 'edit': True, 'bash': True},
}

os.makedirs(os.path.dirname(config_path), exist_ok=True)
with open(config_path, 'w', encoding='utf-8') as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
PY
echo "  ✓ Agente state-guard registrado directamente en opencode.jsonc"

# 5. Generación Dinámica de Slash Commands (OpenCode)
CMD_DIR="$HOME/.config/opencode/commands"
mkdir -p "$CMD_DIR"
rm -f "$CMD_DIR"/*.md 2>/dev/null || true

echo "→ Generando Slash Commands dinámicos..."
cmd_count=0
for skill_dir in "$TARGET_DIR"/*/; do
    skill_name=$(basename "$skill_dir")
    if [[ "$skill_name" != "_shared" && "$skill_name" != "bin" && -f "${skill_dir}SKILL.md" ]]; then
        desc=$(python3 - <<'PY' "${skill_dir}SKILL.md"
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding='utf-8')
lines = text.splitlines()
for idx, line in enumerate(lines):
    if line.startswith('description:'):
        value = line.split(':', 1)[1].strip()
        if value.startswith('>'):
            if idx + 1 < len(lines):
                print(lines[idx + 1].strip())
            else:
                print('')
        else:
            print(value.strip('"').strip("'"))
        break
else:
    print('')
PY
)

        cat > "$CMD_DIR/${skill_name}.md" <<EOF
---
description: "$desc"
agent: state-guard
---
Lee el archivo $TARGET_DIR/$skill_name/SKILL.md y ejecuta sus instrucciones al pie de la letra.
EOF
        cmd_count=$((cmd_count + 1))
    fi
done
echo "  ✓ $cmd_count slash commands generados al vuelo."

echo -e "\nDone!"