# Global Claude Code Reference Documents

This directory contains global reference documents that the main Claude Code session may consult when planning, delegating, implementing, reviewing, validating, or coordinating work.

These documents are intentionally generic and tool-agnostic unless explicitly Claude-Code-specific. They should not contain repo-specific workflows, sensitive access material, local machine quirks, project names, or one-off incident notes.

## How to Use These References

The main session should:

1. Start with the current user request and applicable `CLAUDE.md` instructions.
2. Inspect current code, tests, configuration, and docs.
3. Consult only the global reference documents that are relevant.
4. Treat reference docs as supporting context, not automatic truth.
5. Pass only relevant context to subagents or independent project sessions.
6. Resolve conflicts using primary evidence.

Primary evidence includes:

- current code
- tests
- schemas
- configuration
- logs
- build output
- typecheck output
- runtime behavior
- relevant Claude Code session evidence
- authoritative external documentation

## Available References

- `model-routing.md` — mandatory Claude model-selection, effort, escalation, and acceptance rules for subagents.
- `subagents.md` — rules for when and how to delegate to Claude Code subagents.
- `multi-session-coordination.md` — discovery, ownership, sequencing, session naming, conflict detection, and integration guidance for independent Claude Code sessions.
- `reference-doc-routing.md` — how to choose and classify reference documents.
- `templates/repository-CLAUDE.md` — starter template for repo-specific `CLAUDE.md` instructions.
- `templates/architecture.md` — architecture reference template.
- `templates/testing.md` — testing strategy template.
- `templates/security.md` — safety and access-control model template.
- `templates/design-system.md` — design-system and UI convention template.
- `templates/release.md` — release and deployment template.
- `templates/api-contracts.md` — API contract template.
- `templates/data-model.md` — data model and persistence template.
- `templates/active-work-record.md` — optional repository-local record for active Claude Code session ownership, contracts, dependencies, and validation requirements.

## Placement Rules

Use global references under the resolved Claude Code home for durable, cross-repository guidance.

Use repository-level docs for:

- repo architecture
- repo build/test commands
- repo release flow
- repo-specific design rules
- framework-specific conventions
- domain-specific business logic
- project-specific subagent roles
- project-specific active-work records

Use skills for repeatable workflows.

Use `CLAUDE.local.md` or other local notes for machine-specific or shell-specific quirks.
