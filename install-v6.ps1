###############################################################################
# BMAD Method v6 for Claude Code - PowerShell Installation Script
#
# Installs BMAD Method v6 using only Claude Code native features
# No npx, no external dependencies, pure Claude Code
#
# Supports: PowerShell 5.1+ (Windows default) and PowerShell 6+ (Core)
#
# Usage: .\install-v6.ps1
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

.EXAMPLE
    .\install-v6.ps1

    Installs BMAD Method v6 with standard output.

.EXAMPLE
    .\install-v6.ps1 -Verbose

    Installs BMAD Method v6 with detailed diagnostic output.

.NOTES
    Version: 6.0.0
    Requires: PowerShell 5.1+
#>

[CmdletBinding()]
param(
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "BMAD Method v6 for Claude Code - Installer"
    Write-Host ""
    Write-Host "Usage: .\install-v6.ps1"
    Write-Host ""
    Write-Host "Installs BMAD Method v6 to ~/.claude/ directory"
    exit 0
}

$ErrorActionPreference = "Stop"

# Configuration
$BmadVersion = "6.0.0"

# PowerShell version detection
$PSVersion = $PSVersionTable.PSVersion.Major
$IsPowerShell5 = $PSVersion -lt 6

if ($IsPowerShell5) {
    Write-Host "Detected: PowerShell $PSVersion (using compatibility mode)" -ForegroundColor Yellow
} else {
    Write-Host "Detected: PowerShell $PSVersion" -ForegroundColor Green
}

###############################################################################
# PowerShell 5.1 Compatibility Helper
###############################################################################

function Join-PathCompat {
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

    if ($IsPowerShell5) {
        # PowerShell 5.1: Chain Join-Path calls
        $result = $Path
        foreach ($segment in $ChildPath) {
            $result = Join-Path $result $segment
        }
        return $result
    } else {
        # PowerShell 6+: Use native multiple-argument support
        return Join-Path $Path $ChildPath
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
$ScriptDir = $PSScriptRoot

###############################################################################
# Helper Functions
###############################################################################

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "===============================================" -ForegroundColor Blue
    Write-Host ""
}

###############################################################################
# Installation Functions
###############################################################################

function New-Directories {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Creating directory structure..." -PercentComplete 0
    Write-Info "Creating directory structure..."
    Write-Verbose "Skills directory: $BmadSkillsDir"
    Write-Verbose "Config directory: $BmadConfigDir"

    try {
        # Claude Code directories - Skills
        @("core", "bmm", "bmb", "cis") | ForEach-Object {
            $skillDir = Join-Path $BmadSkillsDir $_
            Write-Verbose "Creating skill directory: $skillDir"
            New-Item -ItemType Directory -Force -Path $skillDir -ErrorAction Stop | Out-Null
        }

        # Claude Code directories - Config
        @("agents", "templates") | ForEach-Object {
            $configDir = Join-Path $BmadConfigDir $_
            Write-Verbose "Creating config directory: $configDir"
            New-Item -ItemType Directory -Force -Path $configDir -ErrorAction Stop | Out-Null
        }

        Write-Success "Directories created"
    }
    catch {
        Write-Error "Failed to create directories: $_" -ErrorAction Stop
    }
}

function Install-Skills {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Installing BMAD skills..." -PercentComplete 20
    Write-Info "Installing BMAD skills..."

    try {
        # Install core skills
        $CoreSkillsPath = Join-PathCompat $ScriptDir "bmad-v6" "skills" "core"
        $CoreDestPath = Join-Path $BmadSkillsDir "core"
        Write-Verbose "Installing core skills from: $CoreSkillsPath"
        if (Test-Path $CoreSkillsPath) {
            Copy-Item -Path (Join-Path $CoreSkillsPath "*") -Destination $CoreDestPath -Recurse -Force -ErrorAction Stop
            Write-Success "Core skills installed"
            Write-Verbose "Core skills copied to: $CoreDestPath"
        } else {
            Write-Warning "Core skills not found at $CoreSkillsPath"
        }

        # Install BMM skills
        $BmmSkillsPath = Join-PathCompat $ScriptDir "bmad-v6" "skills" "bmm"
        $BmmDestPath = Join-Path $BmadSkillsDir "bmm"
        Write-Verbose "Installing BMM skills from: $BmmSkillsPath"
        if (Test-Path $BmmSkillsPath) {
            Copy-Item -Path (Join-Path $BmmSkillsPath "*") -Destination $BmmDestPath -Recurse -Force -ErrorAction Stop
            Write-Success "BMM skills installed"
            Write-Verbose "BMM skills copied to: $BmmDestPath"
        } else {
            Write-Warning "BMM skills not found at $BmmSkillsPath"
        }

        # Install BMB skills (optional)
        $BmbSkillsPath = Join-PathCompat $ScriptDir "bmad-v6" "skills" "bmb"
        $BmbDestPath = Join-Path $BmadSkillsDir "bmb"
        Write-Verbose "Installing BMB skills from: $BmbSkillsPath (optional)"
        if (Test-Path $BmbSkillsPath) {
            Copy-Item -Path (Join-Path $BmbSkillsPath "*") -Destination $BmbDestPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Verbose "BMB skills copied to: $BmbDestPath"
        }

        # Install CIS skills (optional)
        $CisSkillsPath = Join-PathCompat $ScriptDir "bmad-v6" "skills" "cis"
        $CisDestPath = Join-Path $BmadSkillsDir "cis"
        Write-Verbose "Installing CIS skills from: $CisSkillsPath (optional)"
        if (Test-Path $CisSkillsPath) {
            Copy-Item -Path (Join-Path $CisSkillsPath "*") -Destination $CisDestPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Verbose "CIS skills copied to: $CisDestPath"
        }
    }
    catch {
        Write-Error "Failed to install skills: $_" -ErrorAction Stop
    }
}

function Install-Config {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Installing configuration..." -PercentComplete 40
    Write-Info "Installing configuration..."

    try {
        # Install config template
        $ConfigTemplatePath = Join-PathCompat $ScriptDir "bmad-v6" "config" "config.template.yaml"
        $ConfigPath = Join-Path $BmadConfigDir "config.yaml"
        Write-Verbose "Config template path: $ConfigTemplatePath"
        Write-Verbose "Config destination: $ConfigPath"

        if (Test-Path $ConfigTemplatePath) {
            if (-not (Test-Path $ConfigPath)) {
                # Create config from template, substituting variables
                Write-Verbose "Creating config from template"
                $configContent = Get-Content $ConfigTemplatePath -Raw -ErrorAction Stop
                $configContent = $configContent -replace '{{USER_NAME}}', $env:USERNAME
                Set-Content -Path $ConfigPath -Value $configContent -Encoding UTF8 -ErrorAction Stop
                Write-Success "Configuration created"
                Write-Verbose "Config file created with user: $env:USERNAME"
            } else {
                Write-Info "Configuration already exists, skipping"
                Write-Verbose "Existing config preserved at: $ConfigPath"
            }
        } else {
            Write-Warning "Config template not found at $ConfigTemplatePath"
        }

        # Copy project config template
        $ProjectConfigTemplatePath = Join-PathCompat $ScriptDir "bmad-v6" "config" "project-config.template.yaml"
        $ProjectConfigDestPath = Join-Path $BmadConfigDir "project-config.template.yaml"
        Write-Verbose "Installing project config template from: $ProjectConfigTemplatePath"
        if (Test-Path $ProjectConfigTemplatePath) {
            Copy-Item -Path $ProjectConfigTemplatePath -Destination $ProjectConfigDestPath -Force -ErrorAction Stop
            Write-Verbose "Project config template copied to: $ProjectConfigDestPath"
        }
    }
    catch {
        Write-Error "Failed to install configuration: $_" -ErrorAction Stop
    }
}

function Install-Templates {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Installing templates..." -PercentComplete 60
    Write-Info "Installing templates..."

    try {
        # Install all template files
        $TemplatesPath = Join-PathCompat $ScriptDir "bmad-v6" "templates"
        $TemplatesDestPath = Join-Path $BmadConfigDir "templates"
        Write-Verbose "Templates source: $TemplatesPath"
        Write-Verbose "Templates destination: $TemplatesDestPath"

        if (Test-Path $TemplatesPath) {
            Copy-Item -Path (Join-Path $TemplatesPath "*") -Destination $TemplatesDestPath -Force -ErrorAction Stop
            Write-Success "Templates installed"
            Write-Verbose "Templates copied to: $TemplatesDestPath"
        } else {
            Write-Warning "Templates not found at $TemplatesPath"
        }
    }
    catch {
        Write-Error "Failed to install templates: $_" -ErrorAction Stop
    }
}

function Install-Utils {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Installing utility helpers..." -PercentComplete 80
    Write-Info "Installing utility helpers..."

    try {
        # Copy helpers.md to config directory for reference
        $HelpersPath = Join-PathCompat $ScriptDir "bmad-v6" "utils" "helpers.md"
        $HelpersDestPath = Join-Path $BmadConfigDir "helpers.md"
        Write-Verbose "Helpers source: $HelpersPath"
        Write-Verbose "Helpers destination: $HelpersDestPath"

        if (Test-Path $HelpersPath) {
            Copy-Item -Path $HelpersPath -Destination $HelpersDestPath -Force -ErrorAction Stop
            Write-Success "Utility helpers installed"
            Write-Verbose "Helpers copied to: $HelpersDestPath"
        } else {
            Write-Warning "Helpers not found at $HelpersPath"
        }
    }
    catch {
        Write-Error "Failed to install utility helpers: $_" -ErrorAction Stop
    }
}

function Test-Installation {
    Write-Progress -Activity "Installing BMAD Method v6" -Status "Verifying installation..." -PercentComplete 90
    Write-Info "Verifying installation..."

    $errors = 0

    # Check for BMad Master skill
    $BmadMasterPath = Join-PathCompat $BmadSkillsDir "core" "bmad-master" "SKILL.md"
    Write-Verbose "Checking for BMad Master at: $BmadMasterPath"
    if (Test-Path $BmadMasterPath) {
        Write-Success "BMad Master skill verified"
    } else {
        Write-Host "  [X] BMad Master skill missing at: $BmadMasterPath" -ForegroundColor Red
        $errors++
    }

    # Check for config
    $ConfigPath = Join-Path $BmadConfigDir "config.yaml"
    Write-Verbose "Checking for config at: $ConfigPath"
    if (Test-Path $ConfigPath) {
        Write-Success "Configuration verified"
    } else {
        Write-Host "  [X] Configuration missing at: $ConfigPath" -ForegroundColor Red
        $errors++
    }

    # Check for helpers
    $HelpersPath = Join-Path $BmadConfigDir "helpers.md"
    Write-Verbose "Checking for helpers at: $HelpersPath"
    if (Test-Path $HelpersPath) {
        Write-Success "Helpers verified"
    } else {
        Write-Host "  [X] Helpers missing at: $HelpersPath" -ForegroundColor Red
        $errors++
    }

    if ($errors -eq 0) {
        Write-Success "Installation verified successfully"
        Write-Verbose "All components verified: $($errors) errors"
        return $true
    } else {
        Write-Host "[X] Installation verification failed: $errors error(s)" -ForegroundColor Red
        return $false
    }
}

function Show-NextSteps {
    Write-Header "Installation Complete!"

    Write-Host "[SUCCESS] BMAD Method v$BmadVersion installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installation location:"
    Write-Host "  Skills: $BmadSkillsDir"
    Write-Host "  Config: $BmadConfigDir"
    Write-Host "  Utils:  $BmadConfigDir\helpers.md"
    Write-Host ""
    Write-Host "[OK] BMad Master skill (core orchestrator)"
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
    Write-Host "Documentation:"
    Write-Host "   README: $ScriptDir\README.md"
    Write-Host "   Plan:   $ScriptDir\BMAD-V6-CLAUDE-CODE-TRANSITION-PLAN.md"
    Write-Host ""
    Write-Host "[OK] BMAD Method v6 is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Need help? Run /workflow-status in Claude Code after initializing your project."
}

###############################################################################
# Main Installation
###############################################################################

function Main {
    Write-Header "BMAD Method v$BmadVersion Installer"
    Write-Verbose "Installation started at: $(Get-Date)"
    Write-Verbose "PowerShell version: $PSVersion"
    Write-Verbose "Script directory: $ScriptDir"
    Write-Verbose "Claude directory: $ClaudeDir"

    try {
        # Check if Claude directory exists
        if (-not (Test-Path $ClaudeDir)) {
            Write-Info "Creating Claude Code directory: $ClaudeDir"
            Write-Verbose "Creating root Claude directory"
            New-Item -ItemType Directory -Force -Path $ClaudeDir -ErrorAction Stop | Out-Null
        }

        # Perform installation
        Write-Verbose "Starting installation sequence"
        New-Directories
        Install-Skills
        Install-Config
        Install-Templates
        Install-Utils

        # Verify
        if (Test-Installation) {
            Write-Progress -Activity "Installing BMAD Method v6" -Status "Complete!" -PercentComplete 100
            Write-Verbose "Installation completed successfully at: $(Get-Date)"
            Show-NextSteps
            Write-Progress -Activity "Installing BMAD Method v6" -Completed
            exit 0
        } else {
            Write-Host "Installation verification failed" -ForegroundColor Red
            Write-Verbose "Installation failed at: $(Get-Date)"
            exit 1
        }
    }
    catch {
        Write-Progress -Activity "Installing BMAD Method v6" -Completed
        Write-Host "" -ForegroundColor Red
        Write-Host "===============================================" -ForegroundColor Red
        Write-Host "  Installation Failed" -ForegroundColor Red
        Write-Host "===============================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Error: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "For detailed diagnostics, run:" -ForegroundColor Yellow
        Write-Host "  .\install-v6.ps1 -Verbose" -ForegroundColor Cyan
        Write-Host ""
        Write-Verbose "Exception details: $($_.Exception.Message)"
        Write-Verbose "Stack trace: $($_.ScriptStackTrace)"
        exit 1
    }
}

# Run installation
Main
