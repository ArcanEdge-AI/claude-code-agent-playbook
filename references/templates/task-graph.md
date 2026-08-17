# Task Graph: [Task Name]

Use this template only for work that benefits from a formal instruction-only task graph. Keep smaller or genuinely linear tasks in the normal working plan.

## Graph Metadata

- Goal: [One concrete outcome]
- Owner: [Root Claude Code session or coordinating session]
- Root owner: [Session that exclusively owns root topology, permits, budget, and ready set]
- Actual root model and approved rank: [User-selected model; Opus 3 / Sonnet 2 / Haiku 1; never assume Opus]
- Repository and worktree: [Current verified context]
- Applicable instructions: [`CLAUDE.md` paths or other sources]
- Status: [Proposed / Active / Blocked / Complete]
- Last updated: [Timestamp or execution checkpoint]
- Graph-mode reason: [Why the added structure is justified]
- Multi-session preflight: [Not needed / completed with evidence / blocked]

## Success Criteria

- [Observable criterion]
- [Required validation]
- [Required user-visible result]

## Nodes

- Root manifest and total subagent budget: [Finite depth-1 and depth-2 node IDs/count]
- Node permit ledger: [Root permit; parent/child IDs; strict subset; ownership; named agent; explicit invocation model; definition-level effort; parent ceilings; permission/tools; acceptance]
- Auxiliary-worktree budget: [Finite count; default 0 and separate from subagent budget; user approval required for 2 or more active auxiliaries]
- Worktree permit ledger: [None, or root permits linked to exact workspace, owner, isolation reason, integration target, and cleanup condition]

| ID | Parent / lineage | Work | Executor | Inputs | Output and acceptance condition | Depends on | Reads | Writes or mutable state | Explicit invocation model / fixed definition effort | Parent effective ceiling / child-at-or-below proof | Permission / tools | Exact workspace / worktree permit | Verification gate | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| N0 | [Root or parent] | [Bounded work] | [Named subagent by default] | [Authoritative inputs] | [Artifact plus acceptance rule] | None | [Scope] | None | [Explicit per-invocation model / selected definition's fixed effort] | [Parent effective model and effort ceiling; `child rank <= parent rank`; or N/A] | [permissionMode / tools] | [Current shared workspace or W#] | [Evidence] | Ready |

Use node states consistently: `Proposed`, `Ready`, `Running`, `Complete`, `Failed`, `Blocked`, or `Superseded`.

## Dependency Edges

| From | To | Consumed artifact or decision |
| --- | --- | --- |
| N0 | N1 | [Why N1 cannot correctly begin without accepted N0 output] |

Do not add an edge solely to mirror list order.

## Hidden-Edge Review

- Shared file writes: [None or exact conflicts]
- Shared mutable state: [Ports, services, environments, locks, credentials, rate limits, or cost]
- Schema, interface, migration, or contract ordering: [None or exact dependency]
- External Claude Code session, branch, worktree, or pull-request ownership: [None or exact constraint]
- Worktree base state: [Current worktree or required verified starting point]
- Auxiliary-worktree budget and lifecycle: [0 / exact permits and blockers]
- Destructive, irreversible, production, sensitive, costly, or audience-facing actions: [None or approval node]

## Current Ready Set

- [Node IDs whose dependencies and hidden constraints are satisfied]

Ready-node dispatch: [Only finite-manifest nodes whose dependencies and hidden constraints are satisfied, with root permits, remaining total budget, and runtime, safety, permission, and ownership or isolation capacity]

## Local Child Subtrees

| Parent node | Root-permitted depth-2 leaves | Local ownership and sibling non-overlap | Inherited constraints | Parent effective model / effort ceiling | Explicit child invocation model and at-or-below proof | Compact return bundle |
| --- | --- | --- | --- | --- | --- | --- |
| N1 | [Leaf IDs and permits] | [Paths/state; no overlap] | [Inputs, data, scope, permissions, tools, workspace, authority, approval boundary] | [Explicit ceiling] | [Child routes compared with ceiling] | [Lineage, accepted artifacts, evidence, blockers] |

Only `local-orchestrator` may receive `Agent`. Depth 1 executes directly when no valid permitted strict-subset split exists. Depth-2 leaves omit `Agent` and cannot spawn; depth 3 is prohibited. Runtime-full is backpressure. Retries reuse ID, permit, and compatible workspace. Replacements require a new root permit and budget. Only the root may route a replacement at any approved tier within the actual root ceiling, even when stronger than the failed child. Descendants preserve completed work and report insufficiency; they do not request upgrades. Limit expansion reasons to newly discovered dependencies, invalidated gates, or changed user scope; get approval immediately before a material-cost expansion.

Use Opus rank 3, Sonnet rank 2, and Haiku rank 1. The invariant is `child rank <= parent rank`; equal rank is valid and depth does not force a drop. An Opus root normally uses Sonnet or Haiku and records why any exceptional Opus child is necessary. A Sonnet root may use Sonnet or Haiku. A Haiku root may use Haiku only. Treat an unverified or substituted model as a failed routing gate.

## Worktree Lifecycle

Worktrees are not delegation units. Start in the current workspace with an auxiliary budget of zero. Only the root may issue a separate worktree permit or authorize `isolation: worktree`.

| Permit | Node or owner | Canonical path | Base ref and SHA | Branch or HEAD | Creation path and isolation reason | Integration target | Cleanup condition | State |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W1 | [Owner] | [Exact path] | [Ref and SHA] | [Branch or detached SHA] | [`isolation: worktree`, `EnterWorktree`, host UI, or Git; why sharing fails] | [Accepted handoff] | [Required evidence] | [proposed / active / integration-ready / cleanup-ready / removed / preserved] |

Remove the placeholder row when no auxiliary exists. Descendants do not request isolation or create, adopt, repurpose, move, or remove worktrees. Before the final response, mark every task-created auxiliary `removed` with path and registration evidence or `preserved` with exact path, owner, branch or HEAD, blocker, and next action. Do not defer task cleanup to scheduled automation.

## Execution Ledger

| Node | Attempt | Result | Evidence or produced artifact | Downstream nodes invalidated |
| --- | --- | --- | --- | --- |
| N0 | 1 | [Complete / Failed / Blocked] | [Path, command result, diff, or finding] | [None or IDs] |

## Completeness Check

- Expected node IDs: [IDs]
- Accepted node IDs: [IDs]
- Missing node IDs: [IDs or None]
- Failed node IDs: [IDs or None]
- Blocked node IDs: [IDs or None]
- Superseded node IDs: [IDs or None]

## Approval Gates

| Gate | Action | Exact scope and consequence | Required authority | Status |
| --- | --- | --- | --- | --- |
| G1 | [Action] | [Target, audience, cost, permanence, and recovery path] | [User or active permission-mode authority] | Blocked |

If no approval-gated action exists, write `None` and remove the placeholder row.

## Fan-In and Final Verification

- Consolidation nodes: [IDs and expected inputs]
- Preserved evidence identifiers: [Paths, node IDs, counts, severity, confidence]
- Integrated validation: [Commands, runtime checks, or inspection]
- Independent verification: [`senior-reviewer` or `test-triager` node, or reason not needed]
- Final diff reviewed: [Yes / No]
- Required nodes and gates complete: [Yes / No]
- Every task-created auxiliary has a verified final disposition: [Yes / No / N/A]

## Maintenance Rules

- Let the root Claude Code session own root topology, ready-set transitions, permits, budgets, integration, authority-bound actions, and final acceptance.
- Let `local-orchestrator` manage only its declared depth-2 subtree. No child changes root topology or root-ready work.
- Require every child to remain equal to or narrower than its parent, with an explicit per-invocation Claude model and selected definition-level effort, `permissionMode`, and tools at or below the parent ceilings. Bundled agent frontmatter models fail closed at Haiku; reject automatic or omitted-model routes.
- Record the actual root model and rank, accept equal-tier routes, and reject unresolved environment, allowlist, provider, resume, or runtime substitutions.
- Give every child an exact workspace. Keep the auxiliary-worktree budget separate, default it to zero, and let only the root authorize or remove worktrees under `references/worktrees.md`.
- Treat a dependency as real only when the downstream node consumes an accepted upstream artifact or decision.
- Keep completed outputs unless their inputs become invalid.
- Update the ready set after every accepted, failed, blocked, or superseded node.
- Do not change or bypass Claude Code permission modes to advance a node.
- Do not store credentials, sensitive access material, private local paths, full transcripts, or long logs.
- Reuse accepted outputs and send only compact lineage, artifact paths, evidence, and blockers upward.
- Preserve or remove the graph artifact according to repository policy after completion.
