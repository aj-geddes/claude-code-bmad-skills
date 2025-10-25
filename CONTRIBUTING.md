# Contributing to BMAD Skills for Claude Code

Thank you for your interest in contributing! This project implements the BMAD Method for Claude Code.

## 🎯 Attribution

**Important**: The BMAD Method is created and owned by the [BMAD Code Organization](https://github.com/bmad-code-org).

When contributing:
- ✅ Improvements to Claude Code integration
- ✅ Bug fixes in installation or skills
- ✅ Better documentation
- ✅ New domain skills (e.g., Ruby, Go, Rust)
- ✅ Enhanced Memory integration
- ✅ Command improvements

**Do not**:
- ❌ Modify core BMAD methodology without coordinating with BMAD Code org
- ❌ Remove or alter attribution to BMAD authors
- ❌ Change fundamental BMAD workflows or agent roles

## 🚀 How to Contribute

### 1. Fork the Repository

```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/YOUR-USERNAME/claude-code-bmad-skills.git
cd claude-code-bmad-skills
```

### 2. Create a Branch

```bash
# Use descriptive branch names
git checkout -b feature/add-rust-skill
git checkout -b fix/install-script-bug
git checkout -b docs/improve-readme
```

### 3. Make Your Changes

#### Adding a New Skill

```bash
# Create skill directory
mkdir -p skills/your-skill

# Create SKILL.md
# Follow the pattern in existing skills
# Include: Overview, Best Practices, Examples, Anti-patterns
```

**Skill Template:**
```markdown
# [Language/Domain] Skill

## Overview
[Brief description of what this skill covers]

## Best Practices
[Key practices and patterns]

## Code Examples
[Working examples with explanations]

## Common Patterns
[Frequently used patterns]

## Anti-Patterns
[Things to avoid]

## Integration with BMAD
[How this skill works with BMAD projects]
```

#### Improving Existing Skills

- Add missing examples
- Update deprecated practices
- Improve clarity
- Add security considerations
- Include performance tips

#### Updating Commands

Commands are in `commands/*.md`. Follow the existing format:

```markdown
# Command Name

You are being asked to [do something].

## Your Task

[Clear, step-by-step instructions]

## Important
[Critical points]
```

### 4. Test Your Changes

```bash
# Test installation locally
./install.sh

# Verify files installed correctly
ls -la ~/.claude/skills/

# Test in Claude Code
# - Start Claude Code
# - Try /bmad-init or other commands
# - Verify new skills load properly
```

### 5. Commit Your Changes

Follow conventional commits:

```bash
git add .
git commit -m "feat(skills): add Rust development skill"
git commit -m "fix(install): correct permissions issue on Windows"
git commit -m "docs(readme): improve LLM installation instructions"
```

**Commit types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance

### 6. Push and Create PR

```bash
git push origin feature/add-rust-skill
```

Then create a Pull Request on GitHub with:
- **Title**: Clear description of change
- **Description**:
  - What problem does this solve?
  - How does it solve it?
  - Any breaking changes?
  - Testing done?

## 📝 Contribution Guidelines

### Code Quality

- **Skills**: Clear, actionable, with examples
- **Commands**: Step-by-step, LLM-executable
- **Scripts**: Well-commented, error-handling
- **Documentation**: Clear, concise, accurate

### File Organization

```
skills/              # One skill per directory
  skill-name/
    SKILL.md         # Main skill file

commands/            # Slash command definitions
  command-name.md    # One command per file

hooks/               # Claude Code hooks
  hook-name.sh       # Hook scripts
```

### Documentation Standards

- Use clear, simple language
- Include code examples
- Explain WHY, not just HOW
- Keep LLM-readability in mind
- Update README if adding features

## 🐛 Reporting Issues

Found a bug? Have a suggestion?

1. **Check existing issues** first
2. **Create a new issue** with:
   - Clear title
   - Description of problem
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Environment (OS, Claude Code version)

## 💡 Feature Requests

Want a new feature?

1. **Check discussions** to see if it's been proposed
2. **Open a discussion** to get feedback
3. **Create an issue** if there's community interest

## 🤝 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Credit others' work
- Help newcomers
- Focus on the project's goals

## ✅ Pull Request Checklist

Before submitting:

- [ ] Code follows existing patterns
- [ ] Documentation updated
- [ ] Tested locally
- [ ] Commits are clear and atomic
- [ ] PR description is complete
- [ ] BMAD attribution maintained
- [ ] No breaking changes (or clearly documented)

## 🎓 Learning Resources

### BMAD Method
- [Original BMAD](https://github.com/bmad-code-org/BMAD-METHOD)
- [BMAD Website](https://bmadcodes.com/bmad-method/)
- [YouTube Channel](https://www.youtube.com/@BMadCode)

### Claude Code
- [Claude Code Docs](https://docs.claude.com/claude-code)
- Skills system
- Slash commands
- Memory integration

## 🙏 Thank You!

Your contributions help make BMAD more accessible in Claude Code.

Special thanks to:
- **BMAD Code Organization** - For the amazing methodology
- **All contributors** - For improvements and fixes
- **Community** - For feedback and support

---

**Questions?** Open a discussion or issue. We're here to help!
