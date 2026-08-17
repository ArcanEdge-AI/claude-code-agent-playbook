# Claude Code Subagent Model, Effort, Permission, and Tool Routing

The parent of every delegated node must explicitly select a named Claude Code agent and invocation model, then verify that the definition-level effort, permission mode, and tool boundary suit the assigned task and inherited ceilings. The actual model selected for the main Claude Code session is the root model ceiling; never assume that the root is running Opus.

This is an execution rule, not a suggestion.

## Why Explicit Routing Is Required

Claude Code uses `inherit` when a subagent definition omits `model` and inherits session effort when it omits `effort`. A per-invocation `model` takes precedence over an agent definition's frontmatter, but `CLAUDE_CODE_SUBAGENT_MODEL` takes precedence over both. Organization model allowlists may substitute another model. Claude Code documents effort as agent frontmatter, not as an `Agent` invocation argument; the effective effort still must be verified rather than inferred. Permission behavior may also vary with the parent session unless the role declares a baseline.

The bundled agents therefore pin fail-closed Haiku defaults, fixed role effort levels, `permissionMode`, and `tools` allowlists. Every managed dispatch must be an explicit root-permitted `Agent` route that passes a model at or below the parent ceiling. Do not use automatic delegation for this bounded contract: an automatic route or omitted invocation model is unauthorized and its result is not accepted. The Haiku frontmatter default prevents an omitted-model route from exceeding a Haiku root, but it is not a substitute for the explicit route and permit. Do not remove these fields without an explicit maintainer decision. Treat any runtime substitution warning or unresolved effective model as a failed routing gate, not as an acceptable fallback.

## Bundled Agents

| Agent | Fail-closed default | Normal explicit model | Fixed effort | Permission mode | Tools and depth role | Intended work |
| --- | --- | --- | --- | --- | --- | --- |
| `read-only-explorer` | `haiku` | `haiku` | `low` | `plan` | Read-only, no `Agent`; depth-1 worker or depth-2 leaf | Focused repository exploration, call-site mapping, and pattern discovery. |
| `docs-researcher` | `haiku` | `haiku` | `low` | `plan` | Read/web, no `Agent`; depth-1 worker or depth-2 leaf | Focused repository and authoritative documentation lookup. |
| `test-triager` | `haiku` | `sonnet` | `medium` | `default` | Bounded test tools, no `Agent`; depth-1 worker or depth-2 leaf | Test diagnosis, log analysis, and explicitly authorized diagnostic edits. |
| `isolated-worker` | `haiku` | `sonnet` | `medium` | `default` | Bounded write tools, no `Agent`; depth-1 worker or depth-2 leaf | Small, isolated, well-specified implementation. Its name does not imply a worktree. |
| `senior-reviewer` | `haiku` | `sonnet` | `high` | `plan` | Read and validation tools, no `Agent`; depth-1 worker or depth-2 leaf | Evidence-backed review with escalation for high-impact judgment. |
| `local-orchestrator` | `haiku` | `sonnet` | `high` | `default` | Includes `Agent`; depth 1 only | One bounded root-assigned subset that genuinely benefits from root-permitted depth-2 leaves. |

These are supporting agents. The root Claude Code session retains architecture ownership and final judgment. There is one definition per role rather than model-specific copies because Claude Code supports a per-invocation `model` override. The caller routes the same role at `haiku`, `sonnet`, or, exceptionally under an Opus ceiling, `opus`.

## Finite Routing Contract

Before spawning:

1. At depth 0, record a finite task manifest and total subagent budget that count every depth-1 and depth-2 node.
2. Record the root session's actual selected model family and rank. If it cannot be resolved to an approved family, do not delegate until the effective ceiling is known.
3. Give every child a root-issued permit, parent and child IDs, non-empty strict completion subset, declared ownership or read scope, explicit per-invocation model, recorded definition-level effort, permission and tool boundary, exact workspace, and acceptance condition.
4. Require sibling write ownership to be disjoint.
5. Confirm the child is equal to or narrower than its parent in inputs, data access, scope, non-goals, authority, approval boundary, permission mode, and tools.
6. Confirm both the child model tier and effort are at or below the parent's explicit ceilings. Equal-tier routing is valid; depth does not require a tier drop.
7. Select the bundled agent whose job and effective capabilities most closely match the task.
8. State why that route is sufficient, when it must stop, and how the parent will verify the result.

Only the root may issue permits or expand the manifest or total budget. Limit an expansion reason to a newly discovered dependency, invalidated gate, or changed user scope. Obtain user approval immediately before a material-cost expansion.

When runtime capacity is full, continue current ready work and do not create speculative descendants. A retry keeps its node ID and permit. A replacement requires a new root-issued permit and consumes budget.

## Model and Effort Ceilings

Use this approved model-family order:

```text
opus   rank 3
sonnet rank 2
haiku  rank 1
```

The child invariant is `child rank <= parent rank`. A full model ID may be mapped to its `opus`, `sonnet`, or `haiku` family only when that family is unambiguous. Claude Code may support other aliases, but this playbook does not rank them. Treat `inherit`, an unranked alias, an ambiguous full ID, or an unavailable model as unknown until the effective approved family is verified.

The root session records the model the user actually selected, not the strongest model available to the account or client. Route depth 1 as follows:

- Opus root: normally use Sonnet for substantial delegated work and Haiku for cheap, objective work. Use an Opus child only for an exceptional bounded assignment with a recorded reason, finite permit, and explicit verification plan.
- Sonnet root: use Sonnet or Haiku only.
- Haiku root: use Haiku only.

The same invariant applies at depth 2 against the depth-1 parent's effective model. A Sonnet child may use Sonnet or Haiku leaves; a Haiku child may use only Haiku leaves. Opus at one depth does not force Sonnet at the next, and Sonnet does not force Haiku. Equal-tier parent and child routes are valid when the task needs them.

Treat effort as a separate ordered ceiling:

```text
low < medium < high < xhigh < max
```

Effort is a fixed capability of the selected agent definition for this playbook; do not claim or attempt a per-invocation effort override. A child must be at or below the parent in both the model and effort orders, so select only a definition and model combination whose effort the current client reports as supported and within the parent ceiling. If support or the effective effort cannot be verified, do not dispatch: keep the work with the parent or report the limitation. A weaker model does not permit higher effort than the parent ceiling. Model depth and effort are independent: neither requires an automatic decrease merely because another delegated generation is used.

Do not use `inherit` for routine delegated work. Pass the intended model explicitly on every `Agent` invocation and confirm that `CLAUDE_CODE_SUBAGENT_MODEL`, organization allowlists, provider behavior, or resume behavior did not change the effective route. A descendant must not silently change its model or effort, request or perform an upgrade, or fall back to the root route. If its ceiling is insufficient, it preserves completed work, stops, and reports the exact gap upward.

Only the root may create a new depth-1 replacement. It may choose any approved model at or below the actual root ceiling, so the replacement may be stronger than the failed child without being stronger than the root. The root records a new permit, available budget, replacement reason, intended model, and verification plan. This is a new root route, not descendant escalation.

If the requested child model is unknown, blocked, or unavailable, never silently substitute another family. Use the exact known parent family for the child only when Claude Code can explicitly enforce and verify that same-family route. Otherwise keep the work with the parent or report the runtime limitation. A substitution warning invalidates the route until the root confirms that the resulting model still satisfies the recorded ceiling and explicitly re-permits it; no descendant makes that decision.

## Permission and Tool Ceilings

Permission modes are capability contracts, not a single numeric scale.

- A child of a `plan` parent remains `plan` and read-only.
- A child of a `default` parent may use `default` or the narrower `plan` mode, subject to its task.
- Do not use `acceptEdits`, `auto`, `dontAsk`, or `bypassPermissions` in bundled agents without a maintainer-approved use case and documented risk analysis.
- A child's effective `tools` set must be a subset of the parent's declared tool boundary.
- Only `local-orchestrator` includes `Agent`. Direct workers and depth-2 leaves omit it and cannot spawn.
- If a parent session mode overrides a subagent definition's permission behavior, report that limitation rather than claiming a stricter boundary was enforced.

## Depth Capability Gate

The playbook permits root → depth 1 → depth 2 and prohibits depth 3.

Before a depth-1 `local-orchestrator` may use `Agent`, the current Claude Code release must support nested subagents and `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` must already be active in an authorized settings scope and verified for the session. The root does not install or change that setting without authorization. If either capability gate is unavailable or unknown, do not permit nested execution: use depth-1 direct execution or have the local orchestrator execute its subset directly without `Agent`. The instruction contract remains required in addition to the runtime cap.

If the client does not expose nested subagents, use depth-1 direct workers only. Do not emulate depth 2 with independent Claude Code sessions.

## Worktree Isolation

Shared execution is the default and the auxiliary-worktree budget starts at zero. No bundled agent sets `isolation: worktree`.

Only the root may authorize `isolation: worktree` or another auxiliary checkout under a separate worktree permit. The permit must record the exact base ref and SHA because Claude Code worktree isolation may start from the repository default branch rather than the parent session's `HEAD`, depending on `worktree.baseRef` and client behavior. Descendants must not request isolation in an `Agent` call or create, adopt, repurpose, move, or remove a worktree.

Consult `references/worktrees.md` for creation, integration, cleanup, and preservation gates.

## Keep With the Root Session

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

A subagent may gather bounded evidence for these areas, but the root session makes and verifies the decision.

## Required Assignment Fields

```text
Role and named Claude agent:
Explicit per-invocation child model:
Selected agent definition and fixed effort:
Actual root model and rank:
Parent effective model and effort ceiling:
Child-at-or-below proof and explicit invocation model:
Permission mode and exact tool boundary:
Goal:
Context:
Lineage and inherited constraints:
Parent ID / child ID:
Completion subset:
Root-issued node permit and total-budget status:
Declared ownership or read scope and sibling non-overlap:
Exact assigned workspace and worktree permit when applicable:
Acceptance condition:
Scope:
Non-goals:
Evidence required:
Escalation conditions:
Output format:
Parent return bundle:
```

## Acceptance Check

Before accepting delegated work, confirm:

- the route was an explicit root-permitted dispatch rather than automatic delegation
- the named agent, explicit invocation model, definition-level effort, effective model and effort, permission mode, and tools are recorded
- the actual root model and rank were resolved without assuming Opus
- neither model nor effort exceeds the recorded parent ceiling
- the per-invocation model was explicit, and no environment, allowlist, provider, or resume substitution invalidated it
- no unsupported per-invocation effort override was assumed; the selected definition's fixed effort fits the ceiling and the effective effort was verified
- the permission mode and tools are equal to or narrower than the parent boundary
- the root permit, parent and child IDs, and total-budget status are recorded
- the completion subset is non-empty and strictly smaller than the parent's remaining subset
- sibling write ownership is disjoint
- the subagent used its exact assigned workspace and did not create, repurpose, move, or remove a worktree
- the stated acceptance condition passed
- any replacement stayed within the actual root ceiling, consumed a new permit and budget, and documented why its route was needed
- claims are supported by primary evidence
- the root independently reviewed material findings and edits
