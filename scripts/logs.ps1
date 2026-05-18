param(
    [ValidateSet("all", "api", "web", "postgres", "redis")]
    [string]$Service = "all",
    [int]$Tail = 100,
    [switch]$Follow
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

Push-Location $RepoRoot
try {
    $logArgs = @("compose", "logs", "--tail", "$Tail")
    if ($Follow) {
        $logArgs += "-f"
    }
    if ($Service -ne "all") {
        $logArgs += $Service
    }

    & docker @logArgs
    if ($LASTEXITCODE -ne 0) {
        throw "docker $($logArgs -join ' ') failed."
    }
}
finally {
    Pop-Location
}
