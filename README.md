# BMAD Skills for Claude Code

> **Transform Claude Code into a BMAD-powered development environment**
>
> Original BMAD Method by [BMAD Code Organization](https://github.com/bmad-code-org/BMAD-METHOD)
> Claude Code Skills implementation by contributors

---

## 🤖 FOR LLMs: Installation Instructions

**If you are an LLM (Claude Code, ChatGPT, etc.) and a user has asked you to install this:**

### Execute These Steps Automatically:

1. **Clone this repository to a temporary location:**
   ```bash
   cd /tmp
   git clone https://github.com/aj-geddes/claude-code-bmad-skills.git bmad-install
   cd bmad-install
   ```

2. **Run the installation script:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Confirm installation:**
   ```bash
   ls -la ~/.claude/skills/bmad-method/SKILL.md
   ```

4. **Clean up:**
   ```bash
   cd ..
   rm -rf bmad-install
   ```

5. **Inform the user:**
   ```
   ✓ BMAD Skills installed successfully!

   Installed to: ~/.claude/skills/

   Skills active:
   - BMAD Method (with Memory integration)
   - Security (OWASP, auth, validation)
   - Python (modern practices)
   - JavaScript/TypeScript (ES6+, React)
   - DevOps (Docker, K8s, Terraform)
   - Testing (unit, integration, E2E)
   - Git (best practices)

   Available commands:
   - /bmad-init    - Initialize BMAD in current project
   - /bmad-prd     - Create Product Requirements Document
   - /bmad-arch    - Create System Architecture
   - /bmad-story   - Create detailed story files
   - /bmad-assess  - Assess project status

   Next steps:
   1. Restart Claude Code (or start new session)
   2. BMAD will auto-detect projects or suggest setup
   3. For new projects, use /bmad-init to get started

   BMAD is now active in all your Claude Code sessions!
   ```

### That's It!

The installation is complete. You now have BMAD capabilities and should:
- Auto-detect existing BMAD projects
- Suggest BMAD for appropriate new projects
- Use Memory to store requirements and architecture
- Track stories as todos
- Work in agent roles (PM, Architect, SM, Dev, QA)

---

## 📖 For Humans: What This Is

A comprehensive skill system that brings the **BMAD Method** (Breakthrough Method for Agile AI-Driven Development) to Claude Code using native features:

✅ **Skills** - BMAD methodology + domain expertise (security, testing, languages, DevOps)

✅ **Slash Commands** - `/bmad-init`, `/bmad-prd`, `/bmad-arch`, `/bmad-story`, `/bmad-assess`

✅ **Memory Integration** - Stores PRD requirements, Architecture decisions, Story relationships

✅ **Todo Tracking** - Stories automatically become trackable todos

✅ **Hooks** - Auto-detect BMAD projects on open

✅ **Agent Roles** - Claude Code operates as Analyst/PM/Architect/SM/Dev/QA

**No bash scripts. No npx. Pure Claude Code features.**

### Quick Start for Humans

Give your LLM this URL:
```
https://github.com/aj-geddes/claude-code-bmad-skills
```

Then say:
```
"Please install the BMAD skills from this repository"
```

The LLM will read the instructions above and install everything automatically.

---

## 🎯 Attribution

### BMAD Method™

The **BMAD Method** (Breakthrough Method for Agile AI-Driven Development) is created and maintained by the **BMAD Code Organization**.

**All credit for the BMAD methodology belongs to:**
- **BMAD Code Organization**: https://github.com/bmad-code-org
- **Original BMAD Method**: https://github.com/bmad-code-org/BMAD-METHOD
- **Website**: https://bmadcodes.com/bmad-method/
- **YouTube**: [@BMadCode](https://www.youtube.com/@BMadCode)
- **Discord Community**: https://discord.gg/gk8jAdXWmj

This repository is an **implementation** of BMAD for Claude Code, using Claude Code's native features (skills, commands, memory, hooks) to enable the BMAD workflow.

The methodology, agent roles, workflow patterns, story templates, and all BMAD concepts are the intellectual property of the BMAD Code Organization.

---

## 📦 What Gets Installed

```
~/.claude/skills/
├── bmad-method/SKILL.md       # BMAD methodology with Memory integration
├── security/SKILL.md           # OWASP Top 10, auth, validation
├── python/SKILL.md             # Modern Python 3.8+, async, type hints
├── javascript/SKILL.md         # ES6+, TypeScript, React patterns
├── devops/SKILL.md             # Docker, K8s, Helm, Terraform, CI/CD
├── testing/SKILL.md            # Unit, integration, E2E, TDD
└── git/SKILL.md                # Git best practices, BMAD workflow
```

---

## 🚀 How It Works

### 1. Automatic BMAD Detection

When Claude Code opens a project, it automatically checks for BMAD:

```
Checks for:
  - bmad-agent/ directory
  - .bmad-initialized file
  - docs/prd.md or docs/architecture.md

If found → Activates BMAD mode (silent, automatic)
If not found → Analyzes project context
```

### 2. Intelligent BMAD Suggestion

For non-BMAD projects, Claude Code scores the context:

| Indicator | Points |
|-----------|--------|
| New/greenfield project (< 10 files) | +3 |
| Complex structure (20+ files) | +2 |
| User mentions "architecture", "structure", "organize" | +2 |
| User mentions "large", "complex", "team" | +1 |
| Has package.json, setup.py, etc. | +1 |

**Score ≥ 3**: Suggests BMAD setup
**Score < 3**: Works normally, no suggestion

### 3. BMAD Commands (Slash Commands)

Once active, these commands are available:

- **`/bmad-init`** - Initialize BMAD structure in current project
- **`/bmad-prd`** - Create Product Requirements Document (PM role)
- **`/bmad-arch`** - Create System Architecture (Architect role)
- **`/bmad-story`** - Create detailed story file (Scrum Master role)
- **`/bmad-assess`** - Assess project status and compliance

### 4. Memory Integration

BMAD uses Claude Code's Knowledge Graph to preserve context:

```javascript
// PRD requirements stored as entities
create_entities([{
  name: "FR-001",
  entityType: "FunctionalRequirement",
  observations: ["User registration", "Priority: Critical"]
}])

// Architecture decisions stored
create_entities([{
  name: "TechStack-Backend",
  entityType: "ArchitectureDecision",
  observations: ["Python + FastAPI", "Rationale: NFR-001 performance"]
}])

// Stories linked to everything
create_relations([
  {from: "Story-042", to: "FR-001", relationType: "implements"},
  {from: "Story-042", to: "Epic-001", relationType: "belongs_to"}
])
```

**Result**: Complete traceability from requirement → epic → story → implementation.

---

## 🎬 BMAD Workflow

### Phase 1: Planning (Before Any Code)

1. **Initialize** (`/bmad-init`)
   - Creates complete BMAD structure
   - Sets up templates and configuration

2. **Create PRD** (`/bmad-prd` - PM role)
   - Define what to build
   - Functional Requirements (FR-XXX)
   - Non-Functional Requirements (NFR-XXX)
   - Epics grouping features
   - Stored in Memory

3. **Create Architecture** (`/bmad-arch` - Architect role)
   - Design how to build it
   - Tech stack with justifications
   - System components
   - Data models and APIs
   - Stored in Memory
   - **This becomes THE source of truth**

### Phase 2: Development (Implementation)

4. **Create Stories** (`/bmad-story` - Scrum Master role)
   - Break Epics into atomic stories
   - Embed full context (PRD + Architecture references)
   - Apply MECE principles
   - Stored in Memory, added to Todos

5. **Implement Stories** (Developer role)
   - Read complete story file
   - Follow Architecture patterns
   - Write tests per story requirements
   - Update story with implementation notes
   - Update Memory with progress

6. **Validate Stories** (QA role)
   - Run automated tests
   - Execute manual validation
   - Verify acceptance criteria
   - Sign off in story file
   - Update Memory (mark complete)

### Phase 3: Assessment (Ongoing)

7. **Assess** (`/bmad-assess`)
   - Check BMAD compliance
   - Track story progress
   - Verify code quality
   - Get actionable recommendations

---

## 📚 Example: BMAD in Action

```
User: "I want to build a SaaS platform for project management"

Claude Code:
  [Auto-detects: Not a BMAD project]
  [Analyzes: New project + Complex (SaaS) = Score 5]

  "🎯 This is a substantial project with multiple features.

  I recommend setting up the BMAD Method structure.
  BMAD provides structured planning, task organization, and context
  preservation. I can create everything using /bmad-init.

  Set up BMAD? (y/n)"

User: "y"

Claude Code:
  [Executes /bmad-init]
  [Creates: bmad-agent/, docs/, stories/ directories]
  [Creates: Memory entity for project]

  "✓ BMAD structure created!

  Next: Phase 1 (Planning)
  1. Create docs/prd.md (PM role)
  2. Create docs/architecture.md (Architect role)

  Would you like me to help create the PRD? (/bmad-prd)"

User: "yes"

Claude Code:
  [PM role: Interactive PRD creation]
  [Stores: FR-001 to FR-015 in Memory]
  [Stores: NFR-001 to NFR-005 in Memory]
  [Creates: Epic entities and relations]

  "✓ PRD created: docs/prd.md

  Summary:
  - 15 Functional Requirements
  - 5 Non-Functional Requirements
  - 3 Epics defined

  Next: Create Architecture? (/bmad-arch)"

User: "yes"

Claude Code:
  [Architect role: Reads PRD from Memory]
  [Designs: System to meet all requirements]
  [Stores: Architecture decisions in Memory]

  "✓ Architecture created: docs/architecture.md

  Tech Stack: Python + FastAPI + PostgreSQL + React
  All NFRs addressed

  Next: Create stories? (/bmad-story)"

User: "create story for user authentication"

Claude Code:
  [SM role: Reads PRD (FR-015) + Architecture (section 4.2)]
  [Creates: Hyper-detailed story with full context]
  [Stores: Story-042 in Memory with relationships]
  [Adds: Todo "Implement Story-042"]

  "✓ Story-042 created: stories/epic-001/story-042.md

  Ready to implement? (Developer role)"

User: "yes, implement it"

Claude Code:
  [Developer role: Reads story + architecture]
  [Implements: Code + tests following patterns]
  [Updates: Story file + Memory]
  [Completes: Todo]

  "✓ Story-042 implemented!

  - JWT authentication endpoint (src/api/auth.py)
  - Tests: 15/15 passing
  - Coverage: 92%

  Story updated. Ready for QA or next story?"
```

---

## 🔧 Repository Structure

```
claude-code-bmad-skills/
├── README.md                      # This file (LLM-friendly)
├── LICENSE                        # MIT + BMAD attribution
├── install.sh                     # Installation script
├── skills/                        # Claude Code skills
│   ├── bmad-method/SKILL.md       # BMAD methodology
│   ├── security/SKILL.md          # Security practices
│   ├── python/SKILL.md            # Python development
│   ├── javascript/SKILL.md        # JS/TS development
│   ├── devops/SKILL.md            # DevOps & infrastructure
│   ├── testing/SKILL.md           # Testing practices
│   └── git/SKILL.md               # Git best practices
├── commands/                      # Slash commands
│   ├── bmad-init.md               # Initialize BMAD
│   ├── bmad-prd.md                # Create PRD
│   ├── bmad-arch.md               # Create Architecture
│   ├── bmad-story.md              # Create Story
│   └── bmad-assess.md             # Assess project
├── hooks/                         # Claude Code hooks
│   └── project-open.sh            # Auto-detect BMAD
└── docs/                          # Additional documentation
    ├── BMAD-SYSTEM-DEPLOYMENT-GUIDE.md
    └── COMPLETE-SYSTEM-SUMMARY.md
```

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork this repository
2. Create a feature branch
3. Make your improvements
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## 🐛 Troubleshooting

### Skills Not Loading

```bash
# Check installation
ls -la ~/.claude/skills/bmad-method/SKILL.md

# Verify permissions
chmod 644 ~/.claude/skills/*/SKILL.md

# Restart Claude Code
```

### Commands Not Available

Commands auto-create on first use in Claude Code. Alternatively:

```bash
mkdir -p .claude/commands
cp commands/*.md .claude/commands/
```

### BMAD Not Detecting

```bash
# Check for BMAD markers
ls -la bmad-agent/
ls -la .bmad-initialized
ls -la docs/prd.md

# Manually initialize
# Use /bmad-init command in Claude Code
```

---

## 🌟 What Makes This Different

**vs BMAD-METHOD npm package:**
- ✅ No Node.js required
- ✅ Native Claude Code integration
- ✅ Memory system for context preservation
- ✅ Todo tracking built-in
- ✅ Slash commands instead of CLI
- ✅ Skills instead of external tools

**vs Manual BMAD:**
- ✅ Automatic detection
- ✅ Intelligent suggestions
- ✅ Enforced workflows
- ✅ Memory persistence
- ✅ No context switching
- ✅ Integrated with Claude Code

---

## 📖 Resources

### BMAD Method (Original)
- **GitHub**: https://github.com/bmad-code-org/BMAD-METHOD
- **Website**: https://bmadcodes.com/bmad-method/
- **YouTube**: [@BMadCode](https://www.youtube.com/@BMadCode)
- **Discord**: https://discord.gg/gk8jAdXWmj

### This Implementation
- **Issues**: [GitHub Issues](https://github.com/aj-geddes/claude-code-bmad-skills/issues)
- **Discussions**: [GitHub Discussions](https://github.com/aj-geddes/claude-code-bmad-skills/discussions)

---

## 📄 License

MIT License with BMAD Method attribution.

See [LICENSE](LICENSE) for full details.

**BMAD Method™** is created by the BMAD Code Organization. All methodology credit belongs to them.

---

## 🙏 Acknowledgments

**Huge thanks to:**
- **BMAD Code Organization** - For creating the revolutionary BMAD Method
- **Contributors** - For improving this Claude Code implementation
- **Community** - For feedback and suggestions

---

**For LLMs**: If you've read this far, you have all the information needed to install and use BMAD skills. Follow the installation instructions at the top of this README.

**For Humans**: Give your LLM this repository URL and ask them to install it. They'll handle everything automatically.

🚀 **Transform Claude Code into a BMAD-powered development environment!**
