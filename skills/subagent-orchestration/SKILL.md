---
name: subagent-orchestration
description: Use when a coding task may benefit from Claude Code subagents for codebase exploration, review, docs research, test triage, or isolated implementation. Enforces task-sized model routing, bounded delegation, and main-agent verification.
---

# Subagent Orchestration Skill

The main agent is the senior developer and orchestrator. Subagents assist but do not own the outcome.

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
- the main agent cannot verify the result

## Mandatory Model Routing

Before spawning a subagent, consult `references/model-routing.md` when available.

- Explicitly select a custom subagent or per-invocation model for every delegated task.
- Do not rely on the default `inherit` behavior for routine subagent work.
- Use the smallest model likely to complete the bounded task reliably.
- Prefer Haiku for read-only exploration and focused documentation lookup.
- Prefer Sonnet for bounded implementation, test triage, and meaningful review.
- Keep architecture, security-sensitive judgment, destructive operations, migrations, complex concurrency, and other high-impact decisions with the main orchestrator unless Opus is explicitly justified.
- A subagent must stop and report a capability gap; it must not silently escalate itself or fall back to the main model.
- If a stronger model is selected, record why the smaller configured profile is insufficient and how the result will be independently verified.

## Workflow

1. Clarify the task goal and success criteria.
2. Decide which work, if any, should be delegated.
3. Choose from the Claude Code roles: Read-Only Explorer, Senior Reviewer, Docs Researcher, Test Triager, and Isolated Worker.
4. Select the smallest suitable custom profile or per-invocation model.
5. Give each subagent a precise assignment:
   - role
   - goal
   - context
   - selected profile or model
   - why it is the smallest suitable choice
   - escalation conditions
   - scope
   - non-goals
   - permissions
   - required evidence
   - output format
6. Wait for delegated results before accepting conclusions.
7. Verify subagent claims against primary evidence.
8. Inspect any changed files yourself.
9. Accept, reject, revise, or rerun with a stronger model only when justified.
10. Report relevant subagent usage and any escalation in the final response.

Never accept a subagent's conclusion solely because it sounds confident.
