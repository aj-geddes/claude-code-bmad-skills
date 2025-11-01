You are executing the **Workflow Status** command to check project progress and get recommendations.

## Command Overview

**Purpose:** Display project status, completed workflows, and recommend next steps

**Agent:** BMad Master (Core Orchestrator)

**Output:** Status display with recommendations

---

## Execution Steps

### Step 1: Check Initialization

1. Check if `bmad/config.yaml` exists
2. If NOT exists:
   ```
   ⚠ BMAD not initialized in this project.

   To get started, run: /workflow-init

   This will set up BMAD structure and guide you through project setup.
   ```
   Exit command.

3. If exists → Continue

### Step 2: Load Configuration

Load both configs per `helpers.md#Combined-Config-Load`:
1. Project config from `bmad/config.yaml`
2. Workflow status from `docs/bmm-workflow-status.yaml`

Extract:
- `project_name`
- `project_type`
- `project_level`
- `workflow_status` array

### Step 3: Analyze Current State

For each workflow in status array:
1. Check `status` field
2. If status is a file path (e.g., "docs/prd-myapp-2025-01-11.md") → **Completed** ✓
3. If status is "required" → **Required, not started** ⚠
4. If status is "optional" or "recommended" → **Optional** -
5. If status is "skipped" → **Skipped** (no symbol)

Determine current phase:
- **Phase 1:** Any Phase 1 workflow in progress or last completed is Phase 1
- **Phase 2:** Last completed was Phase 1, or Phase 2 in progress
- **Phase 3:** Last completed was Phase 2, or Phase 3 in progress
- **Phase 4:** Last completed was Phase 3, or check sprint-status.yaml

### Step 4: Determine Recommendations

Use logic from `helpers.md#Determine-Next-Workflow`:

**Logic:**
1. If NO workflows completed → Recommend: `/product-brief` (Phase 1) or `/prd`/`/tech-spec` (Phase 2) based on level
2. If product-brief complete, no PRD/tech-spec → Recommend: `/prd` (level 2+) or `/tech-spec` (level 0-1)
3. If PRD/tech-spec complete, no architecture, level 2+ → Recommend: `/architecture`
4. If architecture complete (or not required) → Recommend: `/sprint-planning`
5. If sprint active → Check `docs/sprint-status.yaml`:
   - If no stories → `/create-story`
   - If stories exist → `/dev-story` on first in-progress story

### Step 5: Display Status

Format per `helpers.md#Status-Display-Format`:

```
Project: {project_name} ({project_type}, Level {project_level})
Progress: {X}/{Total} workflows completed

{For each phase:}
{Phase indicator} Phase {N}: {Phase Name}
  {Workflow status} {workflow-name} ({status or file path})
  ...

Recommended Next Step:
{Recommendation with command and brief description}
```

**Status Symbols:**
- `✓` = Completed (green)
- `⚠` = Required but not started (yellow/warning)
- `→` = Current phase indicator
- `-` = Optional/not required

**Example Output:**
```
Project: MyApp (Web Application, Level 2)
Progress: 2/7 workflows completed

✓ Phase 1: Analysis
  ✓ product-brief (docs/product-brief-myapp-2025-01-11.md)
  - research (optional)

→ Phase 2: Planning [CURRENT]
  ⚠ prd (required - NOT STARTED)
  - tech-spec (optional)

Phase 3: Solutioning
  - architecture (required)

Phase 4: Implementation
  (tracked in sprint-status.yaml)

Recommended Next Step:
  Run /prd to create your Product Requirements Document.
  This is required for Level 2 projects to ensure comprehensive planning.
```

### Step 6: Check Sprint Status (If Phase 4)

If current phase is 4 (Implementation):
1. Load `docs/sprint-status.yaml` per `helpers.md#Load-Sprint-Status`
2. Display sprint info:
   ```
   Sprint {sprint_number}: {sprint_goal}
   Epics: {total_epics}
   Stories: {stories_completed}/{total_stories} complete

   In Progress:
   - {story-id}: {story-name}
   ```

3. Recommend:
   - If no stories → `/create-story`
   - If stories in-progress → `/dev-story {story-id}`
   - If stories completed → `/retrospective` or `/create-story` for next

### Step 7: Offer Actions

Present options to user:

```
What would you like to do?
1. Start recommended workflow
2. View workflow options
3. Check specific workflow details
4. Exit
```

**If option 1 selected:**
- Hand off to appropriate agent
- For `/prd` → Product Manager
- For `/product-brief` → Business Analyst
- For `/architecture` → System Architect
- For `/sprint-planning` → Scrum Master
- For `/dev-story` → Developer

**If option 2:**
- Show all available workflows by phase
- Let user select

**If option 3:**
- Ask which workflow
- Show detailed info (purpose, inputs, outputs, status)

**If option 4:**
- "Run /workflow-status anytime to check progress."

---

## Helper References

- **Load configs:** `helpers.md#Combined-Config-Load`
- **Load status:** `helpers.md#Load-Workflow-Status`
- **Load sprint:** `helpers.md#Load-Sprint-Status`
- **Determine next:** `helpers.md#Determine-Next-Workflow`
- **Display format:** `helpers.md#Status-Display-Format`

---

## Special Cases

**Brownfield Project (Existing Code):**
If user mentions existing codebase:
```
I see you have existing code. BMAD can still help!

Consider:
- /research - Document existing architecture
- /prd - Create PRD for new features
- /create-story - Plan incremental improvements

Or run /workflow-init with focus on enhancement/refactor goals.
```

**Level 0 Project:**
```
Level 0 projects (single story) follow simplified path:
Phase 1: Optional (can skip directly to Phase 2)
Phase 2: /tech-spec (lightweight requirements)
Phase 4: /create-story → /dev-story (single story)

You can skip architecture and sprint planning for single-story work.
```

---

## Error Handling

**Config missing:**
- Inform user to run `/workflow-init`
- Explain BMAD not set up

**Status file corrupted:**
- Show error with file path
- Offer to reinitialize: "Run /workflow-init to reset"
- Suggest manual fix if user has custom changes

**Sprint status missing (Phase 4):**
- Inform user to run `/sprint-planning` first
- Explain sprint must be planned before stories

---

## Notes for LLMs

- This is a read-only status check (no modifications)
- Use Read tool for all file loading
- Present information clearly with visual hierarchy
- Be helpful in recommendations - explain WHY each workflow is suggested
- Adapt recommendations to project level (don't over-plan for small projects)
- Maintain BMad Master persona (organized, helpful, clear)
- Use TodoWrite if complex analysis needed

**Remember:** This command is the "GPS" for BMAD. Help users understand where they are and where to go next.
