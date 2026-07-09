# Install Claude Code Agent Playbook

This file is written for both humans and AI coding agents.

The intended experience is:

```text
Install this repo into my Claude Code setup:
https://github.com/ArcanEdge-AI/claude-code-agent-playbook

Follow INSTALL.md. Use full install unless I explicitly ask for support-only mode.
Preserve my existing files with backups and report exactly what changed.
```

## What Gets Installed

A full install creates or updates this user-level structure:

```text
$CLAUDE_HOME/
  CLAUDE.md
  references/
    README.md
    subagents.md
    reference-doc-routing.md
    templates/*.md
  agents/
    read-only-explorer.md
    senior-reviewer.md
    docs-researcher.md
    test-triager.md
    isolated-worker.md
  skills/
    subagent-orchestration/SKILL.md
    reference-doc-routing/SKILL.md
    senior-code-review/SKILL.md
```

Path resolution:

- `CLAUDE_HOME`: use `$CLAUDE_CONFIG_DIR` if set, otherwise `~/.claude`.
- On Windows, resolve equivalent user-home paths safely.

## Install Modes

### Full install

Use this for most users.

Full install:

- installs the global coding-agent instructions into `$CLAUDE_HOME/CLAUDE.md`
- copies reference docs into `$CLAUDE_HOME/references/`
- copies custom agent definitions into `$CLAUDE_HOME/agents/`
- copies skills into `$CLAUDE_HOME/skills/`

If `$CLAUDE_HOME/CLAUDE.md` already exists, preserve it and append a clearly marked Claude Code Agent Playbook section unless the section is already present.

### Support-only install

Use this when the user already pasted the global instructions into their global `CLAUDE.md` manually.

Support-only install:

- does not duplicate the full global instructions into `$CLAUDE_HOME/CLAUDE.md`
- adds only a short reference-map pointer if useful
- still copies reference docs, skills, and custom agent definitions

## Human Install

Clone the repository and run the installer for your shell.

### macOS / Linux / WSL

```bash
git clone https://github.com/ArcanEdge-AI/claude-code-agent-playbook.git
cd claude-code-agent-playbook
bash install/install.sh --full
```

Support-only mode:

```bash
bash install/install.sh --support-only
```

Dry run:

```bash
bash install/install.sh --full --dry-run
```

### Windows PowerShell

```powershell
git clone https://github.com/ArcanEdge-AI/claude-code-agent-playbook.git
cd claude-code-agent-playbook
pwsh -ExecutionPolicy Bypass -File install/install.ps1 -Full
```

Support-only mode:

```powershell
pwsh -ExecutionPolicy Bypass -File install/install.ps1 -SupportOnly
```

Dry run:

```powershell
pwsh -ExecutionPolicy Bypass -File install/install.ps1 -Full -DryRun
```

## Agent Install Instructions

When an AI coding agent is asked to install this repo, it should:

1. Clone or fetch the repository from the provided URL.
2. Read this `INSTALL.md` file first.
3. Resolve `CLAUDE_HOME`.
4. Inspect existing target files before writing.
5. Back up any existing file before changing it.
6. Use full install unless the user explicitly asks for support-only mode or the user clearly states the global instructions already live in their global `CLAUDE.md`.
7. Copy reference docs, skills, and custom agent definitions to the expected user-level locations.
8. Validate the installed files.
9. Report exactly what changed, what was skipped, and where backups were written.

Do not modify arbitrary repositories during installation. Only use a temporary clone of this repository and user-level Claude Code configuration locations.

## Validation Checklist

After installation, verify:

- `$CLAUDE_HOME/CLAUDE.md` exists or was intentionally left as a pointer-only file.
- `$CLAUDE_HOME/references/subagents.md` exists.
- `$CLAUDE_HOME/references/reference-doc-routing.md` exists.
- `$CLAUDE_HOME/agents/read-only-explorer.md` exists.
- `$CLAUDE_HOME/agents/senior-reviewer.md` exists.
- `$CLAUDE_HOME/agents/docs-researcher.md` exists.
- `$CLAUDE_HOME/agents/test-triager.md` exists.
- `$CLAUDE_HOME/agents/isolated-worker.md` exists.
- `$CLAUDE_HOME/skills/subagent-orchestration/SKILL.md` exists.
- Each `SKILL.md` has `name` and `description` frontmatter.
- Each `agents/*.md` file has `name`, `description`, and `tools` frontmatter.
- Read-only roles exclude `Edit` and `Write` from their `tools` frontmatter.

## Uninstall

This project does not currently ship an automatic uninstall command.

To remove it manually, delete:

```text
$CLAUDE_HOME/references/
$CLAUDE_HOME/agents/read-only-explorer.md
$CLAUDE_HOME/agents/senior-reviewer.md
$CLAUDE_HOME/agents/docs-researcher.md
$CLAUDE_HOME/agents/test-triager.md
$CLAUDE_HOME/agents/isolated-worker.md
$CLAUDE_HOME/skills/subagent-orchestration/
$CLAUDE_HOME/skills/reference-doc-routing/
$CLAUDE_HOME/skills/senior-code-review/
```

If you used full install and want to remove the global instructions, edit `$CLAUDE_HOME/CLAUDE.md` and remove the section between the Claude Code Agent Playbook start/end markers.
