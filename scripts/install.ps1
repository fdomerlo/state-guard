<#
.SYNOPSIS
    Agentify: SDD Orchestrator — Install Script for Windows PowerShell
.DESCRIPTION
    Copies skills to your AI coding assistant's skill directory
    Cross-platform: Windows PowerShell 5.1+, PowerShell Core
.PARAMETER Agent
    Specify which agent to install for (opencode, claude-code, gemini-cli, codex, vscode, antigravity, cursor, project-local, all-global)
.PARAMETER Path
    Custom install path (use with -Agent custom)
.EXAMPLE
    .\install.ps1 -Agent opencode
#>

param(
    [string]$Agent = "",
    [string]$Path = ""
)

# ============================================================================
# Script Setup
# ============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir
$SkillsSrc = Join-Path $RepoDir "skills"

# ============================================================================
# OS Detection
# ============================================================================

function Get-DetectedOS {
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        return "pwsh"
    }
    
    if ($IsWindows) {
        return "windows"
    }
    
    if ($IsLinux) {
        if (Test-Path "/proc/version") {
            $version = Get-Content "/proc/version" -Raw -ErrorAction SilentlyContinue
            if ($version -match "microsoft|WSL") {
                return "wsl"
            }
        }
        return "linux"
    }
    
    if ($IsMacOS) {
        return "macos"
    }
    
    return "unknown"
}

$OS = Get-DetectedOS

function Get-OSLabel {
    param([string]$OsType)
    switch ($OsType) {
        "windows" { return "Windows PowerShell" }
        "pwsh"   { return "PowerShell Core" }
        "linux"  { return "Linux" }
        "wsl"    { return "WSL" }
        "macos"  { return "macOS" }
        default  { return "Unknown" }
    }
}

# ============================================================================
# Color Support
# ============================================================================

$ESC = [char]0x1B

function Initialize-Colors {
    # Check if terminal supports ANSI colors
    if ($env:WT_SESSION -or $env:TERM_PROGRAM -or ($OS -eq "pwsh")) {
        $script:RED = "$ESC[0;31m"
        $script:GREEN = "$ESC[0;32m"
        $script:YELLOW = "$ESC[1;33m"
        $script:BLUE = "$ESC[0;34m"
        $script:CYAN = "$ESC[0;36m"
        $script:BOLD = "$ESC[1m"
        $script:NC = "$ESC[0m"
    } else {
        $script:RED = ""
        $script:GREEN = ""
        $script:YELLOW = ""
        $script:BLUE = ""
        $script:CYAN = ""
        $script:BOLD = ""
        $script:NC = ""
    }
}

Initialize-Colors

# ============================================================================
# Path Resolution
# ============================================================================

function Get-ToolPath {
    param([string]$Tool)
    
    $home = $HOME
    if (-not $home) {
        $home = $env:USERPROFILE
    }
    
    switch ($Tool) {
        "claude-code" {
            if ($OS -eq "windows") { return "$env:USERPROFILE\.claude\skills" }
            return "$home/.claude/skills"
        }
        "opencode" {
            if ($OS -eq "windows") { return "$env:USERPROFILE\.config\opencode\skills" }
            return "$home/.config/opencode/skills"
        }
        "opencode-commands" {
            if ($OS -eq "windows") { return "$env:USERPROFILE\.config\opencode\commands" }
            return "$home/.config/opencode/commands"
        }
        "gemini-cli" {
            if ($OS -eq "windows") { return "$env:USERPROFILE\.gemini\skills" }
            return "$home/.gemini/skills"
        }
        "antigravity" {
            if ($OS -eq "windows") { return "$env:USERPROFILE\.gemini\antigravity\skills" }
            return "$home/.gemini/antigravity/skills"
        }
        "project-local" { return ".\skills" }
    }
    return ""
}

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Header {
    Write-Host ""
    Write-Host "${CYAN}${BOLD}======================================${NC}" -NoNewline
    Write-Host "${CYAN}${BOLD}╗${NC}"
    Write-Host "${CYAN}${BOLD}║       Agentify: SDD Orchestrator— Installer     ║${NC}" -NoNewline
    Write-Host "${CYAN}${BOLD}║${NC}"
    Write-Host "${CYAN}${BOLD}║   Spec-Driven Development for AI Agents  ║${NC}" -NoNewline
    Write-Host "${CYAN}${BOLD}║${NC}"
    Write-Host "${CYAN}${BOLD}======================================${NC}" -NoNewline
    Write-Host "${CYAN}${BOLD}╝${NC}"
    Write-Host ""
    Write-Host "  ${BOLD}Detected:${NC} $(Get-OSLabel $OS)"
    Write-Host ""
}

function Write-Skill {
    param([string]$Message)
    Write-Host "  ${GREEN}✓${NC} $Message"
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  ${YELLOW}!${NC} $Message"
}

function Write-Error {
    param([string]$Message)
    Write-Host "  ${RED}✗${NC} $Message"
}

function Write-NextStep {
    param([string]$ConfigFile, [string]$ExampleFile)
    Write-Host ""
    Write-Host "${YELLOW}Next step:${NC} Add the orchestrator to your ${BOLD}$ConfigFile${NC}"
    Write-Host "  See: ${CYAN}$ExampleFile${NC}"
}

function Show-Help {
    Write-Host "Usage: install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Agent NAME    Install for a specific agent (non-interactive)"
    Write-Host "  -Path DIR      Custom install path (use with -Agent custom)"
    Write-Host "  -Help          Show this help"
    Write-Host ""
    Write-Host "Agents: claude-code, opencode, gemini-cli, antigravity, project-local, all-global"
}

# ============================================================================
# Config Injection Helpers
# ============================================================================

function Compile-AndAppendConfig {
    param(
        [string]$TargetFile,
        [string]$HeaderFile,
        [string]$ToolName,
        [string]$SkillsPath
    )
    
    $CoreFile = Join-Path $RepoDir "skills\_shared\orchestrator-core.md"
    $MarkerBegin = "<!-- BEGIN SDD ORCHESTRATOR -->"
    $MarkerEnd = "<!-- END SDD ORCHESTRATOR -->"
    
    $targetDir = Split-Path -Parent $TargetFile
    if ($targetDir -and -not (Test-Path $targetDir)) {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    }
    
    # If file exists and has our block, purge it safely
    if ((Test-Path $TargetFile) -and (Get-Content $TargetFile -Raw -ErrorAction SilentlyContinue) -match [regex]::Escape($MarkerBegin)) {
        $content = Get-Content $TargetFile -Raw
        $pattern = "(?s)$([regex]::Escape($MarkerBegin)).*?$([regex]::Escape($MarkerEnd))"
        $newContent = $content -replace $pattern, ""
        Set-Content -Path $TargetFile -Value $newContent -NoNewline
        Write-Skill "Bloque anterior del orquestador purgado en $(Split-Path $TargetFile -Leaf)"
    }
    
    # Assemble and compile new block
    Add-Content -Path $TargetFile -Value ""
    Add-Content -Path $TargetFile -Value $MarkerBegin
    
    # Add specific header (e.g., original CLAUDE.md)
    if (Test-Path $HeaderFile) {
        Get-Content $HeaderFile | Add-Content -Path $TargetFile
        Add-Content -Path $TargetFile -Value ""
    }
    
    # Inject compiled core
    if (Test-Path $CoreFile) {
        $coreContent = Get-Content $CoreFile -Raw
        $coreContent = $coreContent -replace "{{TOOL_NAME}}", $ToolName
        $coreContent = $coreContent -replace "{{SKILLS_PATH}}", $SkillsPath
        $coreContent = $coreContent -replace "{{EXTRA_LANGUAGE_RULE}}", ""
        Add-Content -Path $TargetFile -Value $coreContent
    } else {
        Write-Warn "No se encontró orchestrator-core.md en $CoreFile"
    }
    
    Add-Content -Path $TargetFile -Value ""
    Add-Content -Path $TargetFile -Value $MarkerEnd
    
    Write-Skill "Orquestador inyectado/actualizado exitosamente en $(Split-Path $TargetFile -Leaf)"
}

function Merge-OpenCodeConfig {
    $configDir = if ($OS -eq "windows") { "$env:USERPROFILE\.config\opencode" } else { "$HOME/.config/opencode" }
    $targetConfig = Join-Path $configDir "opencode.json"
    $sourceConfig = Join-Path $RepoDir "integrations\opencode\opencode.json"
    $coreFile = Join-Path $RepoDir "skills\_shared\orchestrator-core.md"
    
    $toolName = "OpenCode"
    $skillsPath = Get-ToolPath "opencode"
    
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    }
    
    # Use Python for safe JSON merge and prompt compilation
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCmd) {
        $pythonScript = @"
import json, sys, os
target_path, source_path, core_path, tool_name, skills_path = sys.argv[1:]

# Read source JSON (header)
try:
    with open(source_path, "r", encoding="utf-8") as f: source = json.load(f)
except Exception:
    sys.exit(1)

# Compile core in memory
core_text = ""
if os.path.exists(core_path):
    with open(core_path, "r", encoding="utf-8") as f: core_text = f.read()
    core_text = core_text.replace("{{TOOL_NAME}}", tool_name)
    core_text = core_text.replace("{{SKILLS_PATH}}", skills_path)
    core_text = core_text.replace("{{EXTRA_LANGUAGE_RULE}}", "")

# Join OpenCode prompt with core
original_prompt = source["agent"]["sdd-orchestrator"].get("prompt", "")
source["agent"]["sdd-orchestrator"]["prompt"] = original_prompt + "\n\n" + core_text

# Apply to user JSON
if os.path.exists(target_path):
    try:
        with open(target_path, "r", encoding="utf-8") as f: target = json.load(f)
    except Exception:
        target = {"`$schema": "https://opencode.ai/config.json", "agent": {}}
else:
    target = {"`$schema": "https://opencode.ai/config.json", "agent": {}}
    
if "agent" not in target: target["agent"] = {}
target["agent"]["sdd-orchestrator"] = source["agent"]["sdd-orchestrator"]

with open(target_path, "w", encoding="utf-8") as f: json.dump(target, f, indent=2, ensure_ascii=False)
sys.exit(0)
"@
        $tempScript = [System.IO.Path]::GetTempFileName() + ".py"
        Set-Content -Path $tempScript -Value $pythonScript -Encoding UTF8
        
        try {
            & python $tempScript $targetConfig $sourceConfig $coreFile $toolName $skillsPath 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Skill "sdd-orchestrator compilado e inyectado en opencode.json"
            } else {
                Write-Warn "No se pudo inyectar automáticamente. Error en compilación Python."
            }
        } catch {
            Write-Warn "No se detectó Python3. Copia el orquestador a opencode.json manualmente."
        } finally {
            Remove-Item $tempScript -Force -ErrorAction SilentlyContinue
        }
    } else {
        Write-Warn "No se detectó Python3. Copia el orquestador a opencode.json manualmente."
    }
}

# ============================================================================
# Install Functions
# ============================================================================

function Test-SourceValid {
    $missing = 0
    
    foreach ($skillDir in Get-ChildItem -Path $SkillsSrc -Directory) {
        if ($skillDir.Name -eq "_shared" -or $skillDir.Name -eq "skill-registry") {
            continue
        }
        $skillMd = Join-Path $skillDir.FullName "SKILL.md"
        if (-not (Test-Path $skillMd)) {
            Write-Error "Missing: $($skillDir.Name)/SKILL.md"
            $missing++
        }
    }
    
    $sharedDir = Join-Path $SkillsSrc "_shared"
    if (-not (Test-Path $sharedDir)) {
        Write-Error "Missing: _shared/ directory"
        $missing++
    }
    
    if ($missing -gt 0) {
        Write-Host ""
        Write-Host "${RED}${BOLD}Source validation failed.${NC} Is this a complete clone of the repository?"
        Write-Host "  Try: ${CYAN}git clone https://github.com/TU-USUARIO/agentify-sdd.git${NC}"
        Write-Host ""
        exit 1
    }
}

function Install-Skills {
    param([string]$TargetDir, [string]$ToolName)
    
    Write-Host ""
    Write-Host "${BLUE}Installing skills for ${BOLD}$ToolName${NC}${BLUE}...${NC}"
    
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    
    # Copy shared convention files (_shared/)
    $sharedSrc = Join-Path $SkillsSrc "_shared"
    $sharedTarget = Join-Path $TargetDir "_shared"
    
    if (Test-Path $sharedSrc) {
        $sharedCount = 0
        if (-not (Test-Path $sharedTarget)) {
            New-Item -ItemType Directory -Path $sharedTarget -Force | Out-Null
        }
        foreach ($sharedFile in Get-ChildItem -Path $sharedSrc -Filter "*.md") {
            Copy-Item -Path $sharedFile.FullName -Destination $sharedTarget -Force
            $sharedCount++
        }
        if ($sharedCount -gt 0) {
            Write-Skill "_shared ($sharedCount convention files)"
        } else {
            Write-Warn "_shared directory found but no .md files to copy"
        }
    }
    
    $count = 0
    foreach ($skillDir in Get-ChildItem -Path $SkillsSrc -Directory) {
        $skillName = $skillDir.Name
        if ($skillName -eq "_shared") {
            continue
        }
        
        $skillMdSrc = Join-Path $skillDir.FullName "SKILL.md"
        
        # Verify source SKILL.md exists for sdd skills
        if ($skillName -like "sdd-*" -and -not (Test-Path $skillMdSrc)) {
            Write-Warn "Skipping $skillName (SKILL.md not found in source)"
            continue
        }
        
        $skillDirTarget = Join-Path $TargetDir $skillName
        if (-not (Test-Path $skillDirTarget)) {
            New-Item -ItemType Directory -Path $skillDirTarget -Force | Out-Null
        }
        
        Copy-Item -Path "$($skillDir.FullName)\*" -Destination $skillDirTarget -Recurse -Force
        Write-Skill $skillName
        $count++
    }
    
    Write-Host ""
    Write-Host "  ${GREEN}${BOLD}$count skills installed${NC} → $TargetDir"
}



# ============================================================================
# Agent Install Dispatcher
# ============================================================================

function Install-ForAgent {
    param([string]$AgentName)
    
    switch ($AgentName) {
        "claude-code" {
            $targetPath = Get-ToolPath "claude-code"
            Install-Skills $targetPath "Claude Code"
            $configTarget = "$env:USERPROFILE\.claude\CLAUDE.md"
            if (-not $configTarget.Contains("$env:USERPROFILE")) {
                $configTarget = "$HOME\.claude\CLAUDE.md"
            }
            Compile-AndAppendConfig -TargetFile $configTarget -HeaderFile (Join-Path $RepoDir "integrations\claude-code\CLAUDE.md") -ToolName "Claude Code" -SkillsPath $targetPath
        }
        "opencode" {
            $targetPath = Get-ToolPath "opencode"
            Install-Skills $targetPath "OpenCode"
            Merge-OpenCodeConfig
        }
        "gemini-cli" {
            $targetPath = Get-ToolPath "gemini-cli"
            Install-Skills $targetPath "Gemini CLI"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.gemini\GEMINI.md" } else { "$HOME/.gemini/GEMINI.md" }
            Compile-AndAppendConfig -TargetFile $configTarget -HeaderFile (Join-Path $RepoDir "integrations\gemini-cli\GEMINI.md") -ToolName "Gemini CLI" -SkillsPath $targetPath
        }
        "antigravity" {
            $target = Get-ToolPath "antigravity"
            Install-Skills $target "Antigravity"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.gemini\GEMINI.md" } else { "$HOME/.gemini/GEMINI.md" }
            if (Test-Path ".\.agent\rules") {
                Remove-Item -Path ".\.agent\rules" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Compile-AndAppendConfig -TargetFile $configTarget -HeaderFile (Join-Path $RepoDir "integrations\antigravity\sdd-orchestrator.md") -ToolName "Antigravity" -SkillsPath $target
        }
        "project-local" {
            $targetPath = Get-ToolPath "project-local"
            Install-Skills $targetPath "Project-local"
            Write-Host ""
            Write-Host "${YELLOW}Note:${NC} Skills installed in ${BOLD}./skills/${NC} — relative to this project"
        }
        "all-global" {
            # Claude Code
            $targetPath = Get-ToolPath "claude-code"
            Install-Skills $targetPath "Claude Code"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.claude\CLAUDE.md" } else { "$HOME/.claude/CLAUDE.md" }
            Compile-AndAppendConfig -TargetFile $configTarget -HeaderFile (Join-Path $RepoDir "integrations\claude-code\CLAUDE.md") -ToolName "Claude Code" -SkillsPath $targetPath
            
            # OpenCode
            $targetPath = Get-ToolPath "opencode"
            Install-Skills $targetPath "OpenCode"
            Merge-OpenCodeConfig
            
            # Gemini CLI
            $targetPath = Get-ToolPath "gemini-cli"
            Install-Skills $targetPath "Gemini CLI"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.gemini\GEMINI.md" } else { "$HOME/.gemini/GEMINI.md" }
            Compile-AndAppendConfig -TargetFile $configTarget -HeaderFile (Join-Path $RepoDir "integrations\gemini-cli\GEMINI.md") -ToolName "Gemini CLI" -SkillsPath $targetPath
            
            # Antigravity
            $targetPath = Get-ToolPath "antigravity"
            Install-Skills $targetPath "Antigravity"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.gemini\GEMINI.md" } else { "$HOME/.gemini/GEMINI.md" }
            if (Test-Path ".\.agent\rules") {
                Remove-Item -Path ".\.agent\rules" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Compile-AndAppendConfig -TargetFile $configTarget -HeaderFile (Join-Path $RepoDir "integrations\antigravity\sdd-orchestrator.md") -ToolName "Antigravity" -SkillsPath $targetPath
            
            Write-Host ""
            Write-Host "${GREEN}${BOLD}Todos los orquestadores globales configurados automaticamente!${NC}"
        }
        "custom" {
            if ([string]::IsNullOrEmpty($Path)) {
                Write-Host "Enter target path: " -NoNewline
                $customPath = Read-Host
            } else {
                $customPath = $Path
            }
            Install-Skills $customPath "Custom"
        }
        default {
            Write-Error "Unknown agent: $AgentName"
            Write-Host ""
            Show-Help
            exit 1
        }
    }
}

# ============================================================================
# Interactive Menu
# ============================================================================

function Show-InteractiveMenu {
    Write-Host "${BOLD}Select your AI coding assistant:${NC}"
    Write-Host ""
    Write-Host "  1) Claude Code    ($(Get-ToolPath "claude-code"))"
    Write-Host "  2) OpenCode       ($(Get-ToolPath "opencode"))"
    Write-Host "  3) Gemini CLI     ($(Get-ToolPath "gemini-cli"))"
    Write-Host "  4) Antigravity    (~/.gemini/antigravity/skills/)"
    Write-Host "  5) Project-local  ($(Get-ToolPath "project-local"))"
    Write-Host "  6) All global     (Claude Code + OpenCode + Gemini CLI + Antigravity)"
    Write-Host "  7) Custom path"
    Write-Host ""
    $choice = Read-Host "Choice [1-7]"
    
    switch ($choice) {
        "1"  { Install-ForAgent "claude-code" }
        "2"  { Install-ForAgent "opencode" }
        "3"  { Install-ForAgent "gemini-cli" }
        "4"  { Install-ForAgent "antigravity" }
        "5"  { Install-ForAgent "project-local" }
        "6"  { Install-ForAgent "all-global" }
        "7"  { Install-ForAgent "custom" }
        default {
            Write-Error "Invalid choice"
            exit 1
        }
    }
}

# ============================================================================
# Main
# ============================================================================

# Parse arguments
$agentArg = $Agent
$pathArg = $Path

# Check for help
if ($args -contains "-Help" -or $args -contains "-h" -or $args -contains "/?" ) {
    Show-Help
    exit 0
}

Write-Header
Test-SourceValid

if (-not [string]::IsNullOrEmpty($agentArg)) {
    # Non-interactive mode
    Install-ForAgent $agentArg
} else {
    # Interactive mode
    Show-InteractiveMenu
}

Write-Host ""
Write-Host "${GREEN}${BOLD}Done!${NC} Start using SDD with: ${CYAN}/sdd-init${NC} in your project"
Write-Host ""
