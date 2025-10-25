# Initialize BMAD Method Structure

You are being asked to initialize the BMAD Method structure in the current project.

## Your Task

1. **Check if BMAD already exists**:
   - Look for `bmad-agent/` directory
   - Look for `.bmad-initialized` file
   - Look for `docs/prd.md` or `docs/architecture.md`

2. **If BMAD exists**:
   - Report what's already present
   - Ask if user wants to reinitialize (will overwrite templates)

3. **If BMAD doesn't exist**:
   - Analyze project context and explain why BMAD would be beneficial
   - Create complete BMAD structure

4. **Create the following structure**:

```
bmad-agent/
├── agents/
│   ├── analyst.md        # Analyst agent role definition
│   ├── pm.md             # PM agent role definition
│   ├── architect.md      # Architect agent role definition
│   ├── scrum-master.md   # Scrum Master agent role definition
│   ├── developer.md      # Developer agent role definition
│   └── qa.md             # QA agent role definition
├── config/
│   └── bmad.config.yaml  # BMAD configuration
└── README.md             # BMAD guide

docs/
└── templates/
    ├── project-brief-template.md
    ├── prd-template.md
    └── architecture-template.md

stories/
└── templates/
    └── story-template.md

.bmad/
└── .gitignore

.bmad-initialized         # Marker file
```

5. **Use the templates** from `~/.claude/skills/bmad-method/templates/` if available

6. **Create Memory entities** for this BMAD project:
   - Create entity for the project itself
   - Add observation: "BMAD initialized on [date]"
   - Create relation to BMAD methodology

7. **Set up initial todo**:
   - Use TodoWrite to create planning phase todos:
     - "Create docs/prd.md (PM role)"
     - "Create docs/architecture.md (Architect role)"

8. **Explain next steps**:
   - Phase 1: Planning (PRD → Architecture)
   - Phase 2: Development (Stories → Implementation → QA)
   - Offer to help create PRD now

## Important

- Use the Write tool to create all files with proper content
- Reference the BMAD Method skill for complete agent definitions and templates
- Make this fast and seamless - complete structure in seconds
- Be enthusiastic about BMAD's benefits!
