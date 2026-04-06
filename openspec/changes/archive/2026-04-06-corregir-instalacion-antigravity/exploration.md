## Exploración: Error en la instalación de skills para Antigravity en bash

### Estado Actual
El script de instalación en bash (`scripts/install.sh`) no tiene definida la ruta de destino para el agente `antigravity` en la función `get_tool_path`. Cuando un usuario intenta instalar para este agente (ya sea vía interactiva o con `--agent antigravity`), la variable `$target` se asigna vacía. Posteriormente, el comando `mkdir -p "$target_dir"` dentro de `install_skills` recibe una cadena vacía, resultando en el error reportado: `mkdir: no se puede crear el directorio «»: No existe el archivo o el directorio`.

### Áreas Afectadas
- `scripts/install.sh` — La función `get_tool_path` carece del caso `antigravity`.
- `scripts/install.ps1` — (Como contraste) Este archivo sí tiene la implementación correcta, lo que sugiere que es un bug de omisión en el script de bash.

### Enfoques
1. **Corregir `get_tool_path` en `install.sh`** — Agregar el caso faltante para `antigravity` que apunte a `~/.gemini/antigravity/skills`, igualando el comportamiento del script de PowerShell.
   - Ventajas: Resuelve el error de raíz y mantiene la paridad entre plataformas.
   - Desventajas: Ninguna.
   - Esfuerzo: Bajo.

2. **Validar `$target_dir` en `install_skills`** — Agregar una verificación defensiva para asegurar que la ruta no esté vacía antes de intentar crear el directorio.
   - Ventajas: Previene errores similares en el futuro.
   - Desventajas: No soluciona el problema de que Antigravity no se pueda instalar.
   - Esfuerzo: Bajo.

### Recomendación
Implementar la **Opción 1** (corregir `get_tool_path`) ya que es la solución directa al bug reportado. Adicionalmente, se recomienda incluir una validación sencilla en `install_skills` para evitar errores crípticos de `mkdir` si se presentara otro caso similar.

### Riesgos
- **Rutas de usuario:** Asegurar que `$HOME` y `$USERPROFILE` se resuelven correctamente en todos los entornos Linux/WSL. (Ya se hace para otros agentes, por lo que el riesgo es mínimo).

### Listo para Propuesta
Sí — El orquestador puede proceder a crear una propuesta de corrección de bug.
