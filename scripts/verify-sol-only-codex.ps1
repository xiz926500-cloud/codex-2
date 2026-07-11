[CmdletBinding()]
param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }),
    [switch]$SkipCodexRuntimeChecks
)

$ErrorActionPreference = "Stop"

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

$configPath = Join-Path $CodexHome "config.toml"
$globalAgentsPath = Join-Path $CodexHome "AGENTS.md"
$agentsPath = Join-Path $CodexHome "agents"

foreach ($path in @($configPath, $globalAgentsPath, $agentsPath)) {
    Assert-True (Test-Path -LiteralPath $path) "Missing required Sol-only path: $path"
}

$config = Get-Content -Raw -LiteralPath $configPath
$globalAgents = Get-Content -Raw -LiteralPath $globalAgentsPath
$activeAgentFiles = @(Get-ChildItem -LiteralPath $agentsPath -Filter "*.toml" -File -ErrorAction SilentlyContinue)

Assert-True ($config -match '(?m)^model\s*=\s*"gpt-5\.6-sol"\s*$') "Sol is not the default model."
Assert-True ($config -match '(?m)^model_reasoning_effort\s*=\s*"high"\s*$') "Sol must use high reasoning by default."
Assert-True ($config -match '(?ms)^\[agents\].*?^max_threads\s*=\s*1\s*$') "Sol-only mode must limit agent threads to 1."
Assert-True ($config -match '(?ms)^\[agents\].*?^max_depth\s*=\s*1\s*$') "Sol-only mode must use the supported minimum agent depth of 1."
Assert-True ($activeAgentFiles.Count -eq 0) "Active custom agent TOML files remain: $($activeAgentFiles.Name -join ', ')"
Assert-True ($globalAgents -match 'root/main model is always Sol') "Global Sol ownership rule is missing."
Assert-True ($globalAgents -match 'Do not spawn subagents') "Global no-delegation rule is missing."

if (-not $SkipCodexRuntimeChecks) {
    $previousCodexHome = $env:CODEX_HOME
    $stderrPath = $null
    $env:CODEX_HOME = $CodexHome

    try {
        $null = & codex --strict-config --version 2>&1
        Assert-True ($LASTEXITCODE -eq 0) "Codex rejected the Sol-only config in strict mode."

        $catalogRaw = (& codex debug models --bundled 2>$null | Out-String)
        Assert-True ($LASTEXITCODE -eq 0) "Could not read the Codex model catalog."
        $solCatalogMatch = [regex]::Match($catalogRaw, '(?s)"slug"\s*:\s*"gpt-5\.6-sol"(?<body>.*?)(?:"base_instructions"\s*:|\z)')
        Assert-True ($solCatalogMatch.Success) "The gpt-5.6-sol model is unavailable in the bundled catalog."
        $solCatalogEntry = $solCatalogMatch.Value
        Assert-True ($solCatalogEntry -match '"effort"\s*:\s*"high"') "gpt-5.6-sol does not support high reasoning."

        $stderrPath = Join-Path $env:TEMP ("codex-sol-only-verify-" + [guid]::NewGuid().ToString("N") + ".stderr")
        $promptRaw = (& codex debug prompt-input "SOL_ONLY_VERIFY" 2>$stderrPath | Out-String)
        Assert-True ($LASTEXITCODE -eq 0) "Codex could not render Sol-only prompt input."
        $stderrText = if (Test-Path -LiteralPath $stderrPath) { [string](Get-Content -Raw -LiteralPath $stderrPath) } else { "" }
        Assert-True (-not [regex]::IsMatch($stderrText, 'malformed agent role definition')) "Codex rejected an agent definition."

        $promptItems = $promptRaw | ConvertFrom-Json -Depth 100
        $promptText = (($promptItems.content | ForEach-Object { $_.text }) -join "`n")
        Assert-True ($promptText -match 'root/main model is always Sol') "Global Sol-only rules were not injected."
        Assert-True ($promptText -match 'Do not spawn subagents') "No-delegation rule was not injected."
    }
    finally {
        $env:CODEX_HOME = $previousCodexHome
        if ($stderrPath) {
            Remove-Item -LiteralPath $stderrPath -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Output "Sol-only Codex verification passed."
