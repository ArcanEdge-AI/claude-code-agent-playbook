---
name: subagent-orchestration
description: Use when a coding task may benefit from Claude Code subagents for codebase exploration, review, docs research, test triage, or isolated implementation. Helps the main agent delegate bounded work and verify outputs before accepting them.
---

# Subagent Orchestration Skill

The main agent is the senior developer and orchestrator. Subagents assist but do not own the outcome.

Use this skill when:

- the task is complex, multi-file, risky, or ambiguous
- independent read-heavy exploration would help
- review from another perspective would improve quality
- documentation or external API behavior needs verification
- logs, tests, or large files need focused analysis
- a small isolated implementation can be delegated safely

Do not use this skill when:

- the task is trivial
- one coherent design judgment is required
- requirements are materially unclear
- subagents would edit the same files
- the main agent cannot verify the result

Workflow:

1. Clarify the task goal and success criteria.
2. Decide which work, if any, should be delegated.
3. Choose from the Claude Code roles: Read-Only Explorer, Senior Reviewer, Docs Researcher, Test Triager, and Isolated Worker.
4. Right-size the model when model selection is available:
   - use cheaper or faster models for bounded, low-risk, easily verifiable work
   - use stronger reasoning for meaningful review, ambiguous debugging, security-sensitive work, complex test triage, and high-impact implementation
5. Give each subagent a precise assignment:
   - role
   - goal
   - context
   - model / reasoning guidance
   - scope
   - non-goals
   - permissions
   - required evidence
   - output format
6. Wait for delegated results before accepting conclusions.
7. Verify subagent claims against primary evidence.
8. Inspect any changed files yourself.
9. Accept, reject, or revise subagent recommendations.
10. Report relevant subagent usage in the final response.

Never accept a subagent's conclusion solely because it sounds confident.
