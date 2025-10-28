###############################################################################
# BMAD Skills for Claude Code - PowerShell Installer
#
# This script installs BMAD Method skills, commands, and hooks for Claude Code
# on Windows systems using PowerShell
#
# Usage:
#   .\install.ps1
#   .\install.ps1 -Force    # Overwrite existing files
###############################################################################

param(
    [switch]$Force = $false,
    [switch]$Help = $false
)

# Show help if requested
if ($Help) {
    Write-Host "BMAD Skills Installer for Claude Code (PowerShell)"
    Write-Host ""
    Write-Host "Usage: .\install.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Force    Overwrite existing files"
    Write-Host "  -Help     Show this help message"
    exit 0
}

# Configuration
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$SkillsDir = Join-Path $ClaudeDir "skills"
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

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Heading {
    param([string]$Message)
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

###############################################################################
# Installation Functions
###############################################################################

function New-Directories {
    Write-Info "Creating Claude Code directories..."

    $dirs = @(
        "bmad-method",
        "security",
        "python",
        "javascript",
        "devops",
        "testing",
        "git"
    )

    foreach ($dir in $dirs) {
        $path = Join-Path $SkillsDir $dir
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }

    Write-Success "Directories created"
}

function Install-Skills {
    Write-Info "Installing BMAD skills..."

    $skills = @(
        "bmad-method",
        "security",
        "python",
        "javascript",
        "devops",
        "testing",
        "git"
    )

    foreach ($skill in $skills) {
        $source = Join-Path $ScriptDir "skills\$skill\SKILL.md"
        $dest = Join-Path $SkillsDir "$skill\SKILL.md"

        if (Test-Path $source) {
            Copy-Item $source $dest -Force
        } else {
            Write-Error "Skill file not found: $source"
            return $false
        }
    }

    Write-Success "Skills installed to $SkillsDir"
    return $true
}

function Install-Templates {
    Write-Info "Installing BMAD templates..."

    $templatesDir = Join-Path $SkillsDir "bmad-method\templates"
    New-Item -ItemType Directory -Force -Path $templatesDir | Out-Null

    $readmeContent = @'
# BMAD Templates

Templates are automatically created when you run `/bmad-init` in a project.

## Available Templates

- **project-brief-template.md** - Analyst role template
- **prd-template.md** - PM role template (FRs, NFRs, Epics)
- **architecture-template.md** - Architect role template
- **story-template.md** - Scrum Master role template

## Usage

Use slash commands instead of manually copying templates:

- `/bmad-init` - Initialize complete BMAD structure with all templates
- `/bmad-prd` - Create PRD interactively (PM role)
- `/bmad-arch` - Create Architecture interactively (Architect role)
- `/bmad-story` - Create story file interactively (SM role)

Templates will be created in your project directory automatically.
'@

    $readmePath = Join-Path $templatesDir "README.md"
    Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8

    Write-Success "Template reference created"
}

function Test-ProjectCommands {
    Write-Info "Checking for project-level commands directory..."

    if (Test-Path ".claude\commands") {
        Write-Success "Found .claude\commands in current directory"
        return $true
    } else {
        Write-Warning "No .claude\commands found in current directory"
        Write-Info "Commands will be available after you run them once in Claude Code"
        return $false
    }
}

function New-CommandsReadme {
    Write-Info "Creating commands README..."

    $commandsRefDir = Join-Path $SkillsDir "bmad-method\commands-reference"
    New-Item -ItemType Directory -Force -Path $commandsRefDir | Out-Null

    $commandsContent = @'
# BMAD Slash Commands

These commands are available in Claude Code when working with BMAD projects.

## Installation

The first time you use a BMAD command in Claude Code, it will be automatically
created in your project's `.claude/commands/` directory.

Alternatively, copy the command files from this repository's `commands/` directory
to your project's `.claude/commands/` directory.

## Available Commands

### `/bmad-init`
Initialize BMAD structure in the current project.
- Creates bmad-agent/, docs/, stories/ directories
- Generates agent definition files
- Creates document templates
- Sets up configuration

### `/bmad-prd`
Create Product Requirements Document (PM role).
- Interactive PRD creation
- Defines FRs, NFRs, Epics
- Stores requirements in Memory
- Creates foundation for development

### `/bmad-arch`
Create System Architecture Document (Architect role).
- Reads PRD requirements
- Designs system components
- Defines tech stack with justification
- Creates data models and API specs
- Stores architecture decisions in Memory

### `/bmad-story`
Create detailed story file (Scrum Master role).
- Reads PRD and Architecture
- Creates hyper-detailed story with full context
- Embeds implementation guidance
- Stores story in Memory with relationships

### `/bmad-assess`
Assess BMAD project compliance and status.
- Checks structure and document quality
- Analyzes story completeness
- Verifies code alignment with architecture
- Provides actionable recommendations

## Usage in Claude Code

Simply type the command in chat:

```
/bmad-init
```

Claude Code will execute the command and guide you through the process.

## Command Files Location

In your project:
```
.claude/commands/
├── bmad-init.md
├── bmad-prd.md
├── bmad-arch.md
├── bmad-story.md
└── bmad-assess.md
```

In this repository:
```
commands/
├── bmad-init.md
├── bmad-prd.md
├── bmad-arch.md
├── bmad-story.md
└── bmad-assess.md
```
'@

    $commandsReadmePath = Join-Path $commandsRefDir "README.md"
    Set-Content -Path $commandsReadmePath -Value $commandsContent -Encoding UTF8

    Write-Success "Commands README created"
}

function Test-Installation {
    Write-Info "Verifying installation..."

    $errors = 0
    $skills = @("bmad-method", "security", "python", "javascript", "devops", "testing", "git")

    foreach ($skill in $skills) {
        $skillPath = Join-Path $SkillsDir "$skill\SKILL.md"
        if (Test-Path $skillPath) {
            Write-Success "Skill verified: $skill"
        } else {
            Write-Error "Skill missing: $skill"
            $errors++
        }
    }

    if ($errors -eq 0) {
        Write-Success "All skills verified successfully"
        return $true
    } else {
        Write-Error "Installation verification failed: $errors error(s)"
        return $false
    }
}

function Show-NextSteps {
    Write-Heading "Installation Complete!"

    Write-Host "📦 Installed to: $SkillsDir"
    Write-Host ""
    Write-Host "✓ BMAD Method Skill"
    Write-Host "✓ Security Skill"
    Write-Host "✓ Python Skill"
    Write-Host "✓ JavaScript/TypeScript Skill"
    Write-Host "✓ DevOps Skill"
    Write-Host "✓ Testing Skill"
    Write-Host "✓ Git Skill"
    Write-Host ""
    Write-Host "📋 Next Steps:"
    Write-Host ""
    Write-Host "1️⃣  " -NoNewline
    Write-Host "Start or restart Claude Code" -ForegroundColor Cyan
    Write-Host "   Skills will be automatically loaded in new sessions"
    Write-Host ""
    Write-Host "2️⃣  " -NoNewline
    Write-Host "Open a project in Claude Code" -ForegroundColor Cyan
    Write-Host "   BMAD will automatically detect if project uses BMAD Method"
    Write-Host ""
    Write-Host "3️⃣  " -NoNewline
    Write-Host "For new projects, Claude Code will suggest BMAD" -ForegroundColor Cyan
    Write-Host "   If project is substantial/complex, you'll get:"
    Write-Host "   `"Would you like me to set up the BMAD Method structure?`""
    Write-Host ""
    Write-Host "4️⃣  " -NoNewline
    Write-Host "Use BMAD commands" -ForegroundColor Cyan
    Write-Host "   /bmad-init    - Initialize BMAD structure"
    Write-Host "   /bmad-prd     - Create PRD (PM role)"
    Write-Host "   /bmad-arch    - Create Architecture (Architect role)"
    Write-Host "   /bmad-story   - Create story (SM role)"
    Write-Host "   /bmad-assess  - Assess project status"
    Write-Host ""
    Write-Host "📚 " -NoNewline
    Write-Host "To install commands in a project:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Option 1: Use commands in Claude Code (auto-creates)"
    Write-Host "   Option 2: Copy manually:"
    Write-Host "   Copy-Item -Recurse $ScriptDir\commands .claude\"
    Write-Host ""
    Write-Host "🔍 " -NoNewline
    Write-Host "To install hooks in a project:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Copy-Item $ScriptDir\hooks\project-open.sh .claude\hooks\"
    Write-Host ""
    Write-Host "🎯 " -NoNewline
    Write-Host "How BMAD Works in Claude Code:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   • " -NoNewline
    Write-Host "Auto-Detection" -ForegroundColor Green -NoNewline
    Write-Host ": Checks for bmad-agent/, .bmad-initialized, docs/prd.md"
    Write-Host "   • " -NoNewline
    Write-Host "Smart Suggestion" -ForegroundColor Green -NoNewline
    Write-Host ": Scores project (0-9), suggests if score ≥ 3"
    Write-Host "   • " -NoNewline
    Write-Host "Memory Integration" -ForegroundColor Green -NoNewline
    Write-Host ": Stores PRD, Architecture, Stories in Knowledge Graph"
    Write-Host "   • " -NoNewline
    Write-Host "Todo Tracking" -ForegroundColor Green -NoNewline
    Write-Host ": Stories become todos automatically"
    Write-Host "   • " -NoNewline
    Write-Host "Role-Based" -ForegroundColor Green -NoNewline
    Write-Host ": Claude Code acts as Analyst/PM/Architect/SM/Dev/QA"
    Write-Host ""
    Write-Host "✓ BMAD Skills ready! Claude Code now has BMAD superpowers." -ForegroundColor Green
    Write-Host ""
    Write-Host "Documentation: $ScriptDir\README.md"
    Write-Host "GitHub: https://github.com/bmad-code-org/BMAD-METHOD"
}

###############################################################################
# Main Installation
###############################################################################

function Main {
    Write-Heading "BMAD Skills for Claude Code - PowerShell Installer"

    # Check if Claude directory exists
    if (-not (Test-Path $ClaudeDir)) {
        Write-Warning "Claude Code directory not found: $ClaudeDir"
        Write-Info "Creating directory..."
        New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null
    }

    # Check for existing installation
    $bmadSkillPath = Join-Path $SkillsDir "bmad-method\SKILL.md"
    if ((Test-Path $bmadSkillPath) -and (-not $Force)) {
        Write-Warning "BMAD skills already installed"
        $response = Read-Host "Reinstall and overwrite? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Installation cancelled"
            exit 0
        }
    }

    # Perform installation
    New-Directories

    if (-not (Install-Skills)) {
        Write-Error "Installation failed"
        exit 1
    }

    Install-Templates
    New-CommandsReadme

    # Verify installation
    if (Test-Installation) {
        Show-NextSteps
        exit 0
    } else {
        Write-Error "Installation failed"
        exit 1
    }
}

# Run installation
Main
