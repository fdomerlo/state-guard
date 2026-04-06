# Diseño: corregir-instalacion-antigravity

## Enfoque Técnico

El objetivo es corregir la omisión del agente `antigravity` en el script de instalación bash (`scripts/install.sh`), alineándolo con el comportamiento del script de PowerShell (`scripts/install.ps1`). Se implementará una corrección en la resolución de rutas y una validación defensiva en la función de instalación de habilidades.

## Decisiones de Arquitectura

### Decisión: Ruta de instalación para Antigravity

| Opción | Elección | Alternativas consideradas | Justificación |
|--------|----------|---------------------------|---------------|
| `~/.gemini/antigravity/skills` | **Sí** | `~/.antigravity/skills`, `./antigravity/skills` | Mantiene la consistencia con el ecosistema Gemini CLI y con el script `install.ps1`. |

### Decisión: Validación de ruta en `install_skills`

| Opción | Elección | Alternativas consideradas | Justificación |
|--------|----------|---------------------------|---------------|
| Abortar con error claro | **Sí** | Continuar con advertencia, usar ruta temporal | Evita errores silenciosos o crípticos de comandos del sistema (`mkdir`). Mejora la mantenibilidad. |

## Flujo de Datos

```text
Usuario (CLI/Menú) ──→ install_for_agent(agent)
                          │
                          └─→ get_tool_path(agent) ──→ [RUTA]
                                                         │
                                                         ▼
                                          install_skills(target_dir, tool_name)
                                                         │
                                                         ├─→ Validar target_dir != ""
                                                         └─→ mkdir -p target_dir
```

## Cambios de Archivos

| Archivo            | Acción    | Descripción                                                                 |
|--------------------|-----------|-----------------------------------------------------------------------------|
| `scripts/install.sh` | Modificar | Agregar caso `antigravity` en `get_tool_path` y validación en `install_skills`. |

## Interfaces / Contratos

### `get_tool_path` (Bash)
```bash
get_tool_path() {
    local tool="$1"
    case "$tool" in
        # ... existentes
        antigravity)
            case "$OS" in
                windows)  echo "$USERPROFILE/.gemini/antigravity/skills" ;;
                wsl)      echo "$HOME/.gemini/antigravity/skills" ;;
                *)        echo "$HOME/.gemini/antigravity/skills" ;;
            esac
            ;;
        # ...
    esac
}
```

### `install_skills` (Bash)
```bash
install_skills() {
    local target_dir="$1"
    local tool_name="$2"

    if [[ -z "$target_dir" ]]; then
        print_error "Error: No target directory specified for $tool_name. Check get_tool_path."
        exit 1
    fi
    # ... rest
}
```

## Estrategia de Testing

| Capa        | Qué Testear                               | Enfoque                                                                 |
|-------------|-------------------------------------------|-------------------------------------------------------------------------|
| Integración | Instalación de Antigravity via `--agent` | Ejecutar `bash scripts/install.sh --agent antigravity` y verificar `~/.gemini/antigravity/skills`. |
| Manual      | Instalación de Antigravity via Menú      | Ejecutar `bash scripts/install.sh`, elegir opción 4 y verificar.        |
| Regresión   | Validación de ruta vacía                 | Forzar un agente desconocido y verificar que el script aborte limpiamente. |

## Migración / Despliegue

No se requiere migración. Los usuarios que ya tengan Antigravity configurado manualmente no se verán afectados, y los nuevos podrán instalarlo automáticamente.
