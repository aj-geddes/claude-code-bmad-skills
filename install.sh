#!/usr/bin/env bash

###############################################################################
# BMAD Skills for Claude Code - Installer
#
# This script installs BMAD Method skills, commands, and hooks for Claude Code
#
# Usage:
#   ./install.sh
#   ./install.sh --force    # Overwrite existing files
###############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
FORCE=false
CLAUDE_DIR="${HOME}/.claude"
SKILLS_DIR="${CLAUDE_DIR}/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# Parse Arguments
###############################################################################

while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            echo "BMAD Skills Installer for Claude Code"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --force    Overwrite existing files"
            echo "  -h, --help Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

###############################################################################
# Helper Functions
###############################################################################

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_heading() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

###############################################################################
# Installation Functions
###############################################################################

create_directories() {
    log_info "Creating Claude Code directories..."

    mkdir -p "${SKILLS_DIR}/bmad-method"
    mkdir -p "${SKILLS_DIR}/security"
    mkdir -p "${SKILLS_DIR}/python"
    mkdir -p "${SKILLS_DIR}/javascript"
    mkdir -p "${SKILLS_DIR}/devops"
    mkdir -p "${SKILLS_DIR}/testing"
    mkdir -p "${SKILLS_DIR}/git"

    log_success "Directories created"
}

install_skills() {
    log_info "Installing BMAD skills..."

    # Copy all skill files
    cp "${SCRIPT_DIR}/skills/bmad-method/SKILL.md" "${SKILLS_DIR}/bmad-method/SKILL.md"
    cp "${SCRIPT_DIR}/skills/security/SKILL.md" "${SKILLS_DIR}/security/SKILL.md"
    cp "${SCRIPT_DIR}/skills/python/SKILL.md" "${SKILLS_DIR}/python/SKILL.md"
    cp "${SCRIPT_DIR}/skills/javascript/SKILL.md" "${SKILLS_DIR}/javascript/SKILL.md"
    cp "${SCRIPT_DIR}/skills/devops/SKILL.md" "${SKILLS_DIR}/devops/SKILL.md"
    cp "${SCRIPT_DIR}/skills/testing/SKILL.md" "${SKILLS_DIR}/testing/SKILL.md"
    cp "${SCRIPT_DIR}/skills/git/SKILL.md" "${SKILLS_DIR}/git/SKILL.md"

    log_success "Skills installed to ${SKILLS_DIR}"
}

install_templates() {
    log_info "Installing BMAD templates..."

    # Templates are embedded in the /bmad-init command
    # But we can create a reference directory for users
    mkdir -p "${SKILLS_DIR}/bmad-method/templates"

    cat > "${SKILLS_DIR}/bmad-method/templates/README.md" << 'EOF'
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
EOF

    log_success "Template reference created"
}

check_project_commands() {
    log_info "Checking for project-level commands directory..."

    if [[ -d ".claude/commands" ]]; then
        log_success "Found .claude/commands in current directory"
        return 0
    else
        log_warning "No .claude/commands found in current directory"
        log_info "Commands will be available after you run them once in Claude Code"
        return 1
    fi
}

create_commands_readme() {
    log_info "Creating commands README..."

    mkdir -p "${SKILLS_DIR}/bmad-method/commands-reference"

    cat > "${SKILLS_DIR}/bmad-method/commands-reference/README.md" << 'EOF'
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
EOF

    log_success "Commands README created"
}

verify_installation() {
    log_info "Verifying installation..."

    local errors=0

    # Check skills
    for skill in bmad-method security python javascript devops testing git; do
        if [[ -f "${SKILLS_DIR}/${skill}/SKILL.md" ]]; then
            log_success "Skill verified: ${skill}"
        else
            log_error "Skill missing: ${skill}"
            errors=$((errors + 1))
        fi
    done

    if [[ $errors -eq 0 ]]; then
        log_success "All skills verified successfully"
        return 0
    else
        log_error "Installation verification failed: $errors error(s)"
        return 1
    fi
}

print_next_steps() {
    log_heading "Installation Complete!"

    echo "📦 Installed to: ${SKILLS_DIR}"
    echo ""
    echo "✓ BMAD Method Skill"
    echo "✓ Security Skill"
    echo "✓ Python Skill"
    echo "✓ JavaScript/TypeScript Skill"
    echo "✓ DevOps Skill"
    echo "✓ Testing Skill"
    echo "✓ Git Skill"
    echo ""
    echo "📋 Next Steps:"
    echo ""
    echo "1️⃣  ${CYAN}Start or restart Claude Code${NC}"
    echo "   Skills will be automatically loaded in new sessions"
    echo ""
    echo "2️⃣  ${CYAN}Open a project in Claude Code${NC}"
    echo "   BMAD will automatically detect if project uses BMAD Method"
    echo ""
    echo "3️⃣  ${CYAN}For new projects, Claude Code will suggest BMAD${NC}"
    echo "   If project is substantial/complex, you'll get:"
    echo "   \"Would you like me to set up the BMAD Method structure?\""
    echo ""
    echo "4️⃣  ${CYAN}Use BMAD commands${NC}"
    echo "   /bmad-init    - Initialize BMAD structure"
    echo "   /bmad-prd     - Create PRD (PM role)"
    echo "   /bmad-arch    - Create Architecture (Architect role)"
    echo "   /bmad-story   - Create story (SM role)"
    echo "   /bmad-assess  - Assess project status"
    echo ""
    echo "📚 ${CYAN}To install commands in a project:${NC}"
    echo ""
    echo "   Option 1: Use commands in Claude Code (auto-creates)"
    echo "   Option 2: Copy manually:"
    echo "   cp -r ${SCRIPT_DIR}/commands .claude/"
    echo ""
    echo "🔍 ${CYAN}To install hooks in a project:${NC}"
    echo ""
    echo "   cp ${SCRIPT_DIR}/hooks/project-open.sh .claude/hooks/"
    echo "   chmod +x .claude/hooks/project-open.sh"
    echo ""
    echo "🎯 ${CYAN}How BMAD Works in Claude Code:${NC}"
    echo ""
    echo "   • ${GREEN}Auto-Detection${NC}: Checks for bmad-agent/, .bmad-initialized, docs/prd.md"
    echo "   • ${GREEN}Smart Suggestion${NC}: Scores project (0-9), suggests if score ≥ 3"
    echo "   • ${GREEN}Memory Integration${NC}: Stores PRD, Architecture, Stories in Knowledge Graph"
    echo "   • ${GREEN}Todo Tracking${NC}: Stories become todos automatically"
    echo "   • ${GREEN}Role-Based${NC}: Claude Code acts as Analyst/PM/Architect/SM/Dev/QA"
    echo ""
    echo "${GREEN}✓ BMAD Skills ready! Claude Code now has BMAD superpowers.${NC}"
    echo ""
    echo "Documentation: ${SCRIPT_DIR}/README.md"
    echo "GitHub: https://github.com/bmad-code-org/BMAD-METHOD"
}

###############################################################################
# Main Installation
###############################################################################

main() {
    log_heading "BMAD Skills for Claude Code - Installer"

    # Check if Claude directory exists
    if [[ ! -d "${CLAUDE_DIR}" ]]; then
        log_warning "Claude Code directory not found: ${CLAUDE_DIR}"
        log_info "Creating directory..."
        mkdir -p "${CLAUDE_DIR}"
    fi

    # Check for existing installation
    if [[ -f "${SKILLS_DIR}/bmad-method/SKILL.md" ]] && [[ "$FORCE" != "true" ]]; then
        log_warning "BMAD skills already installed"
        read -p "Reinstall and overwrite? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled"
            exit 0
        fi
    fi

    # Perform installation
    create_directories
    install_skills
    install_templates
    create_commands_readme

    # Verify installation
    if verify_installation; then
        print_next_steps
        exit 0
    else
        log_error "Installation failed"
        exit 1
    fi
}

# Run installation
main "$@"
