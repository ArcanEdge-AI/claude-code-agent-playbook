# Contributing

Thanks for helping improve Claude Code Agent Playbook.

This repository is intentionally public and reusable. Contributions should make the playbook clearer, more durable, and less tool-specific.

## What Belongs Here

Good contributions include:

- clearer global coding-agent instructions
- better subagent delegation guidance
- reusable reference document templates
- improved skill definitions
- corrected custom-agent examples
- examples that stay generic and easy to adapt

## What Does Not Belong Here

Avoid adding:

- organization-specific workflows
- private project names
- local machine quirks
- internal URLs
- sensitive access material
- long incident logs
- instructions tied to one tool unless the file is explicitly an example

## Style

- Prefer concise, direct language.
- Keep guidance tool-agnostic unless the file is explicitly tool-specific.
- Prefer behavior and decision rules over rigid command sequences.
- Use examples that are generic and safe for public reuse.
- Keep the root-session orchestration, actual-root-model ceiling, bounded hierarchy, permit, capability-ceiling, and task-local worktree lifecycle model intact.

## Pull Request Checklist

Before opening a PR:

- Review Markdown formatting and fenced code blocks.
- Confirm links and paths match the repository tree.
- Confirm `SKILL.md` files include `name` and `description` frontmatter.
- Confirm `agents/*.md` files include valid YAML frontmatter (`name`, `description`, `model`, `effort`, `permissionMode`, and `tools`) if changed.
- Confirm read-only roles use `permissionMode: plan` and exclude `Edit` and `Write`; only `local-orchestrator.md` lists `Agent`; no bundled agent sets `isolation: worktree` globally.
- Confirm every managed agent defaults to Haiku, the actual root model is the ceiling, accepted routes are explicit and root-permitted, child rank never exceeds parent rank, effort is definition-level, equal-tier routes remain valid, only the root may route replacements, and no model substitution is accepted silently.
- Confirm Unix shell scripts remain LF-only.
- Confirm no sensitive or private material was added.

## License Note

This project is MIT licensed (see `LICENSE`). Contributions are accepted under the same license.
