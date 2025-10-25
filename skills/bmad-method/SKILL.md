# BMAD Method Skill

## Overview

This skill enables the **BMAD Method** (Breakthrough Method for Agile AI-Driven Development) in Claude Code - a revolutionary Agentic Agile framework for structured, context-preserved development.

## Core Principles

### Two-Phase Approach

1. **Agentic Planning** (Before coding)
   - Analyst → Project Brief
   - PM → Product Requirements Document (PRD)
   - Architect → System Architecture

2. **Context-Engineered Development** (Implementation)
   - Scrum Master → Hyper-detailed Story Files
   - Developer → Implementation with tests
   - QA → Validation and sign-off

### Key Innovations

- **Context Preservation**: Story files contain EVERYTHING needed - no searching
- **MECE Task Sharding**: Stories are Mutually Exclusive, Collectively Exhaustive
- **Architecture Authority**: `docs/architecture.md` is single source of truth
- **Memory Integration**: Use Claude Code's Knowledge Graph to track relationships

## Automatic BMAD Detection

At the start of EVERY session:

1. **Check for BMAD structure**:
   - `bmad-agent/` directory exists?
   - `.bmad-initialized` marker file exists?
   - `docs/prd.md` or `docs/architecture.md` exist?

2. **If BMAD detected**:
   - Activate BMAD mode immediately
   - Load planning documents (PRD, Architecture) into context
   - Check Memory for stored entities
   - Determine current phase and agent role
   - DO NOT mention detection to user - just work in BMAD mode

3. **If BMAD not detected**:
   - Analyze project context (scoring system below)
   - If score ≥ 3: Suggest BMAD setup
   - If score < 3: Work normally, don't mention BMAD

## Context Scoring for BMAD Suggestion

Score the project to determine if BMAD would help:

- **New/greenfield project** (< 10 files): +3 points
- **Complex structure** (multiple directories, 20+ files): +2 points
- **User mentions** "architecture", "structure", "organize", "plan": +2 points
- **User mentions** "large", "complex", "multi", "team": +1 point
- **Has project files** (package.json, setup.py, Cargo.toml): +1 point

**If score ≥ 3**: Suggest BMAD
**If score < 3**: Continue normally

### How to Suggest BMAD

```
🎯 I notice this is a [substantial/complex/multi-feature] project.

Would you like me to set up the BMAD Method structure?

BMAD provides:
  ✓ Structured planning (PRD & Architecture docs)
  ✓ Task organization (Epics & Stories)
  ✓ Context preservation across development
  ✓ Agent-based workflow for clarity
  ✓ Prevents technical debt and context loss

I can create the complete structure using `/bmad-init`.

Set up BMAD? (y/n)
```

If yes: Run `/bmad-init` slash command
If no: Never mention BMAD again for this project

## BMAD Commands Available

When BMAD is active or being set up, use these slash commands:

- **`/bmad-init`** - Initialize BMAD structure in current project
- **`/bmad-prd`** - Create Product Requirements Document (PM role)
- **`/bmad-arch`** - Create System Architecture (Architect role)
- **`/bmad-story`** - Create detailed story file (Scrum Master role)
- **`/bmad-assess`** - Assess project status and compliance

These commands handle the heavy lifting - you orchestrate and assist.

## Agent Roles

### Planning Phase

**Analyst Agent**
- Role: Project research, market analysis
- Deliverable: `docs/project-brief.md` (optional)
- When: User wants to explore problem space before PRD

**PM Agent**
- Role: Requirements definition
- Deliverable: `docs/prd.md` (required before coding)
- Use: `/bmad-prd` command
- Creates: Functional Requirements (FR-XXX), Non-Functional Requirements (NFR-XXX), Epics

**Architect Agent**
- Role: System design
- Deliverable: `docs/architecture.md` (required before coding)
- Use: `/bmad-arch` command
- Defines: Tech stack, components, data models, APIs, patterns

### Development Phase

**Scrum Master Agent**
- Role: Story creation with full context
- Deliverable: `stories/epic-XXX/story-YYY.md`
- Use: `/bmad-story` command
- Applies: MECE principles, embeds PRD + Architecture context

**Developer Agent**
- Role: Implementation
- Deliverable: Code, tests, documentation
- Process:
  1. Read complete story file
  2. Verify prerequisites
  3. Implement per architecture
  4. Write tests per story requirements
  5. Update story with implementation notes
  6. Mark Definition of Done items

**QA Agent**
- Role: Validation and sign-off
- Deliverable: Test results, story sign-off
- Process:
  1. Run automated tests
  2. Execute manual validation steps
  3. Verify all acceptance criteria
  4. Document findings in story file
  5. Sign off if approved or report issues

## Memory Integration

Use Claude Code's Memory (Knowledge Graph) to preserve context:

### When Creating PRD
```javascript
// Create entities for the project
create_entities([
  {
    name: "ProjectName",
    entityType: "BMAD_Project",
    observations: ["BMAD initialized on 2025-10-24", "MVP deadline: Q1 2026"]
  }
])

// Create entities for each Epic
create_entities([
  {
    name: "Epic-001-UserAuthentication",
    entityType: "BMAD_Epic",
    observations: ["Business value: Enable secure user access", "Priority: Critical"]
  }
])

// Create relations
create_relations([
  {
    from: "Epic-001-UserAuthentication",
    to: "ProjectName",
    relationType: "belongs_to"
  }
])

// Create FR entities
create_entities([
  {
    name: "FR-001",
    entityType: "FunctionalRequirement",
    observations: ["User registration with email/password", "Priority: Critical"]
  }
])

// Link FRs to Epics
create_relations([
  {
    from: "FR-001",
    to: "Epic-001-UserAuthentication",
    relationType: "implements"
  }
])
```

### When Creating Architecture
```javascript
// Store architecture decisions
create_entities([
  {
    name: "TechStack-Backend",
    entityType: "ArchitectureDecision",
    observations: [
      "Language: Python 3.11+",
      "Framework: FastAPI",
      "Rationale: Async performance for NFR-001",
      "Decided: 2025-10-24"
    ]
  }
])

// Link to NFRs
create_relations([
  {
    from: "TechStack-Backend",
    to: "NFR-001-Performance",
    relationType: "addresses"
  }
])
```

### When Creating Stories
```javascript
// Create story entity
create_entities([
  {
    name: "Story-042",
    entityType: "BMAD_Story",
    observations: [
      "Title: User authentication endpoint",
      "Epic: Epic-001",
      "Status: Pending",
      "Estimated: 2 days"
    ]
  }
])

// Link to requirements and architecture
create_relations([
  {from: "Story-042", to: "FR-001", relationType: "implements"},
  {from: "Story-042", to: "Epic-001-UserAuthentication", relationType: "belongs_to"},
  {from: "Story-042", to: "TechStack-Backend", relationType: "uses"}
])
```

### When Implementing
```javascript
// Update story status
add_observations([
  {
    entityName: "Story-042",
    contents: [
      "Status: In Progress",
      "Started: 2025-10-24",
      "Developer notes: Implementing JWT auth"
    ]
  }
])
```

### When Completing
```javascript
// Mark complete and link to code
add_observations([
  {
    entityName: "Story-042",
    contents: [
      "Status: Complete",
      "Completed: 2025-10-24",
      "Files: src/api/auth.py, tests/test_auth.py",
      "Tests: 15/15 passing",
      "QA: Approved by QA Agent"
    ]
  }
])
```

## TodoWrite Integration

Stories should become Todos for tracking:

### When Creating Story
```javascript
// Add to todo list
TodoWrite({
  todos: [
    {
      content: "Implement Story-042: User authentication endpoint",
      status: "pending",
      activeForm: "Implementing Story-042"
    }
  ]
})
```

### When Starting Implementation
```javascript
// Mark in progress
TodoWrite({
  todos: [
    {
      content: "Implement Story-042: User authentication endpoint",
      status: "in_progress",
      activeForm: "Implementing Story-042"
    }
  ]
})
```

### When Complete
```javascript
// Mark completed
TodoWrite({
  todos: [
    {
      content: "Implement Story-042: User authentication endpoint",
      status: "completed",
      activeForm: "Implementing Story-042"
    }
  ]
})
```

## Workflow Enforcement

### Rule 1: No Coding Without Planning
```
If user asks to implement features:
  if docs/prd.md does NOT exist:
    STOP
    Say: "BMAD requires a PRD before coding. This prevents context loss and rework."
    Offer: "Would you like me to create the PRD now? (`/bmad-prd`)"

  if docs/architecture.md does NOT exist:
    STOP
    Say: "BMAD requires Architecture before coding. This ensures consistent technical decisions."
    Offer: "Would you like me to create the Architecture now? (`/bmad-arch`)"
```

### Rule 2: Architecture is Authority
```
When making ANY technical decision:
  1. Check docs/architecture.md FIRST
  2. Follow what it specifies (language, framework, patterns)
  3. NEVER contradict architecture without user approval
  4. If architecture doesn't address something, propose addition to architecture

When implementing:
  - Use exact tech stack from architecture
  - Follow patterns defined in architecture
  - Reference architecture sections in code comments
  - Match directory structure to architecture
```

### Rule 3: Story Files are Source of Truth
```
When implementing a story:
  1. Read COMPLETE story file before any code
  2. Verify prerequisites are complete
  3. Implement exactly per "Implementation Details" section
  4. Write tests per "Testing Requirements" section
  5. Update story file with "Implementation Notes"
  6. Check off all "Definition of Done" items
  7. Add to Memory: Story status and completion

NEVER make assumptions - story file has all context.
```

### Rule 4: Memory-First Development
```
Before starting work:
  - Check Memory for existing entities
  - Load PRD requirements, Architecture decisions
  - Understand Story relationships

During work:
  - Update Memory with progress
  - Link code to requirements
  - Store important decisions

After completing:
  - Mark entities complete
  - Update relationships
  - Enable future context preservation
```

## Assessment

Use `/bmad-assess` to check:
- ✓ Structure presence
- ✓ Planning document quality (PRD, Architecture)
- ✓ Story completeness and context
- ✓ Code alignment with architecture
- ✓ Test coverage
- ✓ Memory graph health

Provide actionable recommendations.

## Git Integration

### Commit Messages
```
<type>(Story-XXX): <description>

- Detail about change
- Another detail

Implements acceptance criteria 1, 2 from Story-XXX
Addresses FR-YYY from PRD
```

### Branch Names
```
story/042-user-authentication
feature/epic-001-user-management
```

### PR Descriptions
Link to story file and acceptance criteria.

## Best Practices

1. **Always check for BMAD first** - Automatic, silent detection
2. **Suggest BMAD when beneficial** - Use scoring system
3. **Use slash commands** - Don't reinvent, use `/bmad-*` commands
4. **Leverage Memory** - Store and retrieve context via Knowledge Graph
5. **Track with Todos** - Stories → Todos for visibility
6. **Architecture is law** - Never contradict without approval
7. **Context in stories** - Embed everything Developer needs
8. **Update as you go** - Keep story files and Memory current
9. **Assess regularly** - Use `/bmad-assess` to check health

## When NOT to Use BMAD

Don't suggest BMAD for:
- Quick scripts (< 5 files)
- Simple bug fixes
- Exploratory prototypes (unless user wants structure)
- Projects where user prefers ad-hoc development

## Integration with Other Skills

BMAD works WITH other Claude Code skills:

- **Security Skill**: Referenced in Architecture (NFR-002 typically)
- **Python/JS Skill**: Applied per Architecture tech stack choice
- **Testing Skill**: Enforced via story Testing Requirements
- **DevOps Skill**: Deployment architecture section
- **Git Skill**: BMAD-specific workflow (story/XXX branches)

Load skills based on Architecture decisions.

## Quick Reference

**Detect BMAD:**
```bash
Check: bmad-agent/ OR .bmad-initialized OR docs/prd.md
```

**Suggest BMAD:**
```
Score ≥ 3 → Suggest
Score < 3 → Work normally
```

**Commands:**
```
/bmad-init    # Initialize structure
/bmad-prd     # Create PRD (PM role)
/bmad-arch    # Create Architecture (Architect role)
/bmad-story   # Create story (SM role)
/bmad-assess  # Check compliance
```

**Memory:**
```javascript
create_entities()   // Store requirements, stories, decisions
create_relations()  // Link everything together
add_observations()  // Update progress
open_nodes()        // Retrieve context
```

**Workflow:**
```
Planning: PRD → Architecture
Development: Stories → Implementation → QA
Always: Update Memory + Story files
```

---

**BMAD transforms AI-assisted development from chaotic prompting to structured engineering.**

Use it wisely, enforce it consistently, and watch context loss disappear.
