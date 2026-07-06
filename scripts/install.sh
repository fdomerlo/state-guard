#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Agentify — Install Script (unificado)
# Instala el orquestador (state_manager.py + _lock_utils.py) y las skills,
# e inyecta el bootstrap contract en el archivo de instrucciones globales
# del harness elegido. Absorbe lo que antes era context-guard standalone:
# el lock + checkpoint viven en un único motor.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

SKILLS_SRC="$REPO_DIR/skills"
MANAGER_SRC="$SCRIPT_DIR/state_manager.py"
LOCKLIB_SRC="$SCRIPT_DIR/_lock_utils.py"

# Path genérico — cualquier harness compatible con Agent Skills Spec
INSTALL_ROOT="$HOME/.agents/skills/agentify"
BIN_DEST="$INSTALL_ROOT/bin"

MARKER_BEGIN="<!-- agentify:begin -->"
MARKER_END="<!-- agentify:end -->"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }

[ -d "$SKILLS_SRC" ] || { echo "Error: carpeta skills/ no encontrada en $REPO_DIR"; exit 1; }
[ -f "$MANAGER_SRC" ] || { echo "Error: state_manager.py no encontrado en $SCRIPT_DIR"; exit 1; }
[ -f "$LOCKLIB_SRC" ] || { echo "Error: _lock_utils.py no encontrado en $SCRIPT_DIR"; exit 1; }

install_core() {
    info "Copiando orquestador y skills..."
    mkdir -p "$BIN_DEST"
    cp "$MANAGER_SRC" "$BIN_DEST/"
    cp "$LOCKLIB_SRC" "$BIN_DEST/"
    chmod +x "$BIN_DEST/state_manager.py"
    cp -r "$SKILLS_SRC" "$INSTALL_ROOT/"
    ok "Núcleo instalado en $INSTALL_ROOT"
}

inject_bootstrap() {
    local target_file="$1"
    info "Inyectando boot prompt en $target_file..."
    mkdir -p "$(dirname "$target_file")"

    if [ -f "$target_file" ] && grep -q "$MARKER_BEGIN" "$target_file"; then
        # Remove existing block AND any blank lines immediately before it
        awk "
            /$MARKER_BEGIN/{flag=1; next}
            /$MARKER_END/{flag=0; next}
            flag{next}
            {lines[++n]=\$0}
            END{
                # Trim trailing blank lines (left by the removed block)
                while(n>0 && lines[n]==\"\") n--
                for(i=1;i<=n;i++) print lines[i]
            }
        " "$target_file" > "${target_file}.tmp" \
            && mv "${target_file}.tmp" "$target_file"
    fi

    # Add a single blank separator only if file is non-empty and doesn't end with a blank line
    if [ -f "$target_file" ] && [ -s "$target_file" ]; then
        local last_line
        last_line=$(tail -c 1 "$target_file")
        # Append one blank line separator
        echo "" >> "$target_file"
    fi

    {
        echo "$MARKER_BEGIN"
        echo "## ACTIVE PERSISTENCE CONTRACT: agentify (memory-guard)"
        echo "MANDATORY BOOTSTRAP — execute before responding to anything:"
        echo "1. Call read_file on \`$INSTALL_ROOT/skills/_shared/memory-guard.md\`."
        echo "2. Follow every instruction in that file as your absolute state contract."
        echo "3. State manager binary: \`$BIN_DEST/state_manager.py\`"
        echo "   Subcomandos: begin | commit | rollback | checkpoint | status"
        echo "4. Check for an active change at \`.agentify/changes/*/state.ini\`"
        echo "   and act accordingly (Cold Boot, Resume via 'status', or Recovery)."
        echo "$MARKER_END"
    } >> "$target_file"

    ok "Bootstrap inyectado."
}

install_antigravity() {
    install_core
    inject_bootstrap "$HOME/.gemini/GEMINI.md"
}

install_opencode_commands() {
    local cmds_src="$REPO_DIR/integrations/opencode/commands"
    local cmds_dest="$HOME/.config/opencode/commands"
    [ -d "$cmds_src" ] || { warn "No se encontró $cmds_src, omitiendo slash commands."; return; }
    info "Instalando slash commands en $cmds_dest..."
    mkdir -p "$cmds_dest"
    local skills_path="$INSTALL_ROOT/skills"
    for f in "$cmds_src"/*.md; do
        [ -f "$f" ] || continue
        local basename="$(basename "$f")"
        sed "s|{{SKILLS_PATH}}|$skills_path|g" "$f" > "$cmds_dest/$basename"
    done
    ok "$(ls "$cmds_src"/*.md 2>/dev/null | wc -l) slash commands instalados."
}

inject_opencode_agent() {
    local config_file="$HOME/.config/opencode/opencode.jsonc"
    local agent_src="$REPO_DIR/integrations/opencode/opencode.json"
    [ -f "$agent_src" ] || { warn "No se encontró $agent_src, omitiendo config del agente."; return; }

    info "Inyectando agente en $config_file..."
    mkdir -p "$(dirname "$config_file")"

    if [ ! -f "$config_file" ]; then
        # No existe config — copiar directamente
        cp "$agent_src" "$config_file"
        ok "Config creada en $config_file"
        return
    fi

    # Verificar si ya tiene el agente agentify
    if grep -q '"agentify"' "$config_file"; then
        ok "Agente agentify ya presente en $config_file (sin modificar)."
        return
    fi

    # Merge: insertar el bloque "agent" dentro del JSON existente
    # Extraemos solo el contenido del objeto "agent" del source
    local agent_block
    agent_block=$(python3 -c "
import json, sys, re

def strip_jsonc_comments(text):
    \"\"\"Remove // and /* */ comments outside of strings.\"\"\"
    result = []
    i = 0
    in_string = False
    while i < len(text):
        c = text[i]
        if in_string:
            result.append(c)
            if c == '\\\\':
                i += 1
                if i < len(text):
                    result.append(text[i])
            elif c == '\"':
                in_string = False
        elif c == '\"':
            in_string = True
            result.append(c)
        elif c == '/' and i + 1 < len(text):
            if text[i+1] == '/':
                while i < len(text) and text[i] != '\n':
                    i += 1
                continue
            elif text[i+1] == '*':
                i += 2
                while i + 1 < len(text) and not (text[i] == '*' and text[i+1] == '/'):
                    i += 1
                i += 2
                continue
            else:
                result.append(c)
        else:
            result.append(c)
        i += 1
    return ''.join(result)

with open('$agent_src') as f:
    src = json.load(f)
with open('$config_file') as f:
    content = f.read()
    clean = strip_jsonc_comments(content)
    try:
        cfg = json.loads(clean)
    except json.JSONDecodeError:
        cfg = {}

# Merge agent definitions
if 'agent' not in cfg:
    cfg['agent'] = {}
cfg['agent'].update(src.get('agent', {}))

json.dump(cfg, sys.stdout, indent=2, ensure_ascii=False)
" 2>&1) || { warn "Error al parsear config: $agent_block"; return; }

    echo "$agent_block" > "$config_file"
    ok "Agente agentify inyectado en $config_file"
}

install_opencode() {
    install_core
    inject_bootstrap "$HOME/.config/opencode/AGENTS.md"
    install_opencode_commands
    inject_opencode_agent
}

uninstall() {
    local target="$1"
    info "Desinstalando Agentify..."
    rm -rf "$INSTALL_ROOT"
    ok "Archivos base eliminados."

    local target_file=""
    case "$target" in
        antigravity) target_file="$HOME/.gemini/GEMINI.md" ;;
        opencode)    target_file="$HOME/.config/opencode/AGENTS.md" ;;
        *) warn "Target no especificado, omito limpieza de boot prompt."; return ;;
    esac

    if [ -f "$target_file" ] && grep -q "$MARKER_BEGIN" "$target_file"; then
        awk "
            /$MARKER_BEGIN/{flag=1; next}
            /$MARKER_END/{flag=0; next}
            flag{next}
            {lines[++n]=\$0}
            END{
                while(n>0 && lines[n]==\"\") n--
                for(i=1;i<=n;i++) print lines[i]
            }
        " "$target_file" > "${target_file}.tmp" \
            && mv "${target_file}.tmp" "$target_file"
        ok "Prompt removido de $target_file"
    fi

    # Limpieza específica de OpenCode
    if [ "$target" = "opencode" ]; then
        # Eliminar slash commands
        local cmds_dest="$HOME/.config/opencode/commands"
        if [ -d "$cmds_dest" ]; then
            local count=0
            for f in "$cmds_dest"/agentify-*.md; do
                [ -f "$f" ] && rm "$f" && count=$((count + 1))
            done
            [ $count -gt 0 ] && ok "$count slash commands eliminados."
        fi

        # Remover agente agentify del config
        local config_file="$HOME/.config/opencode/opencode.jsonc"
        if [ -f "$config_file" ] && grep -q '"agentify"' "$config_file"; then
            python3 -c "
import json, sys

def strip_jsonc_comments(text):
    result = []
    i = 0
    in_string = False
    while i < len(text):
        c = text[i]
        if in_string:
            result.append(c)
            if c == '\\\\':
                i += 1
                if i < len(text):
                    result.append(text[i])
            elif c == '\"':
                in_string = False
        elif c == '\"':
            in_string = True
            result.append(c)
        elif c == '/' and i + 1 < len(text):
            if text[i+1] == '/':
                while i < len(text) and text[i] != '\n':
                    i += 1
                continue
            elif text[i+1] == '*':
                i += 2
                while i + 1 < len(text) and not (text[i] == '*' and text[i+1] == '/'):
                    i += 1
                i += 2
                continue
            else:
                result.append(c)
        else:
            result.append(c)
        i += 1
    return ''.join(result)

with open('$config_file') as f:
    cfg = json.loads(strip_jsonc_comments(f.read()))
if 'agent' in cfg and 'agentify' in cfg['agent']:
    del cfg['agent']['agentify']
    if not cfg['agent']:
        del cfg['agent']
json.dump(cfg, sys.stdout, indent=2, ensure_ascii=False)
print()
" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
            ok "Agente agentify removido de $config_file"
        fi
    fi
}

echo -e "\n${CYAN}${BOLD}Agentify — Installer${NC}"
echo -e "  Install path: $INSTALL_ROOT\n"

TARGET=""
UNINSTALL=false
while [ $# -gt 0 ]; do
  case "$1" in
    --target)    TARGET="$2"; shift 2 ;;
    --uninstall) UNINSTALL=true; shift ;;
    *) echo "Usage: install.sh --target antigravity|opencode [--uninstall]"; exit 1 ;;
  esac
done

if [ "$UNINSTALL" = true ]; then
    uninstall "$TARGET"
    exit 0
fi

case "$TARGET" in
    antigravity) install_antigravity ;;
    opencode)    install_opencode ;;
    *) echo "Por favor, especifica el target: bash scripts/install.sh --target antigravity|opencode" ;;
esac
