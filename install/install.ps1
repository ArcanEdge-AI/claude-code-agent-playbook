param(
  [switch]$Full,
  [switch]$SupportOnly,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$Mode = "full"
if ($SupportOnly) { $Mode = "support-only" }
if ($Full) { $Mode = "full" }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..")
$ClaudeHome = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"

function Write-Step($Message) {
  Write-Host $Message
}

function Invoke-InstallCommand {
  param([scriptblock]$Command, [string]$Display)
  if ($DryRun) {
    Write-Host "[dry-run] $Display"
  } else {
    & $Command
  }
}

function Backup-File {
  param([string]$Path)
  if (Test-Path -LiteralPath $Path -PathType Leaf) {
    $Backup = "$Path.bak.$Timestamp"
    Write-Step "Backing up $Path -> $Backup"
    Invoke-InstallCommand { Copy-Item -LiteralPath $Path -Destination $Backup -Force } "Copy-Item '$Path' '$Backup'"
  }
}

function Copy-PlaybookFile {
  param([string]$Source, [string]$Destination)
  $Parent = Split-Path -Parent $Destination
  Invoke-InstallCommand { New-Item -ItemType Directory -Force -Path $Parent | Out-Null } "New-Item -ItemType Directory -Force '$Parent'"
  Backup-File $Destination
  Write-Step "Installing $Destination"
  Invoke-InstallCommand { Copy-Item -LiteralPath $Source -Destination $Destination -Force } "Copy-Item '$Source' '$Destination'"
}

function Copy-PlaybookTree {
  param([string]$SourceDir, [string]$DestinationDir)
  if (-not (Test-Path -LiteralPath $SourceDir -PathType Container)) {
    Write-Step "Skipping missing source directory: $SourceDir"
    return
  }

  Get-ChildItem -LiteralPath $SourceDir -Recurse -File | ForEach-Object {
    $RelativePath = $_.FullName.Substring((Resolve-Path $SourceDir).Path.Length).TrimStart('\','/')
    $Dest = Join-Path $DestinationDir $RelativePath
    Copy-PlaybookFile $_.FullName $Dest
  }
}

function AddOrReplace-PlaybookSection {
  param([string]$Target, [string]$Title, [string]$Body)

  $StartMarker = "<!-- claude-code-agent-playbook:start -->"
  $EndMarker = "<!-- claude-code-agent-playbook:end -->"
  $Parent = Split-Path -Parent $Target
  $Existing = ""
  $Newline = "`n"
  $NormalizedBody = ($Body -replace "`r`n", "`n") -replace "`r", "`n"

  if (Test-Path -LiteralPath $Target -PathType Leaf) {
    $Existing = Get-Content -LiteralPath $Target -Raw
    $Newline = if ($Existing.Contains("`r`n")) { "`r`n" } else { "`n" }
    $StartIndex = $Existing.IndexOf($StartMarker, [System.StringComparison]::Ordinal)
    $EndIndex = $Existing.IndexOf($EndMarker, [System.StringComparison]::Ordinal)
    $HasStart = $StartIndex -ge 0
    $HasEnd = $EndIndex -ge 0

    if ($HasStart -or $HasEnd) {
      $SecondStartIndex = if ($HasStart) { $Existing.IndexOf($StartMarker, $StartIndex + $StartMarker.Length, [System.StringComparison]::Ordinal) } else { -1 }
      $SecondEndIndex = if ($HasEnd) { $Existing.IndexOf($EndMarker, $EndIndex + $EndMarker.Length, [System.StringComparison]::Ordinal) } else { -1 }

      if (-not ($HasStart -and $HasEnd) -or $SecondStartIndex -ge 0 -or $SecondEndIndex -ge 0 -or $EndIndex -lt $StartIndex) {
        throw "Malformed Claude Code Agent Playbook markers in $Target; no changes were made."
      }

      if ($Newline -eq "`r`n") {
        $NormalizedBody = $NormalizedBody -replace "`n", "`r`n"
      }
      $Section = "$StartMarker$Newline# $Title$Newline$Newline$NormalizedBody$Newline$EndMarker"
      Backup-File $Target
      if ($DryRun) {
        Write-Step "[dry-run] Would replace the Claude Code Agent Playbook section in $Target"
      } else {
        $Updated = $Existing.Substring(0, $StartIndex) + $Section + $Existing.Substring($EndIndex + $EndMarker.Length)
        Set-Content -LiteralPath $Target -Value $Updated -Encoding UTF8 -NoNewline
      }
      return
    }
  }

  if ($Newline -eq "`r`n") {
    $NormalizedBody = $NormalizedBody -replace "`n", "`r`n"
  }
  $Section = "$StartMarker$Newline# $Title$Newline$Newline$NormalizedBody$Newline$EndMarker"
  Invoke-InstallCommand { New-Item -ItemType Directory -Force -Path $Parent | Out-Null } "New-Item -ItemType Directory -Force '$Parent'"
  Backup-File $Target

  if ($DryRun) {
    Write-Step "[dry-run] Would append $Title to $Target"
  } elseif (Test-Path -LiteralPath $Target -PathType Leaf) {
    $Separator = if ($Existing.Length -eq 0) { "" } else { "$Newline$Newline" }
    Set-Content -LiteralPath $Target -Value ($Existing + $Separator + $Section) -Encoding UTF8 -NoNewline
  } else {
    Set-Content -LiteralPath $Target -Value $Section -Encoding UTF8 -NoNewline
  }
}

$GlobalInstructions = Join-Path $RepoRoot "custom-instructions\global-coding-agent-instructions.md"
$ReferencesDir = Join-Path $RepoRoot "references"
$AgentsDir = Join-Path $RepoRoot "agents"
$SkillsDir = Join-Path $RepoRoot "skills"
$TargetClaudeMd = Join-Path $ClaudeHome "CLAUDE.md"

Write-Step "Claude Code Agent Playbook installer"
Write-Step "Mode: $Mode"
Write-Step "Repository: $RepoRoot"
Write-Step "CLAUDE_HOME: $ClaudeHome"

if (-not (Test-Path -LiteralPath $GlobalInstructions -PathType Leaf)) {
  throw "Missing global instructions: $GlobalInstructions"
}

if ($Mode -eq "full") {
  if (Test-Path -LiteralPath $TargetClaudeMd -PathType Leaf) {
    $Body = Get-Content -LiteralPath $GlobalInstructions -Raw
    AddOrReplace-PlaybookSection $TargetClaudeMd "Claude Code Agent Playbook Global Instructions" $Body
  } else {
    Copy-PlaybookFile $GlobalInstructions $TargetClaudeMd
  }
} else {
  $PointerBody = @'
The primary global coding-agent behavior may already be configured in this CLAUDE.md file.

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

The root session remains accountable for the final plan, final diff, validation, and final response.
'@
  AddOrReplace-PlaybookSection $TargetClaudeMd "Global Reference Documents and Subagent Support" $PointerBody
}

Copy-PlaybookTree $ReferencesDir (Join-Path $ClaudeHome "references")
Copy-PlaybookTree $AgentsDir (Join-Path $ClaudeHome "agents")
Copy-PlaybookTree $SkillsDir (Join-Path $ClaudeHome "skills")

Write-Step ""
Write-Step "Validation:"
$CheckPaths = @(
  $TargetClaudeMd,
  (Join-Path $ClaudeHome "references\model-routing.md"),
  (Join-Path $ClaudeHome "references\subagents.md"),
  (Join-Path $ClaudeHome "references\worktrees.md"),
  (Join-Path $ClaudeHome "references\multi-session-coordination.md"),
  (Join-Path $ClaudeHome "references\reference-doc-routing.md"),
  (Join-Path $ClaudeHome "references\templates\active-work-record.md"),
  (Join-Path $ClaudeHome "references\templates\task-graph.md"),
  (Join-Path $ClaudeHome "references\templates\worktree-manifest.md"),
  (Join-Path $ClaudeHome "agents\local-orchestrator.md"),
  (Join-Path $ClaudeHome "agents\read-only-explorer.md"),
  (Join-Path $ClaudeHome "agents\senior-reviewer.md"),
  (Join-Path $ClaudeHome "agents\docs-researcher.md"),
  (Join-Path $ClaudeHome "agents\test-triager.md"),
  (Join-Path $ClaudeHome "agents\isolated-worker.md"),
  (Join-Path $ClaudeHome "skills\subagent-orchestration\SKILL.md"),
  (Join-Path $ClaudeHome "skills\task-graph-orchestration\SKILL.md"),
  (Join-Path $ClaudeHome "skills\worktree-lifecycle\SKILL.md"),
  (Join-Path $ClaudeHome "skills\multi-session-coordination\SKILL.md"),
  (Join-Path $ClaudeHome "skills\reference-doc-routing\SKILL.md"),
  (Join-Path $ClaudeHome "skills\senior-code-review\SKILL.md")
)

foreach ($Path in $CheckPaths) {
  if ($DryRun -or (Test-Path -LiteralPath $Path)) {
    Write-Step "OK: $Path"
  } else {
    Write-Warning "Missing: $Path"
  }
}

Get-ChildItem -LiteralPath (Join-Path $ClaudeHome "skills") -Filter SKILL.md -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
  $Text = Get-Content -LiteralPath $_.FullName -Raw
  if ($Text -match "(?m)^name:" -and $Text -match "(?m)^description:") {
    Write-Step "OK frontmatter: $($_.FullName)"
  } else {
    Write-Warning "Check frontmatter: $($_.FullName)"
  }
}

$ExpectedAgentNames = @(
  "local-orchestrator",
  "read-only-explorer",
  "senior-reviewer",
  "docs-researcher",
  "test-triager",
  "isolated-worker"
)

foreach ($AgentName in $ExpectedAgentNames) {
  $AgentPath = Join-Path $ClaudeHome "agents\$AgentName.md"
  if ($DryRun -or -not (Test-Path -LiteralPath $AgentPath -PathType Leaf)) {
    continue
  }

  $Text = Get-Content -LiteralPath $AgentPath -Raw
  if ($Text -match "(?m)^name:" -and
      $Text -match "(?m)^description:" -and
      $Text -match "(?m)^model:" -and
      $Text -match "(?m)^effort:" -and
      $Text -match "(?m)^permissionMode:" -and
      $Text -match "(?m)^tools:") {
    Write-Step "OK Claude Code frontmatter: $AgentPath"
  } else {
    Write-Warning "Check Claude Code frontmatter: $AgentPath"
  }

  if ($Text -match "(?m)^name:\s*$([regex]::Escape($AgentName))\s*$" -and
      $Text -match "(?m)^model:\s*haiku\s*$") {
    Write-Step "OK Claude Code agent name and model: $AgentPath"
  } else {
    Write-Warning "Check Claude Code agent name or fail-closed Haiku model: $AgentPath"
  }

  $ToolsMatch = [regex]::Match($Text, "(?m)^tools:\s*(.+)$")
  $HasAgentTool = $ToolsMatch.Success -and ($ToolsMatch.Groups[1].Value -match "(?:^|,\s*)Agent(?:\s*,|$)")
  if ($AgentName -eq "local-orchestrator") {
    if ($HasAgentTool) {
      Write-Step "OK depth-1 Agent tool: $AgentPath"
    } else {
      Write-Warning "local-orchestrator.md must list Agent: $AgentPath"
    }
  } elseif ($HasAgentTool) {
    Write-Warning "Execution worker or leaf must not list Agent: $AgentPath"
  }

  if ($Text -match "(?m)^isolation:\s*worktree\s*$") {
    Write-Warning "Bundled agents must not enable worktree isolation globally: $AgentPath"
  }
}

Write-Step ""
Write-Step "Install complete. Restart Claude Code or start a new session if needed so new instructions, skills, and subagents are loaded."
