#!/usr/bin/env bash
set -euo pipefail

MODE="full"
FULL_REQUESTED="0"
SUPPORT_ONLY_REQUESTED="0"
DRY_RUN="0"

for arg in "$@"; do
  case "$arg" in
    --full)
      FULL_REQUESTED="1"
      ;;
    --support-only)
      SUPPORT_ONLY_REQUESTED="1"
      ;;
    --dry-run)
      DRY_RUN="1"
      ;;
    -h|--help)
      cat <<'HELP'
Usage: bash install/install.sh [--full|--support-only] [--dry-run]

--full          Install or update global instructions, references, skills, and subagents. This is the default.
--support-only  Explicit pointer-only mode for users whose global instructions already live in CLAUDE.md.
--dry-run       Print actions without writing files.
HELP
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

if [[ "$FULL_REQUESTED" == "1" && "$SUPPORT_ONLY_REQUESTED" == "1" ]]; then
  echo "Choose either --full or --support-only, not both. Full mode is the default for installs and updates." >&2
  exit 1
fi

if [[ "$SUPPORT_ONLY_REQUESTED" == "1" ]]; then
  MODE="support-only"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
MANIFEST_PATH="$CLAUDE_HOME/.claude-code-agent-playbook-managed-files.tsv"

say() {
  printf '%s\n' "$*"
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

sha256_file() {
  local path="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{ print tolower($1) }'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$path" | awk '{ print tolower($1) }'
  elif command -v openssl >/dev/null 2>&1; then
    openssl dgst -sha256 "$path" | awk '{ print tolower($NF) }'
  else
    say "No SHA-256 tool is available; install sha256sum, shasum, or openssl." >&2
    return 1
  fi
}

backup_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    local backup="$path.bak.$TIMESTAMP"
    say "Backing up $path -> $backup"
    run cp -p "$path" "$backup"
  fi
}

copy_file() {
  local src="$1"
  local dest="$2"
  run mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    say "Unchanged $dest"
    return
  fi
  backup_file "$dest"
  say "Installing $dest"
  run cp "$src" "$dest"
}

copy_tree() {
  local src_dir="$1"
  local dest_dir="$2"
  if [[ ! -d "$src_dir" ]]; then
    say "Skipping missing source directory: $src_dir"
    return
  fi

  while IFS= read -r -d '' src; do
    local rel="${src#$src_dir/}"
    local dest="$dest_dir/$rel"
    copy_file "$src" "$dest"
  done < <(find "$src_dir" -type f -print0)
}

validate_manifest_relative_path() {
  local rel="$1"
  if [[ -z "$rel" || "$rel" == /* || "$rel" == *$'\t'* || "$rel" == *$'\r'* || "$rel" == *$'\n'* ]]; then
    say "Unsafe managed-file manifest path: '$rel'" >&2
    return 1
  fi

  case "/$rel/" in
    *'/../'*|*'/./'*|*'//'*)
      say "Unsafe managed-file manifest path: '$rel'" >&2
      return 1
      ;;
  esac
}

destination_for_manifest_entry() {
  local root="$1"
  local rel="$2"
  validate_manifest_relative_path "$rel"

  case "$root" in
    references) printf '%s\n' "$CLAUDE_HOME/references/$rel" ;;
    agents) printf '%s\n' "$CLAUDE_HOME/agents/$rel" ;;
    skills) printf '%s\n' "$CLAUDE_HOME/skills/$rel" ;;
    *)
      say "Unknown managed-file root '$root'." >&2
      return 1
      ;;
  esac
}

build_current_manifest() {
  local output="$1"
  local root src_dir src rel hash

  printf '# claude-code-agent-playbook managed files v1\n' > "$output"
  for root in references agents skills; do
    case "$root" in
      references) src_dir="$REFERENCES_DIR" ;;
      agents) src_dir="$AGENTS_DIR" ;;
      skills) src_dir="$SKILLS_DIR" ;;
    esac

    while IFS= read -r src; do
      rel="${src#$src_dir/}"
      validate_manifest_relative_path "$rel"
      hash="$(sha256_file "$src")"
      printf '%s\t%s\t%s\n' "$root" "$rel" "$hash" >> "$output"
    done < <(find "$src_dir" -type f -print | LC_ALL=C sort)
  done
}

validate_install_manifest() {
  local path="$1"
  [[ -f "$path" ]] || {
    say "No previous managed-file manifest found; existing unlisted files will be preserved."
    return
  }

  local duplicates
  duplicates="$(awk -F '\t' '!/^#/ && NF == 3 { print $1 "\t" $2 }' "$path" | LC_ALL=C sort | uniq -d)"
  if [[ -n "$duplicates" ]]; then
    say "Duplicate entries in managed-file manifest $path:" >&2
    say "$duplicates" >&2
    return 1
  fi

  local line_number=0 root rel hash extra
  while IFS=$'\t' read -r root rel hash extra || [[ -n "$root$rel$hash$extra" ]]; do
    line_number=$((line_number + 1))
    [[ -z "$root" || "$root" == \#* ]] && continue

    if [[ -n "$extra" || -z "$rel" || -z "$hash" ]]; then
      say "Malformed managed-file manifest at $path:$line_number" >&2
      return 1
    fi
    case "$root" in
      references|agents|skills) ;;
      *)
        say "Unknown managed-file root '$root' at $path:$line_number" >&2
        return 1
        ;;
    esac
    validate_manifest_relative_path "$rel"
    if [[ ! "$hash" =~ ^[a-fA-F0-9]{64}$ ]]; then
      say "Invalid SHA-256 at $path:$line_number" >&2
      return 1
    fi
  done < "$path"
}

manifest_contains_key() {
  local path="$1"
  local root="$2"
  local rel="$3"
  awk -F '\t' -v root="$root" -v rel="$rel" '
    $1 == root && $2 == rel { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$path"
}

verify_managed_files() {
  local current_manifest="$1"
  local count
  count="$(awk -F '\t' '!/^#/ && NF == 3 { count++ } END { print count + 0 }' "$current_manifest")"

  if [[ "$DRY_RUN" == "1" ]]; then
    say "[dry-run] Would verify $count managed files against repository SHA-256 hashes."
    return
  fi

  local root rel expected_hash extra destination actual_hash
  while IFS=$'\t' read -r root rel expected_hash extra || [[ -n "$root$rel$expected_hash$extra" ]]; do
    [[ -z "$root" || "$root" == \#* ]] && continue
    destination="$(destination_for_manifest_entry "$root" "$rel")"
    if [[ ! -f "$destination" ]]; then
      say "Managed file was not installed: $destination" >&2
      return 1
    fi
    actual_hash="$(sha256_file "$destination")"
    if [[ "$actual_hash" != "$expected_hash" ]]; then
      say "Managed file does not match the repository source: $destination" >&2
      return 1
    fi
  done < "$current_manifest"

  say "OK managed-file content: $count/$count exact SHA-256 matches"
}

retire_stale_managed_files() {
  local previous_manifest="$1"
  local current_manifest="$2"
  [[ -f "$previous_manifest" ]] || return 0

  local root rel expected_hash extra destination actual_hash
  while IFS=$'\t' read -r root rel expected_hash extra || [[ -n "$root$rel$expected_hash$extra" ]]; do
    [[ -z "$root" || "$root" == \#* ]] && continue
    if manifest_contains_key "$current_manifest" "$root" "$rel"; then
      continue
    fi

    destination="$(destination_for_manifest_entry "$root" "$rel")"
    if [[ ! -f "$destination" ]]; then
      say "Formerly managed file already absent: $destination"
      continue
    fi

    actual_hash="$(sha256_file "$destination")"
    expected_hash="$(printf '%s' "$expected_hash" | tr '[:upper:]' '[:lower:]')"
    if [[ "$actual_hash" != "$expected_hash" ]]; then
      say "Preserving customized formerly managed file: $destination" >&2
      continue
    fi

    backup_file "$destination"
    say "Retiring formerly managed file: $destination"
    run rm -f -- "$destination"
  done < "$previous_manifest"
}

write_install_manifest() {
  local current_manifest="$1"
  local destination="$2"

  if [[ -f "$destination" ]] && cmp -s "$current_manifest" "$destination"; then
    say "Unchanged $destination"
    return
  fi

  run mkdir -p "$(dirname "$destination")"
  backup_file "$destination"
  say "Writing managed-file manifest: $destination"
  run cp "$current_manifest" "$destination"
}

add_or_replace_playbook_section() {
  local target="$1"
  local title="$2"
  local body="$3"
  local start_marker='<!-- claude-code-agent-playbook:start -->'
  local end_marker='<!-- claude-code-agent-playbook:end -->'

  if [[ -f "$target" ]]; then
    local start_count end_count start_line end_line marker_line_ending newline section temp
    read -r start_count end_count start_line end_line marker_line_ending < <(
      awk -v start="$start_marker" -v end="$end_marker" '
        {
          line = $0
          has_cr = sub(/\r$/, "", line)
          if (line == start) {
            start_count++
            if (start_line == 0) {
              start_line = NR
              marker_line_ending = has_cr ? "crlf" : "lf"
            }
          }
          if (line == end) {
            end_count++
            if (end_line == 0) end_line = NR
          }
        }
        END { print start_count + 0, end_count + 0, start_line + 0, end_line + 0, marker_line_ending }
      ' "$target"
    )

    if [[ "$start_count" != "0" || "$end_count" != "0" ]]; then
      if [[ "$start_count" != "1" || "$end_count" != "1" ]] || (( end_line <= start_line )); then
        say "Malformed Coding Agent Playbook — Claude Code Edition markers in $target; no changes were made." >&2
        return 1
      fi

      newline=$'\n'
      if [[ "$marker_line_ending" == "crlf" ]]; then
        newline=$'\r\n'
        body="${body//$'\r\n'/$'\n'}"
        body="${body//$'\n'/$'\r\n'}"
      fi
      section="$start_marker$newline# $title$newline$newline$body$newline$end_marker$newline"
      temp="$(mktemp "${target}.claude-code-agent-playbook.XXXXXX")"
      awk -v start="$start_marker" -v end="$end_marker" -v section="$section" -v newline="$newline" '
        {
          line = $0
          sub(/\r$/, "", line)
        }
        line == start { printf "%s", section; in_section = 1; next }
        line == end { in_section = 0; next }
        !in_section { printf "%s%s", line, newline }
      ' "$target" > "$temp"

      if cmp -s "$temp" "$target"; then
        rm -f "$temp"
        say "Unchanged $target"
        return
      fi

      backup_file "$target"
      if [[ "$DRY_RUN" == "1" ]]; then
        rm -f "$temp"
        say "[dry-run] Would replace the Coding Agent Playbook — Claude Code Edition section in $target"
        return
      fi

      cat "$temp" > "$target"
      rm -f "$temp"
      return
    fi
  fi

  run mkdir -p "$(dirname "$target")"
  backup_file "$target"

  if [[ "$DRY_RUN" == "1" ]]; then
    say "[dry-run] Would append $title to $target"
    return
  fi

  newline=$'\n'
  if [[ -f "$target" ]] && awk '
    NR == 1 {
      line = $0
      exit sub(/\r$/, "", line) ? 0 : 1
    }
    END { if (NR == 0) exit 1 }
  ' "$target"; then
    newline=$'\r\n'
    body="${body//$'\r\n'/$'\n'}"
    body="${body//$'\n'/$'\r\n'}"
  fi

  {
    if [[ -s "$target" ]]; then
      printf '%s%s' "$newline" "$newline"
    fi
    printf '%s%s' "$start_marker" "$newline"
    printf '# %s%s%s' "$title" "$newline" "$newline"
    printf '%s%s' "$body" "$newline"
    printf '%s%s' "$end_marker" "$newline"
  } >> "$target"
}

GLOBAL_INSTRUCTIONS="$REPO_ROOT/custom-instructions/global-coding-agent-instructions.md"
REFERENCES_DIR="$REPO_ROOT/references"
AGENTS_DIR="$REPO_ROOT/agents"
SKILLS_DIR="$REPO_ROOT/skills"
TARGET_CLAUDE_MD="$CLAUDE_HOME/CLAUDE.md"

say "Coding Agent Playbook — Claude Code Edition installer"
say "Mode: $MODE"
say "Repository: $REPO_ROOT"
say "CLAUDE_HOME: $CLAUDE_HOME"
say "Managed-file manifest: $MANIFEST_PATH"

if [[ ! -f "$GLOBAL_INSTRUCTIONS" ]]; then
  say "Missing global instructions: $GLOBAL_INSTRUCTIONS" >&2
  exit 1
fi

CURRENT_MANIFEST="$(mktemp "${TMPDIR:-/tmp}/claude-code-agent-playbook-manifest.XXXXXX")"
trap 'rm -f "$CURRENT_MANIFEST"' EXIT
build_current_manifest "$CURRENT_MANIFEST"
validate_install_manifest "$MANIFEST_PATH"

if [[ "$MODE" == "full" ]]; then
  BODY="$(cat "$GLOBAL_INSTRUCTIONS")"
  add_or_replace_playbook_section "$TARGET_CLAUDE_MD" "Coding Agent Playbook — Claude Code Edition Global Instructions" "$BODY"
else
  POINTER_BODY='The primary global coding-agent behavior may already be configured in this CLAUDE.md file.

Supporting global reference documents live under the Claude Code home references directory:

- `references/README.md` — map of available global reference docs
- `references/model-routing.md` — mandatory Claude model, effort, permission, tool, depth, escalation, and acceptance rules
- `references/subagents.md` — Claude Code subagent delegation rules, assignment template, and acceptance checklist
- `references/worktrees.md` — root-owned task-local worktree budgeting, Claude Code isolation, integration, cleanup, and preservation rules
- `references/multi-session-coordination.md` — Claude Code session discovery, naming, ownership, sequencing, conflict detection, and integration guidance
- `references/reference-doc-routing.md` — how to decide which docs to consult and how to treat them
- `references/templates/` — templates for repository-level CLAUDE.md, architecture, testing, access control, design system, release, API, data model, active work, task graphs, and worktree manifests

Reusable Claude Code skills live under the Claude Code home skills directory:

- `skills/subagent-orchestration/SKILL.md`
- `skills/task-graph-orchestration/SKILL.md`
- `skills/worktree-lifecycle/SKILL.md`
- `skills/multi-session-coordination/SKILL.md`
- `skills/reference-doc-routing/SKILL.md`
- `skills/senior-code-review/SKILL.md`

Custom Claude Code subagents live under the Claude Code home agents directory:

- `agents/local-orchestrator.md`
- `agents/read-only-explorer.md`
- `agents/senior-reviewer.md`
- `agents/docs-researcher.md`
- `agents/test-triager.md`
- `agents/isolated-worker.md`

Reference documents are supporting context, not automatic truth. For repository tasks when subagents are available, the root Claude Code session delegates actual execution to at least one bounded subagent and remains accountable for root orchestration, integration, validation, acceptance, and the final response. Direct root execution is limited to unavailable subagents, an explicit user prohibition, or a specific authority-bound action; record the exact exception.

The root owns a finite manifest, total subagent budget, and child-specific permits. The actual user-selected main-session model is the root ceiling: Opus rank 3, Sonnet rank 2, Haiku rank 1. Every managed route is explicit and root-permitted, and every `Agent` invocation passes a model with child rank at or below parent rank; automatic or omitted-model routes are rejected. Bundled definitions fail closed at Haiku, and their fixed effort must fit the parent ceiling. Equal-tier routing is valid and depth does not force a drop. Descendants cannot request upgrades. Only the root may route a new depth-1 replacement within the actual root ceiling, even when stronger than the failed child. Unknown, unavailable, or substituted models are not accepted silently.

Depth 1 contains named direct workers or `local-orchestrator`. A permitted local orchestrator may use only root-permitted depth-2 leaves, and only after nesting support and an active `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=2` setting are verified. Depth-2 leaves omit `Agent` and cannot spawn; depth 3 is prohibited. Every child stays at or below its parent in model, effort, permission mode, tools, scope, workspace, and authority. If either gate is unavailable, depth 1 executes directly without `Agent`; the setting is not changed without authorization.

The auxiliary-worktree budget starts at zero and is separate from the subagent budget. Only the root may authorize `isolation: worktree`, create or adopt an auxiliary, change its purpose, move it, or remove it. One active auxiliary needs no added approval; two or more require user approval for the exact count and reasons. Before the final response, the root removes each task-created auxiliary under verified gates or preserves it with exact path, owner, branch or HEAD, blocker, and next action. Task-local cleanup does not depend on scheduled automation. The active host-managed worktree remains under the host lifecycle.

The root Claude Code session must verify implementation-relevant claims against primary evidence such as current code, tests, schemas, configuration, logs, build output, typecheck output, runtime behavior, relevant session evidence, and authoritative external documentation.

When delegating to subagents or coordinating independent Claude Code sessions, pass only relevant reference document names, paths, or sections. Do not dump large documents or full session transcripts into prompts unless necessary.

The root session remains accountable for the final plan, final diff, validation, and final response.'
  add_or_replace_playbook_section "$TARGET_CLAUDE_MD" "Global Reference Documents and Subagent Support" "$POINTER_BODY"
fi

copy_tree "$REFERENCES_DIR" "$CLAUDE_HOME/references"
copy_tree "$AGENTS_DIR" "$CLAUDE_HOME/agents"
copy_tree "$SKILLS_DIR" "$CLAUDE_HOME/skills"
verify_managed_files "$CURRENT_MANIFEST"
retire_stale_managed_files "$MANIFEST_PATH" "$CURRENT_MANIFEST"
write_install_manifest "$CURRENT_MANIFEST" "$MANIFEST_PATH"

say ""
say "Validation:"
[[ "$DRY_RUN" == "1" ]] && say "Dry run only; validation checks are informational."

for path in \
  "$TARGET_CLAUDE_MD" \
  "$CLAUDE_HOME/references/model-routing.md" \
  "$CLAUDE_HOME/references/subagents.md" \
  "$CLAUDE_HOME/references/worktrees.md" \
  "$CLAUDE_HOME/references/multi-session-coordination.md" \
  "$CLAUDE_HOME/references/reference-doc-routing.md" \
  "$CLAUDE_HOME/references/templates/active-work-record.md" \
  "$CLAUDE_HOME/references/templates/task-graph.md" \
  "$CLAUDE_HOME/references/templates/worktree-manifest.md" \
  "$CLAUDE_HOME/agents/local-orchestrator.md" \
  "$CLAUDE_HOME/agents/read-only-explorer.md" \
  "$CLAUDE_HOME/agents/senior-reviewer.md" \
  "$CLAUDE_HOME/agents/docs-researcher.md" \
  "$CLAUDE_HOME/agents/test-triager.md" \
  "$CLAUDE_HOME/agents/isolated-worker.md" \
  "$CLAUDE_HOME/skills/subagent-orchestration/SKILL.md" \
  "$CLAUDE_HOME/skills/task-graph-orchestration/SKILL.md" \
  "$CLAUDE_HOME/skills/worktree-lifecycle/SKILL.md" \
  "$CLAUDE_HOME/skills/multi-session-coordination/SKILL.md" \
  "$CLAUDE_HOME/skills/reference-doc-routing/SKILL.md" \
  "$CLAUDE_HOME/skills/senior-code-review/SKILL.md"; do
  if [[ -e "$path" || "$DRY_RUN" == "1" ]]; then
    say "OK: $path"
  else
    say "Missing: $path" >&2
  fi
done

for skill in "$CLAUDE_HOME/skills"/*/SKILL.md; do
  [[ -f "$skill" ]] || continue
  if grep -q '^name:' "$skill" && grep -q '^description:' "$skill"; then
    say "OK frontmatter: $skill"
  else
    say "Check frontmatter: $skill" >&2
  fi
done

for agent_name in \
  local-orchestrator \
  read-only-explorer \
  senior-reviewer \
  docs-researcher \
  test-triager \
  isolated-worker; do
  agent="$CLAUDE_HOME/agents/$agent_name.md"
  [[ -f "$agent" ]] || continue
  if grep -q '^name:' "$agent" \
    && grep -q '^description:' "$agent" \
    && grep -q '^model:' "$agent" \
    && grep -q '^effort:' "$agent" \
    && grep -q '^permissionMode:' "$agent" \
    && grep -q '^tools:' "$agent"; then
    say "OK Claude Code frontmatter: $agent"
  else
    say "Check Claude Code frontmatter: $agent" >&2
  fi

  if grep -Eq "^name:[[:space:]]*$agent_name[[:space:]]*$" "$agent" \
    && grep -Eq '^model:[[:space:]]*haiku[[:space:]]*$' "$agent"; then
    say "OK Claude Code agent name and model: $agent"
  else
    say "Check Claude Code agent name or fail-closed Haiku model: $agent" >&2
  fi

  if [[ "$agent_name" == "local-orchestrator" ]]; then
    if grep -Eq '^tools:.*[ ,]Agent([, ]|$)' "$agent"; then
      say "OK depth-1 Agent tool: $agent"
    else
      say "local-orchestrator.md must list Agent: $agent" >&2
    fi
  elif grep -Eq '^tools:.*[ ,]Agent([, ]|$)' "$agent"; then
    say "Execution worker or leaf must not list Agent: $agent" >&2
  fi

  if grep -Eq '^isolation:[[:space:]]*worktree[[:space:]]*$' "$agent"; then
    say "Bundled agents must not enable worktree isolation globally: $agent" >&2
  fi
done

say ""
say "Install complete. Restart Claude Code or start a new session if needed so new instructions, skills, and subagents are loaded."
