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

### Requisito: Conteo de Comandos y Skills

El script `install_test.sh` DEBE validar que el número de comandos equals el número de skills, siendo ambos exactamente 15.

#### Escenario: Validación de Conteo Igual a 15

- GIVEN el usuario ejecuta `scripts/install_test.sh`
- AND existen exactamente 15 comandos en `examples/opencode/commands/`
- AND existen exactamente 15 skills en `~/.config/opencode/skills/sdd-*/`
- WHEN el script procesa la validación
- THEN DEBE pasar todas las validaciones de conteo
- AND DEBE mostrar mensaje de éxito

#### Escenario: Conteo de Comandos Menor a 15

- GIVEN el usuario ejecuta `scripts/install_test.sh`
- AND existen menos de 15 comandos en `examples/opencode/commands/`
- WHEN el script procesa la validación
- THEN DEBE fallar en el assert de comandos
- AND DEBE indicar cuántos comandos faltan

#### Escenario: Conteo de Skills Mayor a Comandos

- GIVEN el usuario ejecuta `scripts/install_test.sh`
- AND existen 15 skills pero solo 12 comandos
- WHEN el script procesa la validación
- THEN DEBE fallar indicando la desincronización
- AND DEBE sugerir qué comandos faltan crear

### Requisito: Arrays de Validación

El script DEBE mantener arrays separados para commands y skills, cada uno con el valor correcto de 15.

#### Escenario: Arrays con Valores Correctos

- GIVEN el script define `EXPECTED_COMMANDS=15` y `EXPECTED_SKILLS=15`
- WHEN el script procesa los conteos
- THEN DEBE usar ambos valores en sus respective validaciones
- AND DEBE fallar si cualquier conteo no coincide con su valor esperado

### Requisito: Integridad de la Instalación

El script DEBE verificar que cada comando nuevo tiene su correspondiente skill.

#### Escenario: mapeo Commands a Skills

- GIVEN el script valida los archivos
- WHEN procesa el mapeo comando → skill
- THEN cada archivo en `examples/opencode/commands/sdd-*.md` DEBE corresponderse con una skill `sdd-*` en el directorio de skills
- AND DEBE fallar si encuentra un comando sin skill correspondiente

### Requisito: Conteo de EXPECTED_COMMANDS

El valor de `EXPECTED_COMMANDS` DEBE ser 15.

#### Escenario: Validación del Nuevo Conteo

- GIVEN el script define `EXPECTED_COMMANDS=15`
- WHEN el script cuenta los archivos en `examples/opencode/commands/`
- THEN DEBE esperar exactamente 15 archivos `.md`
- AND DEBE fallar si el conteo real es diferente
