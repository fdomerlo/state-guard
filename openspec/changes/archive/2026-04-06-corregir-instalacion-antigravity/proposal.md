# Propuesta: corregir-instalacion-antigravity

## Intención

Corregir un error crítico en el script de instalación de bash (`scripts/install.sh`) que impide la instalación de skills para el agente Antigravity. El error `mkdir: no se puede crear el directorio «»: No existe el archivo o el directorio` ocurre porque la ruta de destino no está definida para este agente, resultando en una variable vacía.

## Alcance

### Dentro del Alcance
- Modificar `scripts/install.sh` para incluir la ruta de Antigravity en `get_tool_path`.
- Agregar validación defensiva en la función `install_skills` de `scripts/install.sh` para evitar ejecuciones con rutas vacías.
- Verificar que la instalación manual y automática (`all-global`) funcione correctamente para Antigravity en Linux/WSL.

### Fuera del Alcance
- Modificar el script de PowerShell `scripts/install.ps1` (ya funciona correctamente).
- Cambiar rutas de instalación de otros agentes.

## Enfoque

Se seguirá el enfoque recomendado en la exploración:
1. Actualizar la función `get_tool_path` en `scripts/install.sh` para devolver `~/.gemini/antigravity/skills` (o su equivalente en Windows/WSL) cuando el parámetro sea `antigravity`.
2. Insertar un chequeo al inicio de `install_skills` que aborte con un mensaje de error claro si el primer argumento (`target_dir`) está vacío.

## Áreas Afectadas

| Área               | Impacto    | Descripción                                      |
|--------------------|------------|--------------------------------------------------|
| `scripts/install.sh` | Modificado | Corrección de bug en `get_tool_path` y validación. |

## Riesgos

| Riesgo                                 | Probabilidad | Mitigación                                       |
|----------------------------------------|--------------|--------------------------------------------------|
| Error de sintaxis en el script bash    | Baja         | Probar el script en un entorno de pruebas.        |
| Ruta incorrecta para Antigravity       | Baja         | Sincronizar con la ruta usada en `install.ps1`.   |

## Plan de Rollback

Revertir los cambios en `scripts/install.sh` usando `git checkout scripts/install.sh` o restaurando una copia de seguridad manual.

## Dependencias

Ninguna.

## Criterios de Éxito

- [ ] `bash scripts/install.sh --agent antigravity` completa la instalación sin errores de `mkdir`.
- [ ] Las skills se copian correctamente a `~/.gemini/antigravity/skills/`.
- [ ] El instalador muestra un error descriptivo si se intenta instalar en una ruta vacía (prueba de regresión).
