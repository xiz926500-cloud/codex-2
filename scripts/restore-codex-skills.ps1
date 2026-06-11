param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE ".codex" }),
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Resolve-Python {
    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($python) {
        return $python.Source
    }

    throw "python was not found. Install Python 3.12+ and reopen PowerShell."
}

function Install-CodexSkill {
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $skillRoot = Join-Path $CodexHome "skills"
    $destination = Join-Path $skillRoot $Name

    if (Test-Path -LiteralPath $destination -PathType Container) {
        Write-Host "Already installed: $Name"
        return
    }

    Write-Host "Installing $Name from $Repo/$Path"
    if ($DryRun) {
        return
    }

    & $script:PythonExe $script:Installer --repo $Repo --path $Path
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install skill: $Name"
    }
}

$SkillRoot = Join-Path $CodexHome "skills"
$Installer = Join-Path $SkillRoot ".system\skill-installer\scripts\install-skill-from-github.py"

if (-not (Test-Path -LiteralPath $Installer -PathType Leaf)) {
    throw "Codex skill installer was not found at: $Installer. Install or start Codex first, then retry."
}

$PythonExe = Resolve-Python

$Skills = @(
    @{ Repo = "mattpocock/skills"; Path = "skills/engineering/diagnose"; Name = "diagnose" },
    @{ Repo = "mattpocock/skills"; Path = "skills/engineering/tdd"; Name = "tdd" },
    @{ Repo = "mattpocock/skills"; Path = "skills/engineering/grill-with-docs"; Name = "grill-with-docs" },
    @{ Repo = "mattpocock/skills"; Path = "skills/engineering/to-prd"; Name = "to-prd" },
    @{ Repo = "mattpocock/skills"; Path = "skills/engineering/zoom-out"; Name = "zoom-out" },
    @{ Repo = "mattpocock/skills"; Path = "skills/engineering/to-issues"; Name = "to-issues" },
    @{ Repo = "mattpocock/skills"; Path = "skills/engineering/triage"; Name = "triage" },
    @{ Repo = "mattpocock/skills"; Path = "skills/productivity/handoff"; Name = "handoff" },
    @{ Repo = "mattpocock/skills"; Path = "skills/engineering/improve-codebase-architecture"; Name = "improve-codebase-architecture" },
    @{ Repo = "mattpocock/skills"; Path = "skills/engineering/prototype"; Name = "prototype" },

    @{ Repo = "openai/skills"; Path = "skills/.curated/playwright"; Name = "playwright" },
    @{ Repo = "openai/skills"; Path = "skills/.curated/security-threat-model"; Name = "security-threat-model" },
    @{ Repo = "openai/skills"; Path = "skills/.curated/security-best-practices"; Name = "security-best-practices" },

    @{ Repo = "obra/superpowers"; Path = "skills/brainstorming"; Name = "brainstorming" },
    @{ Repo = "obra/superpowers"; Path = "skills/dispatching-parallel-agents"; Name = "dispatching-parallel-agents" },
    @{ Repo = "obra/superpowers"; Path = "skills/executing-plans"; Name = "executing-plans" },
    @{ Repo = "obra/superpowers"; Path = "skills/finishing-a-development-branch"; Name = "finishing-a-development-branch" },
    @{ Repo = "obra/superpowers"; Path = "skills/receiving-code-review"; Name = "receiving-code-review" },
    @{ Repo = "obra/superpowers"; Path = "skills/requesting-code-review"; Name = "requesting-code-review" },
    @{ Repo = "obra/superpowers"; Path = "skills/subagent-driven-development"; Name = "subagent-driven-development" },
    @{ Repo = "obra/superpowers"; Path = "skills/systematic-debugging"; Name = "systematic-debugging" },
    @{ Repo = "obra/superpowers"; Path = "skills/test-driven-development"; Name = "test-driven-development" },
    @{ Repo = "obra/superpowers"; Path = "skills/using-git-worktrees"; Name = "using-git-worktrees" },
    @{ Repo = "obra/superpowers"; Path = "skills/using-superpowers"; Name = "using-superpowers" },
    @{ Repo = "obra/superpowers"; Path = "skills/verification-before-completion"; Name = "verification-before-completion" },
    @{ Repo = "obra/superpowers"; Path = "skills/writing-plans"; Name = "writing-plans" },
    @{ Repo = "obra/superpowers"; Path = "skills/writing-skills"; Name = "writing-skills" }
)

Write-Host "Codex home: $CodexHome"
Write-Host "Skill root: $SkillRoot"
Write-Host "Skills to ensure: $($Skills.Count)"

foreach ($skill in $Skills) {
    Install-CodexSkill -Repo $skill.Repo -Path $skill.Path -Name $skill.Name
}

Write-Host ""
Write-Host "Installed skills:"
Get-ChildItem -LiteralPath $SkillRoot -Directory |
    Select-Object -ExpandProperty Name |
    Sort-Object |
    ForEach-Object { Write-Host " - $_" }

Write-Host ""
Write-Host "Restart Codex to pick up new skills."
