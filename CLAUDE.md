# Repository Coding Agent Instructions

This repository is a public playbook for Claude Code global instructions, reference documents, skills, and custom subagent definitions.

Repository-specific guidance overrides the global instructions where it is more specific.

## Repository Goals

- Keep the playbook useful for many teams and codebases.
- Keep global guidance tool-agnostic and durable.
- Keep repository-specific, machine-specific, and workflow-specific details out of global instructions.
- Prefer concise, practical guidance over long theory.
- Make the root Claude Code session accountable for root-task framing, finite delegation, coordination, integration, validation, and final reporting.
- Keep the Claude Code subagent model aligned around `local-orchestrator`, `read-only-explorer`, `senior-reviewer`, `docs-researcher`, `test-triager`, and `isolated-worker`.
- Keep every custom subagent pinned to a fail-closed Haiku default, fixed definition-level effort, permission mode, and tool boundary; require explicit root-permitted calls that pass the task-approved model, and reject automatic or omitted-model routes.
- Treat the actual user-selected main-session model as the root ceiling. Use Opus rank 3, Sonnet rank 2, and Haiku rank 1; require `child rank <= parent rank`, allow equal-tier routes, and never assume Opus.
- Keep nested delegation bounded to depth 2 below the root: only `local-orchestrator` may receive `Agent`, execution leaves must not receive it, and nested execution requires verified client support plus an active `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` setting in an authorized scope.
- Keep shared execution as the default. Do not add `isolation: worktree` to bundled agent definitions; worktree isolation requires a task-local root permit and verified base state.

## Content Rules

- Do not include sensitive access material, private local paths, internal-only URLs, full session transcripts, or long incident logs.
- Do not hardcode project names, organization-specific workflows, or local machine quirks in global guidance.
- Do not add instructions tied to a specific issue tracker, review tool, package manager, shell, or hosting provider unless the file is explicitly an example or template.
- Use Claude Code terminology, paths, commands, YAML agent schemas, model aliases, effort fields, permission modes, tool names, and session concepts in Claude-specific files.
- Do not copy configuration paths, file names, agent formats, model identifiers, or command vocabulary from another coding-agent environment into this repository.
- Prefer terms like "safety", "access control", and "sensitive access material" when public documentation does not need product-specific terminology.
- Keep templates reusable and clearly marked as templates.

## Validation

This repo is mostly Markdown, with a small set of YAML frontmatter blocks in skill and agent definitions. Before finalizing meaningful changes:

- Review Markdown headings and fenced code blocks for correctness.
- Confirm each `SKILL.md` has YAML frontmatter with `name` and `description`.
- Confirm each `agents/*.md` file has YAML frontmatter with `name`, `description`, `model`, `effort`, `permissionMode`, and `tools`; every managed model defaults to Haiku and every description rejects automatic selection.
- Confirm read-only roles use `permissionMode: plan` and do not list `Edit` or `Write` in their `tools` frontmatter.
- Confirm write-capable bundled roles use `permissionMode: default` unless a different mode has explicit maintainer approval.
- Confirm only `agents/local-orchestrator.md` lists `Agent`; direct workers and depth-2 leaves must omit it.
- Confirm no bundled agent definition sets `isolation: worktree` globally.
- Confirm every agent definition requires an explicit invocation model, rejects unresolved substitutions, and includes clear stop conditions without descendant upgrade requests.
- Confirm the docs cover Opus, Sonnet, and Haiku roots; equal-tier children; no forced tier drop; root-only stronger replacements within the actual root ceiling; and unknown or unavailable model handling.
- Confirm links and paths in `README.md` match the repository tree.
- Confirm install docs and scripts reference the current Claude Code subagent files.
- Confirm installer validation lists include `references/worktrees.md`, `references/templates/worktree-manifest.md`, `skills/worktree-lifecycle/SKILL.md`, and `agents/local-orchestrator.md`.
- Confirm new Claude-specific guidance uses `CLAUDE.md`, the resolved Claude Code home, Markdown subagent definitions, Claude model aliases, effort levels, permission modes, Claude tool names, and Claude session commands where applicable.
- Search the final diff for paths, schemas, model names, and commands that belong to another coding-agent environment; remove any accidental contamination before merging.

## License

MIT (see `LICENSE`). Do not change the license without an explicit maintainer decision.
