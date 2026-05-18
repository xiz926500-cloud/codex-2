param(
    [switch]$NoBuild,
    [switch]$KeepRunning,
    [int]$TimeoutSeconds = 180
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$PreviousIntegrationBaseUrl = $env:INTEGRATION_BASE_URL

Push-Location $RepoRoot
try {
    $DevScript = Join-Path "." (Join-Path "scripts" "dev.ps1")
    & $DevScript -NoBuild:$NoBuild -TimeoutSeconds $TimeoutSeconds
    if ($LASTEXITCODE -ne 0) {
        throw "scripts\dev.ps1 failed."
    }

    $env:INTEGRATION_BASE_URL = "http://127.0.0.1:8000"

    Push-Location "backend"
    try {
        $IntegrationTests = Join-Path "tests" "integration"
        python -m pytest $IntegrationTests
        if ($LASTEXITCODE -ne 0) {
            throw "Integration tests failed."
        }
    }
    finally {
        Pop-Location
    }

    $frontend = Invoke-WebRequest -Uri "http://127.0.0.1:5173/" -UseBasicParsing -TimeoutSec 10
    if ($frontend.StatusCode -lt 200 -or $frontend.StatusCode -ge 400) {
        throw "Frontend returned unexpected status $($frontend.StatusCode)."
    }
}
finally {
    if ($null -eq $PreviousIntegrationBaseUrl) {
        Remove-Item Env:\INTEGRATION_BASE_URL -ErrorAction SilentlyContinue
    }
    else {
        $env:INTEGRATION_BASE_URL = $PreviousIntegrationBaseUrl
    }

    if (-not $KeepRunning) {
        & docker compose down
    }
    Pop-Location
}
