---
name: multi-session-coordination
description: Use when multiple independent Claude Code sessions are working on related areas of the same project and need session discovery, conflict detection, ownership, sequencing, and integration guidance.
---

# Multi-Session Coordination Skill

The root Claude Code session is the integration coordinator. Independent sessions may contribute work, but the coordinating root owns architecture, compatibility decisions, sequencing, validation, and the final report.

Use this skill when:

- multiple Claude Code sessions are active in the same project or repository
- several features are being implemented concurrently
- branches or worktrees may overlap
- shared APIs, schemas, types, components, dependencies, or user flows are changing
- one session's work could invalidate another session's assumptions
- the user asks to coordinate, reconcile, integrate, or review parallel Claude Code work

Do not use this skill when:

- only one implementation session is active
- the task is ordinary bounded subagent delegation
- the work is unrelated across repositories
- the user only wants a review of one completed change
- available evidence is too incomplete to compare the work meaningfully

Consult `references/multi-session-coordination.md` for the detailed coordination rules.
Consult `references/worktrees.md` when any participating task proposes, owns, integrates, or cleans an auxiliary worktree.

## Session Naming

For new project sessions, use:

```text
Project - Three-to-Four-Word Description
```

Detect the project name from the current directory or repository and derive the description from the primary objective. Do not include literal square brackets or ask the user for a name when the project and task are already clear.

Use Claude Code's native naming controls when available:

```text
claude -n "Project - Three-to-Four-Word Description"
/rename Project - Three-to-Four-Word Description
```

Do not rename existing sessions automatically unless the user requests cleanup. If the environment does not expose a session-rename action to the agent, return the exact recommended session name and `/rename` command instead of claiming it was renamed.

## Workflow

### 1. Resolve the operating context

Identify the current:

- project directory
- repository
- default branch
- active branch
- worktree
- applicable `CLAUDE.md` instructions and authoritative project docs
- resolved Claude Code home when session-history inspection is needed and permitted

Do not ask the user for values that can be detected reliably from the environment or repository.

Classify relevant checkouts as host-managed primary, user-managed existing, or task-created auxiliary. Record exact ownership and permits when known. Never infer cleanup authority from age, inactivity, or clean status.

### 2. Discover active sessions and work

Start with sessions active during the previous 72 hours when session history is accessible.

Then inspect:

- sessions associated with the current project directory
- sessions associated with other worktrees of the same repository
- active branches
- worktrees
- open pull requests
- unmerged commits
- active-work records under `.claude/coordination/active-work/` when present

Include older work when session or repository evidence shows that it remains unmerged, incomplete, blocked, contract-relevant, or otherwise active.

Repository state takes precedence over session recency.

Ask for a specific session name or identifier only when automatic discovery is unavailable or materially incomplete and the missing context affects a safe integration decision.

### 3. Classify discovery coverage

Label every work item as:

- directly reviewed session
- session-metadata inference
- repository-inferred work
- user-supplied session
- potentially missing work

Do not claim direct session review when only metadata, a branch, pull request, or diff was inspected.

### 4. Build the shared change map

For each relevant work item, capture:

- session name and identifier when available
- objective
- status
- last activity
- project directory
- branch or worktree
- files and modules affected
- APIs, events, routes, and shared interfaces affected
- schemas, migrations, and persistence affected
- software or service dependencies added or changed
- accepted upstream work artifacts or decisions required before the item can begin or integrate
- tests affected
- handoff and integration verification gates
- assumptions
- unmet upstream dependencies and other blockers
- open decisions
- integration status
- worktree lifecycle status and final disposition when task-created

Separate confirmed facts from inference.

### 5. Detect conflicts

Check for:

- overlapping file ownership
- incompatible architectural decisions
- conflicting API or event contracts
- conflicting shared types
- incompatible schemas or migrations
- dependency-version conflicts
- authentication or authorization inconsistencies
- user-flow and lifecycle conflicts
- duplicate utilities, components, or services
- tests based on incompatible assumptions
- combined behavior that fails even when isolated changes pass

Do not stop at Git merge-conflict detection.

### 6. Establish ownership and sequence

Define:

- one owner for each shared file, contract, schema, or tightly coupled area
- which sessions may continue independently
- which sessions must pause
- which dependency must complete first
- which session must rebase or move to a separate worktree
- which shared contract must be fixed before implementation continues
- which session must adapt to an established interface
- required integration checkpoints
- the remaining chain of blocking work that controls integration completion

Prefer the smallest safe coordination change. Do not allow independent redesigns of the same shared subsystem.

### 7. Resolve disagreements with primary evidence

Use this order:

1. current `CLAUDE.md` instructions and authoritative project docs
2. current code, tests, schemas, configuration, and runtime behavior
3. explicit user decisions
4. established shared contracts
5. smallest safe compatible change

Ask the user only when a remaining decision materially affects architecture, behavior, data, safety, release timing, or user-visible output.

### 8. Produce copy-ready session instructions

For each active session, state:

- what may continue
- what must pause
- owned paths or systems
- prohibited paths or systems
- required contracts
- upstream dependencies
- compatibility changes
- validation to run
- evidence to return
- integration-ready completion condition

Do not use vague instructions such as “coordinate with the other session.”

### 9. Define integration verification

Require validation appropriate to the combined blast radius, including when relevant:

- targeted tests for each feature
- contract tests
- schema or migration checks
- typechecking
- build validation
- integration tests
- end-to-end user-flow checks
- final combined diff review

The coordinating session must inspect the combined result before declaring the work compatible.

The owning root must also reconcile every task-created auxiliary before its final response: remove it after verified integration and cleanup gates, or preserve it with exact ownership and blocker evidence. Do not defer task-owned cleanup to scheduled automation, and do not remove host-managed, user-managed, or another session's worktree.

## Output Format

Return:

- Executive summary
- Discovery coverage
- Active session and work summary
- Shared change map
- Conflict and overlap matrix
- Ranked risks: Critical, High, Medium, Low
- Recommended implementation order
- Copy-ready instructions for each session
- Integration verification checklist
- Open decisions requiring user approval

## Stop Conditions

Stop and report the limitation when:

- the current project directory or repository cannot be identified safely
- relevant sessions are inaccessible and repository evidence cannot compensate
- destructive, production-impacting, or sensitive changes require approval
- two plausible resolutions materially affect architecture or behavior and primary evidence does not resolve them

Do not implement code unless the user explicitly requests implementation. The default role of this skill is coordination, conflict detection, sequencing, and integration planning.
