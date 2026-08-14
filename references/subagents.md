# Subagent Delegation Reference

The main Claude Code session is the orchestrator and senior developer. Subagents may assist, but they do not own the final outcome.

The main session owns:

- task understanding
- working plan
- architecture and design judgment
- delegation decisions
- final implementation
- final diff
- validation strategy
- final user-facing response

## Claude Code Subagent Roles

Use these five Claude Code subagent roles:

| Subagent | Model and effort | Permission mode | Tools | Best for |
| --- | --- | --- | --- | --- |
| `read-only-explorer` | Haiku, low | Plan | Read, Grep, Glob | Mapping code paths, call sites, ownership boundaries, and likely insertion points. |
| `senior-reviewer` | Sonnet, high | Plan | Read, Grep, Glob, Bash | Reviewing diffs for correctness, regressions, scope creep, maintainability, safety, performance, and accessibility. |
| `docs-researcher` | Haiku, low | Plan | Read, Grep, Glob, WebFetch, WebSearch | Checking framework, library, API, or platform behavior against authoritative docs. |
| `test-triager` | Sonnet, medium | Default | Read, Grep, Glob, Bash, Edit | Analyzing failing tests, logs, flakes, snapshots, and likely root causes. |
| `isolated-worker` | Sonnet, medium | Default | Read, Grep, Glob, Edit, Write, Bash | Implementing small isolated changes after scope and design are clear. |

The role names are intentionally Claude Code-specific. They describe the job, model route, permission baseline, and tool boundary.

Claude Code subagent files live under `agents/` as Markdown files with YAML frontmatter. Set `model`, `effort`, `permissionMode`, and `tools` explicitly. Read-only roles must not include `Edit` or `Write`.

## When to Use Subagents

Use subagents when delegation is likely to improve quality, speed, coverage, or context hygiene.

Good uses include:

- codebase exploration
- tracing call paths
- finding existing patterns
- finding all call sites of an API, component, function, event, schema, or configuration
- reviewing a proposed diff
- looking for bugs, regressions, safety risks, race conditions, test gaps, or maintainability issues
- reproducing UI, integration, or workflow bugs
- analyzing test failures, logs, snapshots, traces, or large files
- checking framework, library, or API behavior against authoritative documentation
- auditing many independent files or components
- implementing a small isolated change after the main design is clear

## When Not to Use Subagents

Avoid subagents when:

- the task is trivial
- the work requires one coherent design judgment
- requirements are still materially ambiguous
- coordination cost exceeds likely benefit
- multiple subagents would need to edit the same files or tightly coupled areas
- the task involves sensitive access material, destructive operations, production-impacting changes, or sensitive data
- the main session cannot realistically verify the result

Prefer read-only subagents for exploration, review, research, reproduction, and diagnosis.

Be careful with write-heavy parallel work. Do not allow multiple subagents to edit the same files or tightly coupled areas at the same time. If parallel writes are necessary, require verified isolation, an explicit required base state, and clear ownership; a request for parallel execution alone does not prove that concurrent edits are safe.

## Dependency-Aware Orchestration

Keep a single bounded task as one node. When work has multiple delegable parts, describe each node before fan-out:

| Field | Purpose |
| --- | --- |
| Node ID | Stable identifier for dependencies, gates, and retries. |
| Goal | One concrete outcome. |
| Inputs / authoritative sources | Artifacts, decisions, code, tests, or documentation the node may rely on. |
| Output and acceptance condition | The artifact or finding the node must return and the criteria it must satisfy. |
| Depends on | Only upstream nodes whose accepted output is required before this node can correctly begin. |
| Write ownership or read scope | Disjoint paths or state a writer may change, or the bounded sources a read-only node may inspect. |
| Verification gate | Proportionate evidence required before the output may be treated as integration-ready. |

An edge is real only when the downstream node cannot correctly begin without an accepted upstream artifact or decision. Do not serialize independent work merely because it was written as a list, and do not parallelize nodes that share mutable state, overlapping write ownership, or an unresolved contract.

Before execution:

- identify parallel-safe nodes
- identify the remaining chain of blocking work that controls completion
- state a runtime-aware concurrency limit and why the coordination cost is justified
- verify that any claimed context, filesystem, worktree, base-state, or mutable-state isolation actually exists

Verification must evaluate the artifact against stated criteria and primary evidence, not the producer's self-assessment. For meaningful implementation, prefer a separate Senior Reviewer or Test Triager assignment with only the necessary artifact, criteria, and evidence requirements when the runtime supports it. This does not replace main-session acceptance, and not every low-risk node needs a separate verification subagent.

If a verification gate fails, revise or rerun the failed node and every downstream node whose inputs became invalid. Do not restart unrelated work by default. Before combining results, confirm all required inputs passed their gates, then validate the integrated behavior and final combined diff.

## Independent Claude Code Sessions

Independent Claude Code sessions are not ordinary subagents. They may have separate conversation history, branches, worktrees, assumptions, and implementation ownership.

When multiple independent sessions are already working on related project areas:

- consult `references/multi-session-coordination.md`
- use the `multi-session-coordination` skill
- identify shared ownership, dependencies, contracts, and integration risks before adding more parallel implementation work
- do not treat one session's summary as authoritative without checking primary evidence
- do not spawn additional implementation subagents merely to solve an existing session-coordination conflict

New project sessions should use:

```text
Project - Three-to-Four-Word Description
```

Use Claude Code's native naming controls when available:

```text
claude -n "Project - Three-to-Four-Word Description"
/rename Project - Three-to-Four-Word Description
```

Detect the project name and derive the concise description from the task instead of asking the user when both are already clear.

## Mandatory Model, Effort, and Permission Selection

Consult `references/model-routing.md` before delegation.

Use the configured Claude Code profiles instead of inherited settings:

- Haiku, low effort, plan mode for focused exploration and documentation lookup
- Sonnet, medium effort, default mode for bounded implementation and test triage
- Sonnet, high effort, plan mode for meaningful review

The main session remains accountable regardless of which model, effort, permission mode, or tool boundary a subagent uses.

Never delegate critical judgment to a weaker model or broader permission mode unless the main session can independently verify the result from primary evidence.

Do not silently escalate a subagent to Opus, higher effort, broader permissions, or worktree isolation. Document why the configured profile is insufficient and how the stronger result will be verified.

## Subagent Assignment Template

Use this structure when delegating:

```text
Role:
You are the [read-only-explorer/senior-reviewer/docs-researcher/test-triager/isolated-worker] subagent for this task.

Selected profile or model:
[Claude Code profile or Claude model alias.]

Effort level:
[low/medium/high as appropriate.]

Permission mode:
[plan/default or an explicitly approved alternative.]

Tool boundary:
[Exact tools available to the subagent.]

Why this is the smallest suitable choice:
[Why the selected model, effort, permissions, and tools can complete the bounded task reliably.]

Goal:
[One concrete outcome.]

Context:
[Relevant user request, repository constraints, current findings, and branch/diff context.]

Reference documents:
Consult [document/path/section] for context on [topic].
Treat it as [authoritative/advisory/historical].
Verify implementation-relevant claims against current code before relying on them.
Do not summarize unrelated sections.

Scope:
Inspect only [files/areas/systems]. Do not work outside this scope unless necessary; report if scope expansion is needed.

Non-goals:
Do not [unwanted work, refactors, formatting churn, unrelated fixes, broad rewrites].

Evidence required:
Return specific file paths, symbols, command output summaries, reproduction steps, docs references, or runtime observations that support your conclusions.

Escalation conditions:
Stop and report if [conditions requiring main-session or stronger-model judgment].

Output format:
- Findings:
- Evidence:
- Recommended action:
- Risks/uncertainty:
- Validation run:
- Escalation needed:
```

For multi-node work, also include:

```text
Node ID:
Inputs / authoritative sources:
Output and acceptance condition:
Depends on:
Write ownership or read scope:
Verification gate:
```

## Acceptance Checklist

Before accepting subagent work, the main session must verify:

- the configured profile or Claude model was explicitly selected
- the effort level was explicitly selected
- the permission mode and tool boundary match the role
- inherited model or effort settings were not used unintentionally
- any Opus, higher-effort, broader-permission, or worktree-isolation escalation was justified
- the subagent stayed within scope
- the result addresses the assigned goal
- claims are backed by code, tests, logs, docs, runtime behavior, or other primary evidence
- any edits are minimal and task-related
- no unrelated files were changed
- the implementation matches existing architecture and style
- validation was run, or a clear reason was given
- any claimed parallel safety, base state, or isolation was verified
- required node gates passed before fan-in and combined validation covered the integrated behavior
- the main session inspected the final diff itself

If subagent findings conflict, resolve the disagreement by inspecting primary evidence.

Never accept a subagent's conclusion solely because it sounds confident.
