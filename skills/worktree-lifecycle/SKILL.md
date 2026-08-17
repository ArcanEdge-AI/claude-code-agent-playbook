---
name: worktree-lifecycle
description: Manage Git worktrees created or used during a Claude Code task. Use when the root proposes Claude Code worktree isolation, parallel writers may need filesystem isolation, a task already owns auxiliary worktrees, or the root must integrate, preserve, or remove a task-created worktree before completion.
---

# Worktree Lifecycle

Keep worktree use finite, root-owned, and task-local. A subagent is not a reason to create a worktree. The default is the current shared workspace with an auxiliary-worktree budget of zero.

Consult `references/worktrees.md` for complete rules and `references/templates/worktree-manifest.md` when a durable ledger is justified.

## Workflow

1. Inspect the current checkout, common Git directory, branch or detached HEAD, registered worktrees, dirty state, and known Claude Code session ownership.
2. Classify the current checkout as host-managed primary, user-managed existing, or task-created auxiliary.
3. Keep the auxiliary budget at zero unless a planned writer needs branch or filesystem isolation that shared execution or serialization cannot provide safely.
4. Let only the root raise the finite budget and issue a worktree permit. The root may authorize one active auxiliary without additional approval; two or more require approval for the exact count and reasons.
5. Record exact base ref and SHA. Account for `worktree.baseRef` before using `isolation: worktree` because the isolated checkout may not contain the parent session's current changes.
6. Reuse a compatible task-owned worktree before creating another. Never create one merely because a new subagent or retry exists.
7. Assign every node its exact workspace and write scope. Descendants must not request isolation, create, adopt, repurpose, move, or remove worktrees.
8. Integrate accepted work through the declared target and validate the combined result.
9. Before the final response, set every task-created auxiliary to `removed` under verified gates or `preserved` with an exact blocker. Do not defer task-owned cleanup to scheduled automation.

## Creation Gate

Create an auxiliary only when all are true:

- repository and common Git directory are verified
- base ref and exact SHA are recorded
- path and branch are explicit or host-assigned under the permit and collision-free
- concrete write or mutable-state isolation is required
- shared execution, reuse, or serialization is insufficient
- the finite root budget has capacity and a root permit exists
- ownership, integration target, and cleanup condition are recorded

No bundled agent enables `isolation: worktree` globally. Use it only on a root-authorized dispatch supported by the current Claude Code client.

## Completion Gate

Remove a task-created auxiliary only after verifying:

- exact permit, canonical path, repository identity, owner, branch or HEAD
- accepted work is integrated or abandonment is explicitly authorized
- tracked, untracked, submodule, and valuable ignored artifacts are accounted for
- no running process depends on the checkout
- the work is recoverable through its integration or backup target
- the checkout is not active and is not owned by another session or user

Prefer supported Claude Code cleanup when the host owns the auxiliary. Otherwise use non-force `git worktree remove <exact-path>` and verify both path and registration removal. Never use force, reset, clean, stash, broad recursive deletion, age, or clean status alone.

If any gate fails, preserve the worktree and return its canonical path, owner, branch or detached HEAD, exact blocker, and next action. The active host-managed worktree remains under the host's lifecycle.

## Required Result

Return a compact ledger of starting worktrees, auxiliary budget, permits, created or reused workspaces, integration evidence, final dispositions, and any preserved blocker.
