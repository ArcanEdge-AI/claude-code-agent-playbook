# Claude Code Task-Local Worktree Lifecycle

The root Claude Code session owns every Git worktree decision made inside its task. Worktrees are isolation tools, not the unit of delegation. Spawning a subagent, retrying a node, or increasing fan-out does not create a worktree requirement.

This reference governs task-local worktree use. It does not depend on a scheduled cleanup task and does not authorize a broad sweep of old, host-managed, user-owned, or unrelated worktrees.

## Workspace Classes

| Class | Meaning | Task-local disposition |
| --- | --- | --- |
| Host-managed primary | The active task workspace was created or managed by Claude Code CLI, Desktop, web, an IDE integration, or another host. | Record it. Do not delete the active checkout from inside itself. Use the host's supported task or workspace lifecycle. |
| User-managed existing | The checkout predates the task or has ownership outside it. | Inspect read-only unless the user or repository evidence grants ownership. Never remove it as task cleanup. |
| Task-created auxiliary | The root created or caused Claude Code to create it under a task-local permit for a declared isolation need. | Integrate, verify, and remove before the final response when every cleanup gate passes; otherwise preserve it with an exact blocker. |

## Default Policy

- Start in the current workspace with an auxiliary-worktree budget of `0`.
- Keep the worktree budget separate from the total subagent budget.
- The root may authorize at most one active auxiliary without additional user approval. Two or more require approval for the exact count and reasons.
- Do not allocate one worktree per agent, node, role, retry, or depth level.
- Read-only work and disjoint bounded writes normally use the shared workspace.
- Serialize overlapping or tightly coupled writes. Separate checkouts do not resolve design or merge conflicts.
- Raise the finite worktree budget only for a specific writer that needs real branch or filesystem isolation.
- Only the root may issue a worktree permit, invoke `EnterWorktree`, authorize an `isolation: worktree` dispatch, create or adopt an auxiliary checkout, change its purpose, move it, or remove it.
- Descendants use the exact workspace assigned by the root. They do not set `isolation: worktree` on child invocations and report additional isolation needs upward.
- Retries reuse the same compatible worktree. A replacement agent does not receive another worktree automatically.

A task may use many bounded subagents and zero auxiliary worktrees.

## Claude Code Isolation Semantics

Claude Code supports `isolation: worktree` in custom agent definitions and supported Agent invocations. The bundled agents do not enable it globally.

Before authorization, account for these native behaviors:

- an isolated subagent runs file and shell work in a temporary Git worktree
- the worktree may branch from the repository default branch rather than the parent session's `HEAD`
- `worktree.baseRef` controls whether supported clients use a fresh remote default-branch base or the current `HEAD`
- an unchanged isolated worktree may be cleaned automatically by Claude Code
- a changed isolated worktree requires integration and an explicit safe disposition
- `EnterWorktree` and `ExitWorktree` are deliberately omitted from every bundled subagent allowlist; descendants are prohibited by this policy from using them even when a Claude Code runtime could expose them

Record the expected base ref and exact SHA before dispatch, then verify the actual checkout after creation. Do not treat a host default as proof that the required parent changes are present.

## When an Auxiliary Worktree Is Justified

An auxiliary may be justified when:

- the user explicitly requests a separate branch or worktree
- the host or repository workflow requires branch-isolated delivery
- an independent writer must preserve conflicting in-progress work while starting from a verified base
- build, test, generation, or mutable-state behavior cannot be isolated safely in the current workspace
- a long-running write stream needs a stable checkout while integration proceeds elsewhere

It is not justified only because another subagent is available, tasks can run in parallel, a node is read-only, a previous attempt failed, a checkout is old, or a clean status looks disposable.

## Root Worktree Permit

Before creating or adopting a task-local auxiliary, record:

| Field | Required value |
| --- | --- |
| Permit ID | Stable root-issued identifier, separate from a subagent permit. |
| Node or owner | The node responsible for work in the checkout. |
| Repository identity | Repository root and common Git directory. |
| Canonical path | Exact absolute worktree path, or the host-assigned path to verify immediately after creation. |
| Base | Base ref and exact base SHA. |
| Branch or detached HEAD | Exact intended Git state. |
| Write scope | Paths or mutable state owned in this workspace. |
| Isolation reason | Why shared execution or serialization is insufficient. |
| Creation path | `isolation: worktree`, `EnterWorktree`, host UI, or explicit Git command. |
| Integration target | Branch, commit, patch, pull request, or other accepted handoff. |
| Cleanup condition | Evidence that will make removal safe. |
| State | `proposed`, `active`, `integration-ready`, `cleanup-ready`, `removed`, or `preserved`. |

Use `references/templates/worktree-manifest.md` when the ledger must persist across phases or sessions. A concise working-plan entry is enough for a small task.

## Creation Procedure

1. Inspect `git worktree list --porcelain` from the verified repository.
2. Resolve the common Git directory, current branch or detached HEAD, exact HEAD, and dirty state.
3. Check related Claude Code session, branch, and worktree ownership.
4. Prefer shared execution, serialization, or a compatible task-owned auxiliary.
5. Confirm the path is explicit or host-assigned under the permit and does not collide with a registered checkout.
6. Confirm the branch is not checked out elsewhere and the exact base SHA is correct. Set or account for `worktree.baseRef` when using Claude Code isolation.
7. Record the permit and finite budget. Obtain user approval first if the result would allow two or more active auxiliaries.
8. Let only the root create the worktree through supported Claude Code or non-force Git behavior.
9. Verify the actual canonical path, registration, branch or HEAD, base state, and starting status before assigning work.

Do not create a worktree speculatively. Do not let a descendant choose an unrecorded path, base, branch, or isolation mode.

## Execution and Integration

- Give every writer the exact workspace and write scope.
- Keep sibling ownership disjoint even when checkouts differ.
- Record HEAD and dirty state at meaningful handoffs.
- Validate the produced artifact before integration.
- Integrate through the declared target and verify the combined result in the integration workspace.
- Keep the auxiliary until accepted work is recoverable and the cleanup gate passes.
- Reuse the same workspace for a retry unless primary evidence proves it incompatible.

## In-Task Cleanup

Before the final response, enumerate every task-created auxiliary permit. For each checkout:

1. Reconfirm canonical path, common Git directory, branch or detached HEAD, exact HEAD, and permit.
2. Confirm its output is accepted and integrated, or abandonment is explicitly within task authority.
3. Account for tracked files, untracked files, submodules, and valuable ignored artifacts. Short clean status alone is insufficient.
4. Check for running processes, terminals, tests, or services that depend on the checkout when the environment can expose them.
5. Confirm the work is recoverable through the integration target, remote backup, tag, or explicit preservation decision.
6. Confirm the target is not the active checkout and is not owned by another session or user.
7. Prefer the supported Claude Code lifecycle when it owns the auxiliary; otherwise use non-force `git worktree remove <exact-path>` only for the verified task-created target.
8. Prune only stale registration metadata for the verified repository when needed; never use prune as a substitute for ownership checks.
9. Verify both path absence and removal from `git worktree list --porcelain`.
10. Mark the permit `removed` with evidence.

Never use force removal, reset, clean, stash, broad recursive deletion, age, inactivity, or clean status alone. If any check is unavailable or ambiguous, mark the worktree `preserved` and report the exact missing evidence or ownership blocker.

## Final Task Contract

Report one disposition for every relevant worktree:

- `removed` — task-created auxiliary cleanup gates passed and path plus registration removal were verified
- `preserved` — exact path, owner, branch or HEAD, blocker, and next action are named
- `reused` — the task used an existing checkout and did not own its removal
- `host-managed` — the active workspace remains under the supported host lifecycle

Do not say the task is clean merely because scheduled automation may inspect it later.
