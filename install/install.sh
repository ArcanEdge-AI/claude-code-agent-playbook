#!/usr/bin/env bash
set -euo pipefail

MODE="full"
DRY_RUN="0"

for arg in "$@"; do
  case "$arg" in
    --full)
      MODE="full"
      ;;
    --support-only)
      MODE="support-only"
      ;;
    --dry-run)
      DRY_RUN="1"
      ;;
    -h|--help)
      cat <<'HELP'
Usage: bash install/install.sh [--full|--support-only] [--dry-run]

--full          Install global instructions plus references, skills, and custom agents.
--support-only  Install references, skills, and custom agents; add only a pointer to CLAUDE.md.
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"

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

append_section_if_missing() {
  local target="$1"
  local title="$2"
  local body="$3"
  local marker="claude-code-agent-playbook"

  run mkdir -p "$(dirname "$target")"

  if [[ -f "$target" ]] && grep -q "$marker" "$target"; then
    say "Claude Code Agent Playbook section already present in $target; leaving it unchanged."
    return
  fi

  backup_file "$target"

  if [[ "$DRY_RUN" == "1" ]]; then
    say "[dry-run] Would append $title to $target"
    return
  fi

  {
    if [[ -f "$target" ]]; then
      printf '\n\n'
    fi
    printf '<!-- claude-code-agent-playbook:start -->\n'
    printf '# %s\n\n' "$title"
    printf '%s\n' "$body"
    printf '<!-- claude-code-agent-playbook:end -->\n'
  } >> "$target"
}

GLOBAL_INSTRUCTIONS="$REPO_ROOT/custom-instructions/global-coding-agent-instructions.md"
REFERENCES_DIR="$REPO_ROOT/references"
AGENTS_DIR="$REPO_ROOT/agents"
SKILLS_DIR="$REPO_ROOT/skills"
TARGET_CLAUDE_MD="$CLAUDE_HOME/CLAUDE.md"

say "Claude Code Agent Playbook installer"
say "Mode: $MODE"
say "Repository: $REPO_ROOT"
say "CLAUDE_HOME: $CLAUDE_HOME"

if [[ ! -f "$GLOBAL_INSTRUCTIONS" ]]; then
  say "Missing global instructions: $GLOBAL_INSTRUCTIONS" >&2
  exit 1
fi

if [[ "$MODE" == "full" ]]; then
  if [[ -f "$TARGET_CLAUDE_MD" ]]; then
    BODY="$(cat "$GLOBAL_INSTRUCTIONS")"
    append_section_if_missing "$TARGET_CLAUDE_MD" "Claude Code Agent Playbook Global Instructions" "$BODY"
  else
    copy_file "$GLOBAL_INSTRUCTIONS" "$TARGET_CLAUDE_MD"
  fi
else
  POINTER_BODY='The primary global coding-agent behavior may already be configured in this CLAUDE.md file.

Supporting global reference documents live under the Claude Code home references directory:

- `references/README.md` — map of available global reference docs
- `references/subagents.md` — subagent delegation rules, assignment template, and acceptance checklist
- `references/reference-doc-routing.md` — how to decide which docs to consult and how to treat them
- `references/templates/` — templates for repository-level architecture, testing, access-control, design-system, release, API, and data-model docs

Reference documents are supporting context, not automatic truth. The main agent remains accountable for the final plan, final diff, validation, and final response.'
  append_section_if_missing "$TARGET_CLAUDE_MD" "Global Reference Documents and Subagent Support" "$POINTER_BODY"
fi

copy_tree "$REFERENCES_DIR" "$CLAUDE_HOME/references"
copy_tree "$AGENTS_DIR" "$CLAUDE_HOME/agents"
copy_tree "$SKILLS_DIR" "$CLAUDE_HOME/skills"

say ""
say "Validation:"
[[ "$DRY_RUN" == "1" ]] && say "Dry run only; validation checks are informational."

for path in \
  "$TARGET_CLAUDE_MD" \
  "$CLAUDE_HOME/references/subagents.md" \
  "$CLAUDE_HOME/references/reference-doc-routing.md" \
  "$CLAUDE_HOME/agents/read-only-explorer.md" \
  "$CLAUDE_HOME/skills/subagent-orchestration/SKILL.md"; do
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

for agent in "$CLAUDE_HOME/agents"/*.md; do
  [[ -f "$agent" ]] || continue
  if grep -q '^name:' "$agent" && grep -q '^description:' "$agent" && grep -q '^tools:' "$agent"; then
    say "OK frontmatter: $agent"
  else
    say "Check frontmatter: $agent" >&2
  fi
done

say ""
say "Install complete. Restart Claude Code or start a new session if needed so new instructions, skills, and agents are loaded."
