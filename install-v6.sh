#!/usr/bin/env bash
###############################################################################
# BMAD Method v6 for Claude Code - Installation Script
#
# Installs BMAD Method v6 using only Claude Code native features
# No npx, no external dependencies, pure Claude Code
#
# Usage: ./install-v6.sh
###############################################################################

set -euo pipefail

# Configuration
BMAD_VERSION="6.0.2"
CLAUDE_DIR="${HOME}/.claude"
BMAD_CONFIG_DIR="${CLAUDE_DIR}/config/bmad"
BMAD_SKILLS_DIR="${CLAUDE_DIR}/skills/bmad"
BMAD_COMMANDS_DIR="${CLAUDE_DIR}/commands/bmad"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
}

###############################################################################
# Installation Functions
###############################################################################

create_directories() {
    log_info "Creating directory structure..."

    # Claude Code directories
    mkdir -p "${BMAD_SKILLS_DIR}"/{core,bmm,bmb,cis}
    mkdir -p "${BMAD_COMMANDS_DIR}"
    mkdir -p "${BMAD_CONFIG_DIR}"/{agents,templates}

    log_success "Directories created"
}

install_skills() {
    log_info "Installing BMAD skills..."

    # Install core skills
    if [ -d "${SCRIPT_DIR}/bmad-v6/skills/core" ]; then
        cp -r "${SCRIPT_DIR}/bmad-v6/skills/core"/* "${BMAD_SKILLS_DIR}/core/"
        log_success "Core skills installed"
    fi

    # Install BMM skills (will add more in later phases)
    if [ -d "${SCRIPT_DIR}/bmad-v6/skills/bmm" ]; then
        cp -r "${SCRIPT_DIR}/bmad-v6/skills/bmm"/* "${BMAD_SKILLS_DIR}/bmm/" 2>/dev/null || true
        log_success "BMM skills installed"
    fi

    # Install BMB skills (optional)
    if [ -d "${SCRIPT_DIR}/bmad-v6/skills/bmb" ]; then
        cp -r "${SCRIPT_DIR}/bmad-v6/skills/bmb"/* "${BMAD_SKILLS_DIR}/bmb/" 2>/dev/null || true
    fi

    # Install CIS skills (optional)
    if [ -d "${SCRIPT_DIR}/bmad-v6/skills/cis" ]; then
        cp -r "${SCRIPT_DIR}/bmad-v6/skills/cis"/* "${BMAD_SKILLS_DIR}/cis/" 2>/dev/null || true
    fi
}

install_config() {
    log_info "Installing configuration..."

    # Install config template
    if [ -f "${SCRIPT_DIR}/bmad-v6/config/config.template.yaml" ]; then
        if [ ! -f "${BMAD_CONFIG_DIR}/config.yaml" ]; then
            # Create config from template, substituting variables
            sed "s/{{USER_NAME}}/${USER}/g" \
                "${SCRIPT_DIR}/bmad-v6/config/config.template.yaml" \
                > "${BMAD_CONFIG_DIR}/config.yaml"
            log_success "Configuration created"
        else
            log_info "Configuration already exists, skipping"
        fi
    fi

    # Copy project config template
    if [ -f "${SCRIPT_DIR}/bmad-v6/config/project-config.template.yaml" ]; then
        cp "${SCRIPT_DIR}/bmad-v6/config/project-config.template.yaml" \
           "${BMAD_CONFIG_DIR}/project-config.template.yaml"
    fi
}

install_templates() {
    log_info "Installing templates..."

    # Install all template files
    if [ -d "${SCRIPT_DIR}/bmad-v6/templates" ]; then
        cp "${SCRIPT_DIR}/bmad-v6/templates"/* \
           "${BMAD_CONFIG_DIR}/templates/" 2>/dev/null || true
        log_success "Templates installed"
    fi
}

install_utils() {
    log_info "Installing utility helpers..."

    # Copy helpers.md to config directory for reference
    if [ -f "${SCRIPT_DIR}/bmad-v6/utils/helpers.md" ]; then
        cp "${SCRIPT_DIR}/bmad-v6/utils/helpers.md" \
           "${BMAD_CONFIG_DIR}/helpers.md"
        log_success "Utility helpers installed"
    fi
}

install_commands() {
    log_info "Installing slash commands..."

    # Install all command files
    if [ -d "${SCRIPT_DIR}/bmad-v6/commands" ]; then
        local command_count=$(find "${SCRIPT_DIR}/bmad-v6/commands" -name "*.md" 2>/dev/null | wc -l)

        if [ "$command_count" -gt 0 ]; then
            cp "${SCRIPT_DIR}/bmad-v6/commands"/*.md \
               "${BMAD_COMMANDS_DIR}/" 2>/dev/null || true
            log_success "Slash commands installed ($command_count commands)"
        else
            echo "⚠ No command files found"
        fi
    else
        echo "⚠ Commands directory not found"
    fi
}

verify_installation() {
    log_info "Verifying installation..."

    local errors=0

    # Check for BMad Master skill
    if [ -f "${BMAD_SKILLS_DIR}/core/bmad-master/SKILL.md" ]; then
        log_success "BMad Master skill verified"
    else
        echo "✗ BMad Master skill missing"
        errors=$((errors + 1))
    fi

    # Check for config
    if [ -f "${BMAD_CONFIG_DIR}/config.yaml" ]; then
        log_success "Configuration verified"
    else
        echo "✗ Configuration missing"
        errors=$((errors + 1))
    fi

    # Check for helpers
    if [ -f "${BMAD_CONFIG_DIR}/helpers.md" ]; then
        log_success "Helpers verified"
    else
        echo "✗ Helpers missing"
        errors=$((errors + 1))
    fi

    # Check for commands
    if [ -f "${BMAD_COMMANDS_DIR}/workflow-init.md" ]; then
        log_success "Slash commands verified"
    else
        echo "✗ Slash commands missing"
        errors=$((errors + 1))
    fi

    if [ $errors -eq 0 ]; then
        log_success "Installation verified successfully"
        return 0
    else
        echo "✗ Installation verification failed: $errors error(s)"
        return 1
    fi
}

print_next_steps() {
    log_header "Installation Complete!"

    cat << EOF
📦 BMAD Method v${BMAD_VERSION} installed successfully!

Installation location:
  Skills:   ${BMAD_SKILLS_DIR}
  Commands: ${BMAD_COMMANDS_DIR}
  Config:   ${BMAD_CONFIG_DIR}

✓ 9 Specialized Skills
  - Core orchestrator (BMad Master)
  - Agile agents (Analyst, PM, Architect, SM, Developer, UX)
  - Builder module (custom agents and workflows)
  - Creative Intelligence (brainstorming and research)

✓ 15 Workflow Commands
  - /workflow-init, /workflow-status
  - /product-brief, /prd, /tech-spec
  - /architecture, /solutioning-gate-check
  - /sprint-planning, /create-story, /dev-story
  - /brainstorm, /research
  - /create-agent, /create-workflow, /create-ux-design

✓ Configuration system
✓ Template engine
✓ Status tracking utilities

📋 Next Steps:

1️⃣  ${BLUE}Restart Claude Code${NC}
   Skills will be loaded in new sessions

2️⃣  ${BLUE}Open your project${NC}
   Navigate to the project you want to use BMAD with

3️⃣  ${BLUE}Initialize BMAD${NC}
   Run: /workflow-init
   This sets up BMAD structure in your project

4️⃣  ${BLUE}Check status${NC}
   Run: /workflow-status
   See your project status and get recommendations

📚 Verification:
   ls -la ~/.claude/skills/bmad/core/bmad-master/SKILL.md
   ls -la ~/.claude/commands/bmad/workflow-init.md

📚 Documentation:
   README: ${SCRIPT_DIR}/README.md

${GREEN}✓ BMAD Method v6 is ready!${NC}

Need help? Visit: https://github.com/aj-geddes/claude-code-bmad-skills/issues
EOF
}

###############################################################################
# Main Installation
###############################################################################

main() {
    log_header "BMAD Method v${BMAD_VERSION} Installer"

    # Check if Claude directory exists
    if [ ! -d "${CLAUDE_DIR}" ]; then
        log_info "Creating Claude Code directory: ${CLAUDE_DIR}"
        mkdir -p "${CLAUDE_DIR}"
    fi

    # Perform installation
    create_directories
    install_skills
    install_config
    install_templates
    install_utils
    install_commands

    # Verify
    if verify_installation; then
        print_next_steps
        exit 0
    else
        echo "Installation failed"
        exit 1
    fi
}

# Run installation
main "$@"
