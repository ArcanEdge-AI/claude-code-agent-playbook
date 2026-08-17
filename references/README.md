# Global Claude Code Reference Documents

This directory contains global reference documents that the root Claude Code session uses to orchestrate repository work, route bounded subagent execution, review, validate, and coordinate related sessions.

These documents are intentionally generic and tool-agnostic unless explicitly Claude-Code-specific. They should not contain repo-specific workflows, sensitive access material, local machine quirks, project names, or one-off incident notes.

## How to Use These References

The root session should:

1. Start with the current user request and applicable `CLAUDE.md` instructions.
2. Inspect current code, tests, configuration, and docs.
3. Consult only the global reference documents that are relevant.
4. Treat reference docs as supporting context, not automatic truth.
5. Route bounded execution to at least one subagent for repository tasks when subagents are available, and pass only relevant context.
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

- `model-routing.md` — mandatory actual-root-model ceilings, Claude family ranks, explicit per-invocation model routing, definition-level effort, permission, tool, depth, replacement, and acceptance rules for subagents.
- `subagents.md` — finite-manifest rules for root permits, two delegated generations, bounded execution, handoff verification, and fan-in.
- `worktrees.md` — root-owned task-local worktree budgeting, Claude Code isolation, integration, cleanup, and preservation rules.
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
- `templates/active-work-record.md` — optional repository-local record for active Claude Code session ownership, contracts, upstream work dependencies, blockers, and validation gates.
- `templates/task-graph.md` — optional instruction-only task graph for complex Claude Code work with real dependencies, declared ownership, permission and tool boundaries, worktree base-state requirements, and verification gates.
- `templates/worktree-manifest.md` — optional task-local ledger for auxiliary-worktree permits, Claude Code isolation, integration, and final disposition.

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
