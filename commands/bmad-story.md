# Create BMAD Story

You are being asked to create a new BMAD story file with full context.

## Your Task - Scrum Master Role

Act as the Scrum Master agent to create a hyper-detailed story file.

### 1. Verify Prerequisites

Before creating a story:
- Check `docs/prd.md` exists and read it
- Check `docs/architecture.md` exists and read it
- If either missing, inform user they must complete Planning Phase first

### 2. Gather Information

Ask the user:
- Which Epic is this story for? (or create new epic)
- What should this story accomplish? (objective)
- Are there any prerequisite stories?

### 3. Determine Story Number

- List existing stories in `stories/epic-XXX/`
- Determine next story number (e.g., story-042)

### 4. Create Story File

Create `stories/epic-XXX/story-YYY.md` with ALL sections:

```markdown
# Story: [Clear, Descriptive Title]

## Epic Reference
Epic-XXX: [Epic Name]

## Story ID
Story-YYY

## Objective
[One paragraph describing what this story accomplishes]

## Context

### Related PRD Sections
- **FR-XXX:** [Quote the relevant functional requirement from PRD]
- **NFR-YYY:** [Quote relevant non-functional requirements]

### Architecture References
- **Component:** [Which component from architecture.md]
- **Pattern:** [Architectural pattern to follow from architecture.md]
- **Dependencies:** [Technical dependencies]

### Prerequisites
- **Story-AAA:** [Description] - Status: ✓ Complete
[Or mark as ☐ Pending or ⧗ In Progress]

## Acceptance Criteria

1. [Specific, testable criterion based on PRD]
2. [Another criterion]
3. [Another criterion]
[Make these VERY specific and verifiable]

## Implementation Details

### Approach
[Step-by-step implementation approach based on architecture]

1. **Step 1:** [Detailed step]
2. **Step 2:** [Next step]

### Files to Modify/Create
- `path/to/file.py`: [What to do in this file]
- `tests/test_file.py`: [Tests to create]

### Technical Considerations
- **Performance:** [From NFRs]
- **Security:** [Security considerations]
- **Edge Cases:** [Important edge cases]

### Code Example
```[language]
# Example showing the pattern to follow
```

## Testing Requirements

### Unit Tests
- **Test 1:** [Specific test case]
- **Test 2:** [Another test]

### Integration Tests
- **Scenario 1:** [Integration to test]

### Manual Validation Steps
1. [Manual step to verify]
2. [Another step]

## Definition of Done
- [ ] Code implemented following architecture
- [ ] Unit tests written and passing (80%+ coverage)
- [ ] Integration tests written and passing
- [ ] Code reviewed for quality
- [ ] Documentation updated
- [ ] Story file updated with implementation notes
- [ ] All acceptance criteria verified

## Implementation Notes
[Developer fills this during implementation]

## QA Validation
[QA fills this during testing]
```

### 5. Apply MECE Principles

Ensure this story is:
- **Mutually Exclusive:** No overlap with other stories
- **Collectively Exhaustive:** Covers its scope completely
- **Atomic:** Can be implemented independently in 1-3 days

### 6. Embed Full Context

Critical: Include enough context that Developer agent can implement without asking questions:
- Quote specific PRD requirements
- Reference exact Architecture sections
- Provide code examples from architecture
- List all prerequisites clearly
- Define acceptance criteria precisely

### 7. Create Memory Entities

Use Memory to track:
- Create story entity
- Link to epic entity
- Link to PRD requirements (FR-XXX entities)
- Link to architecture decisions
- Add prerequisite relationships

### 8. Create Todo

Use TodoWrite to add:
- "Implement Story-YYY: [Title] (Developer role)"
- Mark prerequisites as dependencies

### 9. Confirm with User

Show the story file path and summary:
```
✓ Story created: stories/epic-003/story-042.md

Story-042: User Authentication Endpoint
- Epic: User Management System
- Prerequisites: Story-038 (User Model) ✓ Complete
- Acceptance Criteria: 4 criteria defined
- Estimated: 2 days

Ready for Developer to implement!
```

Offer to:
- Create more stories for this epic
- Transition to Developer role to implement
- Create epic planning breakdown

## Important

- Be extremely detailed in implementation approach
- Quote PRD and Architecture verbatim where relevant
- Provide concrete code examples
- Anticipate edge cases
- Make acceptance criteria testable
- This story file is THE source of truth for implementation
