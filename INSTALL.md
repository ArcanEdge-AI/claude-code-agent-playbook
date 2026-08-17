# Install Coding Agent Playbook — Claude Code Edition

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
  .claude-code-agent-playbook-managed-files.tsv
  references/
    README.md
    model-routing.md
    subagents.md
    worktrees.md
    multi-session-coordination.md
    reference-doc-routing.md
    templates/
      active-work-record.md
      task-graph.md
      worktree-manifest.md
      *.md
  agents/
    local-orchestrator.md
    read-only-explorer.md
    senior-reviewer.md
    docs-researcher.md
    test-triager.md
    isolated-worker.md
  skills/
    task-graph-orchestration/SKILL.md
    subagent-orchestration/SKILL.md
    worktree-lifecycle/SKILL.md
    multi-session-coordination/SKILL.md
    reference-doc-routing/SKILL.md
    senior-code-review/SKILL.md
```

Path resolution:

- `CLAUDE_HOME`: use `$CLAUDE_CONFIG_DIR` if set, otherwise `~/.claude`.
- On Windows, resolve equivalent user-home paths safely.

## Install Modes

### Full install

Use this for normal installs and every normal update. It is the default when no mode flag is provided.

Full install:

- installs the global coding-agent instructions into `$CLAUDE_HOME/CLAUDE.md`
- copies reference docs into `$CLAUDE_HOME/references/`
- copies custom Claude Code subagent definitions into `$CLAUDE_HOME/agents/`
- copies skills into `$CLAUDE_HOME/skills/`

The global instruction body is always installed inside one clearly marked Coding Agent Playbook — Claude Code Edition section. Preserve content outside the markers. Add the marked section when both markers are absent or replace exactly one well-ordered marked section after a timestamped backup. If only one marker exists, either marker is duplicated, or the end appears before the start, stop without writing the file.

After a successful run, the installer writes `$CLAUDE_HOME/.claude-code-agent-playbook-managed-files.tsv` with every managed support-file path and source SHA-256. On later runs, files removed from the repository are backed up and retired only when they still match the previously installed hash. Customized formerly managed files are preserved and reported. Files that were never recorded as playbook-managed are never removed.

The first manifest-aware update has no previous ownership record, so it safely preserves existing unlisted files. Subsequent updates can distinguish unchanged retired files from user customizations.

### Support-only install

Use this only when the user explicitly requests support-only mode and confirms that the full global instructions already live in their global `CLAUDE.md` manually. Do not infer support-only mode merely because an older installation or an existing `CLAUDE.md` is present.

Support-only install:

- does not duplicate the full global instructions into `$CLAUDE_HOME/CLAUDE.md`
- adds only a short reference-map pointer if useful
- still copies reference docs, skills, and custom Claude Code subagent definitions
- still updates the managed-file manifest and safely retires unchanged files removed from later playbook releases

Support-only reruns use the same marker validation and replacement rules, so installed pointers update without duplicating user-authored content.

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

When an AI coding agent is asked to install this repository, it should:

1. Clone or fetch the repository from the provided URL.
2. Read this `INSTALL.md` file first.
3. Resolve `CLAUDE_HOME`.
4. Inspect existing target files before writing.
5. Back up any existing file before changing it.
6. Use full install for both installation and update unless the user explicitly asks for support-only mode. Existing global instructions, markers, or support files are not permission to change modes.
7. Copy reference docs, skills, and custom Claude Code subagent definitions to the expected user-level locations.
8. Validate the installed files and Claude Code YAML frontmatter.
9. Report exactly what changed, what was skipped, and where backups were written.

Do not modify arbitrary repositories during installation. Only use a temporary clone of this repository and user-level Claude Code configuration locations.

## Validation Checklist

After installation, verify:

- `$CLAUDE_HOME/CLAUDE.md` exists or was intentionally left as a pointer-only file.
- `$CLAUDE_HOME/.claude-code-agent-playbook-managed-files.tsv` exists and lists every current managed support file once.
- `$CLAUDE_HOME/references/model-routing.md` exists.
- `$CLAUDE_HOME/references/subagents.md` exists.
- `$CLAUDE_HOME/references/worktrees.md` exists.
- `$CLAUDE_HOME/references/multi-session-coordination.md` exists.
- `$CLAUDE_HOME/references/reference-doc-routing.md` exists.
- `$CLAUDE_HOME/references/templates/active-work-record.md` exists.
- `$CLAUDE_HOME/references/templates/task-graph.md` exists.
- `$CLAUDE_HOME/references/templates/worktree-manifest.md` exists.
- `$CLAUDE_HOME/agents/local-orchestrator.md` exists.
- `$CLAUDE_HOME/agents/read-only-explorer.md` exists.
- `$CLAUDE_HOME/agents/senior-reviewer.md` exists.
- `$CLAUDE_HOME/agents/docs-researcher.md` exists.
- `$CLAUDE_HOME/agents/test-triager.md` exists.
- `$CLAUDE_HOME/agents/isolated-worker.md` exists.
- `$CLAUDE_HOME/skills/subagent-orchestration/SKILL.md` exists.
- `$CLAUDE_HOME/skills/task-graph-orchestration/SKILL.md` exists.
- `$CLAUDE_HOME/skills/worktree-lifecycle/SKILL.md` exists.
- `$CLAUDE_HOME/skills/multi-session-coordination/SKILL.md` exists.
- `$CLAUDE_HOME/skills/reference-doc-routing/SKILL.md` exists.
- `$CLAUDE_HOME/skills/senior-code-review/SKILL.md` exists.
- Each `SKILL.md` has `name` and `description` frontmatter.
- Each `agents/*.md` file has `name`, `description`, `model`, `effort`, `permissionMode`, and `tools` frontmatter.
- Read-only roles use `permissionMode: plan` and exclude `Edit` and `Write` from their `tools` frontmatter.
- Write-capable bundled roles use `permissionMode: default` unless a different mode has explicit maintainer approval.
- Only `local-orchestrator.md` lists `Agent`; direct workers and depth-2 leaves omit it.
- No bundled agent enables `isolation: worktree` globally.
- Every managed agent frontmatter model is the fail-closed `haiku` alias; accepted root-permitted invocations pass any approved Sonnet or exceptional Opus route explicitly within the actual parent ceiling.
- The installed playbook has exactly one managed definition for each of the six listed roles; per-invocation model routing is used instead of model-specific role copies, while effort remains fixed in the selected definition.
- Routing guidance treats the actual user-selected main-session model as the root ceiling, permits equal-tier children, prohibits descendant upgrades, reserves replacement routing for the root, and rejects silent model substitution.
- No non-Claude configuration paths, subagent schemas, or command vocabulary were introduced.
- Every current manifest entry matches its repository source SHA-256.
- Every formerly managed path was either absent, backed up and retired unchanged, or preserved with an explicit customization warning.

## Uninstall

This project does not currently ship an automatic uninstall command.

To remove it manually, delete:

```text
$CLAUDE_HOME/references/
$CLAUDE_HOME/.claude-code-agent-playbook-managed-files.tsv
$CLAUDE_HOME/agents/local-orchestrator.md
$CLAUDE_HOME/agents/read-only-explorer.md
$CLAUDE_HOME/agents/senior-reviewer.md
$CLAUDE_HOME/agents/docs-researcher.md
$CLAUDE_HOME/agents/test-triager.md
$CLAUDE_HOME/agents/isolated-worker.md
$CLAUDE_HOME/skills/subagent-orchestration/
$CLAUDE_HOME/skills/task-graph-orchestration/
$CLAUDE_HOME/skills/worktree-lifecycle/
$CLAUDE_HOME/skills/multi-session-coordination/
$CLAUDE_HOME/skills/reference-doc-routing/
$CLAUDE_HOME/skills/senior-code-review/
```

If you used full install and want to remove the global instructions, edit `$CLAUDE_HOME/CLAUDE.md` and remove the section between the Coding Agent Playbook — Claude Code Edition start/end markers.
