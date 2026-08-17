# Claude Code Subagent Delegation Reference

The root Claude Code session is the orchestrator and senior developer. For every repository task, it delegates actual execution to at least one bounded subagent when subagents are available. Subagents execute bounded work but do not own the final outcome.

The root session exclusively owns:

- task framing and the finite root manifest
- root ready-set transitions, permits, and total subagent budget
- architecture and design judgment
- cross-subtree conflict resolution
- worktree permits and lifecycle decisions
- integration, validation, and final acceptance
- authority-bound actions and approvals
- final diff and user-facing response

## Bundled Claude Code Agents

| Agent | Fail-closed default / normal explicit model / fixed effort | Permission | Tools | Depth role and best use |
| --- | --- | --- | --- | --- |
| `local-orchestrator` | Haiku / Sonnet / high | Default | Agent, Read, Grep, Glob, Bash, Edit, Write, WebFetch, WebSearch | Depth 1 only. Manages one bounded subset through root-permitted leaves when a strict split creates real leverage. |
| `read-only-explorer` | Haiku / Haiku / low | Plan | Read, Grep, Glob | Depth-1 worker or depth-2 leaf. Maps code paths and existing patterns. |
| `docs-researcher` | Haiku / Haiku / low | Plan | Read, Grep, Glob, WebFetch, WebSearch | Depth-1 worker or depth-2 leaf. Verifies authoritative documentation. |
| `test-triager` | Haiku / Sonnet / medium | Default | Read, Grep, Glob, Bash, Edit | Depth-1 worker or depth-2 leaf. Diagnoses tests and makes only authorized diagnostic edits. |
| `isolated-worker` | Haiku / Sonnet / medium | Default | Read, Grep, Glob, Edit, Write, Bash | Depth-1 worker or depth-2 leaf. Implements bounded changes; the name does not imply a worktree. |
| `senior-reviewer` | Haiku / Sonnet / high | Plan | Read, Grep, Glob, Bash | Depth-1 worker or depth-2 leaf. Reviews meaningful artifacts and validation. |

Source agent definitions live under `agents/` and install to the resolved user-level Claude Code agents directory. Repository-specific definitions belong under `.claude/agents/`. Every Markdown definition pins a fail-closed Haiku `model`, fixed role `effort`, `permissionMode`, and `tools` values. Only `local-orchestrator` includes `Agent`; execution leaves omit it. Claude Code's per-invocation `model` override lets one definition serve all approved model routes, so the playbook does not duplicate roles into model-specific agent files. The descriptions prohibit automatic selection while this bounded contract is active; every accepted route is explicit and root-permitted.

## Default Subagent Execution

Use at least one bounded subagent execution assignment for every repository task when subagents are available. The root frames the work, routes the assignment, and verifies the result; one direct worker may complete the entire bounded execution assignment while the root retains orchestration, integration, verification, and final acceptance.

Default assignments include planning evidence, repository exploration, isolated implementation, review, test reproduction and triage, documentation verification, mechanical audits, and call-site or configuration discovery.

Root direct execution is allowed only when subagents are unavailable, the user explicitly forbids delegation, or a specific authority-bound action cannot be delegated. Record the exact exception and limit it to that action. High-impact work still delegates bounded evidence gathering or independent review while the root retains the decision and final acceptance.

## Finite Manifest and Dependency-Aware Orchestration

Keep a single bounded task as one node. Before fan-out, the root records a finite manifest and total subagent budget. Describe each permitted node with:

| Field | Purpose |
| --- | --- |
| Node and permit | Stable node ID plus root-issued authorization, counted against the total budget. |
| Parent / child lineage | The parent ID and child ID; retries retain both. |
| Completion subset | Non-empty work strictly smaller than the parent's remaining subset. |
| Goal | One concrete outcome. |
| Inputs | Only the code, artifacts, decisions, or documentation the node may consume. |
| Output and acceptance | The artifact or finding to return and the evidence required to accept it. |
| Depends on | Only upstream nodes whose accepted output is required before this node can begin correctly. |
| Ownership or read scope | Disjoint paths or state a writer may change, or bounded sources a reader may inspect. |
| Model / effort ceiling | Actual root model and rank, explicit per-invocation child model, selected definition's fixed effort, and proof that both effective capabilities are at or below the parent ceiling. |
| Permission / tools | Explicit `permissionMode` and tools allowlist, equal to or narrower than the parent boundary. |
| Workspace | Exact shared workspace or root-permitted auxiliary. Worktree permits are separate from node permits. |
| Verification gate | Proportionate primary evidence before fan-in. |

An edge is real only when the downstream node cannot begin correctly without an accepted upstream artifact or decision. Do not serialize work merely because it appears in list order, and do not parallelize nodes that share mutable state, overlapping writes, unresolved contracts, or insufficient runtime capacity.

Only dispatch ready manifest nodes with valid root permits and remaining total budget. Runtime-full is backpressure, not permission to queue speculative descendants. Retry a failed node with its existing ID and permit. A replacement consumes a new permit and budget. Expand the manifest or budget only for a newly discovered dependency, invalidated gate, or changed user scope; get user approval immediately before a material-cost expansion.

Verification must judge artifacts against acceptance criteria and primary evidence, not the producer's self-assessment. When risk warrants it, use a separate `senior-reviewer` or `test-triager` node with only the necessary artifacts and criteria. The root still decides acceptance.

## Two Delegated Generations

The root is depth 0. Depth 1 contains callable named Claude Code agents acting as direct workers or a `local-orchestrator`. Depth 2 contains execution leaves that omit `Agent` and cannot spawn. Depth 3 is prohibited.

Every child must remain equal to or narrower than its parent in inputs, data access, scope, non-goals, write ownership, model, effort, permission mode, tools, workspace, authority, and approval boundary. Sibling write ownership must be disjoint. Equal-tier routing is valid; depth does not force a model or effort drop. Descendants cannot issue permits, expand budgets, change root topology, advance root-ready work, resolve cross-subtree conflicts, or route themselves to, or request, a stronger model or effort.

A depth-1 direct worker executes its assigned subset. A depth-1 `local-orchestrator` may spawn only root-permitted depth-2 leaves already named in the manifest, only while the Claude Code runtime supports nested subagents, and only after the required depth cap below is active and verified. It validates child outputs and returns a compact lineage-and-evidence bundle. If no valid permitted strict-subset split exists or either capability gate is unavailable, it executes directly without `Agent` or reports upward; it must not emulate nesting with an independent session.

When a descendant reports that its ceiling is insufficient, only the root may route a new depth-1 replacement. The root may select any approved tier at or below the actual root ceiling, even when that tier is stronger than the failed child. The replacement needs a new permit, available budget, a recorded reason, and an explicit verification plan; it is not a descendant upgrade.

`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` is a required capability gate for local orchestration, not an optional hardening measure. It must already be active in an authorized settings scope and verified before a depth-1 local orchestrator may spawn. The root does not install or change it without authorization. It reinforces but does not replace the instruction contract.

## Worktrees Are Not Delegation Units

Start in the current workspace with an auxiliary-worktree budget of zero. Read-only agents and disjoint writers normally share it. Serialize overlapping writes unless concrete branch or filesystem isolation makes an auxiliary checkout necessary.

Only the root may raise the worktree budget, issue a worktree permit, create or adopt an auxiliary, change its purpose, move it, or remove it. The root may authorize one active auxiliary without additional approval; two or more require user approval for the exact count and reasons. Descendants receive an exact workspace and report any isolation need upward. They must not set `isolation: worktree` on their own child calls. Retries reuse a compatible assigned workspace.

Consult `references/worktrees.md`. Before completion, the root integrates and safely removes each task-created auxiliary or preserves it with exact path, owner, branch or HEAD, blocker, and next action. Task-local cleanup does not depend on scheduled automation. The active host-managed worktree remains under the host lifecycle.

## Independent Claude Code Sessions

Independent Claude Code sessions are not subagents. They may have separate conversation history, branches, worktrees, assumptions, and implementation ownership.

When independent sessions already work on related areas, consult `references/multi-session-coordination.md` and use the `multi-session-coordination` skill before adding more parallel work. Do not treat a session summary as authoritative without primary evidence, and do not use more subagents merely to mask an existing ownership conflict.

## Mandatory Routing

Consult `references/model-routing.md` before delegation.

- Select a named Claude Code agent explicitly.
- Record the model actually selected for the root session; never assume Opus.
- Use the smallest explicit model and select the lowest fixed-effort agent definition that can complete the bounded subset reliably.
- Use Opus rank 3, Sonnet rank 2, and Haiku rank 1. Require `child rank <= parent rank`; equal rank is valid.
- With an Opus root, normally use Sonnet or Haiku and record why any exceptional Opus child is necessary. A Sonnet root may use Sonnet or Haiku; a Haiku root may use Haiku only.
- Use only explicit root-permitted `Agent` routes. Pass the intended child model on every invocation; do not accept automatic delegation or an omitted model. Agent frontmatter fails closed at Haiku and is not execution authority.
- Pin `permissionMode` and the exact tools allowlist.
- Do not use an inherited model unintentionally or claim an unsupported per-invocation effort override. Record the selected definition's fixed effort and verify the effective value.
- Keep each child at or below its parent's model, effort, permission, and tool ceilings.
- Do not silently escalate to Opus, higher effort, broader permissions, more tools, or worktree isolation.
- Treat model substitutions and unresolved effective models as failed routing gates. Use the exact known parent family only when it can be explicitly enforced and verified; otherwise keep the work with the parent or report the limitation.
- Stop and report when inherited limits are insufficient; descendants do not request upgrades.

## Assignment Template

```text
Role:
You are the [local-orchestrator/read-only-explorer/docs-researcher/test-triager/isolated-worker/senior-reviewer] subagent for this task.

Selected Claude agent and model:
[Named agent, explicit per-invocation model alias or ID, actual root model and rank, parent effective model, and child-at-or-below proof.]

Definition effort and parent ceiling:
[Selected definition's fixed effort; effective effort; parent model and effort ceilings; proof the child is at or below both.]

Permission mode and tools:
[Exact permissionMode and tools; proof they are equal to or narrower than the parent boundary.]

Goal and acceptance condition:
[One concrete outcome and the primary evidence required to accept it.]

Context:
[Relevant request, repository constraints, accepted inputs, and branch/diff state.]

Lineage and inherited constraints:
[Root/node lineage; parent ID and child ID; parent remaining subset; this strict non-empty subset; inherited data, scope, non-goals, authority, and approval limits.]

Permit and ownership:
[Root-issued node permit; total-budget status; read scope or write ownership; sibling non-overlap.]

Workspace:
[Exact shared workspace or root-permitted auxiliary; separate worktree permit if applicable.]

Reference documents:
[Relevant path and authority classification. Verify claims against current primary evidence.]

Scope and non-goals:
[Exact allowed and prohibited work.]

Local-child limits:
[For local-orchestrator only: exact root-permitted depth-2 leaves, plus proof that nested subagents are supported and CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2 is active. Leaves omit Agent and cannot spawn.]

Evidence and validation:
[Paths, symbols, commands, runtime observations, or docs required.]

Escalation conditions:
[Ambiguity, conflicting evidence, scope expansion, capability ceiling, or authority boundary.]

Output:
- Findings or changed files
- Evidence and validation
- Risks or uncertainty
- Escalation needed
- Parent return bundle with compact lineage, accepted artifact paths, and blockers
```

## Acceptance Checklist

Before accepting subagent work, the root verifies:

- the permit, lineage, strict subset, and total-budget status
- disjoint sibling ownership
- actual root model and rank recorded without assuming Opus
- explicit invocation model and definition-level effort, plus effective model, effort, permission mode, and tools at or below parent ceilings, with equal-tier routing accepted
- per-invocation model recorded and no environment, allowlist, provider, resume, or runtime substitution left unresolved
- route was explicit and root-permitted rather than automatic, and no per-invocation effort override was assumed
- exact workspace use and no descendant worktree lifecycle action
- scope compliance and required output
- primary evidence and validation
- minimal task-related edits with no unrelated changes
- any root-routed replacement's new permit, budget, reason, verification, and proof that it remains at or below the actual root ceiling
- required fan-in gates and combined validation
- every task-created auxiliary's integration evidence and final `removed` or exact-blocker `preserved` disposition
- the complete final diff

Never accept a subagent conclusion solely because it sounds confident.
