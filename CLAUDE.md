# Repository Coding Agent Instructions

This repository is a public playbook for Claude Code global instructions, reference documents, skills, and custom subagent definitions.

Repository-specific guidance overrides the global instructions where it is more specific.

## Repository Goals

- Keep the playbook useful for many teams and codebases.
- Keep global guidance tool-agnostic and durable.
- Keep repository-specific, machine-specific, and workflow-specific details out of global instructions.
- Prefer concise, practical guidance over long theory.
- Make the main Claude Code session accountable for planning, delegation, coordination, validation, and final reporting.
- Keep the Claude Code subagent model aligned around `read-only-explorer`, `senior-reviewer`, `docs-researcher`, `test-triager`, and `isolated-worker`.
- Keep every custom subagent pinned to an explicit task-appropriate Claude model, effort level, permission mode, and tool boundary so it does not inherit broader main-session settings unintentionally.

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
- Confirm each `agents/*.md` file has YAML frontmatter with `name`, `description`, `model`, `effort`, `permissionMode`, and `tools`.
- Confirm read-only roles use `permissionMode: plan` and do not list `Edit` or `Write` in their `tools` frontmatter.
- Confirm write-capable bundled roles use `permissionMode: default` unless a different mode has explicit maintainer approval.
- Confirm smaller-model profiles include clear stop and escalation conditions.
- Confirm links and paths in `README.md` match the repository tree.
- Confirm install docs and scripts reference the current Claude Code subagent files.
- Confirm new Claude-specific guidance uses `CLAUDE.md`, the resolved Claude Code home, Markdown subagent definitions, Claude model aliases, effort levels, permission modes, Claude tool names, and Claude session commands where applicable.
- Search the final diff for paths, schemas, model names, and commands that belong to another coding-agent environment; remove any accidental contamination before merging.

## License

MIT (see `LICENSE`). Do not change the license without an explicit maintainer decision.
