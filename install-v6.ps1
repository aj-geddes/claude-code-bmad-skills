###############################################################################
# BMAD Method v6 for Claude Code - PowerShell Installation Script
#
# Installs BMAD Method v6 using only Claude Code native features
# No npx, no external dependencies, pure Claude Code
#
# Supports: PowerShell 5.1+ (Windows default) and PowerShell 6+ (Core)
#
# Usage:
#   .\install-v6.ps1              # Standard installation
#   .\install-v6.ps1 -Verbose     # Detailed diagnostic output
#   .\install-v6.ps1 -WhatIf      # Dry-run (show what would be installed)
#   .\install-v6.ps1 -Force       # Force reinstall over existing
#   .\install-v6.ps1 -Uninstall   # Remove BMAD Method v6
###############################################################################

<#
.SYNOPSIS
    Installs BMAD Method v6 for Claude Code.

.DESCRIPTION
    This script installs the BMAD Method v6 framework to the Claude Code
    configuration directory (~/.claude/). It includes:
    - Core orchestration skills
    - BMM (BMAD Method Management) skills
    - BMB (BMAD Method Baseline) skills (optional)
    - CIS (Contribution Integration System) skills (optional)
    - Configuration templates
    - Utility helpers

    The installer is compatible with PowerShell 5.1 (Windows default) and
    PowerShell 6+ (Core) on Windows, Linux, and macOS.

.PARAMETER Help
    Display this help information.

.PARAMETER Verbose
    Display detailed diagnostic information during installation.

.PARAMETER WhatIf
    Show what would be installed without actually installing (dry-run).

.PARAMETER Force
    Force reinstallation even if BMAD v6 is already installed.

.PARAMETER Uninstall
    Remove BMAD Method v6 from the system.

.EXAMPLE
    .\install-v6.ps1

    Installs BMAD Method v6 with standard output.

.EXAMPLE
    .\install-v6.ps1 -Verbose

    Installs BMAD Method v6 with detailed diagnostic output.

.EXAMPLE
    .\install-v6.ps1 -WhatIf

    Shows what would be installed without actually installing.

.EXAMPLE
    .\install-v6.ps1 -Uninstall

    Removes BMAD Method v6 from the system.

.NOTES
    Version: 6.0.3
    Requires: PowerShell 5.1+
    Updated: 2025-11-14
    Changes: Fixed PowerShell function scoping issues for WSL compatibility by making all
             functions globally scoped. This resolves "Write-Success is not recognized" errors
             when running in WSL PowerShell environments.
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$Help = $false,
    [switch]$Force = $false,
    [switch]$Uninstall = $false
)

# Exit on any error
$ErrorActionPreference = "Stop"

###############################################################################
# Configuration
###############################################################################

$BmadVersion = "6.0.3"

# PowerShell version detection
$PSVersion = $PSVersionTable.PSVersion.Major
$IsPowerShell5 = $PSVersion -lt 6

###############################################################################
# Helper Functions
###############################################################################

function global:Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function global:Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function global:Write-ErrorMsg {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function global:Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "===============================================" -ForegroundColor Blue
    Write-Host ""
}

function global:Join-PathCompat {
    <#
    .SYNOPSIS
    Join-Path that works in both PowerShell 5.1 and PowerShell 6+

    .DESCRIPTION
    PowerShell 5.1 only accepts 2 arguments to Join-Path
    PowerShell 6+ accepts multiple path segments
    This function provides compatibility for both
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$ChildPath
    )

    # Validate inputs
    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "Path parameter cannot be null or empty"
    }

    if ($IsPowerShell5) {
        # PowerShell 5.1: Chain Join-Path calls
        $result = $Path
        foreach ($segment in $ChildPath) {
            if (-not [string]::IsNullOrWhiteSpace($segment)) {
                $result = Join-Path $result $segment
            }
        }
        return $result
    } else {
        # PowerShell 6+: Use native multiple-argument support
        # Filter out null/empty segments
        $validSegments = $ChildPath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        return Join-Path $Path $validSegments
    }
}

function global:Copy-ItemSafe {
    <#
    .SYNOPSIS
    Safely copy items ensuring destination directory exists

    .DESCRIPTION
    Wraps Copy-Item with proper error handling and destination directory creation
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,

        [Parameter(Mandatory=$true)]
        [string]$DestinationPath,

        [switch]$Recurse,
        [switch]$Force,
        [string]$ErrorContext = "file operation"
    )

    try {
        # Ensure destination parent directory exists
        $destParent = Split-Path $DestinationPath -Parent
        if ($destParent -and -not (Test-Path $destParent)) {
            Write-Verbose "Creating destination directory: $destParent"
            New-Item -ItemType Directory -Force -Path $destParent -ErrorAction Stop | Out-Null
        }

        # Ensure destination directory exists if copying with wildcard
        if ($SourcePath -match '\*' -and -not (Test-Path $DestinationPath)) {
            Write-Verbose "Creating destination directory: $DestinationPath"
            New-Item -ItemType Directory -Force -Path $DestinationPath -ErrorAction Stop | Out-Null
        }

        # Perform copy
        $copyParams = @{
            Path = $SourcePath
            Destination = $DestinationPath
            Force = $Force
            ErrorAction = 'Stop'
        }

        if ($Recurse) {
            $copyParams['Recurse'] = $true
        }

        Copy-Item @copyParams
        Write-Verbose "Copied: $SourcePath -> $DestinationPath"
    }
    catch {
        Write-ErrorMsg "Failed during $ErrorContext"
        Write-ErrorMsg "  Source: $SourcePath"
        Write-ErrorMsg "  Destination: $DestinationPath"
        Write-ErrorMsg "  Reason: $($_.Exception.Message)"
        throw
    }
}

###############################################################################
# Directory Configuration
###############################################################################

# Cross-platform home directory detection
if ($IsWindows -or $env:OS -match "Windows" -or (-not (Test-Path variable:IsWindows))) {
    # Windows (PowerShell 5.1 or PowerShell 7+ on Windows)
    $HomeDir = $env:USERPROFILE
} else {
    # Linux/macOS (PowerShell Core)
    $HomeDir = $env:HOME
}

$ClaudeDir = Join-Path $HomeDir ".claude"
$BmadConfigDir = Join-PathCompat $ClaudeDir "config" "bmad"
$BmadSkillsDir = Join-PathCompat $ClaudeDir "skills" "bmad"
$BmadCommandsDir = Join-PathCompat $ClaudeDir "commands" "bmad"
$ScriptDir = $PSScriptRoot

# Source directories
$SourceBmadV6Dir = Join-Path $ScriptDir "bmad-v6"
$SourceSkillsDir = Join-PathCompat $SourceBmadV6Dir "skills"
$SourceConfigDir = Join-PathCompat $SourceBmadV6Dir "config"
$SourceTemplatesDir = Join-PathCompat $SourceBmadV6Dir "templates"
$SourceUtilsDir = Join-PathCompat $SourceBmadV6Dir "utils"
$SourceCommandsDir = Join-PathCompat $SourceBmadV6Dir "commands"

###############################################################################
# Pre-Flight Validation
###############################################################################

function global:Test-Prerequisites {
    Write-Info "Running pre-flight checks..."
    $errors = @()

    # Check PowerShell version
    if ($PSVersion -eq 5 -and $PSVersionTable.PSVersion.Minor -eq 0) {
        Write-Warning "PowerShell 5.0 detected. PowerShell 5.1 or newer recommended."
        Write-Host "  Download: https://aka.ms/wmf5download" -ForegroundColor Yellow
    }

    Write-Verbose "PowerShell version: $($PSVersionTable.PSVersion)"
    if ($IsPowerShell5) {
        Write-Verbose "Running in compatibility mode (PowerShell 5.1)"
    } else {
        Write-Verbose "Running in native mode (PowerShell $PSVersion)"
    }

    # Check if script directory is valid
    if ([string]::IsNullOrWhiteSpace($ScriptDir)) {
        $errors += "Cannot determine script directory (PSScriptRoot is empty)"
    } elseif (-not (Test-Path $ScriptDir)) {
        $errors += "Script directory not found: $ScriptDir"
    }

    # Check if bmad-v6 source directory exists
    if (-not (Test-Path $SourceBmadV6Dir)) {
        $errors += "Source directory not found: $SourceBmadV6Dir"
        $errors += "Make sure you're running this script from the repository root"
    } else {
        Write-Success "Found source directory: $SourceBmadV6Dir"
    }

    # Check required source subdirectories
    $requiredDirs = @{
        "skills" = $SourceSkillsDir
        "config" = $SourceConfigDir
        "templates" = $SourceTemplatesDir
        "utils" = $SourceUtilsDir
        "commands" = $SourceCommandsDir
    }

    foreach ($dirName in $requiredDirs.Keys) {
        $dirPath = $requiredDirs[$dirName]
        if (-not (Test-Path $dirPath)) {
            $errors += "Required source directory not found: $dirPath"
        } else {
            Write-Verbose "Found $dirName directory: $dirPath"
        }
    }

    # Check write permissions to home directory
    try {
        $testFile = Join-Path $HomeDir ".bmad-install-test-$(Get-Date -Format 'yyyyMMddHHmmss')"
        Set-Content -Path $testFile -Value "test" -ErrorAction Stop
        Remove-Item $testFile -ErrorAction SilentlyContinue
        Write-Success "Write permissions verified for: $HomeDir"
    }
    catch {
        $errors += "No write permission to home directory: $HomeDir"
        $errors += "  Reason: $($_.Exception.Message)"
    }

    # Check if already installed
    $bmadMasterPath = Join-PathCompat $BmadSkillsDir "core" "bmad-master" "SKILL.md"
    if ((Test-Path $bmadMasterPath) -and -not $Force) {
        Write-Warning "BMAD Method v6 is already installed at: $BmadSkillsDir"
        Write-Host ""
        Write-Host "Options:" -ForegroundColor Yellow
        Write-Host "  1. Run with -Force to reinstall"
        Write-Host "  2. Run with -Uninstall to remove first"
        Write-Host "  3. Cancel installation (Ctrl+C)"
        Write-Host ""

        if (-not $WhatIfPreference) {
            $response = Read-Host "Reinstall over existing installation? (y/N)"
            if ($response -ne 'y' -and $response -ne 'Y') {
                Write-Info "Installation cancelled by user"
                exit 0
            }
        }
    }

    # Report errors
    if ($errors.Count -gt 0) {
        Write-ErrorMsg "Pre-flight checks failed with $($errors.Count) error(s):"
        foreach ($error in $errors) {
            Write-Host "  - $error" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "Installation cannot proceed. Please fix the errors above." -ForegroundColor Yellow
        return $false
    }

    Write-Success "All pre-flight checks passed"
    return $true
}

###############################################################################
# Uninstall Function
###############################################################################

function global:Uninstall-BmadV6 {
    Write-Header "BMAD Method v$BmadVersion Uninstaller"

    Write-Info "Checking for BMAD Method v6 installation..."

    $dirsToRemove = @(
        $BmadSkillsDir,
        $BmadCommandsDir,
        $BmadConfigDir
    )

    $found = $false
    foreach ($dir in $dirsToRemove) {
        if (Test-Path $dir) {
            $found = $true
            Write-Info "Found: $dir"
        }
    }

    if (-not $found) {
        Write-Warning "BMAD Method v6 is not installed"
        Write-Host "Nothing to uninstall."
        exit 0
    }

    Write-Host ""
    Write-Warning "This will remove BMAD Method v6 from your system:"
    foreach ($dir in $dirsToRemove) {
        if (Test-Path $dir) {
            Write-Host "  - $dir" -ForegroundColor Yellow
        }
    }
    Write-Host ""

    if (-not $WhatIfPreference) {
        $response = Read-Host "Continue with uninstall? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Uninstall cancelled"
            exit 0
        }
    }

    Write-Info "Uninstalling BMAD Method v6..."

    try {
        foreach ($dir in $dirsToRemove) {
            if (Test-Path $dir) {
                if ($PSCmdlet.ShouldProcess($dir, "Remove directory")) {
                    Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
                    Write-Success "Removed: $dir"
                }
            }
        }

        Write-Host ""
        Write-Success "BMAD Method v6 has been uninstalled successfully!"
        Write-Host ""
        exit 0
    }
    catch {
        Write-ErrorMsg "Uninstall failed: $($_.Exception.Message)"
        exit 1
    }
}

###############################################################################
# Installation Functions
###############################################################################

function global:New-Directories {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Creating directory structure..." -PercentComplete 0
    Write-Info "Creating directory structure..."

    try {
        # Claude Code directories - Skills
        @("core", "bmm", "bmb", "cis") | ForEach-Object {
            $skillDir = Join-Path $BmadSkillsDir $_
            if ($PSCmdlet.ShouldProcess($skillDir, "Create directory")) {
                Write-Verbose "Creating skill directory: $skillDir"
                New-Item -ItemType Directory -Force -Path $skillDir -ErrorAction Stop | Out-Null
            }
        }

        # Claude Code directories - Config
        @("agents", "templates") | ForEach-Object {
            $configDir = Join-Path $BmadConfigDir $_
            if ($PSCmdlet.ShouldProcess($configDir, "Create directory")) {
                Write-Verbose "Creating config directory: $configDir"
                New-Item -ItemType Directory -Force -Path $configDir -ErrorAction Stop | Out-Null
            }
        }

        Write-Success "Directory structure created"
        Write-Verbose "  Skills: $BmadSkillsDir"
        Write-Verbose "  Config: $BmadConfigDir"
    }
    catch {
        Write-ErrorMsg "Failed to create directory structure"
        Write-ErrorMsg "  Reason: $($_.Exception.Message)"
        throw
    }
}

function global:Install-Skills {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Installing BMAD skills..." -PercentComplete 20
    Write-Info "Installing BMAD skills..."

    $skillComponents = @(
        @{
            Name = "Core Skills"
            SourcePath = Join-PathCompat $SourceSkillsDir "core"
            DestPath = Join-Path $BmadSkillsDir "core"
            Required = $true
        },
        @{
            Name = "BMM Skills"
            SourcePath = Join-PathCompat $SourceSkillsDir "bmm"
            DestPath = Join-Path $BmadSkillsDir "bmm"
            Required = $true
        },
        @{
            Name = "BMB Skills"
            SourcePath = Join-PathCompat $SourceSkillsDir "bmb"
            DestPath = Join-Path $BmadSkillsDir "bmb"
            Required = $false
        },
        @{
            Name = "CIS Skills"
            SourcePath = Join-PathCompat $SourceSkillsDir "cis"
            DestPath = Join-Path $BmadSkillsDir "cis"
            Required = $false
        }
    )

    foreach ($component in $skillComponents) {
        $sourcePath = $component.SourcePath
        $destPath = $component.DestPath
        $componentName = $component.Name
        $required = $component.Required

        Write-Verbose "Installing $componentName from: $sourcePath"

        if (Test-Path $sourcePath) {
            try {
                $sourcePattern = Join-Path $sourcePath "*"
                if ($PSCmdlet.ShouldProcess($destPath, "Copy $componentName")) {
                    Copy-ItemSafe -SourcePath $sourcePattern -DestinationPath $destPath -Recurse -Force -ErrorContext "$componentName installation"
                    Write-Success "$componentName installed"
                    Write-Verbose "  Copied to: $destPath"
                }
            }
            catch {
                if ($required) {
                    throw
                } else {
                    Write-Warning "Optional $componentName could not be installed"
                    Write-Verbose "  Error: $($_.Exception.Message)"
                }
            }
        } else {
            if ($required) {
                Write-ErrorMsg "$componentName not found at: $sourcePath"
                Write-ErrorMsg "Installation cannot continue"
                throw "Required component missing: $componentName"
            } else {
                Write-Verbose "$componentName not found (optional): $sourcePath"
            }
        }
    }
}

function global:Install-Config {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Installing configuration..." -PercentComplete 40
    Write-Info "Installing configuration..."

    try {
        # Install config template
        $ConfigTemplatePath = Join-PathCompat $SourceConfigDir "config.template.yaml"
        $ConfigPath = Join-Path $BmadConfigDir "config.yaml"

        Write-Verbose "Config template: $ConfigTemplatePath"
        Write-Verbose "Config destination: $ConfigPath"

        if (Test-Path $ConfigTemplatePath) {
            if (-not (Test-Path $ConfigPath) -or $Force) {
                if ($PSCmdlet.ShouldProcess($ConfigPath, "Create configuration")) {
                    # Create config from template, substituting variables
                    Write-Verbose "Creating config from template"
                    $configContent = Get-Content $ConfigTemplatePath -Raw -ErrorAction Stop

                    # Get username (cross-platform)
                    $userName = if ($env:USERNAME) { $env:USERNAME } else { $env:USER }
                    $configContent = $configContent -replace '{{USER_NAME}}', $userName

                    Set-Content -Path $ConfigPath -Value $configContent -Encoding UTF8 -ErrorAction Stop
                    Write-Success "Configuration created"
                    Write-Verbose "  User: $userName"
                }
            } else {
                Write-Info "Configuration already exists, preserving"
                Write-Verbose "  Existing config: $ConfigPath"
            }
        } else {
            Write-Warning "Config template not found at: $ConfigTemplatePath"
        }

        # Copy project config template
        $ProjectConfigTemplatePath = Join-PathCompat $SourceConfigDir "project-config.template.yaml"
        $ProjectConfigDestPath = Join-Path $BmadConfigDir "project-config.template.yaml"

        Write-Verbose "Project config template: $ProjectConfigTemplatePath"

        if (Test-Path $ProjectConfigTemplatePath) {
            if ($PSCmdlet.ShouldProcess($ProjectConfigDestPath, "Copy project config template")) {
                Copy-ItemSafe -SourcePath $ProjectConfigTemplatePath -DestinationPath $ProjectConfigDestPath -Force -ErrorContext "project config template"
                Write-Verbose "  Project config template installed"
            }
        } else {
            Write-Verbose "Project config template not found (skipping)"
        }
    }
    catch {
        Write-ErrorMsg "Failed to install configuration"
        throw
    }
}

function global:Install-Templates {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Installing templates..." -PercentComplete 60
    Write-Info "Installing templates..."

    try {
        $TemplatesDestPath = Join-Path $BmadConfigDir "templates"

        Write-Verbose "Templates source: $SourceTemplatesDir"
        Write-Verbose "Templates destination: $TemplatesDestPath"

        if (Test-Path $SourceTemplatesDir) {
            $templatePattern = Join-Path $SourceTemplatesDir "*"
            if ($PSCmdlet.ShouldProcess($TemplatesDestPath, "Copy templates")) {
                Copy-ItemSafe -SourcePath $templatePattern -DestinationPath $TemplatesDestPath -Force -ErrorContext "templates"
                Write-Success "Templates installed"
                Write-Verbose "  Copied to: $TemplatesDestPath"
            }
        } else {
            Write-Warning "Templates not found at: $SourceTemplatesDir"
        }
    }
    catch {
        Write-ErrorMsg "Failed to install templates"
        throw
    }
}

function global:Install-Utils {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Installing utility helpers..." -PercentComplete 70
    Write-Info "Installing utility helpers..."

    try {
        $HelpersPath = Join-PathCompat $SourceUtilsDir "helpers.md"
        $HelpersDestPath = Join-Path $BmadConfigDir "helpers.md"

        Write-Verbose "Helpers source: $HelpersPath"
        Write-Verbose "Helpers destination: $HelpersDestPath"

        if (Test-Path $HelpersPath) {
            if ($PSCmdlet.ShouldProcess($HelpersDestPath, "Copy helpers")) {
                Copy-ItemSafe -SourcePath $HelpersPath -DestinationPath $HelpersDestPath -Force -ErrorContext "utility helpers"
                Write-Success "Utility helpers installed"
                Write-Verbose "  Copied to: $HelpersDestPath"
            }
        } else {
            Write-Warning "Helpers not found at: $HelpersPath"
        }
    }
    catch {
        Write-ErrorMsg "Failed to install utility helpers"
        throw
    }
}

function global:Install-Commands {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Installing slash commands..." -PercentComplete 80
    Write-Info "Installing slash commands..."

    try {
        Write-Verbose "Commands source: $SourceCommandsDir"
        Write-Verbose "Commands destination: $BmadCommandsDir"

        if (Test-Path $SourceCommandsDir) {
            # Count commands for user feedback
            $commandFiles = Get-ChildItem -Path $SourceCommandsDir -Filter "*.md" -ErrorAction SilentlyContinue
            $commandCount = $commandFiles.Count

            if ($commandCount -gt 0) {
                $commandPattern = Join-Path $SourceCommandsDir "*"
                if ($PSCmdlet.ShouldProcess($BmadCommandsDir, "Copy $commandCount slash commands")) {
                    Copy-ItemSafe -SourcePath $commandPattern -DestinationPath $BmadCommandsDir -Force -ErrorContext "slash commands"
                    Write-Success "Slash commands installed ($commandCount commands)"
                    Write-Verbose "  Commands:"
                    foreach ($cmd in $commandFiles) {
                        $cmdName = $cmd.BaseName
                        Write-Verbose "    /$cmdName"
                    }
                }
            } else {
                Write-Warning "No command files found in: $SourceCommandsDir"
            }
        } else {
            Write-Warning "Commands directory not found at: $SourceCommandsDir"
        }
    }
    catch {
        Write-ErrorMsg "Failed to install slash commands"
        throw
    }
}

function global:Test-Installation {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Verifying installation..." -PercentComplete 90
    Write-Info "Verifying installation..."

    $errors = 0
    $checks = @(
        @{
            Name = "BMad Master skill"
            Path = Join-PathCompat $BmadSkillsDir "core" "bmad-master" "SKILL.md"
        },
        @{
            Name = "Configuration"
            Path = Join-Path $BmadConfigDir "config.yaml"
        },
        @{
            Name = "Helpers"
            Path = Join-Path $BmadConfigDir "helpers.md"
        },
        @{
            Name = "Slash commands"
            Path = Join-Path $BmadCommandsDir "workflow-init.md"
        }
    )

    foreach ($check in $checks) {
        $path = $check.Path
        $name = $check.Name

        Write-Verbose "Checking: $name at $path"

        if (Test-Path $path) {
            # Verify file is not empty
            $fileInfo = Get-Item $path
            if ($fileInfo.Length -gt 0) {
                Write-Success "$name verified"
            } else {
                Write-ErrorMsg "$name exists but is empty: $path"
                $errors++
            }
        } else {
            Write-ErrorMsg "$name missing: $path"
            $errors++
        }
    }

    if ($errors -eq 0) {
        Write-Success "Installation verified successfully"
        return $true
    } else {
        Write-ErrorMsg "Installation verification failed: $errors error(s)"
        return $false
    }
}

function global:Show-NextSteps {
    Write-Header "Installation Complete!"

    Write-Host "[SUCCESS] BMAD Method v$BmadVersion installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installation location:"
    Write-Host "  Skills:   $BmadSkillsDir"
    Write-Host "  Commands: $BmadCommandsDir"
    Write-Host "  Config:   $BmadConfigDir"
    Write-Host ""
    Write-Host "[OK] 9 Specialized Skills"
    Write-Host "     - Core orchestrator (BMad Master)"
    Write-Host "     - Agile agents (Analyst, PM, Architect, SM, Developer, UX)"
    Write-Host "     - Builder module (custom agents and workflows)"
    Write-Host "     - Creative Intelligence (brainstorming and research)"
    Write-Host ""
    Write-Host "[OK] 15 Workflow Commands"
    Write-Host "     - /workflow-init, /workflow-status"
    Write-Host "     - /product-brief, /prd, /tech-spec"
    Write-Host "     - /architecture, /solutioning-gate-check"
    Write-Host "     - /sprint-planning, /create-story, /dev-story"
    Write-Host "     - /brainstorm, /research"
    Write-Host "     - /create-agent, /create-workflow, /create-ux-design"
    Write-Host ""
    Write-Host "[OK] Configuration system"
    Write-Host "[OK] Template engine"
    Write-Host "[OK] Status tracking utilities"
    Write-Host ""
    Write-Host "Next Steps:"
    Write-Host ""
    Write-Host "1. " -NoNewline
    Write-Host "Restart Claude Code" -ForegroundColor Blue
    Write-Host "   Skills will be loaded in new sessions"
    Write-Host ""
    Write-Host "2. " -NoNewline
    Write-Host "Open your project" -ForegroundColor Blue
    Write-Host "   Navigate to the project you want to use BMAD with"
    Write-Host ""
    Write-Host "3. " -NoNewline
    Write-Host "Initialize BMAD" -ForegroundColor Blue
    Write-Host "   Run: /workflow-init"
    Write-Host "   This sets up BMAD structure in your project"
    Write-Host ""
    Write-Host "4. " -NoNewline
    Write-Host "Check status" -ForegroundColor Blue
    Write-Host "   Run: /workflow-status"
    Write-Host "   See your project status and get recommendations"
    Write-Host ""
    Write-Host "Verification Commands:"

    if ($IsWindows -or $env:OS -match "Windows" -or (-not (Test-Path variable:IsWindows))) {
        Write-Host "  dir `"$BmadSkillsDir\core\bmad-master\SKILL.md`""
    } else {
        Write-Host "  ls -la ~/.claude/skills/bmad/core/bmad-master/SKILL.md"
    }

    Write-Host ""
    Write-Host "Documentation:"
    Write-Host "  README: $ScriptDir\README.md"
    Write-Host ""
    Write-Host "[OK] BMAD Method v6 is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Need help? Visit: https://github.com/aj-geddes/claude-code-bmad-skills/issues"
}

function global:Show-WhatIfSummary {
    Write-Header "Installation Summary (Dry-Run)"

    Write-Host "Would install BMAD Method v$BmadVersion to:"
    Write-Host "  Skills:   $BmadSkillsDir"
    Write-Host "  Commands: $BmadCommandsDir"
    Write-Host "  Config:   $BmadConfigDir"
    Write-Host ""
    Write-Host "Components:"
    Write-Host "  [*] 9 specialized skills (Core, BMM, BMB, CIS)"
    Write-Host "  [*] 15 workflow slash commands"
    Write-Host "  [*] Configuration templates"
    Write-Host "  [*] Utility helpers"
    Write-Host "  [*] Status tracking system"
    Write-Host ""
    Write-Host "To perform actual installation, run without -WhatIf"
}

###############################################################################
# Main Installation
###############################################################################

function global:Main {
    # Show help
    if ($Help) {
        Get-Help $PSCommandPath -Detailed
        exit 0
    }

    # Handle uninstall
    if ($Uninstall) {
        Uninstall-BmadV6
        return
    }

    Write-Header "BMAD Method v$BmadVersion Installer"

    # Show version info
    if ($IsPowerShell5) {
        Write-Host "Detected: PowerShell $PSVersion (compatibility mode)" -ForegroundColor Yellow
    } else {
        Write-Host "Detected: PowerShell $PSVersion" -ForegroundColor Green
    }
    Write-Host ""

    # Pre-flight checks
    if (-not (Test-Prerequisites)) {
        exit 1
    }

    # WhatIf summary
    if ($WhatIfPreference) {
        Write-Host ""
        Show-WhatIfSummary
        exit 0
    }

    Write-Verbose "Installation started at: $(Get-Date)"
    Write-Verbose "Script directory: $ScriptDir"
    Write-Verbose "Target directory: $ClaudeDir"

    try {
        # Perform installation
        Write-Host ""
        Write-Info "Starting installation..."

        New-Directories
        Install-Skills
        Install-Config
        Install-Templates
        Install-Utils
        Install-Commands

        # Verify
        Write-Host ""
        if (Test-Installation) {
            Write-Progress -Activity "Installing BMAD Method v6" -Status "Complete!" -PercentComplete 100
            Write-Host ""
            Show-NextSteps
            Write-Progress -Activity "Installing BMAD Method v6" -Completed
            Write-Verbose "Installation completed successfully at: $(Get-Date)"
            exit 0
        } else {
            Write-ErrorMsg "Installation verification failed"
            Write-Host ""
            Write-Host "Troubleshooting:" -ForegroundColor Yellow
            Write-Host "  1. Run with -Verbose flag for detailed diagnostics"
            Write-Host "  2. Check file permissions on: $ClaudeDir"
            Write-Host "  3. Verify source files exist in: $SourceBmadV6Dir"
            Write-Host "  4. Try running with -Force to reinstall"
            Write-Host ""
            exit 1
        }
    }
    catch {
        Write-Progress -Activity "Installing BMAD Method v6" -Completed
        Write-Host ""
        Write-Host "===============================================" -ForegroundColor Red
        Write-Host "  Installation Failed" -ForegroundColor Red
        Write-Host "===============================================" -ForegroundColor Red
        Write-Host ""
        Write-ErrorMsg $_.Exception.Message
        Write-Host ""
        Write-Host "Troubleshooting:" -ForegroundColor Yellow
        Write-Host "  1. Run with -Verbose flag for detailed diagnostics:"
        Write-Host "     .\install-v6.ps1 -Verbose"
        Write-Host ""
        Write-Host "  2. Check if bmad-v6/ directory exists:"
        Write-Host "     dir bmad-v6\"
        Write-Host ""
        Write-Host "  3. Verify write permissions:"
        Write-Host "     Test writing to $ClaudeDir"
        Write-Host ""
        Write-Host "  4. Report issues:"
        Write-Host "     https://github.com/aj-geddes/claude-code-bmad-skills/issues"
        Write-Host ""
        Write-Verbose "Exception: $($_.Exception.Message)"
        Write-Verbose "Stack trace: $($_.ScriptStackTrace)"
        exit 1
    }
}

# Run installation
Main
