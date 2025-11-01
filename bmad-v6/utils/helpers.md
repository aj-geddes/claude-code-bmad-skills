# BMAD v6 Helper Utilities

This document contains reusable utilities for BMAD workflows. Skills and commands can reference specific sections to avoid repetition.

## Config Loading

### Load Global Config
```
Path: ~/.claude/config/bmad/config.yaml
Purpose: Get user settings, enabled modules, defaults

Using Read tool:
1. Read ~/.claude/config/bmad/config.yaml
2. Parse YAML to extract:
   - user_name
   - communication_language
   - default_output_folder
   - modules_enabled
3. Store in memory for workflow
```

### Load Project Config
```
Path: {project-root}/bmad/config.yaml
Purpose: Get project-specific settings

Using Read tool:
1. Read bmad/config.yaml
2. Parse YAML to extract:
   - project_name
   - project_type
   - project_level
   - output_folder
3. Merge with global config (project overrides global)
```

### Combined Config Load
```
Execute in order:
1. Load global config (defaults)
2. Load project config (overrides)
3. Return merged config object
```

## Status File Operations

### Load Workflow Status
```
Path: {output_folder}/bmm-workflow-status.yaml (from project config)
Purpose: Check completed workflows, current phase

Using Read tool:
1. Read docs/bmm-workflow-status.yaml (or path from config)
2. Parse YAML to extract:
   - project metadata
   - workflow_status array
3. Determine current phase:
   - Find last completed workflow (status = file path)
   - Identify next required/recommended workflow
```

### Update Workflow Status
```
Purpose: Mark workflow as complete

Using Edit tool:
1. Load current status file
2. Find workflow by name
3. Update status field: "{file-path}"
4. Update last_updated: current timestamp
5. Save changes
```

### Load Sprint Status
```
Path: {output_folder}/sprint-status.yaml
Purpose: Check epic/story progress

Using Read tool:
1. Read docs/sprint-status.yaml
2. Parse YAML to extract:
   - sprint_number
   - epics array
   - stories within epics
   - metrics
```

### Update Sprint Status
```
Purpose: Add/update epics and stories

Using Edit tool:
1. Load current sprint status
2. Modify epics/stories array
3. Recalculate metrics
4. Update last_updated timestamp
5. Save changes
```

## Template Operations

### Load Template
```
Purpose: Load document template for workflow

Using Read tool:
1. Read template from: ~/.claude/config/bmad/templates/{workflow-name}.md
2. Store template content
3. Extract variable placeholders: {{variable_name}}
```

### Apply Variables to Template
```
Purpose: Substitute {{variables}} with actual values

Process:
1. For each variable in template:
   - {{project_name}} → from config
   - {{date}} → current date (YYYY-MM-DD)
   - {{timestamp}} → current ISO timestamp
   - {{user_name}} → from global config
   - {{custom_var}} → from user input
2. Replace all {{variable}} with values
3. Return completed document
```

### Save Output Document
```
Purpose: Write completed document to output folder

Using Write tool:
1. Determine output path:
   - {output_folder}/{workflow-name}-{project-name}-{date}.md
   - Example: docs/prd-myapp-2025-01-11.md
2. Write content to path
3. Return file path for status update
```

## Variable Substitution

### Standard Variables
```
{{project_name}}           → config: project_name
{{project_type}}           → config: project_type
{{project_level}}          → config: project_level
{{user_name}}              → config: user_name
{{date}}                   → current date (YYYY-MM-DD)
{{timestamp}}              → current timestamp (ISO 8601)
{{output_folder}}          → config: output_folder
```

### Conditional Variables
```
{{PRD_STATUS}}             → "required" if level >= 2, else "recommended"
{{TECH_SPEC_STATUS}}       → "required" if level <= 1, else "optional"
{{ARCHITECTURE_STATUS}}    → "required" if level >= 2, else "optional"
```

### Level-Based Logic
```
Level 0 (1 story):         PRD optional, tech-spec required, no architecture
Level 1 (1-10 stories):    PRD recommended, tech-spec required, no architecture
Level 2 (5-15 stories):    PRD required, tech-spec optional, architecture required
Level 3 (12-40 stories):   PRD required, tech-spec optional, architecture required
Level 4 (40+ stories):     PRD required, tech-spec optional, architecture required
```

## Workflow Recommendations

### Determine Next Workflow
```
Input: workflow_status array
Output: recommended next workflow

Logic:
1. If no product-brief and project new → Recommend: /product-brief
2. If product-brief complete, no PRD/tech-spec → Recommend based on level:
   - Level 0-1: /tech-spec
   - Level 2+: /prd
3. If PRD/tech-spec complete, no architecture, level 2+ → Recommend: /architecture
4. If architecture complete (or not required) → Recommend: /sprint-planning
5. If sprint active → Recommend: /create-story or /dev-story
```

### Status Display Format
```
✓ = Completed (green)
⚠ = Required but not started (yellow)
→ = Current phase indicator
- = Optional/not required

Example:
✓ Phase 1: Analysis
  ✓ product-brief (docs/product-brief-myapp-2025-01-11.md)
  - research (optional)

→ Phase 2: Planning [CURRENT]
  ⚠ prd (required - NOT STARTED)
  - tech-spec (optional)

Phase 3: Solutioning
  - architecture (required)
```

## Path Resolution

### Resolve Project Root
```
Method: Use environment or detect
- Claude Code provides working directory
- Use `{project-root}` as placeholder
- Replace at runtime with actual path
```

### Resolve Config Paths
```
~/.claude/config/bmad/config.yaml           → Global config
{project-root}/bmad/config.yaml             → Project config
{project-root}/{output_folder}              → Output directory (usually docs/)
```

### Resolve Template Paths
```
~/.claude/config/bmad/templates/{name}.md   → Template files
```

## Error Handling

### File Not Found
```
If config file missing:
  - Use defaults
  - Prompt user to run /workflow-init

If status file missing:
  - Inform user project not initialized
  - Offer to run /workflow-init

If template missing:
  - Use inline template
  - Log warning
```

### Invalid YAML
```
If YAML parse error:
  - Show error message
  - Provide file path
  - Suggest manual fix or reinit
```

## Token Optimization Tips

### Reference vs. Embed
```
✓ Good: "Follow helper instructions in utils/helpers.md#Load-Global-Config"
✗ Bad: Embed full instructions in every command

✓ Good: "Use standard variables from helpers.md#Standard-Variables"
✗ Bad: List all variables in every template
```

### Lazy Loading
```
✓ Good: Load config only when needed
✗ Bad: Load all files upfront

✓ Good: Read status file when checking progress
✗ Bad: Keep status in memory throughout chat
```

### Reuse Patterns
```
✓ Good: "Execute Step 1-3 from helpers.md#Combined-Config-Load"
✗ Bad: Repeat config loading steps in every workflow
```

## Quick Reference Commands

### For Skills/Commands
```
To load config: See helpers.md#Combined-Config-Load
To check status: See helpers.md#Load-Workflow-Status
To update status: See helpers.md#Update-Workflow-Status
To use template: See helpers.md#Load-Template + helpers.md#Apply-Variables-to-Template
To save output: See helpers.md#Save-Output-Document
To recommend next: See helpers.md#Determine-Next-Workflow
```
