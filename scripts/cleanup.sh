#!/bin/bash
# cleanup.sh - Limpia la instalación de State Guard

STATE_GUARD_DIR="$HOME/.agents/skills/state-guard"
MARKER_START="<!-- state-guard:begin -->"
MARKER_END="<!-- state-guard:end -->"

echo "Iniciando limpieza de State Guard..."

# 1. Eliminar el directorio unificado de skills
if [ -d "$STATE_GUARD_DIR" ]; then
    rm -rf "$STATE_GUARD_DIR"
    echo "✓ Directorio base eliminado: $STATE_GUARD_DIR"
else
    echo "- El directorio $STATE_GUARD_DIR no existe."
fi

# 2. Limpiar los archivos de configuración de los orquestadores (ejemplo para OpenCode/Claude si los inyectas globalmente)
# Nota: Ajusta estas rutas a los archivos reales donde install.sh hace la inyección.
CONFIG_FILES=(
    "$HOME/.config/opencode/AGENTS.md"
    "$HOME/.claude/AGENTS.md"
)

for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Elimina el bloque entre los marcadores usando sed
        sed -i.bak "/$MARKER_START/,/$MARKER_END/d" "$file"
        rm -f "$file.bak"
        echo "✓ Inyección limpiada en: $file"
    fi
done

echo "Limpieza completada."