---
name: subagent-orchestration
description: Use when a coding task may benefit from Claude Code subagents for codebase exploration, review, docs research, test triage, or isolated implementation. Enforces dependency-aware decomposition, task-sized model, effort, and permission routing, bounded delegation, and main-session verification.
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

## Dependency-Aware Delegation

Keep simple tasks simple. For work with multiple delegable parts, define each candidate work node with:

- a node identifier
- one bounded goal
- inputs and authoritative sources
- an output and acceptance condition
- only the upstream nodes that block it from starting
- write ownership or read scope
- a verification gate proportionate to risk

A dependency exists only when a node cannot correctly begin without an accepted upstream artifact or decision. Identify which nodes are safe to run in parallel and which remaining chain of blocking work controls completion.

Run independent nodes concurrently only when the runtime can isolate them, their writes and mutable state do not conflict, and the coordination cost is justified. State a concurrency limit and rationale instead of assuming unlimited fan-out. Serialize overlapping writers unless verified isolation is available. Treat `isolation: worktree` as safe only when the assignment's required base state is explicit and the isolated worktree is confirmed to start from that state.

While delegated work is running, continue available independent, non-conflicting planning, inspection, integration, or validation work in the main session. Do not wait solely for a subagent when useful work remains. Do not invent parallel work, exceed runtime limits, broaden permission modes, or trade evidence and verification for lower latency.

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
2. For multi-node work, map bounded nodes, real blocking dependencies, parallel-safe nodes, the completion-controlling path, and required handoff gates.
3. Decide which work, if any, should be delegated and whether parallel execution creates real leverage.
4. Choose from the Claude Code roles: Read-Only Explorer, Senior Reviewer, Docs Researcher, Test Triager, and Isolated Worker.
5. Select the smallest suitable custom profile or per-invocation Claude model, effort, permission mode, and tool boundary.
6. Give each subagent a precise assignment:
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
   - for multi-node work, the node identifier, inputs, output and acceptance condition, blocking dependencies, ownership or read scope, and verification gate
7. Launch only parallel-safe nodes concurrently and keep write-heavy work sequential unless isolation is verified.
8. Verify subagent claims against primary evidence. For meaningful implementation, use a separate verification task with only the necessary artifact, criteria, and evidence requirements when the runtime supports it; the main session still decides acceptance.
9. If a gate fails, revise or rerun the failed node and any downstream nodes whose inputs became invalid. Do not restart unrelated nodes by default.
10. Before combining results, confirm every required input passed its designated gate, then inspect the combined diff and run validation for the integrated behavior.
11. Accept, reject, revise, or rerun with stronger settings only when justified.
12. Report relevant subagent usage, concurrency decisions, and any escalation in the final response.

Never accept a subagent's conclusion solely because it sounds confident.
