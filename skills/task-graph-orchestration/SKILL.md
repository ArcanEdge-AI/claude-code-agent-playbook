---
name: task-graph-orchestration
description: Use for complex Claude Code tasks with substantial fan-out, multiple genuine dependencies, broad file or repository scope, multi-layer consolidation, separate implementation and verification paths, or an approval-gated irreversible action. Compiles an instruction-only task graph, executes only ready nodes, preserves completeness through fan-in, and retries only invalidated work. Skip for small or genuinely linear tasks.
---

# Task Graph Orchestration

Use instructions and Markdown to make complex work topology explicit. Do not introduce a graph database, scheduler, runner, schema package, or orchestration framework. Claude Code executes ordinary inline work and subagent assignments; the root session compiles the root graph, exclusively controls its ready set and permits, accepts evidence, and owns the final result.

## Decide Whether to Use a Formal Graph

Consider a formal graph when one or more of these conditions apply:

- multiple independent investigations can run concurrently
- several Claude Code subagents will be used
- many similar items must be audited or transformed without omissions
- results require layered consolidation
- implementation branches share contracts, schemas, interfaces, or mutable state
- a schema or interface change creates downstream consumers
- the result is difficult for the user to verify manually
- the task ends with deployment, deletion, publication, outbound communication, or another approval-gated action

Skip formal graph mode when the task is small, genuinely linear, dominated by one coherent design judgment, limited to tightly coupled writes, impossible for the root session to verify, or cheaper to execute than to maintain as a graph. This does not waive default bounded subagent execution when subagents are available. Keep ordinary tasks on the normal engineering loop.

## Establish the Preflight

1. Inspect the request, repository state, applicable `CLAUDE.md` instructions, validation surfaces, and existing ownership before compiling nodes.
2. Run the `multi-session-coordination` skill first when related Claude Code sessions, branches, worktrees, pull requests, or active-work records may affect ownership or contracts. Treat that work as external nodes or hidden constraints; do not assume the current graph controls it.
3. Define the overall goal and observable success criteria.
4. Resolve the actual model selected for the root session and its approved family rank. Do not assume Opus.
5. Identify actions that require explicit approval because they are audience-facing, destructive, irreversible, sensitive, production-impacting, materially costly, or outside existing authority.
6. Read `references/templates/task-graph.md` before creating a formal graph artifact.
7. Read `references/worktrees.md` when any node proposes or already uses an auxiliary worktree. Keep worktree permits separate from node permits.

Keep a medium task graph in the working plan or response. For long-running, multi-phase, or multi-session implementation, create `.claude/coordination/task-graphs/<task-slug>.md` when repository policy permits a local coordination artifact. Otherwise keep the graph in the available planning mechanism. Do not create or commit a repository artifact for an informational question or when the task does not authorize changes.

## Compile the Graph

Define each node with:

- a stable node identifier
- one bounded goal
- an executor: use a named Claude Code subagent for repository execution; root nodes are limited to orchestration, topology, integration, verification, approval, final acceptance, or a documented direct-execution exception
- authoritative inputs
- a declared output shape and acceptance condition
- only the upstream nodes whose accepted outputs it consumes
- read scope
- write or mutable-state ownership
- the smallest suitable explicit per-invocation Claude model and a compatible agent definition with fixed effort when delegated
- a permission mode and tool boundary when delegated
- an exact workspace and a separate root-issued worktree permit only when auxiliary isolation is justified
- a verification gate proportionate to risk
- a current status

The root records its actual selected model and approved family rank, then a finite manifest and total subagent budget counting depth-1 and depth-2 nodes. Every child needs a root-issued permit, parent and child IDs, non-empty strict completion subset, disjoint sibling write ownership, explicit per-invocation Claude model and selected definition-level effort at or below the parent ceilings, permission and tools equal to or narrower than the parent boundary, exact workspace, and acceptance condition. Opus is rank 3, Sonnet rank 2, and Haiku rank 1; require `child rank <= parent rank`. Equal-tier routes are valid, and depth does not force a drop.

Depth 1 contains callable named agents acting as direct workers or a `local-orchestrator`. A permitted `local-orchestrator` may use only declared depth-2 leaves already in the root manifest, and only after nesting support and an active `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` setting are verified. Depth-2 leaves omit `Agent`, execute directly, and cannot spawn. Depth 3 is prohibited. If either capability gate is unavailable or unknown, depth 1 executes directly without `Agent` or reports upward; do not change the setting without authorization.

Audit every proposed edge with this question:

> Can the downstream node correctly begin without consuming an accepted output or decision from the upstream node?

If yes, do not add a data-dependency edge merely to preserve narrative order. Check separately for hidden ordering constraints:

- overlapping file or mutable-state writes
- schemas, migrations, interfaces, or public contracts
- shared ports, services, environments, locks, credentials, or rate limits
- cost or resource ceilings
- active ownership in another Claude Code session or worktree
- worktree base-state requirements
- auxiliary-worktree budget and lifecycle obligations
- destructive, irreversible, production, or audience-facing actions

Add explicit fan-in nodes where multiple outputs must be combined. Add independent verification nodes for high-risk claims or changes. Add approval nodes immediately before actions that require user authorization. Identify the completion-controlling path and the initial ready set.

## Dispatch Ready Nodes

Dispatch a node only when all declared dependencies have accepted outputs and all hidden constraints are satisfied.

- Dispatch only ready nodes in the finite root manifest that have root permits, remaining total budget, and runtime, safety, permission, and verified ownership or isolation capacity.
- Treat runtime-full as backpressure. Do not create speculative descendants.
- If parallel execution is unavailable, process ready nodes sequentially while preserving dependencies and state.
- Keep architecture, security-sensitive judgment, destructive operations, migrations, concurrency design, public API compatibility, and final acceptance with the root session. Delegate bounded evidence gathering or review.
- Use `plan` permission mode for read-only exploration, research, and review. Use `default` for bundled write-capable roles so normal approval prompts remain active.
- Treat each subagent definition's `tools` field as an allowlist. All bundled frontmatter models fail closed at Haiku. Use only explicit root-permitted routes, pass the model on every `Agent` invocation, and reject automatic or omitted-model routes. Effort comes from the selected definition; do not claim a per-invocation effort override. Do not silently broaden the model, effective effort, permission mode, tools, or isolation declared for a node.
- With an Opus root, normally use Sonnet or Haiku and record the exceptional reason for any Opus child. A Sonnet root may use Sonnet or Haiku. A Haiku root may use Haiku only.
- Treat an environment override, allowlist or provider substitution, resumed-route change, unknown alias, or unavailable model as a failed routing gate. Use the exact known parent family only when it can be explicitly enforced and verified; otherwise keep the work with the parent or report the limitation.
- Start in the shared workspace with an auxiliary-worktree budget of zero. Only the root may issue a separate worktree permit and authorize `isolation: worktree`; one active auxiliary needs no added approval, while two or more require user approval for the exact count and reasons. Descendants must not request isolation or create, adopt, repurpose, move, or remove worktrees.

When delegating, use the existing Claude Code subagent assignment contract and add:

```text
Graph node:
Parent / child IDs and root permit:
Strict completion subset and total-budget status:
Declared inputs:
Output and acceptance condition:
Depends on:
Read scope:
Write or mutable-state ownership:
Actual root model and rank:
Explicit per-invocation Claude model:
Selected definition and fixed effort:
Parent effective model / effort ceiling and child-at-or-below proof:
Permission mode and tools:
Exact workspace and separate worktree permit when applicable:
Verification gate:
```

A Claude Code subagent must not silently restructure the root graph, expand its scope, consume undeclared inputs, broaden its configured capabilities, request an upgrade, or claim a blocked dependency is complete. A `local-orchestrator` may manage only its declared child subtree within inherited constraints. It must return the declared output or preserve completed work and report the exact capability gap, hidden dependency, conflict, or missing input upward. Only the root may issue a new depth-1 replacement permit at any approved tier within the actual root ceiling, including a tier stronger than the failed child.

## Update State and Consolidate Results

After each node returns:

1. Check its output against the declared acceptance condition and primary evidence.
2. Record its status, evidence, produced artifacts, and any changed assumptions.
3. Keep dependent nodes blocked when the output is missing, failed, or rejected.
4. Recalculate the ready set.
5. Record expected, received, missing, failed, and blocked node identifiers before fan-in.

For large fan-out, consolidate in layers. Preserve node IDs, paths, evidence references, counts, severity, and confidence. Do not collapse specific findings into vague summaries. Confirm every expected node appears exactly once or is explicitly listed as missing, failed, blocked, or superseded. Local parents return compact lineage, accepted artifact paths, evidence, and blockers rather than full histories, transcripts, or long logs.

## Verify and Retry Selectively

Use an independent `senior-reviewer` or `test-triager` node when risk, blast radius, or unverifiable synthesis warrants it. Give the verifier the source artifacts, acceptance criteria, and primary-evidence requirements, not merely the producer's summary.

If a gate fails:

- preserve accepted outputs from unrelated nodes
- revise or rerun the failed node
- rerun downstream nodes only when their consumed inputs became invalid
- recompile the affected graph portion when the failure reveals a missing edge or invalid decomposition
- stop blind retries and report the exact blocker when the same failure persists
- let only the root create a replacement; record its new permit, budget, reason, model within the actual root ceiling, and verification plan

Before completion, verify the combined behavior and final diff, confirm the completeness counts, and ensure no required node or approval gate remains blocked.

Also reconcile every task-created auxiliary worktree. Integrate and remove it under `references/worktrees.md`, or preserve it with exact path, owner, branch or HEAD, blocker, and next action. Do not defer task-owned cleanup to scheduled automation. Keep the active host-managed worktree under the host lifecycle.

## Enforce Approval Gates

Complete safe inspection, reversible preparation, and validation before the gate when useful. Immediately before the gated action, present the exact target, scope, consequences, material cost, audience, and rollback or recovery path when one exists. Stop until the required authority is explicit. The active Claude Code permission mode still applies; never change or bypass it solely to avoid confirmation. Approval for the plan or an earlier node does not authorize a broader or different irreversible action.

## Respect Instruction-Only Limits

This skill provides soft executable semantics, not a deterministic scheduler. Claude Code may not support concurrency, graph state may drift, dependency classification may be wrong, and no automatic caching or transactional state exists. Recheck repository state, session ownership, node inputs, permission mode, and approval status at each consequential transition. Do not describe the result as a graph runtime or mechanically enforced workflow.
