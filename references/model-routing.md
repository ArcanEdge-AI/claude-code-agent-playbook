# Claude Code Subagent Model Routing

The main agent must explicitly route each delegated task to the smallest model likely to complete it reliably.

This is an execution rule, not a suggestion.

## Why Explicit Routing Is Required

Claude Code subagents use `inherit` when the `model` field is omitted. That can cause routine subagents to use the same expensive model as the main conversation.

The installed agent profiles therefore pin explicit model aliases. Do not remove those fields without an explicit maintainer decision.

## Default Profiles

| Profile | Model | Intended work |
| --- | --- | --- |
| `read-only-explorer` | `haiku` | Focused repository exploration, call-site mapping, and pattern discovery. |
| `docs-researcher` | `haiku` | Focused repository and authoritative documentation lookup. |
| `test-triager` | `sonnet` | Bounded test diagnosis, log analysis, and targeted diagnostic edits. |
| `isolated-worker` | `sonnet` | Small, isolated, well-specified implementation. |
| `senior-reviewer` | `sonnet` | Evidence-backed review with escalation for high-impact judgment. |

These are supporting agents. The main orchestrator retains architecture ownership and final judgment.

## Selection Rules

Before spawning a subagent:

1. Confirm delegation creates real leverage.
2. Bound the goal, scope, permissions, and evidence requirements.
3. Choose the profile whose role most closely matches the task.
4. Use the configured model instead of `inherit`.
5. State why the selected profile is sufficient.
6. Define the conditions that require stopping and escalation.
7. Define how the main agent will independently verify the result.

When two profiles appear suitable, choose Haiku or the more constrained profile.

## Keep With the Main Agent

Do not delegate final ownership of:

- architecture and system design
- security-sensitive or access-control decisions
- authentication, authorization, privacy, payments, or billing
- destructive operations
- data migrations or persisted-schema strategy
- concurrency, locking, queues, caching, or background-job design
- public API compatibility
- release or production-impacting configuration
- large or high-impact refactors
- final acceptance of meaningful changes

A smaller subagent may gather evidence for these areas, but the main agent must make and verify the decision.

## Escalation

A subagent must stop and report when:

- requirements are materially ambiguous
- primary evidence conflicts
- the task exceeds its assigned scope
- the conclusion cannot be independently verified
- the work becomes security-sensitive, destructive, or production-impacting
- the task requires architectural or cross-system judgment

The subagent must not silently change models or fall back to `inherit`.

The main agent may rerun a narrowed task with Opus only after documenting:

- why the configured Haiku or Sonnet profile was insufficient
- why narrowing or supplying more context did not solve the problem
- what evidence the stronger agent must return
- how the result will be independently checked

## Required Assignment Fields

```text
Role:
Selected profile or model:
Why this is the smallest suitable choice:
Goal:
Context:
Scope:
Non-goals:
Permissions:
Evidence required:
Escalation conditions:
Output format:
```

## Acceptance Check

Before accepting delegated work, confirm:

- the model or profile was explicitly selected
- `inherit` was not used unintentionally
- any Opus escalation was justified
- the subagent stayed within scope
- claims are supported by primary evidence
- the main agent independently reviewed material findings and edits
