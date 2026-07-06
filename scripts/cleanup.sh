#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Agentify: Memory Guard — Cleanup / Uninstall Script
# Removes skills and injected configurations safely
# Cross-platform: macOS, Linux, Windows (Git Bash / WSL)
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Globals
HARD_MODE=0
AGENT=""

# ============================================================================
# OS Detection
# ============================================================================

detect_os() {
    case "$(uname -s)" in
        Darwin)  OS="macos" ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                OS="wsl"
            else
                OS="linux"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)  OS="windows" ;;
        *)  OS="unknown" ;;
    esac
}

os_label() {
    case "$OS" in
        macos)   echo "macOS" ;;
        linux)   echo "Linux" ;;
        wsl)     echo "WSL" ;;
        windows) echo "Windows (Git Bash)" ;;
        *)       echo "Unknown" ;;
    esac
}

# ============================================================================
# Color support
# ============================================================================

setup_colors() {
    if [ "$OS" = "windows" ] && [ -z "${WT_SESSION:-}" ] && [ -z "${TERM_PROGRAM:-}" ]; then
        RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
    else
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        BLUE='\033[0;34m'
        CYAN='\033[0;36m'
        BOLD='\033[1m'
        NC='\033[0m'
    fi
}

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}╔═════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║       Agentify: Memory Guard — Cleanup          ║${NC}"
    echo -e "${CYAN}${BOLD}╚═════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BOLD}Detected:${NC} $(os_label)"
    echo ""
}

print_step() { echo -e "  ${BLUE}•${NC} $1"; }
print_success() { echo -e "  ${GREEN}✓${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}!${NC} $1"; }
print_error() { echo -e "  ${RED}✗${NC} $1"; }

show_help() {
    echo "Usage: cleanup.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --agent NAME    Clean for a specific agent (claude-code, opencode, antigravity-cli, project-local, all-global)"
    echo "  --hard          Hard mode: Remove .agentify/changes historical data"
    echo "  -h, --help      Show this help"
    echo ""
}

# ============================================================================
# Path Resolution
# ============================================================================

get_tool_path() {
    local tool="$1"
    case "$tool" in
        claude-code)
            case "$OS" in
                windows)  echo "$USERPROFILE/.claude/skills" ;;
                wsl)      echo "$HOME/.claude/skills" ;;
                *)        echo "$HOME/.claude/skills" ;;
            esac
            ;;
        opencode)
            case "$OS" in
                windows)  echo "$USERPROFILE/.config/opencode/skills" ;;
                macos)    echo "$HOME/.config/opencode/skills" ;;
                *)        echo "$HOME/.config/opencode/skills" ;;
            esac
            ;;
        opencode-commands)
            case "$OS" in
                windows)  echo "$USERPROFILE/.config/opencode/commands" ;;
                macos)    echo "$HOME/.config/opencode/commands" ;;
                *)        echo "$HOME/.config/opencode/commands" ;;
            esac
            ;;
        antigravity-cli)
            case "$OS" in
                windows)  echo "$USERPROFILE/.gemini/skills" ;;
                wsl)      echo "$HOME/.gemini/skills" ;;
                *)        echo "$HOME/.gemini/skills" ;;
            esac
            ;;
        project-local) echo "./skills" ;;
    esac
}

# ============================================================================
# Helpers
# ============================================================================

remove_directory() {
    local target="$1"
    local name="$2"
    if [ -d "$target" ]; then
        rm -rf "$target"
        print_success "Directorio de $name limpiado: $target"
    else
        print_step "Directorio no encontrado para $name: $target (Skipped)"
    fi
}

remove_injected_blocks() {
    local target_file="$1"
    local name="$2"
    local marker_begin="<!-- BEGIN MEMORY GUARD -->"
    local marker_end="<!-- END MEMORY GUARD -->"

    if [ -f "$target_file" ]; then
        if grep -q "$marker_begin" "$target_file"; then
            awk "/$marker_begin/{flag=1} /$marker_end/{flag=0; next} !flag" "$target_file" > "${target_file}.tmp"
            mv "${target_file}.tmp" "$target_file"
            print_success "Bloque Memory Guard purgado exitosamente de $name ($target_file)"
        else
            print_step "No se encontró tag Memory Guard inyectado en $name ($target_file)"
        fi
    else
        print_step "Archivo de configuración persistente no encontrado para $name ($target_file)"
    fi
}

# ============================================================================
# Agent Clean Dispatcher
# ============================================================================

clean_agent() {
    local agent="$1"

    case "$agent" in
        claude-code)
            echo -e "\n${BLUE}Limpiando Claude Code...${NC}"
            remove_directory "$(get_tool_path claude-code)" "Claude Code Skills"
            remove_injected_blocks "${USERPROFILE:-$HOME}/.claude/CLAUDE.md" "Claude Code Config"
            ;;
        opencode)
            echo -e "\n${BLUE}Limpiando OpenCode...${NC}"
            remove_directory "$(get_tool_path opencode)" "OpenCode Skills"
            remove_directory "$(get_tool_path opencode-commands)" "OpenCode Commands"
            local config_dir
            if [ "$OS" = "windows" ]; then
                config_dir="$USERPROFILE/.config/opencode"
            else
                config_dir="$HOME/.config/opencode"
            fi
            
            if [ -f "$config_dir/opencode.json" ]; then
                if command -v python3 >/dev/null 2>&1; then
                    python3 -c '
import json, sys, os
target_path = sys.argv[1]
try:
    with open(target_path, "r", encoding="utf-8") as f: data = json.load(f)
    if "agent" in data and "agentify" in data["agent"]:
        del data["agent"]["agentify"]
        with open(target_path, "w", encoding="utf-8") as f: json.dump(data, f, indent=2, ensure_ascii=False)
        print("SUCCESS|Bloque agent.agentify json purgado de OpenCode Config")
    else:
        print("STEP|No se halló key agent.agentify en opencode.json")
except Exception:
    print("WARN|Error al parsear estructura de opencode.json")
sys.exit(0)
' "$config_dir/opencode.json" | while IFS='|' read -r status msg || [ -n "$status" ]; do
                        if [ "$status" = "SUCCESS" ]; then print_success "$msg"
                        elif [ "$status" = "STEP" ]; then print_step "$msg"
                        elif [ "$status" = "WARN" ]; then print_warn "$msg"
                        else print_step "${status}${msg:+\|${msg}}"
                        fi
                    done
                else
                     print_warn "No se encontró ejecución de Python3. Requiere remuevo manual de opencode.json."
                fi
            else
                 print_step "Archivo de configuración no encontrado para OpenCode Config ($config_dir/opencode.json)"
            fi
            ;;
        antigravity-cli)
            echo -e "\n${BLUE}Limpiando Antigravity CLI...${NC}"
            remove_directory "$(get_tool_path antigravity-cli)" "Antigravity CLI Skills"
            remove_injected_blocks "${USERPROFILE:-$HOME}/.gemini/GEMINI.md" "Antigravity CLI Global Config"
            ;;
project-local)
            echo -e "\n${BLUE}Limpiando locación del proyecto...${NC}"
            local target_dir
            target_dir="$(get_tool_path project-local)"
            
            # GUARD CLAUSE: Prevenir auto-borrado del código fuente de Agentify
            if [ "$PWD" = "$REPO_DIR" ]; then
                print_warn "Ejecución detectada en la raíz del repositorio fuente ($REPO_DIR)."
                print_error "Protección de seguridad: Se omite la eliminación de './skills' para no destruir el código del framework."
            else
                remove_directory "$target_dir" "Project-local Skills"
            fi
            ;;
        all-global)
            clean_agent "claude-code"
            clean_agent "opencode"
            clean_agent "antigravity-cli"
            clean_agent "project-local"
            echo -e "\n${GREEN}${BOLD}¡Todas las integraciones de agentes globales procesadas!${NC}"
            ;;
        *)
            print_error "Herramienta desconocida: $agent"
            exit 1
            ;;
    esac
}

# ============================================================================
# Interactive menu
# ============================================================================

interactive_menu() {
    echo -e "${BOLD}Select integration to clean:${NC}\n"
    echo "  1) Claude Code    ($(get_tool_path claude-code))"
    echo "  2) OpenCode       ($(get_tool_path opencode))"
    echo "  3) Project-local    ($(get_tool_path project-local))"
    echo "  4) Antigravity CLI  (~/.gemini/skills/)"
    echo "  5) All global"
    echo ""
    read -rp "Choice [1-5]: " choice

    case $choice in
        1)  clean_agent "claude-code" ;;
        2)  clean_agent "opencode" ;;
        3)  clean_agent "project-local" ;;
        4)  clean_agent "antigravity-cli" ;;
        5)  clean_agent "all-global" ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

# ============================================================================
# Hard Mode handler
# ============================================================================

handle_hard_mode() {
    if [ "$HARD_MODE" -eq 1 ]; then
        echo -e "\n${YELLOW}${BOLD}⚠ ATENCIÓN: MODO HARD ACTIVADO ⚠${NC}"
        echo -e "¿Estás seguro que deseas purgar todo el historial local del proyecto?"
        echo -e "Esto borrará de forma irrecuperable: ${CYAN}.agentify/changes/*${NC}"
        read -r -p "Proceder con la purga? [y/N] " input
        if case "$input" in [yY][eE][sS]|[yY]) true;; *) false;; esac; then
            if [ -d ".agentify/changes" ]; then
                rm -rf .agentify/changes/* || true
                print_success "Historial en .agentify/changes/ eliminado permanentemente."
                mkdir -p ".agentify/changes/archive"
                print_step "Árbol básico inicializado."
            else
                print_step "Directorio .agentify/changes/ no detectado, ignorando..."
            fi
        else
            print_warn "Purga de historial denegada u omitida. Terminando asertivamente."
        fi
    fi
}

# ============================================================================
# Main
# ============================================================================

detect_os
setup_colors

while [ $# -gt 0 ]; do
    case "$1" in
        --agent)  AGENT="$2"; shift 2 ;;
        --hard)   HARD_MODE=1; shift 1 ;;
        -h|--help) show_help; exit 0 ;;
        *)  echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

print_header

if [ -n "$AGENT" ]; then
    clean_agent "$AGENT"
else
    interactive_menu
fi

handle_hard_mode

echo -e "\n${GREEN}${BOLD}¡Limpieza finalizada!${NC}"
echo ""
