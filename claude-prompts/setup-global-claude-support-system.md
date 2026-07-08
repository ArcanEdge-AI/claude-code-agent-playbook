# Prompt: Set Up Global Claude Code Support System

Paste this prompt into Claude Code after you have already added the global coding-agent instructions from `custom-instructions/global-coding-agent-instructions.md` to your global `CLAUDE.md`.

```markdown
You are configuring my global Claude Code support system.

Important context:
I have already added my full global coding-agent instructions to my global CLAUDE.md (the user-level memory file Claude Code loads into every session). Treat that as true even if you cannot inspect it directly in this conversation.

Do not duplicate those full instructions elsewhere.

Your job is to create the supporting global system only:

- global reference documents
- reference document routing docs
- subagent delegation docs
- reusable skills
- global custom subagent definitions
- a small pointer section in the global CLAUDE.md only if helpful and not already present

Do not modify any repository files. Work only in user-level/global Claude Code configuration locations.

## Path Resolution

Resolve paths like this:

- `CLAUDE_HOME`: use the `CLAUDE_CONFIG_DIR` environment variable if set; otherwise use the user's Claude Code home directory, normally `~/.claude`.
- `GLOBAL_CLAUDE_MD`: `$CLAUDE_HOME/CLAUDE.md`.
- `GLOBAL_REFERENCES_HOME`: `$CLAUDE_HOME/references`.
- `GLOBAL_SKILLS_HOME`: `$CLAUDE_HOME/skills`.
- `GLOBAL_AGENTS_HOME`: `$CLAUDE_HOME/agents`.

If the platform is Windows, resolve equivalent user-home paths safely instead of hardcoding Unix-only paths.

Do not hardcode machine-specific usernames or absolute paths.

## Preflight Requirements

Before writing anything:

1. Print the resolved paths.
2. Inspect whether these exist:
   - `$GLOBAL_CLAUDE_MD`
   - `$GLOBAL_REFERENCES_HOME`
   - `$GLOBAL_SKILLS_HOME`
   - `$GLOBAL_AGENTS_HOME`
3. Do not delete existing content.
4. Do not overwrite existing content without a timestamped backup.
5. If a file already exists, prefer a careful merge/update over replacement.
6. If replacement is necessary, create a timestamped backup next to the file.
7. Do not store sensitive access material, private local paths, or long incident logs.
8. Keep everything tool-agnostic where it is not explicitly Claude-Code-specific.
9. Do not mention issue-tracker-specific review mechanics, repo-specific workflows, local machine quirks, or project names.
10. Do not ask me questions unless you are blocked. Make reasonable assumptions and report them.

## Desired Global Structure

Create or update this structure:

```text
$CLAUDE_HOME/
  CLAUDE.md
  references/
    README.md
    subagents.md
    reference-doc-routing.md
    templates/
      repository-CLAUDE.md
      architecture.md
      testing.md
      security.md
      design-system.md
      release.md
      api-contracts.md
      data-model.md
  skills/
    subagent-orchestration/
      SKILL.md
    reference-doc-routing/
      SKILL.md
    senior-code-review/
      SKILL.md
  agents/
    read-only-explorer.md
    senior-reviewer.md
    docs-researcher.md
    test-triager.md
    isolated-worker.md
```

Each agent file under `$GLOBAL_AGENTS_HOME` must have YAML frontmatter with `name`, `description`, and `tools` (a comma-separated list), followed by the system-prompt body. Set `tools` to the minimum set the role needs — read-only roles must not include `Edit` or `Write`.

Do not create custom agents named `general-purpose`, `claude`, or other names that shadow Claude Code's built-in agent types. Use the custom names listed above.

## Handle the Global CLAUDE.md Safely

The full global coding-agent instructions have already been added to `$GLOBAL_CLAUDE_MD`.

Do not duplicate those instructions elsewhere.

Inspect `$GLOBAL_CLAUDE_MD` if it exists.

If `$GLOBAL_CLAUDE_MD` does not exist:
- Create it with the small pointer section below.
- Do not fabricate the full global instruction set — tell me to add it myself from `custom-instructions/global-coding-agent-instructions.md`.

If `$GLOBAL_CLAUDE_MD` already exists:
- Preserve it.
- Do not replace it.
- Do not remove existing guidance.
- Add only a small reference section if it is missing.
- If the existing file already appears to duplicate this pointer section, report that possible duplication but do not delete anything.

The pointer section should be:

```markdown
## Global Reference Documents and Subagent Support

Supporting global reference documents live under `~/.claude/references/`:

- `references/README.md` — map of available global reference docs
- `references/subagents.md` — subagent delegation rules, assignment template, and acceptance checklist
- `references/reference-doc-routing.md` — how to decide which docs to consult and how to treat them
- `references/templates/` — templates for repository-level CLAUDE.md, architecture, testing, security, design-system, release, API, and data-model docs

Reusable skills live under `~/.claude/skills/`, and global custom subagent definitions live under `~/.claude/agents/`.

Reference documents are supporting context, not automatic truth.

The main agent must verify implementation-relevant claims against primary evidence such as current code, tests, schemas, configuration, logs, build output, typecheck output, runtime behavior, and authoritative external documentation.

When delegating to subagents, the main agent should pass only relevant reference document names, paths, or sections. Do not dump large documents into subagent prompts unless necessary.

The main agent remains accountable for the final plan, final diff, validation, and final response.
```

If adding this to an existing `CLAUDE.md`, insert it under the heading `## Global Reference Documents and Subagent Support` and do not duplicate a similar existing section.

## Create Supporting Files

Use the contents from this repository as the canonical source for:

- `references/README.md`
- `references/subagents.md`
- `references/reference-doc-routing.md`
- `references/templates/*.md`
- `skills/*/SKILL.md`
- `agents/*.md`

Preserve the same intent, names, descriptions, and instructions. If the installed Claude Code version uses a different subagent or skill schema, adapt only as necessary.

## Validation

After creating or updating files:

1. Print the resulting file tree for `$CLAUDE_HOME`, `$GLOBAL_REFERENCES_HOME`, `$GLOBAL_SKILLS_HOME`, and `$GLOBAL_AGENTS_HOME`.
2. Confirm no repository files were modified.
3. Confirm each agent `.md` file has valid YAML frontmatter with `name`, `description`, and `tools`, and that read-only roles exclude `Edit`/`Write`.
4. Confirm each `SKILL.md` has YAML frontmatter with `name` and `description`.
5. Report any files backed up.
6. Report any files skipped and why.
7. Report any assumptions.
8. Report whether the small `CLAUDE.md` pointer section was created, updated, already present, or skipped.

Final response format:

```text
Summary:
- Created/updated global Claude Code reference structure.
- Created/updated global skills.
- Created/updated global custom subagent definitions.
- Left the existing global CLAUDE.md instructions section untouched.

Files:
- [list created/updated files]

Verification:
- [checks performed and results]

Notes:
- [backups, skipped files, assumptions, risks]
```
```
