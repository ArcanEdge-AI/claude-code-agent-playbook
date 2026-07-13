# Repository Coding Agent Instructions

This repository is a public playbook for Claude Code global instructions, reference documents, skills, and custom subagent definitions.

Repository-specific guidance overrides the global instructions where it is more specific.

## Repository Goals

- Keep the playbook useful for many teams and codebases.
- Keep global guidance tool-agnostic and durable.
- Keep repository-specific, machine-specific, and workflow-specific details out of global instructions.
- Prefer concise, practical guidance over long theory.
- Make the main agent accountable for planning, delegation, validation, and final reporting.
- Keep the Claude Code subagent model aligned around `read-only-explorer`, `senior-reviewer`, `docs-researcher`, `test-triager`, and `isolated-worker`.
- Keep every custom subagent pinned to an explicit task-appropriate model so it does not inherit the main conversation model unintentionally.

## Content Rules

- Do not include sensitive access material, private local paths, internal-only URLs, or long incident logs.
- Do not hardcode project names, organization-specific workflows, or local machine quirks in global guidance.
- Do not add instructions tied to a specific issue tracker, review tool, package manager, shell, or hosting provider unless the file is explicitly an example or template.
- Prefer terms like "safety", "access control", and "sensitive access material" when public documentation does not need product-specific terminology.
- Keep templates reusable and clearly marked as templates.

## Validation

This repo is mostly Markdown, with a small set of YAML frontmatter blocks in skill and agent definitions. Before finalizing meaningful changes:

- Review Markdown headings and fenced code blocks for correctness.
- Confirm each `SKILL.md` has YAML frontmatter with `name` and `description`.
- Confirm each `agents/*.md` file has YAML frontmatter with `name`, `description`, `model`, and `tools`.
- Confirm read-only roles do not list `Edit` or `Write` in their `tools` frontmatter.
- Confirm smaller-model profiles include clear stop and escalation conditions.
- Confirm links and paths in `README.md` match the repository tree.
- Confirm install docs and scripts reference the current Claude Code agent files.

## License

MIT (see `LICENSE`). Do not change the license without an explicit maintainer decision.
