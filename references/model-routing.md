# Claude Code Subagent Model, Effort, and Permission Routing

The main Claude Code session must explicitly route each delegated task to the smallest Claude model, lowest effort level, and safest permission mode likely to complete it reliably.

This is an execution rule, not a suggestion.

## Why Explicit Routing Is Required

Claude Code subagents use `inherit` when the `model` field is omitted and inherit the session effort level when `effort` is omitted. Permission behavior can also vary with the parent session unless the role declares an appropriate baseline.

The installed subagent profiles therefore pin explicit Claude model aliases, effort levels, permission modes, and tool allowlists. Do not remove those fields without an explicit maintainer decision.

## Default Profiles

| Profile | Model | Effort | Permission mode | Intended work |
| --- | --- | --- | --- | --- |
| `read-only-explorer` | `haiku` | `low` | `plan` | Focused repository exploration, call-site mapping, and pattern discovery. |
| `docs-researcher` | `haiku` | `low` | `plan` | Focused repository and authoritative documentation lookup. |
| `test-triager` | `sonnet` | `medium` | `default` | Bounded test diagnosis, log analysis, and explicitly approved diagnostic edits. |
| `isolated-worker` | `sonnet` | `medium` | `default` | Small, isolated, well-specified implementation with normal approval prompts. |
| `senior-reviewer` | `sonnet` | `high` | `plan` | Evidence-backed read-only review with escalation for high-impact judgment. |

These are supporting subagents. The main Claude Code session retains architecture ownership and final judgment.

## Selection Rules

Before spawning a subagent:

1. Confirm delegation creates real leverage.
2. Bound the goal, scope, permissions, and evidence requirements.
3. Choose the profile whose role most closely matches the task.
4. Use the configured Claude model, effort, permission mode, and tool allowlist instead of inherited or broader settings.
5. State why the selected profile is sufficient.
6. Define the conditions that require stopping and escalation.
7. Define how the main session will independently verify the result.

When two profiles appear suitable, choose Haiku or the more constrained profile when it can complete the task reliably.

## Permission Rules

- Use `plan` for read-only exploration, documentation research, and review.
- Use `default` for roles that may edit files so Claude Code retains normal approval prompts.
- Do not use `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions` in bundled profiles without a specific maintainer-approved use case and documented risk analysis.
- Treat the `tools` field as an allowlist. Read-only profiles must not include `Edit` or `Write`.
- If the parent session uses a mode that overrides subagent permission behavior, report that limitation rather than implying the profile enforced a stricter mode.

## Worktree Isolation

Claude Code supports `isolation: worktree`, but the bundled profiles do not enable it globally.

Use worktree isolation only when the assignment can safely start from the repository's default branch or when the invoking workflow explicitly establishes the required base state. A global worktree setting can omit uncommitted changes or current-branch commits that exist only in the parent session.

For parallel project work, use the multi-session coordination workflow to decide branch and worktree ownership explicitly.

## Keep With the Main Session

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

A smaller subagent may gather evidence for these areas, but the main session must make and verify the decision.

## Escalation

A subagent must stop and report when:

- requirements are materially ambiguous
- primary evidence conflicts
- the task exceeds its assigned scope
- the conclusion cannot be independently verified
- the work becomes security-sensitive, destructive, or production-impacting
- the task requires architectural or cross-system judgment

The subagent must not silently change its model, effort, permission mode, tool access, or isolation behavior, or fall back to inherited settings.

The main session may rerun a narrowed task with Opus, higher effort, or broader permissions only after documenting:

- why the configured Haiku or Sonnet profile was insufficient
- why narrowing or supplying more context did not solve the problem
- what model, effort, and permission mode will be used
- whether worktree isolation is required and which base state it must use
- what evidence the stronger run must return
- how the result will be independently checked

## Required Assignment Fields

```text
Role:
Selected profile or model:
Effort level:
Permission mode:
Tool boundary:
Why this is the smallest suitable choice:
Goal:
Context:
Scope:
Non-goals:
Evidence required:
Escalation conditions:
Output format:
```

## Acceptance Check

Before accepting delegated work, confirm:

- the model or profile was explicitly selected
- the effort level was explicitly selected
- the permission mode and tool boundary match the role
- `inherit` was not used unintentionally
- any Opus, higher-effort, broader-permission, or worktree-isolation escalation was justified
- the subagent stayed within scope
- claims are supported by primary evidence
- the main session independently reviewed material findings and edits
