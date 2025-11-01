You are executing the **Workflow Init** command to initialize BMAD Method in the current project.

## Command Overview

**Purpose:** Set up BMAD Method v6 structure and configuration in the current project

**Agent:** BMad Master (Core Orchestrator)

**Output:**
- `bmad/config.yaml` - Project configuration
- `docs/bmm-workflow-status.yaml` - Workflow status tracking
- Directory structure for BMAD artifacts

---

## Execution Steps

### Step 1: Check for Existing Installation

1. Check if `bmad/config.yaml` exists
2. If exists:
   - Read current config
   - Ask: "BMAD already initialized. Reinitialize (overwrites config)?"
   - If no → Exit
   - If yes → Continue

### Step 2: Create Directory Structure

Create the following directories using Write/Bash tool:

```
bmad/
├── config.yaml
└── agent-overrides/

docs/
├── bmm-workflow-status.yaml
└── stories/
    └── (story directories created as needed)

.claude/
└── commands/
    └── bmad/
        └── (commands auto-registered by Claude Code)
```

**Note:** Only create directories that don't exist. Use `mkdir -p` to be safe.

### Step 3: Collect Project Information

Ask user these questions (one at a time):

**Q1: Project Name**
```
"What is your project name?"

Examples: "MyApp", "E-Commerce Platform", "Mobile Game"
Default: Use directory name if user skips
```

**Q2: Project Type**
```
"What type of project is this?"

Options (present as menu):
1. Web Application
2. Mobile App (iOS/Android)
3. API / Backend Service
4. Game
5. Library / Framework
6. Other

Store as: "web-app", "mobile-app", "api", "game", "library", "other"
```

**Q3: Project Level**
```
"What is the project complexity level?"

Explain levels:
- Level 0: Single atomic change (1 story)
- Level 1: Small feature set (1-10 stories)
- Level 2: Medium feature set (5-15 stories)
- Level 3: Complex integration (12-40 stories)
- Level 4: Enterprise expansion (40+ stories)

Options (present as menu):
0. Level 0 - Single story
1. Level 1 - Small (1-10 stories)
2. Level 2 - Medium (5-15 stories)
3. Level 3 - Complex (12-40 stories)
4. Level 4 - Enterprise (40+ stories)

Store as: 0, 1, 2, 3, or 4
```

### Step 4: Create Project Config

1. Load global config from `~/.claude/config/bmad/config.yaml` per `helpers.md#Load-Global-Config`

2. Load template from `~/.claude/config/bmad/project-config.template.yaml`

3. Substitute variables:
   - `{{PROJECT_NAME}}` → User input from Step 3
   - `{{PROJECT_TYPE}}` → User input from Step 3
   - `{{PROJECT_LEVEL}}` → User input from Step 3

4. Write to `bmad/config.yaml` using Write tool

**Example output:**
```yaml
project_name: "MyApp"
project_type: "web-app"
project_level: 2
output_folder: "docs"
bmm:
  workflow_status_file: "docs/bmm-workflow-status.yaml"
  sprint_status_file: "docs/sprint-status.yaml"
paths:
  docs: "docs"
  stories: "docs/stories"
  tests: "tests"
```

### Step 5: Create Workflow Status File

1. Load template from `~/.claude/config/bmad/templates/bmm-workflow-status.template.yaml`

2. Determine conditional statuses based on project level:
   ```
   Level 0-1:
     - PRD: "recommended" (optional for level 0)
     - Tech-spec: "required"
     - Architecture: "optional"

   Level 2+:
     - PRD: "required"
     - Tech-spec: "optional"
     - Architecture: "required"
   ```

3. Substitute variables:
   - `{{TIMESTAMP}}` → Current ISO timestamp
   - `{{PROJECT_NAME}}` → From project config
   - `{{PROJECT_TYPE}}` → From project config
   - `{{PROJECT_LEVEL}}` → From project config
   - `{{PRD_STATUS}}` → Conditional per above
   - `{{TECH_SPEC_STATUS}}` → Conditional per above
   - `{{ARCHITECTURE_STATUS}}` → Conditional per above

4. Write to `docs/bmm-workflow-status.yaml` using Write tool

### Step 6: Confirm Initialization

Display success message:

```
✓ BMAD Method v6 initialized successfully!

Project Configuration:
  Name: {project_name}
  Type: {project_type}
  Level: {project_level}

Files Created:
  ✓ bmad/config.yaml
  ✓ docs/bmm-workflow-status.yaml
  ✓ Directory structure

Workflow Path for Level {project_level}:
  {Display path based on level - see Step 7}

Recommended Next Step:
  {Recommend workflow - see helpers.md#Determine-Next-Workflow}
```

### Step 7: Recommend Workflow Path

Based on project level, show recommended path:

**Level 0:**
```
Phase 1 (Optional): /product-brief
Phase 2 (Required): /tech-spec
Phase 4 (Required): /create-story → /dev-story
```

**Level 1:**
```
Phase 1 (Recommended): /product-brief
Phase 2 (Required): /tech-spec
Phase 4 (Required): /sprint-planning → stories
```

**Level 2+:**
```
Phase 1 (Recommended): /product-brief
Phase 2 (Required): /prd
Phase 3 (Required): /architecture
Phase 4 (Required): /sprint-planning → stories
```

### Step 8: Offer to Start

Ask user:
```
"Would you like to start with the recommended workflow?"

If Phase 1 recommended: "I can help you create a product brief."
If Phase 2 required: "I can help you create a [PRD/tech-spec]."
```

If yes: Hand off to appropriate agent (Analyst for brief, PM for PRD/tech-spec)
If no: "Run /workflow-status anytime to check your progress."

---

## Helper References

- **Load global config:** `helpers.md#Load-Global-Config`
- **Load template:** `helpers.md#Load-Template`
- **Apply variables:** `helpers.md#Apply-Variables-to-Template`
- **Save document:** `helpers.md#Save-Output-Document`
- **Determine next:** `helpers.md#Determine-Next-Workflow`

---

## Error Handling

**If BMAD already initialized:**
- Inform user
- Offer to reinitialize (overwrites config)
- Offer to check status instead (`/workflow-status`)

**If directory creation fails:**
- Show error
- Check permissions
- Suggest manual directory creation

**If template missing:**
- Use inline fallback template
- Log warning
- Continue initialization

---

## Notes for LLMs

- Use TodoWrite to track 8 steps
- Create directories with `mkdir -p` (safe for existing dirs)
- Be clear about conditional requirements based on level
- Present options as numbered menus for clarity
- Use Write tool for config/status files
- Maintain BMad Master persona (helpful, organized, clear)
- Don't skip steps - initialization must be complete

**Remember:** This is the entry point for BMAD. Set users up for success with clear explanation of their path forward.
