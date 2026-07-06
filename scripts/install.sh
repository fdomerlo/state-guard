#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Agentify SDD — Install Script (unificado)
# Instala el orquestador (sdd_state_manager.py + _lock_utils.py) y las skills,
# e inyecta el bootstrap contract en el archivo de instrucciones globales
# del harness elegido. Absorbe lo que antes era context-guard standalone:
# el lock + checkpoint viven en un único motor.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

SKILLS_SRC="$REPO_DIR/skills"
MANAGER_SRC="$SCRIPT_DIR/sdd_state_manager.py"
LOCKLIB_SRC="$SCRIPT_DIR/_lock_utils.py"

# Path genérico — cualquier harness compatible con Agent Skills Spec
INSTALL_ROOT="$HOME/.agents/skills/agentify-sdd"
BIN_DEST="$INSTALL_ROOT/bin"

MARKER_BEGIN="<!-- agentify-sdd:begin -->"
MARKER_END="<!-- agentify-sdd:end -->"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }

[ -d "$SKILLS_SRC" ] || { echo "Error: carpeta skills/ no encontrada en $REPO_DIR"; exit 1; }
[ -f "$MANAGER_SRC" ] || { echo "Error: sdd_state_manager.py no encontrado en $SCRIPT_DIR"; exit 1; }
[ -f "$LOCKLIB_SRC" ] || { echo "Error: _lock_utils.py no encontrado en $SCRIPT_DIR"; exit 1; }

install_core() {
    info "Copiando orquestador y skills..."
    mkdir -p "$BIN_DEST"
    cp "$MANAGER_SRC" "$BIN_DEST/"
    cp "$LOCKLIB_SRC" "$BIN_DEST/"
    chmod +x "$BIN_DEST/sdd_state_manager.py"
    cp -r "$SKILLS_SRC" "$INSTALL_ROOT/"
    ok "Núcleo instalado en $INSTALL_ROOT"
}

inject_bootstrap() {
    local target_file="$1"
    info "Inyectando boot prompt en $target_file..."
    mkdir -p "$(dirname "$target_file")"

    if [ -f "$target_file" ] && grep -q "$MARKER_BEGIN" "$target_file"; then
        awk "/$MARKER_BEGIN/{flag=1} /$MARKER_END/{flag=0; next} !flag" "$target_file" > "${target_file}.tmp" \
            && mv "${target_file}.tmp" "$target_file"
    fi

    {
        echo ""
        echo "$MARKER_BEGIN"
        echo "## ACTIVE PERSISTENCE CONTRACT: agentify-sdd (memory-guard)"
        echo "MANDATORY BOOTSTRAP — execute before responding to anything:"
        echo "1. Call read_file on \`$INSTALL_ROOT/skills/_shared/memory-guard.md\`."
        echo "2. Follow every instruction in that file as your absolute state contract."
        echo "3. State manager binary: \`$BIN_DEST/sdd_state_manager.py\`"
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

install_opencode() {
    install_core
    inject_bootstrap "$HOME/.config/opencode/AGENTS.md"
}

uninstall() {
    local target="$1"
    info "Desinstalando Agentify SDD..."
    rm -rf "$INSTALL_ROOT"
    ok "Archivos base eliminados."

    local target_file=""
    case "$target" in
        antigravity) target_file="$HOME/.gemini/GEMINI.md" ;;
        opencode)    target_file="$HOME/.config/opencode/AGENTS.md" ;;
        *) warn "Target no especificado, omito limpieza de boot prompt."; return ;;
    esac

    if [ -f "$target_file" ] && grep -q "$MARKER_BEGIN" "$target_file"; then
        awk "/$MARKER_BEGIN/{flag=1} /$MARKER_END/{flag=0; next} !flag" "$target_file" > "${target_file}.tmp" \
            && mv "${target_file}.tmp" "$target_file"
        ok "Prompt removido de $target_file"
    fi
}

echo -e "\n${CYAN}${BOLD}Agentify SDD — Installer${NC}"
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
