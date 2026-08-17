# Prompt: Coordinate Active Project Work

Use this prompt when multiple Claude Code sessions are working on related features in the same project.

```markdown
Coordinate all active work for the current project.

Use the `multi-session-coordination` skill and consult `references/multi-session-coordination.md`. Consult `references/worktrees.md` when any participating task owns or proposes an auxiliary worktree.

Identify the current project directory, repository, default branch, active branch, worktree, and applicable CLAUDE.md instructions from the environment. Do not ask me for information that can be detected reliably.

Use `Project - Three-to-Four-Word Description` for new Claude Code session names. Detect the project name and derive the description from the primary objective. Do not include literal square brackets or ask me for a name when the project and task are already clear. If you cannot rename the current session directly, return the exact recommended name and `/rename` command.

Begin with related Claude Code sessions active during the previous 72 hours when session history is accessible. Include older work when session or repository evidence shows that it remains unmerged, incomplete, blocked, contract-relevant, or otherwise active.

When complete session discovery is unavailable, inspect accessible session metadata, branches, worktrees, pull requests, commits, diffs, tests, and optional active-work records. Clearly distinguish directly reviewed sessions, session-metadata inference, repository-inferred work, user-supplied sessions, and potentially missing work.

Classify relevant checkouts as host-managed primary, user-managed existing, or task-created auxiliary. Do not infer cleanup authority from age, inactivity, or clean status. Require each owning task to integrate and remove its own safe task-created auxiliaries or preserve them with exact path, owner, branch or HEAD, blocker, and next action. Do not defer task-local cleanup to scheduled automation.

Build a shared change map and identify conflicts across files, architecture, APIs, events, schemas, migrations, shared types, dependencies, authentication, user flows, and tests. Do not limit the review to Git merge conflicts.

For each dependency, distinguish a software or service dependency from an accepted upstream work artifact or decision. Identify unmet blockers, handoff and integration verification gates, and the remaining chain of blocking work that controls integration completion.

Assign clear ownership for shared areas, recommend the safest implementation order, identify sessions that should continue or pause, and provide copy-ready instructions for each active session.

Return:

1. Executive summary
2. Discovery coverage
3. Active session and work summary
4. Shared change map
5. Conflict and overlap matrix
6. Ranked integration risks
7. Recommended implementation order
8. Instructions for each session
9. Integration verification checklist
10. Open decisions requiring my approval

Do not implement changes unless I explicitly ask. Do not claim complete coverage when relevant Claude Code session context is inaccessible. Ask for a specific session name or identifier only when missing context materially prevents a safe coordination decision.
```

Optional constraints can be added in plain language, for example:

- Prioritize one feature.
- Include a known session.
- Exclude an abandoned branch.
- Prevent database changes until approval.
- Coordinate only planning and review work.
