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
- Keep the main-agent accountability model intact.

## Pull Request Checklist

Before opening a PR:

- Review Markdown formatting and fenced code blocks.
- Confirm links and paths match the repository tree.
- Confirm `SKILL.md` files include `name` and `description` frontmatter.
- Confirm `agents/*.md` files include valid YAML frontmatter (`name`, `description`, `tools`) if changed, and that read-only roles exclude `Edit`/`Write`.
- Confirm no sensitive or private material was added.

## License Note

This project is MIT licensed (see `LICENSE`). Contributions are accepted under the same license.
