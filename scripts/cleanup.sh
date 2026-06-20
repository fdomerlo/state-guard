#!/usr/bin/env bash

# ==============================================================================
# AGENTIFY SDD — UNIX CLEANUP & UNINSTALL SCRIPT (V3)
# Safely removes compiled artifacts, hooks, and clean environments.
# ==============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Globals
HARD_MODE=0
AGENT=""

# Style & Color support setup
if [[ -t 1 ]]; then
    RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m'
    BLUE='\033[0;34m' CYAN='\033[0;36m' BOLD='\033[1m' NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

print_header() {
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║        Agentify SDD — Environment Cleanup (V3)       ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() { echo -e "  ${BLUE}•${NC} $1"; }
print_success() { echo -e "  ${GREEN}✓${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}!${NC} $1"; }
print_error() { echo -e "  ${RED}✗${NC} $1"; }

show_help() {
    echo "Usage: ./cleanup.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --agent NAME    Clean specific environment (opencode | antigravity | all)"
    echo "  --hard          Hard Mode: Irrecoverably purge active openspec/changes historical data"
    echo "  -h, --help      Display this lifecycle menu."
}

remove_directory() {
    local target="$1"
    local name="$2"
    if [[ -d "$target" ]]; then
        rm -rf "$target"
        print_success "Directorio de $name eliminado: $target"
    else
        print_step "Directorio no detectado para $name (Saltado)"
    fi
}

clean_opencode() {
    echo -e "\n${BLUE}Purging OpenCode V3 environment...${NC}"
    remove_directory "$HOME/.config/opencode/skills" "OpenCode Skills"
    remove_directory "$HOME/.config/opencode/commands" "OpenCode Commands"

    local config_file="$HOME/.config/opencode/opencode.json"
    if [[ -f "$config_file" ]]; then
        python3 -c '
import json, sys
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as f: data = json.load(f)
    if "agent" in data and "sdd-orchestrator" in data["agent"]:
        del data["agent"]["sdd-orchestrator"]
        with open(path, "w", encoding="utf-8") as f: json.dump(data, f, indent=2, ensure_ascii=False)
        print("SUCCESS")
    else:
        print("ABSENT")
except Exception:
    print("ERROR")
' "$config_file" | read -r py_res

        if [[ "$py_res" == "SUCCESS" ]]; then
            print_success "Bloque 'sdd-orchestrator' purgado de opencode.json"
        elif [[ "$py_res" == "ABSENT" ]]; then
            print_step "No se detectó el bloque del orquestador en opencode.json"
        else
            print_warn "Error crítico al parsear opencode.json. Requiere remoción manual."
        fi
    fi
}

clean_antigravity() {
    echo -e "\n${BLUE}Purging Antigravity-CLI V3 environment...${NC}"
    remove_directory "$HOME/.config/antigravity/commands" "Antigravity Slash Commands"

    local compiled_prompt="$HOME/.config/antigravity/antigravity-system-prompt.md"
    if [[ -f "$compiled_prompt" ]]; then
        rm -f "$compiled_prompt"
        print_success "Prompt de sistema maestro global eliminado con éxito."
    fi
}

purge_workspace_history() {
    if [[ "$HARD_MODE" -eq 1 ]]; then
        echo -e "\n${RED}${BOLD}⚠ ALERTA CRÍTICA: MODO HARD ACTIVADO ⚠${NC}"
        echo "Esta acción es irreversible y destruirá todo el historial de cambios locales."
        echo -e "Se eliminarán todos los directorios bajo: ${CYAN}openspec/changes/*${NC}"
        read -rp "¿Confirmar destrucción permanente de datos del espacio de trabajo? [y/N]: " confirm
        if [[ "$confirm" =~ ^[yY](eE[sS])?$ ]]; then
            if [[ -d "$REPO_DIR/openspec/changes" ]]; then
                rm -rf "$REPO_DIR/openspec/changes"/*
                print_success "Historial de cambios purgado del disco."
                mkdir -p "$REPO_DIR/openspec/changes/archive"
                print_step "Estructura base transaccional regenerada."
            fi
        else
            print_warn "Purgado de historial abortado."
        fi
    fi
}

interactive_menu() {
    echo -e "${BOLD}Select configuration environment to wipe:${NC}\n"
    echo "  1) OpenCode Global Environment"
    echo "  2) Antigravity-CLI Local Context"
    echo "  3) Wipe All Environments (Global & Local)"
    echo "  4) Abort Cleanup"
    echo ""
    read -rp "Choice [1-4]: " choice

    case "$choice" in
        1) clean_opencode ;;
        2) clean_antigravity ;;
        3) clean_opencode; clean_antigravity ;;
        *) echo "Cleanup sequence aborted."; exit 0 ;;
    esac
}

# ==============================================================================
# Main Execution Flow
# ==============================================================================
print_header

while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent) AGENT="$2"; shift 2 ;;
        --hard)  HARD_MODE=1; shift 1 ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Unknown runtime flag: $1"; show_help; exit 1 ;;
    esac
done

if [[ -n "$AGENT" ]]; then
    case "$AGENT" in
        opencode) clean_opencode ;;
        antigravity) clean_antigravity ;;
        all) clean_opencode; clean_antigravity ;;
        *) print_error "Target context unknown: $AGENT"; exit 1 ;;
    esac
else
    interactive_menu
fi

purge_workspace_history

echo -e "\n${GREEN}${BOLD}✓ Proceso de limpieza finalizado con éxito.${NC}\n"
