# Diseño: feat-last-mile-polish

## Enfoque Técnico

Este cambio implementa 4 mejoras independientes y ortogonales al ecosistema agentify-sdd:

1. **Seguridad en archivado**: Agregar verificación git antes de mover cambios al archive, bloquando si hay cambios sin commitear en el directorio del cambio.

2. **Soporte Windows PowerShell**: Crear un script `install.ps1` que replique exactamente la funcionalidad de `install.sh` usando cmdlets PowerShell idiomáticos.

3. **Autogeneración de Changelog**: Crear el skill `sdd-changelog` que genera `CHANGELOG.md` desde las carpetas archivadas en `openspec/changes/archive/`.

4. **Naming y Errores Comunes**: Imponer regla `kebab-case` para nombres de cambios y documentar errores comunes en skills relevantes.

Las 4 tareas se implementarán de forma secuencial e independiente, dado que no tienen dependencias entre sí.

## Decisiones de Arquitectura

### Decisión 1: Verificación Git en sdd-archive

**Elección**: Ejecutar `git status --porcelain` desde el directorio raíz del proyecto antes de proceder con el archivado.

**Alternativas consideradas**:
- Usar `git diff --quiet` (solo detecta cambios, no qué archivos)
- Usar `git status --short` (formato menos estable que --porcelain)
- Verificar solo en el directorio del cambio con `git -C path status` (puede fallar si el cambio no está en git)

**Justificación**: El formato `--porcelain` es estable y machine-parseable. Ejecutar desde raíz permite filtrar exactamente qué archivos modificados pertenecen al directorio del cambio usando prefix matching.

### Decisión 2: Diseño del Script PowerShell

**Elección**: Implementar `install.ps1` con la misma arquitectura modular que `install.sh`: detección de SO, colores, helpers, funciones de instalación, y compilación de config.

**Alternativas consideradas**:
- Wrapper que llame a `install.sh` desde PowerShell (no es nativo Windows)
- Usar solo cmdlets básicos sin estructura modular (difícil de mantener)
- Generar el script dinámicamente desde una plantilla (añade complejidad innecesaria)

**Justificación**: Mantener paridad estructural con `install.sh` facilita el mantenimiento y la comparación. Los cmdlets PowerShell equivalentes (`$env:USERPROFILE`, `-replace`, `Test-Path`, etc.) son idiomáticos y bien documentados.

### Decisión 3: Formato del Changelog Generado

**Elección**: Formato Markdown con secciones por fecha, extrayendo intención y alcance de `proposal.md`.

**Alternativas consideradas**:
- Formato JSON (menos legible para humanos)
- Formato Keep a Changelog (más estricto, requiere mapeo de categorías)
- Generar solo lista simple (pierde contexto de intención)

**Justificación**: El formato propuesto preserva la información más relevante (intención, alcance) sin añadir complejidad de categorización. Es legible y extensible.

### Decisión 4: Validación de Naming

**Elección**: Validar nombre en fase `sdd-propose` (cuando se crea el cambio), no en fases posteriores.

**Alternativas consideradas**:
- Validar en todas las fases (redundante, impacta rendimiento)
- Validar solo en sdd-apply (tarde, ya hay trabajo realizado)
- Validar en orquestador antes de delegar (requiere cambios en core)

**Justificación**: `sdd-propose` es el punto de entrada donde se define el nombre. Validar aquí es temprano enough para corregir y centraliza la validación.

## Flujo de Datos

### Componente 1: Seguridad Git en Archive

```
Usuario ejecuta /sdd-archive
         │
         ▼
sdd-archive detecta modo openspec
         │
         ▼
Verificar si .git/ existe ──NO──▶ Continuar sin verificación
         │
        SÍ
         ▼
Ejecutar git status --porcelain
         │
         ▼
Filtrar archivos del directorio del cambio
         │
    ┌────┴────┐
    │         │
Hay cambios  No hay cambios
    │         │
    ▼         ▼
BLOQUEAR    Proceder con
            archivado
```

### Componente 2: Instalador PowerShell

```
Usuario ejecuta install.ps1 -Agent {tool}
         │
         ▼
Detectar OS con $PSVersionTable.OS
         │
         ▼
Validar source (skills/sdd-*/SKILL.md)
         │
         ▼
Determinar ruta destino según tool
         │
         ▼
Copiar skills a destino
         │
         ▼
Compilar orchestrator-core.md (reemplazar {{TOOL_NAME}}, {{SKILLS_PATH}})
         │
         ▼
Inyectar en archivo de config del tool
```

### Componente 3: Generación de Changelog

```
Usuario ejecuta /sdd-changelog
         │
         ▼
Listar carpetas en openspec/changes/archive/
         │
         ▼
Para cada carpeta: leer proposal.md
         │
         ▼
Extraer: título, intención, alcance, fecha
         │
         ▼
Ordenar por fecha (más reciente primero)
         │
         ▼
Generar CHANGELOG.md en raíz
```

### Componente 4: Validación de Naming

```
Usuario ejecuta /sdd-new {nombre}
         │
         ▼
sdd-propose recibe nombre
         │
         ▼
Validar regex: ^[a-z0-9]+(-[a-z0-9]+)*$
         │
    ┌────┴────┐
    │         │
 Válido    Inválido
    │         │
    ▼         ▼
Continuar  Mostrar error
           con ejemplo
```

## Cambios de Archivos

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `skills/sdd-archive/SKILL.md` | Modificar | Agregar paso de verificación git antes de mover al archive |
| `scripts/install.ps1` | Crear | Equivalente PowerShell de install.sh (~550 líneas) |
| `skills/sdd-changelog/SKILL.md` | Crear | Skill para generar CHANGELOG.md desde archive |
| `examples/opencode/commands/sdd-changelog.md` | Crear | Comando OpenCode para invocar sdd-changelog |
| `skills/_shared/orchestrator-core.md` | Modificar | Agregar comando /sdd-changelog a la lista de comandos |
| `scripts/install_test.sh` | Modificar | Actualizar contador de 12 a 13 skills |
| `skills/sdd-init/SKILL.md` | Modificar | Incluir `change_naming: kebab-case` en template de config.yaml |
| `skills/_shared/openspec-convention.md` | Modificar | Documentar regla de nomenclatura kebab-case |
| `skills/sdd-propose/SKILL.md` | Modificar | Agregar sección "Errores Comunes" |
| `skills/sdd-apply/SKILL.md` | Modificar | Agregar sección "Errores Comunes" |

## Interfaces / Contratos

###Nueva Función: Verificación Git (sdd-archive)

```bash
# En sdd-archive/SKILL.md, agregar función:
verify_git_clean_for_change() {
    local change_dir="$1"
    
    # Verificar si es repositorio git
    if [ ! -d ".git" ]; then
        echo "INFO: No git repository detected, skipping verification"
        return 0
    fi
    
    # Verificar si git está disponible
    if ! command -v git &> /dev/null; then
        echo "WARN: git not available, skipping verification"
        return 0
    fi
    
    # Obtener cambios sin commitear
    local status
    status=$(git status --porcelain)
    
    # Filtrar solo archivos del directorio del cambio
    local changed_files
    changed_files=$(echo "$status" | grep "$change_dir" || true)
    
    if [ -n "$changed_files" ]; then
        echo "ERROR: Uncommitted changes detected in $change_dir:"
        echo "$changed_files"
        echo ""
        echo "Please commit your changes before archiving."
        return 1
    fi
    
    return 0
}
```

###Nueva Función: Reemplazo de Variables (PowerShell)

```powershell
# En install.ps1
function Compile-CoreFile {
    param(
        [string]$CoreFilePath,
        [string]$ToolName,
        [string]$SkillsPath
    )
    
    $content = Get-Content $CoreFilePath -Raw
    $content = $content -replace '{{TOOL_NAME}}', $ToolName
    $content = $content -replace '{{SKILLS_PATH}}', $SkillsPath
    
    return $content
}
```

###Nueva Función: Validación de Naming

```bash
# En sdd-propose/SKILL.md, agregar validación:
validate_change_name() {
    local name="$1"
    
    if ! [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
        echo "ERROR: Change name must be kebab-case"
        echo "Example: my-feature-name, fix-bug-123"
        echo "Invalid: camelCase, PascalCase, snake_case, with spaces"
        return 1
    fi
    
    return 0
}
```

## Estrategia de Testing

| Capa | Qué Testear | Enfoque |
|------|-------------|---------|
| Unitario (archive) | Función de verificación git | Mockear `git status --porcelain` y verificar detección de archivos del cambio |
| Unitario (install.ps1) | Detección de SO, compilación de variables | Tests con variables de entorno simuladas |
| Unitario (naming) | Validación regex | Casos: kebab-case válido, camelCase, PascalCase, espacios, snake_case |
| Integración (changelog) | Generación real con archive vacío y con cambios | Crear carpetas de prueba y verificar salida |
| Manual (installer) | Ejecución en Windows real | Probar con Windows 10/11 PowerShell y pwsh |

### Testing Específico para install.ps1

- Ejecutar en Windows PowerShell 5.1 (Windows 10)
- Ejecutar en PowerShell Core 7+ (pwsh)
- Verificar que genera los mismos archivos que install.sh
- Verificar que purga bloques anteriores del orquestador

## Migración / Despliegue

No se requiere migración. Este cambio:
- Añade nuevo archivo (install.ps1, sdd-changelog)
- Modifica skills existentes de forma additive
- No altera datos existentes
- Es backwards compatible

El único archivo que puede ser regenerado es `CHANGELOG.md`, que se regenera completamente en cada ejecución de sdd-changelog.

## Preguntas Abiertas

- [ ] ¿Se debe verificar también que el repositorio tenga al menos un commit antes dearchivar? (Actualmente solo verifica cambios sin commitear)
- [ ] ¿El formato del changelog debe incluir enlaces a los archivos archive? (Añadiría complejidad pero mejoraría navegabilidad)
- [ ] ¿La validación de naming debe ser blockeante o solo warning? (Spec dice RECHAZAR, pero podría ser muy estricto)

---

**Nota**: Este diseño se basa en el código existente de `install.sh` (539 líneas), las convenciones de `openspec-convention.md`, y los requisitos de las 4 specs delta. Cualquier desviación de estos archivos fuente debe ser justificada explícitamente durante la implementación.
