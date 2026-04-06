# Especificación de Instalación

## Propósito

Define el comportamiento del script de instalación (`scripts/install.sh` y `scripts/install.ps1`) para asegurar que las skills y la configuración del orquestador se desplieguen correctamente en los entornos de los agentes de IA compatibles.

## Requisitos

### Requisito: Soporte para el Agente Antigravity

El instalador **MUST** permitir la instalación de skills para el agente Antigravity. La ruta de destino predeterminada **SHALL** ser `~/.gemini/antigravity/skills/` (en entornos POSIX) o `$env:USERPROFILE\.gemini\antigravity\skills` (en entornos Windows).

#### Escenario: Instalación exitosa para Antigravity

- GIVEN el script de instalación `scripts/install.sh`
- WHEN el usuario ejecuta `bash scripts/install.sh --agent antigravity`
- THEN el script **MUST** crear el directorio `~/.gemini/antigravity/skills/` si no existe
- AND el script **MUST** copiar todas las skills SDD y los archivos compartidos a ese directorio

#### Escenario: Instalación para Antigravity mediante menú interactivo

- GIVEN el script de instalación `scripts/install.sh` en modo interactivo
- WHEN el usuario selecciona la opción "Antigravity"
- THEN el script **MUST** ejecutar el proceso de instalación para la ruta de Antigravity

### Requisito: Validación de Ruta de Destino

El script de instalación **MUST NOT** intentar realizar operaciones de copia o creación de directorios si la ruta de destino (target path) está vacía o es nula.

#### Escenario: Error por ruta de destino vacía

- GIVEN un agente cuya ruta de destino no ha sido definida en `get_tool_path`
- WHEN se intenta instalar para ese agente
- THEN el script **MUST** abortar la operación
- AND el script **MUST** mostrar un mensaje de error claro indicando que no se pudo determinar la ruta de instalación

#### Escenario: Prevención de ejecución en ruta vacía en install_skills

- GIVEN la función `install_skills` es invocada con un primer argumento vacío
- WHEN se intenta ejecutar el comando `mkdir -p`
- THEN el script **MUST** detectar el valor vacío antes de ejecutar el comando
- AND el script **MUST** salir con un código de error distinto de cero
