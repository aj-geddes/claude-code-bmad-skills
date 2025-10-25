# Git Excellence Skill

## Overview

Best practices for Git version control, with special integration for BMAD Method projects.

## Branch Strategies

### Standard Projects

**Main Branches:**
- `main` / `master` - Production-ready code
- `develop` - Integration branch (if using Git Flow)

**Feature Branches:**
```bash
# Format: feature/description
git checkout -b feature/user-authentication
git checkout -b feature/add-payment-processing
```

**Bug Fix Branches:**
```bash
# Format: bugfix/description
git checkout -b bugfix/fix-login-error
git checkout -b bugfix/resolve-memory-leak
```

**Hotfix Branches:**
```bash
# Format: hotfix/description
git checkout -b hotfix/security-patch
```

### BMAD Projects

**Story Branches:**
```bash
# Format: story/XXX-description
git checkout -b story/042-user-authentication
git checkout -b story/015-database-schema
```

**Epic Branches** (if needed):
```bash
# Format: epic/XXX-description
git checkout -b epic/001-user-management
```

## Commit Discipline

### Conventional Commits (Standard Projects)

```bash
# Format: <type>(<scope>): <description>

git commit -m "feat(auth): add JWT token generation"
git commit -m "fix(api): resolve null pointer in user endpoint"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(database): optimize query performance"
git commit -m "test(auth): add integration tests for login"
git commit -m "chore(deps): update dependencies"
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes

### BMAD Commit Format

```bash
# Format: <type>(Story-XXX): <description>

git commit -m "feat(Story-042): implement JWT authentication endpoint"
git commit -m "test(Story-042): add unit tests for auth service"
git commit -m "fix(Story-038): correct user model validation"

# With detailed body
git commit -m "feat(Story-042): implement JWT authentication endpoint

- Add JWT token generation with 1-hour expiration
- Implement refresh token mechanism
- Add rate limiting (5 attempts per minute)
- Include comprehensive error handling

Implements acceptance criteria 1, 2, 3 from Story-042
Addresses FR-015 from PRD
Follows architecture pattern in architecture.md section 4.2"
```

## Commit Best Practices

### Make Atomic Commits

**Good:**
```bash
# One logical change per commit
git add src/auth/jwt.py tests/test_jwt.py
git commit -m "feat(auth): add JWT token generation"

git add src/auth/refresh.py tests/test_refresh.py
git commit -m "feat(auth): add token refresh mechanism"
```

**Bad:**
```bash
# Multiple unrelated changes
git add src/auth/*.py src/api/*.py src/models/*.py
git commit -m "add auth and other stuff"
```

### Write Clear Commit Messages

**Good:**
```bash
"fix(api): resolve race condition in concurrent user updates

The previous implementation didn't handle concurrent updates properly,
leading to data inconsistency. This fix introduces optimistic locking
using version fields."
```

**Bad:**
```bash
"fix stuff"
"wip"
"update code"
```

### Commit Often

```bash
# Commit after completing each logical unit of work
git commit -m "feat(auth): add password hashing"
git commit -m "feat(auth): add password validation"
git commit -m "test(auth): add password security tests"
```

## Git Workflow

### Standard Feature Workflow

```bash
# 1. Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/add-user-profile

# 2. Make changes and commit
git add src/profile.py
git commit -m "feat(profile): add user profile model"

git add tests/test_profile.py
git commit -m "test(profile): add profile tests"

# 3. Push to remote
git push -u origin feature/add-user-profile

# 4. Create PR on GitHub/GitLab
# 5. After review and approval, merge
# 6. Delete feature branch
git checkout main
git pull origin main
git branch -d feature/add-user-profile
```

### BMAD Story Workflow

```bash
# 1. Read story file first
cat stories/epic-001/story-042.md

# 2. Create story branch
git checkout main
git pull origin main
git checkout -b story/042-user-authentication

# 3. Implement with frequent commits
git commit -m "feat(Story-042): implement JWT service"
git commit -m "feat(Story-042): add auth endpoints"
git commit -m "test(Story-042): add comprehensive tests"
git commit -m "docs(Story-042): update API documentation"

# 4. Update story file
# Edit stories/epic-001/story-042.md with implementation notes
git add stories/epic-001/story-042.md
git commit -m "docs(Story-042): update story with implementation notes"

# 5. Push and create PR
git push -u origin story/042-user-authentication

# 6. Reference story in PR description
# Title: Story-042: User Authentication Endpoint
# Body: Link to stories/epic-001/story-042.md
```

## History Management

### Interactive Rebase (Clean Up Before Pushing)

```bash
# View commit history
git log --oneline

# Rebase last 3 commits (before pushing)
git rebase -i HEAD~3

# In editor:
# pick abc1234 feat(auth): add JWT service
# squash def5678 fix(auth): fix typo
# squash ghi9012 fix(auth): update tests

# Result: One clean commit with all changes
```

### Amending Last Commit

```bash
# Forgot to add a file
git add forgotten-file.py
git commit --amend --no-edit

# Fix commit message
git commit --amend -m "feat(auth): add JWT token generation (corrected message)"
```

**⚠️ WARNING:** Never amend or rebase commits that have been pushed and others may have pulled!

### Recovering from Mistakes

```bash
# Undo last commit but keep changes
git reset --soft HEAD~1

# Undo last commit and discard changes (careful!)
git reset --hard HEAD~1

# Recover from bad reset
git reflog
git reset --hard HEAD@{2}  # Jump to previous state
```

## Merge vs Rebase

### When to Merge

```bash
# Merge feature branch into main (preserves history)
git checkout main
git merge feature/add-user-profile
```

**Use merge when:**
- Integrating feature branches into main
- You want to preserve complete history
- Working on shared branches

### When to Rebase

```bash
# Rebase feature branch onto updated main (linear history)
git checkout feature/add-user-profile
git rebase main
```

**Use rebase when:**
- Updating your feature branch with main's changes
- Cleaning up local commits before pushing
- You want linear history

**⚠️ Golden Rule:** Never rebase public branches others are using!

## Conflict Resolution

```bash
# When conflicts occur during merge/rebase
git status  # See conflicted files

# Edit conflicted files, look for:
# <<<<<<< HEAD
# Your changes
# =======
# Their changes
# >>>>>>> branch-name

# After resolving conflicts
git add resolved-file.py
git commit  # For merge
# OR
git rebase --continue  # For rebase

# Abort if needed
git merge --abort
# OR
git rebase --abort
```

## Stashing

```bash
# Save uncommitted changes temporarily
git stash

# List stashes
git stash list

# Apply stash
git stash apply  # Keep stash
git stash pop    # Apply and drop stash

# Stash with message
git stash save "WIP: implementing auth endpoint"

# Apply specific stash
git stash apply stash@{2}
```

## Useful Git Commands

### Viewing History

```bash
# Pretty log
git log --oneline --graph --decorate --all

# Show changes in commit
git show abc1234

# Show file history
git log --follow -- path/to/file.py

# Search commits
git log --grep="authentication"
git log -S"JWT"  # Search code changes
```

### Viewing Changes

```bash
# Unstaged changes
git diff

# Staged changes
git diff --staged

# Changes between branches
git diff main..feature/auth

# Changes in specific file
git diff HEAD~1 src/auth.py
```

### Undoing Changes

```bash
# Discard unstaged changes in file
git checkout -- file.py

# Unstage file
git restore --staged file.py

# Discard all uncommitted changes (careful!)
git reset --hard HEAD
```

## Git Configuration

### User Setup

```bash
# Set name and email
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Set default editor
git config --global core.editor "vim"

# Set default branch name
git config --global init.defaultBranch main
```

### Useful Aliases

```bash
# Shortcuts
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.lg "log --oneline --graph --decorate"
```

## BMAD-Specific Git Practices

### Story Branch Naming

```bash
# Always use story/XXX format
git checkout -b story/042-user-authentication

# Not:
git checkout -b auth-feature  # Bad: No story reference
```

### Commit Messages Reference Stories

```bash
# Always reference Story-XXX
git commit -m "feat(Story-042): implement authentication

Implements acceptance criteria 1, 2, 3
Addresses FR-015 from PRD"

# Not:
git commit -m "add auth"  # Bad: No story reference
```

### Update Story Files in Git

```bash
# Story file updates are part of the work
git add stories/epic-001/story-042.md
git commit -m "docs(Story-042): add implementation notes"

# Story file should be updated BEFORE merging
```

### PR Descriptions Link to Stories

```markdown
# Pull Request Title
Story-042: User Authentication Endpoint

# Description
Implements Story-042 from Epic-001

**Story File:** `stories/epic-001/story-042.md`

**Acceptance Criteria:**
- [x] AC-1: System validates user credentials
- [x] AC-2: JWT token generated on success
- [x] AC-3: Rate limiting active
- [x] AC-4: Comprehensive error handling

**Related PRD:** FR-015, NFR-002
**Architecture:** Follows pattern in architecture.md section 4.2

**Tests:**
- Unit tests: 15/15 passing
- Integration tests: 3/3 passing
- Coverage: 92%
```

## .gitignore Best Practices

```gitignore
# Python
__pycache__/
*.py[cod]
*.so
.Python
venv/
.env

# Node
node_modules/
npm-debug.log
.next/
dist/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# BMAD - Don't ignore these!
# bmad-agent/    # Keep agent files
# docs/          # Keep planning docs
# stories/       # Keep story files
```

## Git Hooks (Advanced)

### Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Run linter
npm run lint || exit 1

# Run tests
npm test || exit 1

# For BMAD: Check story reference in branch name
branch=$(git symbolic-ref --short HEAD)
if [[ ! $branch =~ ^(story|epic)/ ]]; then
    echo "Error: Branch must start with story/ or epic/"
    exit 1
fi
```

### Commit-msg Hook

```bash
# .git/hooks/commit-msg
#!/bin/bash

# Ensure BMAD commits reference story
commit_msg=$(cat "$1")
if [[ ! $commit_msg =~ Story-[0-9]+ ]]; then
    echo "Error: Commit message must reference Story-XXX"
    exit 1
fi
```

## Best Practices Summary

1. **Commit early and often** - Small, atomic commits
2. **Write meaningful messages** - Explain WHY, not just WHAT
3. **Keep branches short-lived** - Merge frequently
4. **Pull before push** - Avoid conflicts
5. **Review before committing** - Use `git diff --staged`
6. **Use branches for all work** - Never commit directly to main
7. **Keep history clean** - Rebase before pushing (if sole contributor)
8. **Reference context** - In BMAD, always reference stories
9. **Update documentation** - Story files, README, etc.
10. **Communicate with team** - PRs, commit messages, branch names

## BMAD Integration Summary

In BMAD projects, Git becomes part of the methodology:

- **Branch names** → `story/XXX-description`
- **Commit messages** → Reference `Story-XXX`
- **PR descriptions** → Link to story files
- **Story files tracked** → Under version control
- **Planning docs tracked** → PRD, Architecture in Git
- **Context preserved** → Through commit history + story files

Git + BMAD = Complete traceability from requirement → story → implementation → deployment.
