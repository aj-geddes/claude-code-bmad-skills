# Legacy Files Removed

This repository now focuses exclusively on **BMAD Method v6** for Claude Code.

## Files Removed (as of 2025-11-12)

### Legacy Installers
- `install.ps1` - Old PowerShell installer for original BMAD skills
- `install.sh` - Old Bash installer for original BMAD skills

### Legacy Directories
- `skills/` - Old BMAD skills structure (7 skills: bmad-method, security, python, javascript, devops, testing, git)
- `commands/` - Old BMAD commands (5 commands: bmad-init, bmad-prd, bmad-arch, bmad-story, bmad-assess)
- `hooks/` - Old BMAD hooks (project-open.sh)

## Migration Guide

**If you were using the old BMAD installation:**

1. **Uninstall old version:**
   ```bash
   rm -rf ~/.claude/skills/bmad-method
   rm -rf ~/.claude/skills/security
   rm -rf ~/.claude/skills/python
   rm -rf ~/.claude/skills/javascript
   rm -rf ~/.claude/skills/devops
   rm -rf ~/.claude/skills/testing
   rm -rf ~/.claude/skills/git
   ```

2. **Install BMAD v6:**

   **Linux/macOS/WSL:**
   ```bash
   ./install-v6.sh
   ```

   **Windows PowerShell:**
   ```powershell
   .\install-v6.ps1
   ```

3. **Restart Claude Code**

## What's New in BMAD v6

- **Token-optimized** (70-85% reduction via helper pattern)
- **9 specialized skills** (core orchestrator + 6 agile agents + builder + creative intelligence)
- **15 workflow commands** (complete agile development lifecycle)
- **Cross-platform support** (Windows, Linux, macOS, WSL)
- **No external dependencies** (pure Claude Code native)
- **Better error handling** and user experience

## Documentation

See [README.md](README.md) for complete BMAD v6 documentation.

## Repository History

This repository originally contained the original BMAD Method implementation for Claude Code. As of November 2025, it has been fully updated to BMAD Method v6, which is a complete rewrite with significant improvements.

For the original BMAD Method, see: https://github.com/bmad-code-org/BMAD-METHOD
