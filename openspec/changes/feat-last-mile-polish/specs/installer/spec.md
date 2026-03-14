# Delta para Installer

## Propósito

Esta especificación define el comportamiento del script de instalación en Windows usando PowerShell. El script debe replicar exactamente la funcionalidad de `install.sh` incluyendo detección de SO, compilación de configuración, e instalación de skills.

## Requisitos AGREGADOS

### Requisito: Compatibilidad con PowerShell Nativo

El sistema DEBE proporcionar un script `install.ps1` que funcione en Windows PowerShell 5.1+ (Windows 10+) sin depender de Bash.

#### Escenario: Ejecución en Windows PowerShell

- GIVEN el usuario ejecuta `powershell -ExecutionPolicy Bypass -File install.ps1` en Windows
- AND el sistema operativo es Windows 10/11
- WHEN el script procesa la ejecución
- THEN DEBE detectar correctamente el SO como Windows
- AND DEBE usar cmdlets PowerShell equivalentes (`$env:USERPROFILE`, etc.)
- AND DEBE completar la instalación exitosamente

#### Escenario: Ejecución en PowerShell Core (pwsh)

- GIVEN el usuario ejecuta `pwsh install.ps1` en Windows con PowerShell Core instalado
- WHEN el script procesa la ejecución
- THEN DEBE detectar el SO correctamente
- AND DEBE funcionar de manera equivalente a Windows PowerShell

#### Escenario: Ejecución con Flags de Herramienta

- GIVEN el usuario ejecuta `install.ps1 -Agent opencode`
- AND especifica una herramienta válida (opencode, claude-code, etc.)
- WHEN el script procesa los argumentos
- THEN DEBE instalar los skills para la herramienta especificada
- AND DEBE comportarse de manera idéntica a `install.sh --agent {herramienta}`

### Requisito: Compilación de Configuración

El sistema DEBE realizar compilación estática inyectando las variables `{{TOOL_NAME}}` y `{{SKILLS_PATH}}` en el archivo `orchestrator-core.md`.

#### Escenario: Inyección de Variables en Core

- GIVEN el usuario ejecuta `install.ps1 -Agent opencode`
- AND el archivo `orchestrator-core.md` contiene marcadores `{{TOOL_NAME}}` y `{{SKILLS_PATH}}`
- WHEN el script compila el archivo
- THEN DEBE reemplazar `{{TOOL_NAME}}` con "OpenCode"
- AND DEBE reemplazar `{{SKILLS_PATH}}` con la ruta correcta (`$env:USERPROFILE/.config/opencode/skills`)
- AND DEBE escribir el archivo compilado en el destino apropiado

#### Escenario: Actualización de Instalación Existente

- GIVEN el usuario tiene una instalación previa del orquestador
- AND ejecuta `install.ps1 -Agent opencode` nuevamente
- WHEN el script procesa la instalación
- THEN DEBE purgar el bloque anterior del orquestador ( markers `### BEGIN SDD ORCHESTRATOR ###` y `### END SDD ORCHESTRATOR ###`)
- AND DEBE agregar el nuevo bloque compilado

### Requisito: Detección de SO

El sistema DEBE detectar correctamente el sistema operativo usando `$PSVersionTable.OS` o variables de entorno equivalentes.

#### Escenario: Detección de Windows Nativo

- GIVEN el script se ejecuta en Windows nativo (no WSL)
- WHEN el script detecta el SO
- THEN DEBE identificar OS como "windows"
- AND DEBE usar `%USERPROFILE%` o `$env:USERPROFILE` para rutas

#### Escenario: Detección de WSL

- GIVEN el script se ejecuta en WSL (Windows Subsystem for Linux)
- AND el usuario ejecuta el script desde Bash en WSL
- WHEN el script detecta el SO
- THEN DEBE identificar como WSL si es detectable
- AND DEBE usar rutas de Linux (`$HOME/.config/...`)

### Requisito: Validación de Source

El sistema DEBE validar que el código fuente del proyecto esté completo antes de proceder con la instalación.

#### Escenario: Source Válido

- GIVEN el usuario ejecuta `install.ps1`
- AND todos los archivos `SKILL.md` existen en `skills/sdd-*/`
- AND el directorio `_shared/` existe
- WHEN el script valida el source
- THEN DEBE continuar con la instalación

#### Escenario: Source Incompleto

- GIVEN el usuario ejecuta `install.ps1`
- AND faltan archivos `SKILL.md` en el directorio skills
- OR el directorio `_shared/` no existe
- WHEN el script valida el source
- THEN DEBE mostrar error indicando los archivos faltantes
- AND DEBE salir con código de error 1
