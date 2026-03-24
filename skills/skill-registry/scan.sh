#!/bin/sh
# Skill Registry — Escáner POSIX
# Escanea ./skills/ e identifica skills no-SDD para indexar.
# Uso: sh skills/skill-registry/scan.sh [directorio-skills]

SKILLS_DIR="${1:-./skills}"
OUTPUT="./.agentify/skill-registry.md"

# Crear directorio de salida si no existe
mkdir -p ./.agentify

# Encabezado del índice
cat > "$OUTPUT" << 'HEADER'
# Skill Registry

Generado automáticamente por skill-registry/scan.sh

| Nombre | Descripción | Trigger | Ubicación |
|--------|-------------|---------|-----------|
HEADER

found=0

for dir in "$SKILLS_DIR"/*/; do
  # Verificar que el directorio existe
  [ -d "$dir" ] || continue

  name=$(basename "$dir")

  # Ignorar directorios sdd-* y _*
  case "$name" in
    sdd-*) continue ;;
    _*)    continue ;;
  esac

  # Verificar que existe SKILL.md
  skill_file="$dir/SKILL.md"
  [ -f "$skill_file" ] || continue

  # Extraer descripción del frontmatter YAML usando awk
  # Busca entre los "---" del frontmatter, extrae desde "description:" hasta
  # encontrar "license:" o "metadata:" o fin de frontmatter
  desc=$(awk '
    /^---$/ { fm_count++; next }
    fm_count == 1 {
      if (in_desc) {
        if ($0 ~ /^license:/ || $0 ~ /^metadata:/ || $0 ~ /^name:/ || $0 ~ /^---$/) {
          in_desc = 0
          next
        }
        # Continuación de descripción multiline
        gsub(/^[[:space:]]+/, "", $0)
        if (length($0) > 0) {
          if (desc_text != "") desc_text = desc_text " " $0
          else desc_text = $0
        }
        next
      }
      if ($0 ~ /^description:/) {
        in_desc = 1
        # Extraer valor inline si existe
        val = $0
        sub(/^description:[[:space:]]*>?[[:space:]]*/, "", val)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", val)
        if (length(val) > 0) desc_text = val
        next
      }
    }
    END { print desc_text }
  ' "$skill_file")

  # Fallback si no se encontró descripción
  if [ -z "$desc" ]; then
    desc="(Sin descripción)"
  fi

  # Extraer disparador del contenido del archivo
  trigger=$(grep -i "disparador" "$skill_file" | head -1 | sed 's/.*[*_]*[Dd]isparador[*_]*:[[:space:]]*//;s/[[:space:]]*\.$//')

  if [ -z "$trigger" ]; then
    trigger="(No especificado)"
  fi

  # Limpiar doble /
  clean_path=$(echo "$skill_file" | sed 's|//|/|g')

  # Escribir entrada al índice
  echo "| **$name** | $desc | $trigger | \`$clean_path\` |" >> "$OUTPUT"
  found=1
done

# Si no se encontraron skills, indicar vacío
if [ "$found" -eq 0 ]; then
  echo "_No se encontraron skills adicionales a las fases SDD._" >> "$OUTPUT"
fi

echo ""
echo "Índice generado en: $OUTPUT"
