#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Agentify: SDD Orchestrator— Install Script
# Copies skills to your AI coding assistant's skill directory
# Cross-platform: macOS, Linux, Windows (Git Bash / WSL)
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SKILLS_SRC="$REPO_DIR/skills"

# Ensure global custom skills directory exists
mkdir -p "$HOME/.skills-custom"

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
        # Plain CMD without Windows Terminal — no ANSI support
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
        gemini-cli)
            case "$OS" in
                windows)  echo "$USERPROFILE/.gemini/skills" ;;
                wsl)      echo "$HOME/.gemini/skills" ;;
                *)        echo "$HOME/.gemini/skills" ;;
            esac
            ;;
        antigravity)
            case "$OS" in
                windows)  echo "$USERPROFILE/.gemini/antigravity/skills" ;;
                wsl)      echo "$HOME/.gemini/antigravity/skills" ;;
                *)        echo "$HOME/.gemini/antigravity/skills" ;;
            esac
            ;;
        project-local) echo "./skills" ;;
    esac
}

# ============================================================================
# Helpers
# ============================================================================

make_writable() {
    if [ "$OS" != "windows" ]; then
        chmod u+w "$1" 2>/dev/null || true
    fi
}

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║     Agentify: SDD Memory Guard — Installer    ║${NC}"
    echo -e "${CYAN}${BOLD}║   Spec-Driven Development for AI Agents  ║${NC}"
    echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BOLD}Detected:${NC} $(os_label)"
    echo ""
}

print_skill() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "  ${YELLOW}!${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
}

print_next_step() {
    local config_file="$1"
    local example_file="$2"
    echo -e "\n${YELLOW}Next step:${NC} Add the orchestrator to your ${BOLD}$config_file${NC}"
    echo -e "  See: ${CYAN}$example_file${NC}"
}


show_help() {
    echo "Usage: install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --agent NAME    Install for a specific agent (non-interactive)"
    echo "  --path DIR      Custom install path (use with --agent custom)"
    echo "  -h, --help      Show this help"
    echo ""
    echo "Agents: claude-code, opencode, gemini-cli, antigravity, project-local, all-global"
}

# ============================================================================
# Config Injection Helpers
# ============================================================================

compile_and_append_config() {
    local target_file="$1"
    local header_file="$2"
    local marker_begin="<!-- BEGIN SDD MEMORY GUARD -->"
    local marker_end="<!-- END SDD MEMORY GUARD -->"

    mkdir -p "$(dirname "$target_file")" 2>/dev/null || true

    # Si el archivo existe y tiene nuestro bloque, lo purgamos de forma segura
    if [ -f "$target_file" ] && grep -q "$marker_begin" "$target_file"; then
        awk "/$marker_begin/{flag=1} /$marker_end/{flag=0; next} !flag" "$target_file" > "${target_file}.tmp"
        mv "${target_file}.tmp" "$target_file"
        print_skill "Bloque anterior del Memory Guard purgado en $(basename "$target_file")"
    fi

    # Ensamblar y compilar el nuevo bloque
    echo "" >> "$target_file"
    echo "$marker_begin" >> "$target_file"
    
    # 1. Agregar el header específico (ej. CLAUDE.md original)
    if [ -f "$header_file" ]; then
        cat "$header_file" >> "$target_file"
    fi
    echo "$marker_end" >> "$target_file"
    
    print_skill "Memory Guard inyectado/actualizado exitosamente en $(basename "$target_file")"
}

merge_opencode_config() {
    local config_dir
    if [ "$OS" = "windows" ]; then
        config_dir="$USERPROFILE/.config/opencode"
    else
        config_dir="$HOME/.config/opencode"
    fi
    local target_config="$config_dir/opencode.json"
    local source_config="$REPO_DIR/integrations/opencode/opencode.json"

    mkdir -p "$config_dir"

    # Usamos Python para hacer un merge seguro del JSON y compilar el prompt
    if command -v python3 >/dev/null 2>&1; then
        python3 -c '
import json, sys, os
target_path, source_path = sys.argv[1:3]

# Leer el source JSON (header)
try:
    with open(source_path, "r", encoding="utf-8") as f: source = json.load(f)
except Exception:
    sys.exit(1)

# Aplicar al JSON del usuario
if os.path.exists(target_path):
    try:
        with open(target_path, "r", encoding="utf-8") as f: target = json.load(f)
    except Exception:
        target = {"$schema": "https://opencode.ai/config.json", "agent": {}}
else:
    target = {"$schema": "https://opencode.ai/config.json", "agent": {}}
    
if "agent" not in target: target["agent"] = {}
target["agent"]["sdd-orchestrator"] = source["agent"]["sdd-orchestrator"]

with open(target_path, "w", encoding="utf-8") as f: json.dump(target, f, indent=2, ensure_ascii=False)
sys.exit(0)
' "$target_config" "$source_config"
        
        if [ $? -eq 0 ]; then
            print_skill "sdd-orchestrator compilado e inyectado en opencode.json"
        else
            print_warn "No se pudo inyectar automáticamente. Error en compilación Python."
        fi
    else
        print_warn "No se detectó Python3. Copia el orquestador a opencode.json manualmente."
    fi
}

# ============================================================================
# Install functions
# ============================================================================

validate_source() {
    local missing=0
    for skill_dir in "$SKILLS_SRC"/*/; do
        local skill_name
        skill_name=$(basename "$skill_dir")
        if [ "$skill_name" = "_shared" ] || [ "$skill_name" = "skill-registry" ]; then
            continue
        fi
        if [ ! -f "$skill_dir/SKILL.md" ]; then
            print_error "Missing: $skill_name/SKILL.md"
            missing=$((missing + 1))
        fi
    done
    if [ ! -d "$SKILLS_SRC/_shared" ]; then
        print_error "Missing: _shared/ directory"
        missing=$((missing + 1))
    fi
    if [ "$missing" -gt 0 ]; then
        echo -e "\n${RED}${BOLD}Source validation failed.${NC} Is this a complete clone of the repository?"
        echo -e "  Try: ${CYAN}git clone https://github.com/ctrbts/agentify-sdd.git${NC}\n"
        exit 1
    fi
}

install_skills() {
    local target_dir="$1"
    local tool_name="$2"

    if [ -z "$target_dir" ]; then
        print_error "Error: No se especificó el directorio de destino para $tool_name. Verificá get_tool_path."
        exit 1
    fi

    echo -e "\n${BLUE}Installing skills for ${BOLD}$tool_name${NC}${BLUE}...${NC}"

    mkdir -p "$target_dir"

    # Copy shared convention files (_shared/)
    local shared_src="$SKILLS_SRC/_shared"
    local shared_target="$target_dir/_shared"

    if [ -d "$shared_src" ]; then
        local shared_count=0
        mkdir -p "$shared_target" 2>/dev/null || {
            make_writable "$shared_target"
        }
        for shared_file in "$shared_src"/*.md; do
            if [ -f "$shared_file" ]; then
                cp "$shared_file" "$shared_target/" 
                shared_count=$((shared_count + 1))
            fi
        done
        if [ "$shared_count" -gt 0 ]; then
            print_skill "_shared ($shared_count convention files)"
        else
            print_warn "_shared directory found but no .md files to copy"
        fi
    fi

    local count=0
    for skill_dir in "$SKILLS_SRC"/*/; do
        local skill_name
        skill_name=$(basename "$skill_dir")

        if [ "$skill_name" = "_shared" ]; then
            continue
        fi

        # Verify source SKILL.md exists for sdd skills
        if [ "${skill_name#sdd-}" != "$skill_name" ] && [ ! -f "$skill_dir/SKILL.md" ]; then
            print_warn "Skipping $skill_name (SKILL.md not found in source)"
            continue
        fi

        mkdir -p "$target_dir/$skill_name" 2>/dev/null || {
            make_writable "$target_dir/$skill_name"
        }
        cp -R "$skill_dir/"* "$target_dir/$skill_name/" 2>/dev/null || true
        print_skill "$skill_name"
        count=$((count + 1))
    done

    echo -e "\n  ${GREEN}${BOLD}$count skills installed${NC} → $target_dir"
}



# ============================================================================
# Install commands (OpenCode — markdown files)
# ============================================================================

install_opencode_commands() {
    local skills_path="$1"
    local commands_src="$REPO_DIR/integrations/opencode/commands"
    local commands_target
    if [ "$OS" = "windows" ]; then
        commands_target="$USERPROFILE/.config/opencode/commands"
    else
        commands_target="$HOME/.config/opencode/commands"
    fi

    if [ ! -d "$commands_src" ]; then
        print_warn "No se encontró integrations/opencode/commands/ en el repositorio"
        return
    fi

    mkdir -p "$commands_target"
    local count=0
    for cmd_file in "$commands_src"/*.md; do
        [ -f "$cmd_file" ] || continue
        local cmd_name
        cmd_name=$(basename "$cmd_file")
        sed "s|{{SKILLS_PATH}}|$skills_path|g" "$cmd_file" > "$commands_target/$cmd_name"
        count=$((count + 1))
    done
    if [ "$count" -gt 0 ]; then
        print_skill "$count slash commands instalados → $commands_target"
    fi
}


# ============================================================================
# Agent install dispatcher
# ============================================================================

install_for_agent() {
    local agent="$1"

    case "$agent" in
        claude-code)
            install_skills "$(get_tool_path claude-code)" "Claude Code"
            local config_target="${USERPROFILE:-$HOME}/.claude/CLAUDE.md"
            compile_and_append_config "$config_target" "$REPO_DIR/integrations/claude-code/CLAUDE.md"
            ;;
        opencode)
            install_skills "$(get_tool_path opencode)" "OpenCode"
            install_opencode_commands "$(get_tool_path opencode)"
            merge_opencode_config
            ;;
        gemini-cli)
            install_skills "$(get_tool_path gemini-cli)" "Gemini CLI"
            local config_target="${USERPROFILE:-$HOME}/.gemini/GEMINI.md"
            compile_and_append_config "$config_target" "$REPO_DIR/integrations/gemini-cli/GEMINI.md"
            ;;
        antigravity)
            local target="$(get_tool_path antigravity)"
            install_skills "$target" "Antigravity"
            local config_target="${USERPROFILE:-$HOME}/.gemini/GEMINI.md"
            rm -rf "./.agent/rules" 2>/dev/null || true
            compile_and_append_config "$config_target" "$REPO_DIR/integrations/antigravity/sdd-orchestrator.md"
            ;;
        project-local)
            install_skills "$(get_tool_path project-local)" "Project-local"
            echo -e "\n${YELLOW}Note:${NC} Skills installed in ${BOLD}./skills/${NC} — relative to this project"
            ;;
        all-global)
            install_skills "$(get_tool_path claude-code)" "Claude Code"
            compile_and_append_config "${USERPROFILE:-$HOME}/.claude/CLAUDE.md" "$REPO_DIR/integrations/claude-code/CLAUDE.md"
            
            install_skills "$(get_tool_path opencode)" "OpenCode"
            install_opencode_commands "$(get_tool_path opencode)"
            merge_opencode_config
            
            install_skills "$(get_tool_path gemini-cli)" "Gemini CLI"
            compile_and_append_config "${USERPROFILE:-$HOME}/.gemini/GEMINI.md" "$REPO_DIR/integrations/gemini-cli/GEMINI.md"
            
            local ag_target
            ag_target="$(get_tool_path antigravity)"
            install_skills "$ag_target" "Antigravity"
            rm -rf "./.agent/rules" 2>/dev/null || true
            compile_and_append_config "${USERPROFILE:-$HOME}/.gemini/GEMINI.md" "$REPO_DIR/integrations/antigravity/sdd-orchestrator.md"
            
            echo -e "\n${GREEN}${BOLD}¡Todos los orquestadores globales configurados automáticamente!${NC}"
            ;;
        custom)
            if [ -z "${CUSTOM_PATH:-}" ]; then
                read -rp "Enter target path: " CUSTOM_PATH
            fi
            install_skills "$CUSTOM_PATH" "Custom"
            ;;
        *)
            print_error "Unknown agent: $agent"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# ============================================================================
# Interactive menu
# ============================================================================

interactive_menu() {
    echo -e "${BOLD}Select your AI coding assistant:${NC}\n"
    echo "  1) Claude Code    ($(get_tool_path claude-code))"
    echo "  2) OpenCode       ($(get_tool_path opencode))"
    echo "  3) Gemini CLI     ($(get_tool_path gemini-cli))"
    echo "  4) Antigravity    (~/.gemini/antigravity/skills/)"
    echo "  5) Project-local  ($(get_tool_path project-local))"
    echo "  6) All global     (Claude Code + OpenCode + Gemini CLI + Antigravity)"
    echo "  7) Custom path"
    echo ""
    read -rp "Choice [1-7]: " choice

    case $choice in
        1)  install_for_agent "claude-code" ;;
        2)  install_for_agent "opencode" ;;
        3)  install_for_agent "gemini-cli" ;;
        4)  install_for_agent "antigravity" ;;
        5)  install_for_agent "project-local" ;;
        6)  install_for_agent "all-global" ;;
        7)  install_for_agent "custom" ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
}

# ============================================================================
# Main
# ============================================================================

# Detect OS first — needed for colors and paths
detect_os

# Setup colors based on OS + terminal capabilities
setup_colors

# Parse arguments
AGENT=""
CUSTOM_PATH=""
while [ $# -gt 0 ]; do
    case "$1" in
        --agent)  AGENT="$2"; shift 2 ;;
        --path)   CUSTOM_PATH="$2"; shift 2 ;;
        -h|--help) show_help; exit 0 ;;
        *)  echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

print_header
validate_source

if [ -n "$AGENT" ]; then
    # Non-interactive mode
    install_for_agent "$AGENT"
else
    # Interactive mode
    interactive_menu
fi

echo -e "\n${GREEN}${BOLD}Done!${NC} Start using SDD with: ${CYAN}/sdd-init${NC} in your project"
echo ""
