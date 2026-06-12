<#
.SYNOPSIS
    Agentify: SDD Memory Guard — Install Script for Windows PowerShell
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
    [Alias("Agent")]
    [string]$Target = "",
    [string]$Path = ""
)

# ============================================================================
# Script Setup
# ============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoDir = Split-Path -Parent $ScriptDir
$SkillsSrc = Join-Path $RepoDir "skills"

# Ensure global custom skills directory exists
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.skills-custom" -ErrorAction SilentlyContinue | Out-Null

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
    Write-Host "${CYAN}${BOLD}║       Agentify: SDD Memory Guard — Installer     ║${NC}" -NoNewline
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

function Show-Help {
    Write-Host "Usage: install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Target NAME   Install for a specific target engine (non-interactive)"
    Write-Host "  -Path DIR      Custom install path (use with -Target custom)"
    Write-Host "  -Help          Show this help"
    Write-Host ""
    Write-Host "Targets: claude-code, opencode, gemini-cli, antigravity, project-local, all-global"
}

# ============================================================================
# Packager Wrapper
# ============================================================================

function Call-Packager {
    param([string]$TargetName, [string]$SkillsPath, [string]$ConfigTarget)
    
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCmd) {
        $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
    }
    
    if ($pythonCmd) {
        $packagerScript = Join-Path $ScriptDir "packager.py"
        
        if ($TargetName -eq "opencode") {
            $commandsSrc = Join-Path $RepoDir "integrations\opencode\commands"
            $commandsTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.config\opencode\commands" } else { "$HOME/.config/opencode/commands" }
            & $pythonCmd.Path $packagerScript --target $TargetName --skills-path $SkillsPath --config-target "$ConfigTarget" --commands-src $commandsSrc --commands-target $commandsTarget 2>&1 | Out-Null
        } else {
            & $pythonCmd.Path $packagerScript --target $TargetName --skills-path $SkillsPath --config-target "$ConfigTarget" 2>&1 | Out-Null
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Skill "Configuracion inyectada correctamente para $TargetName mediante packager.py"
        } else {
            Write-Error "Error ejecutando packager.py para $TargetName"
        }
    } else {
        Write-Warn "No se detectó Python. La configuración no pudo ser empaquetada."
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
        Write-Host "  Try: ${CYAN}git clone https://github.com/fdomerlo/agentify-sdd.git${NC}"
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

function Install-ForTarget {
    param([string]$TargetName)
    
    switch ($TargetName) {
        "claude-code" {
            $targetPath = Get-ToolPath "claude-code"
            Install-Skills $targetPath "Claude Code"
            $configTarget = "$env:USERPROFILE\.claude\CLAUDE.md"
            if (-not $configTarget.Contains("$env:USERPROFILE")) {
                $configTarget = "$HOME\.claude\CLAUDE.md"
            }
            Call-Packager "claude-code" (Get-ToolPath "claude-code") $configTarget
        }
        "opencode" {
            $targetPath = Get-ToolPath "opencode"
            Install-Skills $targetPath "OpenCode"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.config\opencode\opencode.json" } else { "$HOME/.config/opencode/opencode.json" }
            Call-Packager "opencode" (Get-ToolPath "opencode") $configTarget
        }
        "gemini-cli" {
            $targetPath = Get-ToolPath "gemini-cli"
            Install-Skills $targetPath "Gemini CLI"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.gemini\GEMINI.md" } else { "$HOME/.gemini/GEMINI.md" }
            Call-Packager "gemini-cli" (Get-ToolPath "gemini-cli") $configTarget
        }
        "antigravity" {
            $targetPath = Get-ToolPath "antigravity"
            Install-Skills $targetPath "Antigravity"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.gemini\GEMINI.md" } else { "$HOME/.gemini/GEMINI.md" }
            if (Test-Path ".\.agent\rules") {
                Remove-Item -Path ".\.agent\rules" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Call-Packager "antigravity" (Get-ToolPath "antigravity") $configTarget
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
            Call-Packager "claude-code" (Get-ToolPath "claude-code") $configTarget
            
            # OpenCode
            $targetPath = Get-ToolPath "opencode"
            Install-Skills $targetPath "OpenCode"
            $ocTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.config\opencode\opencode.json" } else { "$HOME/.config/opencode/opencode.json" }
            Call-Packager "opencode" (Get-ToolPath "opencode") $ocTarget
            
            # Gemini CLI
            $targetPath = Get-ToolPath "gemini-cli"
            Install-Skills $targetPath "Gemini CLI"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.gemini\GEMINI.md" } else { "$HOME/.gemini/GEMINI.md" }
            Call-Packager "gemini-cli" (Get-ToolPath "gemini-cli") $configTarget
            
            # Antigravity
            $targetPath = Get-ToolPath "antigravity"
            Install-Skills $targetPath "Antigravity"
            $configTarget = if ($OS -eq "windows") { "$env:USERPROFILE\.gemini\GEMINI.md" } else { "$HOME/.gemini/GEMINI.md" }
            if (Test-Path ".\.agent\rules") {
                Remove-Item -Path ".\.agent\rules" -Recurse -Force -ErrorAction SilentlyContinue
            }
            Call-Packager "antigravity" (Get-ToolPath "antigravity") $configTarget
            
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
            Call-Packager "custom" $customPath ""
        }
        default {
            Write-Error "Unknown target: $TargetName"
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
        "1"  { Install-ForTarget "claude-code" }
        "2"  { Install-ForTarget "opencode" }
        "3"  { Install-ForTarget "gemini-cli" }
        "4"  { Install-ForTarget "antigravity" }
        "5"  { Install-ForTarget "project-local" }
        "6"  { Install-ForTarget "all-global" }
        "7"  { Install-ForTarget "custom" }
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
$targetArg = $Target
$pathArg = $Path

# Check for help
if ($args -contains "-Help" -or $args -contains "-h" -or $args -contains "/?" ) {
    Show-Help
    exit 0
}

Write-Header
Test-SourceValid

if (-not [string]::IsNullOrEmpty($targetArg)) {
    # Non-interactive mode
    Install-ForTarget $targetArg
} else {
    # Interactive mode
    Show-InteractiveMenu
}

Write-Host ""
Write-Host "${GREEN}${BOLD}Done!${NC} Start using SDD with: ${CYAN}/sdd-init${NC} in your project"
Write-Host ""
