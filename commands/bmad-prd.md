# Create Product Requirements Document

You are being asked to create a comprehensive PRD for this project.

## Your Task - PM Agent Role

Act as the PM (Product Manager) agent to create a detailed Product Requirements Document.

### 1. Check Prerequisites

- Look for `docs/project-brief.md` (optional but helpful)
- If exists, read it thoroughly to understand the problem and opportunity

### 2. Gather Information

Have a conversation with the user to understand:

**Project Vision:**
- What is this product/project?
- What problem does it solve?
- Who are the users?
- What's the business value?

**Functional Needs:**
- What capabilities must the system have?
- What user journeys are critical?
- What features are must-have vs nice-to-have?

**Non-Functional Needs:**
- Performance requirements (response time, throughput)
- Security requirements
- Scalability needs
- Reliability targets
- Usability standards

### 3. Create PRD Structure

Create `docs/prd.md` with comprehensive sections:

```markdown
# Product Requirements Document (PRD)

> **Product:** [Product Name]
> **Created by:** PM Agent
> **Date:** [Today's date]
> **Status:** Draft
> **Version:** 1.0

## Executive Summary
[2-3 paragraphs: what this is, why it matters, key goals]

## Product Vision

### Mission
[The overarching mission]

### Goals
1. [Primary goal]
2. [Secondary goal]
3. [Tertiary goal]

### Success Metrics
| Metric | Target | Measurement |
|--------|--------|-------------|
| [Metric] | [Value] | [How measured] |

## User Personas

### Persona 1: [Role/Name]
- **Background:** [Context]
- **Goals:** [What they want]
- **Pain Points:** [Current frustrations]
- **Technical Proficiency:** [Skill level]

[Repeat for each persona]

## Functional Requirements (FRs)

### FR-001: [Requirement Title]
**Priority:** Critical / High / Medium / Low
**User Story:** As a [user], I want [capability] so that [benefit]
**Description:** [Detailed description]
**Acceptance Criteria:**
- [Criterion 1]
- [Criterion 2]

### FR-002: [Next Requirement]
[Continue numbering sequentially]

[... more FRs ...]

## Non-Functional Requirements (NFRs)

### NFR-001: Performance
**Description:** [Performance requirements]
**Criteria:**
- API response time: < 200ms for 95th percentile
- Page load time: < 2 seconds
- [More metrics]

### NFR-002: Security
**Description:** [Security requirements]
**Criteria:**
- [Specific security measures]

### NFR-003: Scalability
**Description:** [Scalability requirements]

### NFR-004: Reliability
**Description:** [Reliability requirements]
**Target:** 99.9% uptime

### NFR-005: Usability
**Description:** [Usability requirements]

[Add more NFRs as needed]

## Epics

### Epic-001: [Epic Name]
**Business Value:** [Why this matters]
**Priority:** Critical / High / Medium / Low
**Target Release:** [Version or timeframe]

**Description:** [Detailed epic description]

**Related Requirements:**
- FR-001: [Title]
- FR-003: [Title]
- NFR-001: [Title]

**User Stories:**
1. As a [user], I want [capability] so that [benefit]
2. [More stories]

**Success Criteria:**
- [How we know this Epic succeeded]

---

### Epic-002: [Next Epic]
[Same structure]

[... more Epics ...]

## MVP Definition

### MVP Features (Must Have)
- Epic-001: [Epic name]
- Epic-002: [Epic name]
- FR-XXX, FR-YYY (if standalone)

### Post-MVP (Future)
- Epic-XXX: [Future epic]
- [Future features]

## Dependencies
- [External or internal dependencies]

## Constraints
- [Technical, business, timeline constraints]

## Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| [Risk] | H/M/L | H/M/L | [Strategy] |

## Appendix

### Glossary
- **Term:** Definition

### References
- [Links to research, user studies, etc.]
```

### 4. Apply Best Practices

- Number all FRs sequentially (FR-001, FR-002, ...)
- Number all NFRs sequentially (NFR-001, NFR-002, ...)
- Make requirements SMART: Specific, Measurable, Achievable, Relevant, Time-bound
- Keep requirements solution-agnostic (describe WHAT, not HOW)
- Each Epic should deliver independent user value
- Group related FRs into Epics logically

### 5. Create Memory Entities

Store in Knowledge Graph:
- Create entity for the project
- Create entities for each Epic (Epic-001, Epic-002)
- Create entities for critical FRs
- Create entities for NFRs
- Link FRs to their Epics
- Add observations about priorities and dependencies

### 6. Create Todos

Use TodoWrite for next steps:
- "Create docs/architecture.md (Architect role)"
- "Review PRD with stakeholders"

### 7. Explain Next Steps

```
✓ PRD created: docs/prd.md

Summary:
- X Functional Requirements (FR-001 to FR-XXX)
- Y Non-Functional Requirements (NFR-001 to NFR-YYY)
- Z Epics defined

Next Steps:
1. Architect role: Create docs/architecture.md
   - Design system to meet these requirements
   - Choose tech stack addressing NFRs
   - Define data models and APIs

Would you like me to transition to Architect role now?
```

### 8. Offer Assistance

Ask if user wants to:
- Review and refine any sections
- Add more Epics or requirements
- Move to Architect role to create architecture
- Create project brief first (if not done)

## Important

- Be thorough but pragmatic
- Focus on user value and business outcomes
- Make every requirement testable and verifiable
- Avoid technical implementation details (that's Architect's job)
- Ensure consistency across all sections
- This PRD is the foundation for ALL development work
