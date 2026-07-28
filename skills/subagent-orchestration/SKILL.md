---
name: subagent-orchestration
description: Use when a coding task may benefit from Claude Code subagents for codebase exploration, review, docs research, test triage, or isolated implementation. Enforces task-sized model, effort, and permission routing, bounded delegation, and main-session verification.
---

# Subagent Orchestration Skill

The main Claude Code session is the senior developer and orchestrator. Subagents assist but do not own the outcome.

Use this skill when:

- the task is complex, multi-file, risky, or ambiguous
- independent read-heavy exploration would help
- review from another perspective would improve quality
- documentation or external API behavior needs verification
- logs, tests, or large files need focused analysis
- a small isolated implementation can be delegated safely

Do not use this skill when:

- the task is trivial
- one coherent design judgment is required
- requirements are materially unclear
- subagents would edit the same files
- the main session cannot verify the result
- multiple independent Claude Code sessions are already implementing related work

When multiple independent project sessions need discovery, conflict detection, ownership, sequencing, or integration guidance, use the `multi-session-coordination` skill instead. Do not spawn additional implementation subagents merely to solve an existing session-coordination conflict.

## Mandatory Model, Effort, and Permission Routing

Before spawning a subagent, consult `references/model-routing.md` when available.

- Explicitly select a custom subagent or per-invocation model for every delegated task.
- Do not rely on the default `inherit` behavior for routine subagent work.
- Use the smallest Claude model and lowest effort likely to complete the bounded task reliably.
- Use `plan` permission mode for read-only exploration, documentation research, and review.
- Use `default` permission mode for bundled write-capable roles so normal approval prompts remain active.
- Treat each profile's `tools` field as an allowlist.
- Prefer Haiku with low effort for read-only exploration and focused documentation lookup.
- Prefer Sonnet with medium effort for bounded implementation and test triage.
- Prefer Sonnet with high effort for meaningful review.
- Keep architecture, security-sensitive judgment, destructive operations, migrations, complex concurrency, and other high-impact decisions with the main session unless Opus, higher effort, or broader permissions are explicitly justified.
- Do not enable bundled `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions` modes without maintainer-approved risk analysis.
- Do not force `isolation: worktree` globally; decide isolation from the assignment's required base state.
- A subagent must stop and report a capability gap. It must not silently change its model, effort, permission mode, tools, or isolation behavior, or fall back to inherited settings.
- If a stronger model, higher effort, broader permission mode, or worktree isolation is selected, record why the configured profile is insufficient and how the result will be independently verified.

## Workflow

1. Clarify the task goal and success criteria.
2. Decide which work, if any, should be delegated.
3. Choose from the Claude Code roles: Read-Only Explorer, Senior Reviewer, Docs Researcher, Test Triager, and Isolated Worker.
4. Select the smallest suitable custom profile or per-invocation Claude model, effort, permission mode, and tool boundary.
5. Give each subagent a precise assignment:
   - role
   - goal
   - context
   - selected profile or model
   - effort level
   - permission mode
   - tool boundary
   - why it is the smallest suitable choice
   - escalation conditions
   - scope
   - non-goals
   - required evidence
   - output format
6. Wait for delegated results before accepting conclusions.
7. Verify subagent claims against primary evidence.
8. Inspect any changed files yourself.
9. Accept, reject, revise, or rerun with stronger settings only when justified.
10. Report relevant subagent usage and any escalation in the final response.

Never accept a subagent's conclusion solely because it sounds confident.
