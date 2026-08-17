---
name: subagent-orchestration
description: Use when a coding task needs Claude Code subagents for bounded execution, local orchestration, exploration, review, docs research, test triage, or implementation. Enforces a finite root manifest, two delegated generations, root permits, task-sized model and capability ceilings, shared-workspace defaults, and root verification.
---

# Subagent Orchestration

The root Claude Code session owns root topology, permits, budgets, worktree lifecycle, integration, and final acceptance. Subagents perform bounded execution.

Use this skill for complex, multi-file, risky, ambiguous, read-heavy, validation-heavy, or safely isolated implementation work. Use `multi-session-coordination` instead when independent Claude Code sessions already own related project work.

Keep a simple bounded task as one direct-worker node. Do not create hierarchy when one worker can complete the subset reliably.

## Finite Dependency-Aware Delegation

Before dispatch, the root records a finite manifest and total subagent budget. Each node declares:

- node, parent, and child IDs
- root-issued permit
- non-empty completion subset strictly smaller than its parent's remaining subset
- goal, inputs, output, and acceptance condition
- only real blocking dependencies
- read scope or disjoint write ownership
- named Claude Code agent, explicit per-invocation model, and selected definition-level effort at or below parent ceilings
- `permissionMode` and exact tools equal to or narrower than the parent boundary
- exact workspace and separate worktree permit when applicable
- verification gate

Dispatch only ready manifest nodes with remaining budget and runtime, safety, permission, and ownership capacity. Runtime-full is backpressure. Do not create speculative descendants.

A dependency exists only when a node cannot begin correctly without an accepted upstream artifact or decision. Serialize overlapping writers unless root-authorized isolation is verified. Preserve accepted outputs after unrelated failures and invalidate only downstream work that consumed rejected output.

## Two Delegated Generations

Depth 0 is the root session. Depth 1 contains named direct workers or `local-orchestrator`. Depth 2 contains execution leaves that omit `Agent` and cannot spawn. Depth 3 is prohibited.

Only the root issues permits or expands the total budget. A `local-orchestrator` may use `Agent` only for root-permitted depth-2 leaves already in the manifest. Every child must remain equal to or narrower than its parent in inputs, data access, model, effort, permissions, tools, scope, non-goals, workspace, authority, and approval boundary. Equal-tier model and effort routes are valid; depth does not force a drop. Sibling write ownership must be disjoint.

Before a local orchestrator uses `Agent`, nested subagents must be supported and `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` must already be active in an authorized settings scope and verified. If either gate is unavailable or unknown, depth 1 executes directly without `Agent` or reports upward. Do not emulate depth 2 with independent sessions or change the setting without authorization.

Retries reuse their node ID, permit, and compatible workspace. Replacements require a new root permit and budget. Descendants cannot request or perform a stronger model, higher effort, broader permissions, more tools, expanded scope, greater authority, or worktree isolation.

Keep payloads to minimum paths and accepted artifacts; reuse accepted outputs, avoid duplicate discovery, and omit full history, transcripts, and long logs.

## Model, Effort, Permission, and Tool Routing

Consult `references/model-routing.md` before dispatch.

- Use explicit root-permitted named-agent routes; reject automatic delegation and do not rely on `inherit` for routine work.
- Record the actual user-selected root model and rank; never assume Opus because it is available.
- Use Opus rank 3, Sonnet rank 2, and Haiku rank 1. Require `child rank <= parent rank`; equal rank is valid.
- Prefer Haiku / low for focused exploration and documentation lookup.
- Prefer Sonnet / medium for bounded implementation and test triage.
- Prefer Sonnet / high for meaningful review and local orchestration.
- With an Opus root, normally use Sonnet or Haiku; use an Opus child only for an exceptional bounded assignment with a recorded reason and verification plan. A Sonnet root may use Sonnet or Haiku. A Haiku root may use Haiku only.
- Pass the intended model explicitly on every `Agent` invocation; all bundled frontmatter models fail closed at Haiku and are not execution authority.
- Effort is fixed by the selected agent definition; do not claim a per-invocation effort override. Keep both the effective child model tier and effort at or below the parent ceilings.
- Use `plan` for read-only work and `default` for bundled write-capable roles.
- Treat `tools` as an allowlist. Only `local-orchestrator` includes `Agent`.
- Do not use bundled `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions` without approved risk analysis.
- Treat an environment override, allowlist or provider substitution, resumed-route change, unknown alias, or unavailable model as a failed routing gate. Use the exact known parent family only when the runtime can explicitly enforce and verify it; otherwise keep the work with the parent or report the limitation.
- A descendant preserves completed work and stops when its ceiling is insufficient; it does not request an upgrade. Only the root may route a new depth-1 replacement at any approved tier within the actual root ceiling, including a tier stronger than the failed child, with a new permit, budget, reason, and verification plan.

## Shared Workspace and Worktree Budget

Start in the current shared workspace with an auxiliary-worktree budget of zero. Only the root may raise the budget, issue a separate worktree permit, authorize `isolation: worktree`, create or adopt an auxiliary, change its purpose, move it, or remove it.

The root may authorize one active auxiliary without additional approval; two or more require user approval for the exact count and reasons. Descendants use only their assigned workspace and do not set isolation on child calls. Reuse compatible worktrees for retries.

Before the final response, the root integrates and removes every task-created auxiliary under `references/worktrees.md` or preserves it with exact path, owner, branch or HEAD, blocker, and next action. Do not defer task-owned cleanup to scheduled automation. Keep the active host-managed worktree under the host lifecycle.

## Workflow

1. Clarify the goal, success criteria, active instructions, actual root model and rank, and root task ceiling.
2. Map bounded nodes, real dependencies, parallel-safe ownership, and the completion-controlling path.
3. Record the finite manifest, total subagent budget, permits, exact workspaces, and any root direct-execution exception.
4. Select Local Orchestrator, Read-Only Explorer, Docs Researcher, Test Triager, Isolated Worker, or Senior Reviewer.
5. Route an explicit per-invocation model and select a definition whose fixed effort, permission mode, and tools fit the parent ceilings.
6. Give each subagent a precise assignment containing:
   - role, goal, context, scope, and non-goals
   - parent and child IDs, root permit, strict subset, and total-budget status
   - inherited model, effort, permission, tool, workspace, scope, authority, and approval ceilings
   - sibling ownership non-overlap
   - output and acceptance condition
   - required primary evidence and validation
   - escalation and stop conditions
   - compact parent return bundle
7. Launch only ready permitted nodes with remaining budget and runtime capacity.
8. Verify returned claims against primary evidence. Use a separate verifier when risk warrants it.
9. Retry failed nodes with the same ID and permit; invalidate only dependent work whose inputs changed.
10. Fan in only accepted inputs, then inspect the combined diff and validate integrated behavior.
11. Accept, reject, or revise within existing ceilings. Only the root may create a replacement, and it may be stronger than the failed child only while remaining within the actual root ceiling.
12. Reconcile every task-created auxiliary worktree before the final response.
13. Report permit and budget use, subagent work, validation, and workspace dispositions.

Never accept a subagent conclusion solely because it sounds confident.
