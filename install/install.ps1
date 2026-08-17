param(
  [switch]$Full,
  [switch]$SupportOnly,
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if ($Full -and $SupportOnly) {
  throw "Choose either -Full or -SupportOnly, not both. Full mode is the default for installs and updates."
}

$Mode = "full"
if ($SupportOnly) { $Mode = "support-only" }
if ($Full) { $Mode = "full" }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..")
$ClaudeHome = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }
$Timestamp = Get-Date -Format "yyyyMMddHHmmss"
$ManifestPath = Join-Path $ClaudeHome ".claude-code-agent-playbook-managed-files.tsv"

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

function Get-FileSha256 {
  param([string]$Path)
  return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
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
  if (Test-Path -LiteralPath $Destination -PathType Leaf) {
    if ((Get-FileSha256 $Source) -eq (Get-FileSha256 $Destination)) {
      Write-Step "Unchanged $Destination"
      return
    }
  }

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

function Assert-SafeManifestRelativePath {
  param([string]$RelativePath)

  if ([string]::IsNullOrWhiteSpace($RelativePath) -or
      [System.IO.Path]::IsPathRooted($RelativePath) -or
      $RelativePath.Contains("`t") -or
      $RelativePath.Contains("`r") -or
      $RelativePath.Contains("`n")) {
    throw "Unsafe managed-file manifest path: '$RelativePath'"
  }

  $Segments = $RelativePath -split '[/\\]'
  if ($Segments | Where-Object { $_ -in @('', '.', '..') }) {
    throw "Unsafe managed-file manifest path: '$RelativePath'"
  }
}

function Get-ManagedDestination {
  param([System.Collections.IDictionary]$ManagedRoots, [string]$RootName, [string]$RelativePath)

  if (-not $ManagedRoots.Contains($RootName)) {
    throw "Unknown managed-file root '$RootName'."
  }

  Assert-SafeManifestRelativePath $RelativePath
  $DestinationRoot = [System.IO.Path]::GetFullPath($ManagedRoots[$RootName].Destination)
  $NativeRelativePath = $RelativePath -replace '/', [System.IO.Path]::DirectorySeparatorChar
  $Destination = [System.IO.Path]::GetFullPath((Join-Path $DestinationRoot $NativeRelativePath))
  $RootPrefix = $DestinationRoot.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar

  if (-not $Destination.StartsWith($RootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Managed-file destination escapes '$DestinationRoot': '$RelativePath'"
  }

  return $Destination
}

function Get-CurrentManifestEntries {
  param([System.Collections.IDictionary]$ManagedRoots)

  $Entries = @()
  foreach ($RootName in $ManagedRoots.Keys) {
    $SourceRoot = (Resolve-Path -LiteralPath $ManagedRoots[$RootName].Source).Path
    foreach ($File in Get-ChildItem -LiteralPath $SourceRoot -Recurse -File) {
      $RelativePath = $File.FullName.Substring($SourceRoot.Length).TrimStart('\', '/') -replace '\\', '/'
      Assert-SafeManifestRelativePath $RelativePath
      $Entries += [pscustomobject]@{
        Root = $RootName
        Path = $RelativePath
        Hash = Get-FileSha256 $File.FullName
      }
    }
  }

  return @($Entries | Sort-Object Root, Path)
}

function Read-InstallManifest {
  param([string]$Path, [System.Collections.IDictionary]$ManagedRoots)

  $Entries = @{}
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    Write-Step "No previous managed-file manifest found; existing unlisted files will be preserved."
    return $Entries
  }

  $LineNumber = 0
  foreach ($Line in Get-Content -LiteralPath $Path) {
    $LineNumber++
    if ([string]::IsNullOrWhiteSpace($Line) -or $Line.StartsWith('#')) {
      continue
    }

    $Parts = $Line -split "`t"
    if ($Parts.Count -ne 3) {
      throw "Malformed managed-file manifest at ${Path}:$LineNumber"
    }

    $RootName, $RelativePath, $Hash = $Parts
    if (-not $ManagedRoots.Contains($RootName)) {
      throw "Unknown managed-file root '$RootName' at ${Path}:$LineNumber"
    }
    Assert-SafeManifestRelativePath $RelativePath
    if ($Hash -notmatch '^[a-fA-F0-9]{64}$') {
      throw "Invalid SHA-256 at ${Path}:$LineNumber"
    }

    $Key = "$RootName/$RelativePath"
    if ($Entries.ContainsKey($Key)) {
      throw "Duplicate managed-file manifest entry '$Key' at ${Path}:$LineNumber"
    }

    $Entries[$Key] = [pscustomobject]@{
      Root = $RootName
      Path = $RelativePath
      Hash = $Hash.ToLowerInvariant()
    }
  }

  return $Entries
}

function Assert-ManagedFilesMatch {
  param([array]$Entries, [System.Collections.IDictionary]$ManagedRoots)

  if ($DryRun) {
    Write-Step "[dry-run] Would verify $($Entries.Count) managed files against repository SHA-256 hashes."
    return
  }

  foreach ($Entry in $Entries) {
    $Destination = Get-ManagedDestination $ManagedRoots $Entry.Root $Entry.Path
    if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
      throw "Managed file was not installed: $Destination"
    }
    if ((Get-FileSha256 $Destination) -ne $Entry.Hash) {
      throw "Managed file does not match the repository source: $Destination"
    }
  }

  Write-Step "OK managed-file content: $($Entries.Count)/$($Entries.Count) exact SHA-256 matches"
}

function Retire-StaleManagedFiles {
  param([hashtable]$PreviousEntries, [array]$CurrentEntries, [System.Collections.IDictionary]$ManagedRoots)

  $CurrentKeys = @{}
  foreach ($Entry in $CurrentEntries) {
    $CurrentKeys["$($Entry.Root)/$($Entry.Path)"] = $true
  }

  foreach ($Key in @($PreviousEntries.Keys | Sort-Object)) {
    if ($CurrentKeys.ContainsKey($Key)) {
      continue
    }

    $Entry = $PreviousEntries[$Key]
    $Destination = Get-ManagedDestination $ManagedRoots $Entry.Root $Entry.Path
    if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
      Write-Step "Formerly managed file already absent: $Destination"
      continue
    }

    if ((Get-FileSha256 $Destination) -ne $Entry.Hash) {
      Write-Warning "Preserving customized formerly managed file: $Destination"
      continue
    }

    Backup-File $Destination
    Write-Step "Retiring formerly managed file: $Destination"
    Invoke-InstallCommand { Remove-Item -LiteralPath $Destination -Force } "Remove-Item '$Destination'"
  }
}

function Write-InstallManifest {
  param([array]$Entries, [string]$Path)

  $Lines = @('# claude-code-agent-playbook managed files v1')
  foreach ($Entry in $Entries) {
    $Lines += "$($Entry.Root)`t$($Entry.Path)`t$($Entry.Hash)"
  }
  $Content = ($Lines -join "`n") + "`n"

  if (Test-Path -LiteralPath $Path -PathType Leaf) {
    $Existing = (Get-Content -LiteralPath $Path -Raw) -replace "`r`n", "`n"
    if ($Existing -eq $Content) {
      Write-Step "Unchanged $Path"
      return
    }
  }

  $Parent = Split-Path -Parent $Path
  Invoke-InstallCommand { New-Item -ItemType Directory -Force -Path $Parent | Out-Null } "New-Item -ItemType Directory -Force '$Parent'"
  Backup-File $Path
  Write-Step "Writing managed-file manifest: $Path"
  if ($DryRun) {
    Write-Step "[dry-run] Would write $($Entries.Count) managed-file entries."
  } else {
    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
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
      $Updated = $Existing.Substring(0, $StartIndex) + $Section + $Existing.Substring($EndIndex + $EndMarker.Length)
      if ($Updated -eq $Existing) {
        Write-Step "Unchanged $Target"
        return
      }

      Backup-File $Target
      if ($DryRun) {
        Write-Step "[dry-run] Would replace the Claude Code Agent Playbook section in $Target"
      } else {
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
$ManagedRoots = [ordered]@{
  references = @{ Source = $ReferencesDir; Destination = (Join-Path $ClaudeHome "references") }
  agents = @{ Source = $AgentsDir; Destination = (Join-Path $ClaudeHome "agents") }
  skills = @{ Source = $SkillsDir; Destination = (Join-Path $ClaudeHome "skills") }
}

Write-Step "Claude Code Agent Playbook installer"
Write-Step "Mode: $Mode"
Write-Step "Repository: $RepoRoot"
Write-Step "CLAUDE_HOME: $ClaudeHome"
Write-Step "Managed-file manifest: $ManifestPath"

if (-not (Test-Path -LiteralPath $GlobalInstructions -PathType Leaf)) {
  throw "Missing global instructions: $GlobalInstructions"
}

$CurrentManifestEntries = Get-CurrentManifestEntries $ManagedRoots
$PreviousManifestEntries = Read-InstallManifest $ManifestPath $ManagedRoots

if ($Mode -eq "full") {
  $Body = Get-Content -LiteralPath $GlobalInstructions -Raw
  AddOrReplace-PlaybookSection $TargetClaudeMd "Claude Code Agent Playbook Global Instructions" $Body
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

Copy-PlaybookTree $ReferencesDir $ManagedRoots['references'].Destination
Copy-PlaybookTree $AgentsDir $ManagedRoots['agents'].Destination
Copy-PlaybookTree $SkillsDir $ManagedRoots['skills'].Destination
Assert-ManagedFilesMatch $CurrentManifestEntries $ManagedRoots
Retire-StaleManagedFiles $PreviousManifestEntries $CurrentManifestEntries $ManagedRoots
Write-InstallManifest $CurrentManifestEntries $ManifestPath

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
