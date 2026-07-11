[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "Medium")]
param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }),
    [string]$BackupRoot = $(Join-Path ([Environment]::GetFolderPath("MyDocuments")) "Codex\Backups"),
    [switch]$SkipCodexRuntimeChecks
)

$ErrorActionPreference = "Stop"

function Set-RequiredTomlScalar {
    param(
        [string]$Text,
        [string]$Key,
        [string]$TomlValue
    )

    $pattern = "(?m)^$([regex]::Escape($Key))\s*=.*$"
    $matches = [regex]::Matches($Text, $pattern)
    if ($matches.Count -ne 1) {
        throw "Expected exactly one '$Key' entry in config.toml; found $($matches.Count)."
    }

    return [regex]::Replace($Text, $pattern, "$Key = $TomlValue", 1)
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$templateRoot = Join-Path $repoRoot "config\codex-sol-only"
$agentsTemplatePath = Join-Path $templateRoot "AGENTS.md"
$verifierTemplatePath = Join-Path $PSScriptRoot "verify-sol-only-codex.ps1"
$configPath = Join-Path $CodexHome "config.toml"
$globalAgentsPath = Join-Path $CodexHome "AGENTS.md"
$agentsPath = Join-Path $CodexHome "agents"

foreach ($path in @($agentsTemplatePath, $verifierTemplatePath, $configPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required file is missing: $path"
    }
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = Join-Path $BackupRoot "pre-sol-only-$stamp"

if (-not $PSCmdlet.ShouldProcess($CodexHome, "Switch Codex to global Sol-only mode")) {
    return
}

New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
Copy-Item -LiteralPath $configPath -Destination $backupPath
if (Test-Path -LiteralPath $globalAgentsPath) {
    Copy-Item -LiteralPath $globalAgentsPath -Destination $backupPath
}
if (Test-Path -LiteralPath $agentsPath) {
    Copy-Item -LiteralPath $agentsPath -Destination $backupPath -Recurse
}

$config = Get-Content -Raw -LiteralPath $configPath
$config = Set-RequiredTomlScalar -Text $config -Key "model" -TomlValue '"gpt-5.6-sol"'
$config = Set-RequiredTomlScalar -Text $config -Key "model_reasoning_effort" -TomlValue '"high"'
$config = Set-RequiredTomlScalar -Text $config -Key "max_threads" -TomlValue "1"
$config = Set-RequiredTomlScalar -Text $config -Key "max_depth" -TomlValue "1"

$tempConfigPath = "$configPath.sol-only.tmp"
Set-Content -LiteralPath $tempConfigPath -Value $config -Encoding utf8NoBOM
Move-Item -LiteralPath $tempConfigPath -Destination $configPath -Force
Copy-Item -LiteralPath $agentsTemplatePath -Destination $globalAgentsPath -Force
New-Item -ItemType Directory -Path $agentsPath -Force | Out-Null

$activeAgentFiles = @(Get-ChildItem -LiteralPath $agentsPath -Filter "*.toml" -File -ErrorAction SilentlyContinue)
foreach ($agentFile in $activeAgentFiles) {
    $disabledPath = "$($agentFile.FullName).disabled"
    if (Test-Path -LiteralPath $disabledPath) {
        $disabledPath = "$disabledPath.$stamp"
    }
    Move-Item -LiteralPath $agentFile.FullName -Destination $disabledPath
}

$installedVerifier = Join-Path $agentsPath "verify-topology.ps1"
Copy-Item -LiteralPath $verifierTemplatePath -Destination $installedVerifier -Force

if ($SkipCodexRuntimeChecks) {
    & $installedVerifier -CodexHome $CodexHome -SkipCodexRuntimeChecks
}
else {
    & $installedVerifier -CodexHome $CodexHome
}

Write-Output "Sol-only Codex mode applied."
Write-Output "Backup: $backupPath"
Write-Output "Restart Codex or start a new task to load the new root model."
