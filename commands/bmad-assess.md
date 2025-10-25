# Assess BMAD Project Status

You are being asked to assess the current BMAD project's compliance and status.

## Your Task

Perform a comprehensive assessment of the BMAD project and provide a detailed report.

### 1. BMAD Structure Check

Check for presence and quality of:
- `bmad-agent/` directory and agent files
- `.bmad-initialized` marker
- `docs/prd.md` - Product Requirements Document
- `docs/architecture.md` - System Architecture
- `stories/` directory and story files
- BMAD configuration files

### 2. Planning Document Assessment

**PRD Quality:**
- [ ] Has Functional Requirements (FR-XXX format)
- [ ] Has Non-Functional Requirements (NFR-XXX format)
- [ ] Has Epics with business value
- [ ] Requirements are specific and testable
- [ ] User personas defined
- [ ] Success metrics defined

**Architecture Quality:**
- [ ] System components defined
- [ ] Technology stack documented and justified
- [ ] Data models defined
- [ ] API contracts specified
- [ ] Security measures documented
- [ ] Scalability addressed
- [ ] NFRs from PRD addressed

### 3. Story File Assessment

For each story in `stories/`:
- [ ] Has all required sections
- [ ] References PRD requirements (FR-XXX)
- [ ] References Architecture patterns
- [ ] Has specific acceptance criteria
- [ ] Has implementation details
- [ ] Has testing requirements
- [ ] Has Definition of Done
- [ ] Prerequisites documented

Calculate:
- Total stories
- Stories complete (QA signed off)
- Stories in progress (Developer notes present)
- Stories pending (no implementation notes)

### 4. Code Alignment Check

Verify implementation aligns with architecture:
- Check if code structure matches architecture document
- Verify technology choices match architecture
- Look for story references in git commits
- Check test coverage

### 5. Memory System Check

Check Knowledge Graph for:
- Project entity exists
- PRD requirements stored as entities
- Architecture decisions stored
- Story relationships tracked

### 6. Generate Report

Provide a comprehensive report with:

```
# BMAD Project Assessment Report

## Overall Status
- BMAD Compliance: [Score 0-100]
- Phase: [Planning / Development / Mixed]
- Health: [Excellent / Good / Needs Attention / Critical]

## Structure Check
✓ bmad-agent/ present
✓ Planning documents exist
⚠ X stories missing prerequisites
✗ No configuration file

## Planning Documents
### PRD Quality: [Score]/10
- Strengths: [What's good]
- Issues: [What needs improvement]

### Architecture Quality: [Score]/10
- Strengths: [What's good]
- Issues: [What needs improvement]

## Story Progress
- Total: X stories
- Complete: Y stories (Z%)
- In Progress: N stories
- Pending: M stories

### Epic Breakdown
Epic-001: User Authentication
  - Story-001: ✓ Complete
  - Story-002: ⧗ In Progress
  - Story-003: ☐ Pending

## Code Alignment
- Structure matches architecture: [Yes/No/Partial]
- Test coverage: X%
- Git commits reference stories: [Yes/No/Sometimes]

## Recommendations
1. [Priority] [Specific recommendation]
2. [Priority] [Specific recommendation]

## Next Steps
- [Immediate action needed]
- [Follow-up tasks]
```

### 7. Use Memory

Store assessment results:
- Create assessment entity with date
- Add observations about project health
- Link to project entity

### 8. Offer Actions

Based on findings, offer to:
- Create missing documents
- Fix incomplete stories
- Update architecture
- Generate missing tests
- Create new stories from PRD

## Important

- Be thorough but constructive
- Provide specific, actionable feedback
- Use color coding (✓ ⚠ ✗) for clarity
- Quantify everything possible
- Offer to help fix issues immediately
