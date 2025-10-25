#!/usr/bin/env bash
#
# Claude Code Hook: Project Open
# Automatically detects BMAD structure when project is opened

# This hook runs when Claude Code opens a project directory
# It should execute quickly and not block the UI

# Check for BMAD indicators
has_bmad=false

if [[ -d "bmad-agent" ]] || [[ -f ".bmad-initialized" ]] || [[ -f "docs/prd.md" ]]; then
    has_bmad=true
fi

if [[ "$has_bmad" == "true" ]]; then
    # Signal to Claude Code that BMAD mode should be activated
    echo "BMAD_DETECTED=true"
    echo "BMAD_MODE=active"

    # Check what planning documents exist
    [[ -f "docs/prd.md" ]] && echo "BMAD_HAS_PRD=true" || echo "BMAD_HAS_PRD=false"
    [[ -f "docs/architecture.md" ]] && echo "BMAD_HAS_ARCH=true" || echo "BMAD_HAS_ARCH=false"

    # Count stories
    if [[ -d "stories" ]]; then
        story_count=$(find stories -name "*.md" -not -path "*/templates/*" 2>/dev/null | wc -l)
        echo "BMAD_STORY_COUNT=$story_count"
    fi
else
    echo "BMAD_DETECTED=false"
fi

# Exit successfully
exit 0
