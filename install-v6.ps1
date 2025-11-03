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
    Write-Host "ℹ $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Blue
    Write-Host "  $Message" -ForegroundColor Blue
    Write-Host "═══════════════════════════════════════════════" -ForegroundColor Blue
    Write-Host ""
}

###############################################################################
# Installation Functions
###############################################################################

function New-Directories {
    Write-Info "Creating directory structure..."

    # Claude Code directories
    @("core", "bmm", "bmb", "cis") | ForEach-Object {
        New-Item -ItemType Directory -Force -Path "$BmadSkillsDir/$_" | Out-Null
    }

    @("agents", "templates") | ForEach-Object {
        New-Item -ItemType Directory -Force -Path "$BmadConfigDir/$_" | Out-Null
    }

    Write-Success "Directories created"
}

function Install-Skills {
    Write-Info "Installing BMAD skills..."

    # Install core skills
    $CoreSkillsPath = Join-Path $ScriptDir "bmad-v6\skills\core"
    if (Test-Path $CoreSkillsPath) {
        Copy-Item -Recurse -Force "$CoreSkillsPath\*" "$BmadSkillsDir/core\"
        Write-Success "Core skills installed"
    }

    # Install BMM skills (will add more in later phases)
    $BmmSkillsPath = Join-Path $ScriptDir "bmad-v6\skills\bmm"
    if (Test-Path $BmmSkillsPath) {
        Copy-Item -Recurse -Force "$BmmSkillsPath\*" "$BmadSkillsDir/bmm\" -ErrorAction SilentlyContinue
        Write-Success "BMM skills installed"
    }

    # Install BMB skills (optional)
    $BmbSkillsPath = Join-Path $ScriptDir "bmad-v6\skills\bmb"
    if (Test-Path $BmbSkillsPath) {
        Copy-Item -Recurse -Force "$BmbSkillsPath\*" "$BmadSkillsDir/bmb\" -ErrorAction SilentlyContinue
    }

    # Install CIS skills (optional)
    $CisSkillsPath = Join-Path $ScriptDir "bmad-v6\skills\cis"
    if (Test-Path $CisSkillsPath) {
        Copy-Item -Recurse -Force "$CisSkillsPath\*" "$BmadSkillsDir/cis\" -ErrorAction SilentlyContinue
    }
}

function Install-Config {
    Write-Info "Installing configuration..."

    # Install config template
    $ConfigTemplatePath = Join-Path $ScriptDir "bmad-v6\config\config.template.yaml"
    $ConfigPath = Join-Path $BmadConfigDir "config.yaml"

    if (Test-Path $ConfigTemplatePath) {
        if (-not (Test-Path $ConfigPath)) {
            # Create config from template, substituting variables
            $configContent = Get-Content $ConfigTemplatePath -Raw
            $configContent = $configContent -replace '{{USER_NAME}}', $env:USERNAME
            Set-Content -Path $ConfigPath -Value $configContent -Encoding UTF8
            Write-Success "Configuration created"
        } else {
            Write-Info "Configuration already exists, skipping"
        }
    }

    # Copy project config template
    $ProjectConfigTemplatePath = Join-Path $ScriptDir "bmad-v6\config\project-config.template.yaml"
    if (Test-Path $ProjectConfigTemplatePath) {
        Copy-Item $ProjectConfigTemplatePath "$BmadConfigDir/project-config.template.yaml" -Force
    }
}

function Install-Templates {
    Write-Info "Installing templates..."

    # Install all template files
    $TemplatesPath = Join-Path $ScriptDir "bmad-v6\templates"
    if (Test-Path $TemplatesPath) {
        Copy-Item "$TemplatesPath\*" "$BmadConfigDir/templates\" -Force -ErrorAction SilentlyContinue
        Write-Success "Templates installed"
    }
}

function Install-Utils {
    Write-Info "Installing utility helpers..."

    # Copy helpers.md to config directory for reference
    $HelpersPath = Join-Path $ScriptDir "bmad-v6\utils\helpers.md"
    if (Test-Path $HelpersPath) {
        Copy-Item $HelpersPath "$BmadConfigDir/helpers.md" -Force
        Write-Success "Utility helpers installed"
    }
}

function Test-Installation {
    Write-Info "Verifying installation..."

    $errors = 0

    # Check for BMad Master skill
    if (Test-Path "$BmadSkillsDir/core\bmad-master\SKILL.md") {
        Write-Success "BMad Master skill verified"
    } else {
        Write-Host "✗ BMad Master skill missing" -ForegroundColor Red
        $errors++
    }

    # Check for config
    if (Test-Path "$BmadConfigDir/config.yaml") {
        Write-Success "Configuration verified"
    } else {
        Write-Host "✗ Configuration missing" -ForegroundColor Red
        $errors++
    }

    # Check for helpers
    if (Test-Path "$BmadConfigDir/helpers.md") {
        Write-Success "Helpers verified"
    } else {
        Write-Host "✗ Helpers missing" -ForegroundColor Red
        $errors++
    }

    if ($errors -eq 0) {
        Write-Success "Installation verified successfully"
        return $true
    } else {
        Write-Host "✗ Installation verification failed: $errors error(s)" -ForegroundColor Red
        return $false
    }
}

function Show-NextSteps {
    Write-Header "Installation Complete!"

    Write-Host "📦 BMAD Method v$BmadVersion installed successfully!"
    Write-Host ""
    Write-Host "Installation location:"
    Write-Host "  Skills: $BmadSkillsDir"
    Write-Host "  Config: $BmadConfigDir"
    Write-Host "  Utils:  $BmadConfigDir\helpers.md"
    Write-Host ""
    Write-Host "✓ BMad Master skill (core orchestrator)"
    Write-Host "✓ Configuration system"
    Write-Host "✓ Template engine"
    Write-Host "✓ Status tracking utilities"
    Write-Host ""
    Write-Host "📋 Next Steps:"
    Write-Host ""
    Write-Host "1️⃣  " -NoNewline
    Write-Host "Restart Claude Code" -ForegroundColor Blue
    Write-Host "   Skills will be loaded in new sessions"
    Write-Host ""
    Write-Host "2️⃣  " -NoNewline
    Write-Host "Open your project" -ForegroundColor Blue
    Write-Host "   Navigate to the project you want to use BMAD with"
    Write-Host ""
    Write-Host "3️⃣  " -NoNewline
    Write-Host "Initialize BMAD" -ForegroundColor Blue
    Write-Host "   Run: /workflow-init"
    Write-Host "   This sets up BMAD structure in your project"
    Write-Host ""
    Write-Host "4️⃣  " -NoNewline
    Write-Host "Check status" -ForegroundColor Blue
    Write-Host "   Run: /workflow-status"
    Write-Host "   See your project status and get recommendations"
    Write-Host ""
    Write-Host "📚 Documentation:"
    Write-Host "   README: $ScriptDir\README.md"
    Write-Host "   Plan:   $ScriptDir\BMAD-V6-CLAUDE-CODE-TRANSITION-PLAN.md"
    Write-Host ""
    Write-Host "✓ BMAD Method v6 is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Need help? Run /workflow-status in Claude Code after initializing your project."
}

###############################################################################
# Main Installation
###############################################################################

function Main {
    Write-Header "BMAD Method v$BmadVersion Installer"

    # Check if Claude directory exists
    if (-not (Test-Path $ClaudeDir)) {
        Write-Info "Creating Claude Code directory: $ClaudeDir"
        New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
    }

    # Perform installation
    New-Directories
    Install-Skills
    Install-Config
    Install-Templates
    Install-Utils

    # Verify
    if (Test-Installation) {
        Show-NextSteps
        exit 0
    } else {
        Write-Host "Installation failed" -ForegroundColor Red
        exit 1
    }
}

# Run installation
Main
