#!/usr/bin/env bash

# ==============================================================================
# AGENTIFY SDD — UNIX INTERACTIVE INSTALLATION & DEPLOYMENT SCRIPT (V3)
# ==============================================================================
set -euo pipefail

# Configuration parameters
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENCODE_CONFIG_DIR="$HOME/.config/opencode"
ANTIGRAVITY_CONFIG_DIR="$HOME/.config/antigravity"

show_help() {
    echo "Usage: ./install.sh [OPTION]"
    echo "Options:"
    echo "  --target opencode      Deploy environment for OpenCode integration."
    echo "  --target antigravity   Deploy environment optimized for local Antigravity-CLI."
    echo "  --help                 Display this structural help menu."
}

# Parse inbound parameters
TARGET=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)
            TARGET="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "ERROR: Unknown parameter: $1"
            show_help
            exit 1
            ;;
    esac
done

# Interactive Menu Fallback
if [[ -z "$TARGET" ]]; then
    echo "--------------------------------------------------"
    echo "      Agentify SDD — V3 Installation Wizard       "
    echo "--------------------------------------------------"
    echo "Select deployment target environment:"
    echo "  1) OpenCode Integration"
    echo "  2) Antigravity-CLI (Local/Edge Models)"
    echo "  3) Cancel Installation"
    echo "--------------------------------------------------"
    read -rp "Choice [1-3]: " choice

    case "$choice" in
        1) TARGET="opencode" ;;
        2) TARGET="antigravity" ;;
        *) echo "Installation cancelled by user."; exit 0 ;;
    esac
fi

# 1. Dependency Validation Gating
echo "Checking runtime prerequisites..."
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 environment was not detected. Execution halted."
    exit 1
fi

# 2. Legacy Purging (Sanitizing Environment)
echo "Purging stale legacy configurations..."
rm -rf "$REPO_DIR/integrations/claude-code"
rm -f "$REPO_DIR/scripts/install.ps1"
rm -rf "$REPO_DIR/skills/sdd-skill-registry"
rm -f "$REPO_DIR/integrations/opencode/commands/sdd-skill-registry.md"

# 3. Target Deployment Routing
case "$TARGET" in
    opencode)
        echo "Initializing deployment pipeline for OpenCode target..."

        # Build paths
        TARGET_CONFIG_FILE="$OPENCODE_CONFIG_DIR/opencode.json"
        TARGET_COMMANDS_DIR="$OPENCODE_CONFIG_DIR/commands"
        TARGET_SKILLS_DIR="$OPENCODE_CONFIG_DIR/skills"

        # Mirror source skills folder structure natively
        mkdir -p "$TARGET_SKILLS_DIR"
        cp -R "$REPO_DIR/skills/"* "$TARGET_SKILLS_DIR/"

        # Run compiler pipeline
        python3 "$REPO_DIR/scripts/packager.py" \
            --target opencode \
            --repo-dir "$REPO_DIR" \
            --opencode-config-file "$TARGET_CONFIG_FILE" \
            --opencode-commands-dir "$TARGET_COMMANDS_DIR"

        echo "SUCCESS: OpenCode V3 engine integration deployed successfully."
        ;;

    antigravity)
        echo "Initializing deployment pipeline for Antigravity-CLI target..."

        TARGET_COMMANDS_DIR="$ANTIGRAVITY_CONFIG_DIR/commands"
        TARGET_SYSTEM_FILE="$ANTIGRAVITY_CONFIG_DIR/antigravity-system-prompt.md"
        SKILLS_RESOLVED_PATH="$REPO_DIR/skills"

        # Run compiler to build standalone system prompts and optimized hooks
        python3 "$REPO_DIR/scripts/packager.py" \
            --target antigravity \
            --repo-dir "$REPO_DIR" \
            --opencode-commands-dir "$TARGET_COMMANDS_DIR" \
            --skills-path "$SKILLS_RESOLVED_PATH" \
            --antigravity-system-file "$TARGET_SYSTEM_FILE"

        echo "----------------------------------------------------------------------"
        echo "SUCCESS: Antigravity local V3 configuration generated successfully."
        echo "-> Master System Prompt built globally at: $TARGET_SYSTEM_FILE"
        echo "-> Context-Aware Slash Commands mapped to: $TARGET_COMMANDS_DIR"
        echo "----------------------------------------------------------------------"
        ;;

    *)
        echo "ERROR: Invalid deployment target identifier: $TARGET"
        exit 1
        ;;
esac
