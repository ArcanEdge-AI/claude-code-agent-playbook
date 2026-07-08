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

function Append-SectionIfMissing {
  param([string]$Target, [string]$Title, [string]$Body)

  $Marker = "claude-code-agent-playbook"
  $Parent = Split-Path -Parent $Target
  Invoke-InstallCommand { New-Item -ItemType Directory -Force -Path $Parent | Out-Null } "New-Item -ItemType Directory -Force '$Parent'"

  if ((Test-Path -LiteralPath $Target -PathType Leaf) -and ((Get-Content -LiteralPath $Target -Raw) -match $Marker)) {
    Write-Step "Claude Code Agent Playbook section already present in $Target; leaving it unchanged."
    return
  }

  Backup-File $Target

  $Section = @"

<!-- claude-code-agent-playbook:start -->
# $Title

$Body
<!-- claude-code-agent-playbook:end -->
"@

  if ($DryRun) {
    Write-Step "[dry-run] Would append $Title to $Target"
  } else {
    Add-Content -LiteralPath $Target -Value $Section -Encoding UTF8
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
    Append-SectionIfMissing $TargetClaudeMd "Claude Code Agent Playbook Global Instructions" $Body
  } else {
    Copy-PlaybookFile $GlobalInstructions $TargetClaudeMd
  }
} else {
  $PointerBody = @"
The primary global coding-agent behavior may already be configured in this CLAUDE.md file.

Supporting global reference documents live under the Claude Code home references directory:

- ``references/README.md`` — map of available global reference docs
- ``references/subagents.md`` — subagent delegation rules, assignment template, and acceptance checklist
- ``references/reference-doc-routing.md`` — how to decide which docs to consult and how to treat them
- ``references/templates/`` — templates for repository-level architecture, testing, access-control, design-system, release, API, and data-model docs

Reference documents are supporting context, not automatic truth. The main agent remains accountable for the final plan, final diff, validation, and final response.
"@
  Append-SectionIfMissing $TargetClaudeMd "Global Reference Documents and Subagent Support" $PointerBody
}

Copy-PlaybookTree $ReferencesDir (Join-Path $ClaudeHome "references")
Copy-PlaybookTree $AgentsDir (Join-Path $ClaudeHome "agents")
Copy-PlaybookTree $SkillsDir (Join-Path $ClaudeHome "skills")

Write-Step ""
Write-Step "Validation:"
$CheckPaths = @(
  $TargetClaudeMd,
  (Join-Path $ClaudeHome "references\subagents.md"),
  (Join-Path $ClaudeHome "references\reference-doc-routing.md"),
  (Join-Path $ClaudeHome "agents\read-only-explorer.md"),
  (Join-Path $ClaudeHome "skills\subagent-orchestration\SKILL.md")
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

Get-ChildItem -LiteralPath (Join-Path $ClaudeHome "agents") -Filter *.md -ErrorAction SilentlyContinue | ForEach-Object {
  $Text = Get-Content -LiteralPath $_.FullName -Raw
  if ($Text -match "(?m)^name:" -and $Text -match "(?m)^description:" -and $Text -match "(?m)^tools:") {
    Write-Step "OK frontmatter: $($_.FullName)"
  } else {
    Write-Warning "Check frontmatter: $($_.FullName)"
  }
}

Write-Step ""
Write-Step "Install complete. Restart Claude Code or start a new session if needed so new instructions, skills, and agents are loaded."
