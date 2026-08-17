# Prompt: Set Up Global Claude Code Support System

> This is an explicit support-only setup prompt, not a normal installer or updater. For every normal install or update, follow `INSTALL.md` in full mode. Do not select this prompt merely because existing playbook files are present.

Paste this prompt into Claude Code after you have already added the global coding-agent instructions from `custom-instructions/global-coding-agent-instructions.md` to your global `CLAUDE.md`.

```markdown
You are configuring my global Claude Code support system.

Important context:
I have already added my full global coding-agent instructions to my global CLAUDE.md, the user-level memory file Claude Code loads into every session. Treat that as true even if you cannot inspect it directly in this conversation.
Do not duplicate those full instructions elsewhere.
This explicit statement is the authorization for support-only behavior. Without it, stop using this prompt and follow `INSTALL.md` in full mode.

Your job is to create the supporting global system only:

- global reference documents
- Claude model, effort, and permission routing docs
- reference document routing docs
- subagent delegation docs
- multi-session coordination docs
- reusable skills
- global custom Claude Code subagent definitions
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
7. Do not store sensitive access material, private local paths, full session transcripts, or long incident logs.
8. Keep everything tool-agnostic where it is not explicitly Claude-Code-specific.
9. Use only Claude Code file names, configuration paths, subagent schemas, model aliases, effort fields, permission modes, tool names, and session commands.
10. Do not ask me questions unless you are blocked. Make reasonable assumptions and report them.

## Desired Global Structure

Create or update this structure:

```text
$CLAUDE_HOME/
  CLAUDE.md
  references/
    README.md
    model-routing.md
    subagents.md
    worktrees.md
    multi-session-coordination.md
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
      active-work-record.md
      task-graph.md
      worktree-manifest.md
  skills/
    task-graph-orchestration/
      SKILL.md
    subagent-orchestration/
      SKILL.md
    worktree-lifecycle/
      SKILL.md
    multi-session-coordination/
      SKILL.md
    reference-doc-routing/
      SKILL.md
    senior-code-review/
      SKILL.md
  agents/
    local-orchestrator.md
    read-only-explorer.md
    senior-reviewer.md
    docs-researcher.md
    test-triager.md
    isolated-worker.md
```

Each agent file under `$GLOBAL_AGENTS_HOME` must have YAML frontmatter with `name`, `description`, `model`, `effort`, `permissionMode`, and `tools`, followed by the system-prompt body.

Use these Claude Code frontmatter defaults. Every model defaults to Haiku so omitted or automatic model routing fails closed; the normal explicit model is listed separately:

- `local-orchestrator`: Haiku default, Sonnet normal explicit model, high effort, default permission mode; Agent, Read, Grep, Glob, Bash, Edit, Write, WebFetch, WebSearch
- `read-only-explorer`: Haiku default and normal explicit model, low effort, plan permission mode; Read, Grep, Glob
- `docs-researcher`: Haiku default and normal explicit model, low effort, plan permission mode; Read, Grep, Glob, WebFetch, WebSearch
- `test-triager`: Haiku default, Sonnet normal explicit model, medium effort, default permission mode; Read, Grep, Glob, Bash, Edit
- `isolated-worker`: Haiku default, Sonnet normal explicit model, medium effort, default permission mode; Read, Grep, Glob, Edit, Write, Bash
- `senior-reviewer`: Haiku default, Sonnet normal explicit model, high effort, plan permission mode; Read, Grep, Glob, Bash

Keep exactly one definition for each role. Claude Code supports a per-invocation `model` override, so do not create model-specific copies of the agent files. At execution time, record the actual model selected for the main session and treat it as the root ceiling. Use Opus rank 3, Sonnet rank 2, and Haiku rank 1; require `child rank <= parent rank`, allow equal-tier routes, and never assume Opus. Use only explicit root-permitted routes and pass the permitted model on every `Agent` invocation; reject automatic or omitted-model routes. Effort is fixed in the role definition and must fit the recorded parent ceiling; do not invent a per-invocation effort parameter.

With an Opus root, normally use Sonnet for substantial delegated work and Haiku for cheap, objective work; record the exceptional reason and verification plan for an Opus child. A Sonnet root may use Sonnet or Haiku. A Haiku root may use Haiku only. Descendants stop and report insufficiency without requesting an upgrade. Only the root may issue a new depth-1 replacement permit, and that replacement may be stronger than the failed child only while remaining within the actual root ceiling. Do not accept unknown, unavailable, or substituted models silently.

Set `tools` to the minimum set the role needs. Only `local-orchestrator` includes `Agent`; direct workers and depth-2 leaves omit it. The local orchestrator's broad list is its inherited child ceiling, not permission for unassigned direct edits.

Do not enable `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions` in bundled agent definitions without an explicit maintainer-approved use case and risk analysis.

Do not set `isolation: worktree` globally. Use it only for assignments whose required base state is explicit, because an isolated subagent worktree may not include current-session changes.

Do not create custom agents with names that shadow Claude Code's built-in agent types. Use the custom names listed above.

## Handle the Global CLAUDE.md Safely

The full global coding-agent instructions have already been added to `$GLOBAL_CLAUDE_MD`.

Do not duplicate those instructions elsewhere.

Inspect `$GLOBAL_CLAUDE_MD` if it exists.

If `$GLOBAL_CLAUDE_MD` does not exist:
- Create it with the small pointer section below.
- Do not fabricate the full global instruction set. Tell me to add it from `custom-instructions/global-coding-agent-instructions.md`.

If `$GLOBAL_CLAUDE_MD` already exists:
- Preserve it.
- Preserve all user-authored content outside the exact `<!-- claude-code-agent-playbook:start -->` and `<!-- claude-code-agent-playbook:end -->` markers.
- If exactly one well-ordered marked section exists, create a timestamped backup and replace only that inclusive block with the current small reference section.
- If neither marker exists, add the marked small reference section.
- If only one marker exists, either marker is duplicated, or the end appears before the start, stop and report the malformed state without writing the file.
- If the existing file already appears to duplicate this pointer section, report that possible duplication but do not delete anything.

The pointer section should be:

```markdown
## Global Reference Documents and Subagent Support

The primary global coding-agent behavior may already be configured in this CLAUDE.md file.

Supporting global reference documents live under the Claude Code home references directory:

- `references/README.md` — map of available global reference docs
- `references/model-routing.md` — mandatory Claude model, effort, permission, tool, depth, escalation, and acceptance rules
- `references/subagents.md` — Claude Code subagent delegation rules, assignment template, and acceptance checklist
- `references/worktrees.md` — root-owned task-local worktree budgeting, Claude Code isolation, integration, cleanup, and preservation rules
- `references/multi-session-coordination.md` — Claude Code session discovery, naming, ownership, sequencing, conflict detection, and integration guidance
- `references/reference-doc-routing.md` — how to decide which docs to consult and how to treat them
- `references/templates/` — templates for repository-level CLAUDE.md, architecture, testing, access control, design system, release, API, data model, active work, task graphs, and worktree manifests

Reusable Claude Code skills live under the Claude Code home skills directory:

- `skills/subagent-orchestration/SKILL.md`
- `skills/task-graph-orchestration/SKILL.md`
- `skills/worktree-lifecycle/SKILL.md`
- `skills/multi-session-coordination/SKILL.md`
- `skills/reference-doc-routing/SKILL.md`
- `skills/senior-code-review/SKILL.md`

Custom Claude Code subagents live under the Claude Code home agents directory:

- `agents/local-orchestrator.md`
- `agents/read-only-explorer.md`
- `agents/senior-reviewer.md`
- `agents/docs-researcher.md`
- `agents/test-triager.md`
- `agents/isolated-worker.md`

Reference documents are supporting context, not automatic truth. For repository tasks when subagents are available, the root Claude Code session delegates actual execution to at least one bounded subagent and remains accountable for root orchestration, integration, validation, acceptance, and the final response. Direct root execution is limited to unavailable subagents, an explicit user prohibition, or a specific authority-bound action; record the exact exception.

The root owns a finite manifest, total subagent budget, and child-specific permits. The actual user-selected main-session model is the root ceiling: Opus rank 3, Sonnet rank 2, Haiku rank 1. Every managed route is explicit and root-permitted, and every `Agent` invocation passes a model with child rank at or below parent rank; automatic or omitted-model routes are rejected. Bundled definitions fail closed at Haiku, and their fixed effort must fit the parent ceiling. Equal-tier routing is valid and depth does not force a drop. Descendants cannot request upgrades. Only the root may route a new depth-1 replacement within the actual root ceiling, even when stronger than the failed child. Unknown, unavailable, or substituted models are not accepted silently.

Depth 1 contains named direct workers or `local-orchestrator`. A permitted local orchestrator may use only root-permitted depth-2 leaves, and only after nesting support and an active `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` setting are verified. Depth-2 leaves omit `Agent` and cannot spawn; depth 3 is prohibited. Every child stays at or below its parent in model, effort, permission mode, tools, scope, workspace, and authority. If either gate is unavailable, depth 1 executes directly without `Agent`; the setting is not changed without authorization.

The auxiliary-worktree budget starts at zero and is separate from the subagent budget. Only the root may authorize `isolation: worktree`, create or adopt an auxiliary, change its purpose, move it, or remove it. One active auxiliary needs no added approval; two or more require user approval for the exact count and reasons. Before the final response, the root removes each task-created auxiliary under verified gates or preserves it with exact path, owner, branch or HEAD, blocker, and next action. Task-local cleanup does not depend on scheduled automation. The active host-managed worktree remains under the host lifecycle.

The root Claude Code session must verify implementation-relevant claims against primary evidence such as current code, tests, schemas, configuration, logs, build output, typecheck output, runtime behavior, relevant session evidence, and authoritative external documentation.

When delegating to subagents or coordinating independent Claude Code sessions, pass only relevant reference document names, paths, or sections. Do not dump large documents or full session transcripts into prompts unless necessary.

The root session remains accountable for the final plan, final diff, validation, and final response.
```

If adding this to an existing `CLAUDE.md`, insert it under the heading `## Global Reference Documents and Subagent Support` and do not duplicate a similar existing section.

## Create Supporting Files

Use the contents from this repository as the canonical source for:

- `references/README.md`
- `references/model-routing.md`
- `references/subagents.md`
- `references/multi-session-coordination.md`
- `references/reference-doc-routing.md`
- `references/templates/*.md`
- `skills/*/SKILL.md`
- `agents/*.md`

Preserve the same intent, names, descriptions, Claude model defaults, effort levels, permission modes, tools, and instructions. If the installed Claude Code version uses a different supported subagent or skill schema, adapt only as necessary and report the exact adjustment. Do not substitute an unknown model or invent model-specific agent copies.

## Validation

After creating or updating files:

1. Print the resulting file tree for `$CLAUDE_HOME`, `$GLOBAL_REFERENCES_HOME`, `$GLOBAL_SKILLS_HOME`, and `$GLOBAL_AGENTS_HOME`.
2. Confirm no repository files were modified.
3. Confirm each agent Markdown file has valid YAML frontmatter with `name`, `description`, `model`, `effort`, `permissionMode`, and `tools`; each managed `model` is the fail-closed `haiku` alias and each description rejects automatic selection.
4. Confirm read-only roles use `permissionMode: plan` and exclude `Edit` and `Write`.
5. Confirm write-capable bundled roles use `permissionMode: default`.
6. Confirm each `SKILL.md` has YAML frontmatter with `name` and `description`.
7. Confirm the exact expected agent set exists: `local-orchestrator.md`, `read-only-explorer.md`, `senior-reviewer.md`, `docs-researcher.md`, `test-triager.md`, and `isolated-worker.md`. Confirm each default model is the fail-closed `haiku` alias, only `local-orchestrator.md` lists `Agent`, no model-specific role copies were created, and no bundled definition sets `isolation: worktree`.
8. Confirm `references/model-routing.md`, `references/multi-session-coordination.md`, `references/worktrees.md`, `references/templates/active-work-record.md`, `references/templates/task-graph.md`, `references/templates/worktree-manifest.md`, and all six managed skills listed above exist.
9. Confirm the routing docs cover actual Opus, Sonnet, and Haiku roots, explicit root-permitted routing, definition-level effort, equal-tier children, no forced tier drop, the required depth-cap gate, root-only replacement routing, and unknown or unavailable model handling. Confirm only Claude Code paths, commands, model aliases, effort fields, permission modes, tool names, and subagent schemas were installed.
10. Report any files backed up.
11. Report any files skipped and why.
12. Report any assumptions.
13. Report whether the small `CLAUDE.md` pointer section was created, updated, already present, or skipped.

Final response format:

```text
Summary:
- Created or updated the global Claude Code reference structure.
- Created or updated global Claude Code skills.
- Created or updated global Claude Code subagent definitions.
- Left the existing global CLAUDE.md instruction section untouched.

Files:
- [list created or updated files]

Verification:
- [checks performed and results]

Notes:
- [backups, skipped files, assumptions, risks]
```
```
