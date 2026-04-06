# Tareas: corregir-instalacion-antigravity

## Fase 1: Implementación en `scripts/install.sh`

- [x] 1.1 **Actualizar `get_tool_path`**: Agregar el caso `antigravity` que devuelva la ruta `~/.gemini/antigravity/skills` (con soporte para Windows/WSL).
- [x] 1.2 **Validación defensiva en `install_skills`**: Insertar un chequeo al inicio de la función para abortar con `print_error` si `target_dir` está vacío.

## Fase 2: Testing y Verificación

- [x] 2.1 **Test: Instalación directa**: Ejecutar `bash scripts/install.sh --agent antigravity` y verificar que el directorio `~/.gemini/antigravity/skills` se cree y contenga las skills.
- [x] 2.2 **Test: Instalación interactiva**: Ejecutar `bash scripts/install.sh`, seleccionar la opción 4 y verificar la instalación.
- [x] 2.3 **Test de regresión (Ruta vacía)**: Modificar temporalmente el script para llamar a `install_skills` con un argumento vacío y verificar que aborte con el mensaje de error diseñado.

## Fase 3: Documentación y Cierre

- [x] 3.1 **Verificar consistencia**: Asegurar que las rutas coincidan con `scripts/install.ps1`.
- [x] 3.2 **Actualizar estado**: Marcar todas las tareas como completadas en `tasks.md`.
