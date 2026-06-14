#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Agentify: SDD Memory Guard — Install Script
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

make_writable() {
    if [ "$OS" != "windows" ]; then
        chmod u+w "$1" 2>/dev/null || true
    fi
}

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}╔═════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║     Agentify: SDD Memory Guard — Installer      ║${NC}"
    echo -e "${CYAN}${BOLD}║   Spec-Driven Development for AI Agents 00000   ║${NC}"
    echo -e "${CYAN}${BOLD}╚═════════════════════════════════════════════════╝${NC}"
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

show_help() {
    echo "Usage: install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --target NAME   Install for a specific target engine (non-interactive)"
    echo "  --path DIR      Custom install path (use with --target custom)"
    echo "  -h, --help      Show this help"
    echo ""
    echo "Targets: claude-code, opencode, antigravity-cli, project-local, all-global"
}

# ============================================================================
# Packager Wrapper
# ============================================================================

call_packager() {
    local target="$1"
    local skills_path="$2"
    local config_target="$3"
    
    if command -v python3 >/dev/null 2>&1; then
        if [ "$target" = "opencode" ]; then
            local commands_src="$REPO_DIR/integrations/opencode/commands"
            local commands_target
            if [ "$OS" = "windows" ]; then
                commands_target="$USERPROFILE/.config/opencode/commands"
            else
                commands_target="$HOME/.config/opencode/commands"
            fi
            python3 "$SCRIPT_DIR/packager.py" --target "$target" --skills-path "$skills_path" --config-target "$config_target" --commands-src "$commands_src" --commands-target "$commands_target"
        else
            python3 "$SCRIPT_DIR/packager.py" --target "$target" --skills-path "$skills_path" --config-target "$config_target"
        fi
        if [ $? -eq 0 ]; then
            print_skill "Configuración inyectada correctamente para $target mediante packager.py"
        else
            print_error "Error ejecutando packager.py para $target"
        fi
    else
        print_warn "No se detectó Python3. La configuración no pudo ser empaquetada."
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
        echo -e "  Try: ${CYAN}git clone https://github.com/TU_USUARIO/agentify-sdd.git${NC}\n"
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
# Agent install dispatcher
# ============================================================================

install_for_agent() {
    local target="$1"

    case "$target" in
        claude-code)
            install_skills "$(get_tool_path claude-code)" "Claude Code"
            local config_target="${USERPROFILE:-$HOME}/.claude/CLAUDE.md"
            call_packager "claude-code" "$(get_tool_path claude-code)" "$config_target"
            ;;
        opencode)
            install_skills "$(get_tool_path opencode)" "OpenCode"
            local config_target
            if [ "$OS" = "windows" ]; then
                config_target="$USERPROFILE/.config/opencode/opencode.json"
            else
                config_target="$HOME/.config/opencode/opencode.json"
            fi
            call_packager "opencode" "$(get_tool_path opencode)" "$config_target"
            ;;
        antigravity-cli)
            local skills_target="$(get_tool_path antigravity-cli)"
            install_skills "$skills_target" "Antigravity CLI"
            local config_target="${USERPROFILE:-$HOME}/.gemini/GEMINI.md"
            rm -rf "./.agent/rules" 2>/dev/null || true
            call_packager "antigravity-cli" "$(get_tool_path antigravity-cli)" "$config_target"
            ;;
        project-local)
            install_skills "$(get_tool_path project-local)" "Project-local"
            echo -e "\n${YELLOW}Note:${NC} Skills installed in ${BOLD}./skills/${NC} — relative to this project"
            ;;
        all-global)
            install_skills "$(get_tool_path claude-code)" "Claude Code"
            call_packager "claude-code" "$(get_tool_path claude-code)" "${USERPROFILE:-$HOME}/.claude/CLAUDE.md"
            
            install_skills "$(get_tool_path opencode)" "OpenCode"
            local oc_target
            if [ "$OS" = "windows" ]; then
                oc_target="$USERPROFILE/.config/opencode/opencode.json"
            else
                oc_target="$HOME/.config/opencode/opencode.json"
            fi
            call_packager "opencode" "$(get_tool_path opencode)" "$oc_target"
            
            local ag_target
            ag_target="$(get_tool_path antigravity-cli)"
            install_skills "$ag_target" "Antigravity CLI"
            rm -rf "./.agent/rules" 2>/dev/null || true
            call_packager "antigravity-cli" "$(get_tool_path antigravity-cli)" "${USERPROFILE:-$HOME}/.gemini/GEMINI.md"
            
            echo -e "\n${GREEN}${BOLD}¡Todos los orquestadores globales configurados automáticamente!${NC}"
            ;;
        custom)
            if [ -z "${CUSTOM_PATH:-}" ]; then
                read -rp "Enter target path: " CUSTOM_PATH
            fi
            install_skills "$CUSTOM_PATH" "Custom"
            call_packager "custom" "$CUSTOM_PATH" ""
            ;;
        *)
            print_error "Unknown target: $target"
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
    echo "  3) Project-local    ($(get_tool_path project-local))"
    echo "  4) Antigravity CLI  (~/.gemini/skills/)"
    echo "  5) All global       (Claude Code + OpenCode + Antigravity CLI)"
    echo "  6) Custom path"
    echo ""
    read -rp "Choice [1-6]: " choice

    case $choice in
        1)  install_for_agent "claude-code" ;;
        2)  install_for_agent "opencode" ;;
        3)  install_for_agent "project-local" ;;
        4)  install_for_agent "antigravity-cli" ;;
        5)  install_for_agent "all-global" ;;
        6)  install_for_agent "custom" ;;
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
TARGET=""
CUSTOM_PATH=""
while [ $# -gt 0 ]; do
    case "$1" in
        --target) TARGET="$2"; shift 2 ;;
        --agent)  TARGET="$2"; shift 2 ;; # Fallback for backward compatibility
        --path)   CUSTOM_PATH="$2"; shift 2 ;;
        -h|--help) show_help; exit 0 ;;
        *)  echo "Unknown option: $1"; show_help; exit 1 ;;
    esac
done

print_header
validate_source

if [ -n "$TARGET" ]; then
    # Non-interactive mode
    install_for_agent "$TARGET"
else
    # Interactive mode
    interactive_menu
fi

echo -e "\n${GREEN}${BOLD}Done!${NC} Start using SDD with: ${CYAN}/sdd-init${NC} in your project"
echo ""
