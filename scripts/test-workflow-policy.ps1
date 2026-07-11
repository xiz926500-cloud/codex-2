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

$agentsPath = Join-Path $PSScriptRoot "..\AGENTS.md"
$workflowPath = Join-Path $PSScriptRoot "..\docs\CODEX_WORKFLOW.md"
$agents = Get-Content -Raw -LiteralPath $agentsPath
$workflow = Get-Content -Raw -LiteralPath $workflowPath

Assert-Match $agents 'Normative repository guidance' "AGENTS.md must identify itself as the normative repository policy."
Assert-Match $agents 'persistent multi-module project' "The project structure audit must be risk-based."
Assert-Match $agents 'one-file utility' "Small projects need an autonomous fast path."
Assert-Match $agents 'Check that a tool is available and ready' "Context tools need a readiness gate."
Assert-Match $agents 'do not repeatedly call an unready tool' "Unready tools must not cause retry loops."
Assert-Match $agents 'production code, shared tracked' "Branch creation must use a change-risk threshold."
Assert-Match $agents 'meaningless test' "Verification policy must reject test-for-test's-sake artifacts."
Assert-Match $agents 'affected behavior' "Affected saved tests must be rerun."

Assert-NotMatch $agents 'Treat that new-project structure audit as a required checkpoint' "Unconditional structure review returned."
Assert-NotMatch $agents 'When MCP tools are available, include them' "Unconditional MCP use returned."
Assert-NotMatch $agents 'Use one branch per task' "Unconditional branch creation returned."
Assert-NotMatch $agents 'After changing or adding a feature, create or update' "Unconditional test creation returned."

Assert-Match $workflow 'AGENTS\.md.*normative' "The runbook must defer to AGENTS.md."
Assert-Match $workflow 'up to 90 seconds' "The Sol consultation budget is missing."
Assert-Match $workflow 'wait 30 seconds' "The Sol interruption grace period is missing."
Assert-Match $workflow 'one write-capable agent per worktree' "The single-writer rule is missing."
Assert-Match $workflow 'Current repo is indexed' "GitNexus readiness is not documented."
Assert-Match $workflow 'Current repo is initialized' "OpenSpec readiness is not documented."
Assert-Match $workflow 'Do not add empty or' "Configuration verification must remain meaningful."

Write-Output "Workflow policy tests passed."
