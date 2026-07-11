$ErrorActionPreference = "Stop"

function Assert-Match {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

function Assert-NotMatch {
    param(
        [string]$Text,
        [string]$Pattern,
        [string]$Message
    )

    if ($Text -match $Pattern) {
        throw $Message
    }
}
function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$agentsPath = Join-Path $repoRoot "AGENTS.md"
$workflowPath = Join-Path $repoRoot "docs\CODEX_WORKFLOW.md"
$projectConfigPath = Join-Path $repoRoot "config\codex-sol-only\config.toml"
$templateAgentsPath = Join-Path $repoRoot "config\codex-sol-only\AGENTS.md"
$applyScriptPath = Join-Path $PSScriptRoot "apply-sol-only-codex.ps1"
$verifierPath = Join-Path $PSScriptRoot "verify-sol-only-codex.ps1"

$agents = Get-Content -Raw -LiteralPath $agentsPath
$workflow = Get-Content -Raw -LiteralPath $workflowPath
$projectConfig = Get-Content -Raw -LiteralPath $projectConfigPath
$templateAgents = Get-Content -Raw -LiteralPath $templateAgentsPath
$verifier = Get-Content -Raw -LiteralPath $verifierPath

Assert-Match $agents 'Normative repository guidance' "AGENTS.md must identify itself as the normative repository policy."
Assert-Match $agents 'persistent multi-module project' "The project structure audit must be risk-based."
Assert-Match $agents 'one-file utility' "Small projects need an autonomous fast path."
Assert-Match $agents 'Check that a tool is available and ready' "Context tools need a readiness gate."
Assert-Match $agents 'do not repeatedly call an unready tool' "Unready tools must not cause retry loops."
Assert-Match $agents 'production code, shared tracked' "Branch creation must use a change-risk threshold."
Assert-Match $agents 'meaningless test' "Verification policy must reject test-for-test's-sake artifacts."
Assert-Match $agents 'affected behavior' "Affected saved tests must be rerun."
Assert-Match $agents 'Run in Sol-only mode' "The repository must require Sol-only execution."
Assert-NotMatch $agents 'Terra/Sol/Luna|TASK_NOT_READY' "Multi-agent routing returned to repository policy."

Assert-NotMatch $agents 'Treat that new-project structure audit as a required checkpoint' "Unconditional structure review returned."
Assert-NotMatch $agents 'When MCP tools are available, include them' "Unconditional MCP use returned."
Assert-NotMatch $agents 'Use one branch per task' "Unconditional branch creation returned."
Assert-NotMatch $agents 'After changing or adding a feature, create or update' "Unconditional test creation returned."

Assert-Match $projectConfig '(?m)^model\s*=\s*"gpt-5\.6-sol"\s*$' "Project config must select gpt-5.6-sol."
Assert-Match $projectConfig '(?m)^model_reasoning_effort\s*=\s*"high"\s*$' "Project Sol reasoning must be high."
Assert-Match $projectConfig '(?ms)^\[agents\].*?^max_threads\s*=\s*1\s*$' "Project config must limit agent threads to 1."
Assert-Match $projectConfig '(?ms)^\[agents\].*?^max_depth\s*=\s*1\s*$' "Sol-only config must use the supported minimum agent depth."

Assert-Match $templateAgents 'root/main model is always Sol' "Global template must assign ownership to Sol."
Assert-Match $templateAgents 'Do not spawn subagents' "Global template must forbid delegation."
Assert-NotMatch $templateAgents 'Terra|Luna|TASK_NOT_READY' "Global template still contains multi-model routing."
Assert-Match $verifier 'debug models --bundled' "Verifier must use the reproducible bundled model catalog."
Assert-NotMatch $verifier '\$catalogRaw\s*\|\s*ConvertFrom-Json' "Verifier must not deserialize the full model catalog."

Assert-Match $workflow 'AGENTS\.md.*normative' "The runbook must defer to AGENTS.md."
Assert-Match $workflow '## Sol-Only Execution' "The runbook must document Sol-only execution."
Assert-Match $workflow 'agents\.max_depth = 1' "The runbook must document the supported minimum agent depth."
Assert-Match $workflow 'apply-sol-only-codex\.ps1' "The runbook must document the global migration command."
Assert-Match $workflow 'Current repo is indexed' "GitNexus readiness is not documented."
Assert-Match $workflow 'Current repo is initialized' "OpenSpec readiness is not documented."
Assert-Match $workflow 'Do not add empty or' "Configuration verification must remain meaningful."
Assert-NotMatch $workflow 'Terra|Luna|TASK_NOT_READY|one write-capable agent|up to 90 seconds' "The runbook still contains multi-agent behavior."

$fixtureRoot = Join-Path $env:TEMP ("codex-sol-only-test-" + [guid]::NewGuid().ToString("N"))
$fakeHome = Join-Path $fixtureRoot "codex-home"
$backupRoot = Join-Path $fixtureRoot "backups"

try {
    New-Item -ItemType Directory -Path (Join-Path $fakeHome "agents") -Force | Out-Null
    $fakeConfig = @"
model = "gpt-5.6-terra"
model_reasoning_effort = "ultra"
sandbox_mode = "workspace-write"

[agents]
max_threads = 4
max_depth = 2
interrupt_message = true
"@
    Set-Content -LiteralPath (Join-Path $fakeHome "config.toml") -Value $fakeConfig -Encoding utf8NoBOM
    Set-Content -LiteralPath (Join-Path $fakeHome "AGENTS.md") -Value "old multi-agent guidance" -Encoding utf8NoBOM
    Set-Content -LiteralPath (Join-Path $fakeHome "agents\sol.toml") -Value 'name = "sol"' -Encoding utf8NoBOM
    Set-Content -LiteralPath (Join-Path $fakeHome "agents\luna.toml") -Value 'name = "luna"' -Encoding utf8NoBOM

    & $applyScriptPath -CodexHome $fakeHome -BackupRoot $backupRoot -SkipCodexRuntimeChecks | Out-Null
    & $verifierPath -CodexHome $fakeHome -SkipCodexRuntimeChecks | Out-Null

    $migratedConfig = Get-Content -Raw -LiteralPath (Join-Path $fakeHome "config.toml")
    Assert-Match $migratedConfig '(?m)^model\s*=\s*"gpt-5\.6-sol"\s*$' "Migration did not select Sol."
    Assert-Match $migratedConfig '(?ms)^\[agents\].*?^max_depth\s*=\s*1\s*$' "Migration did not set the supported minimum agent depth."
    Assert-True (@(Get-ChildItem -LiteralPath (Join-Path $fakeHome "agents") -Filter "*.toml" -File).Count -eq 0) "Migration left active custom agents."
    Assert-True (@(Get-ChildItem -LiteralPath (Join-Path $fakeHome "agents") -Filter "*.toml.disabled*" -File).Count -eq 2) "Migration did not preserve disabled agent files."
    Assert-True (@(Get-ChildItem -LiteralPath $backupRoot -Directory).Count -eq 1) "Migration did not create exactly one backup."
}
finally {
    Remove-Item -LiteralPath $fixtureRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "Workflow policy tests passed."
