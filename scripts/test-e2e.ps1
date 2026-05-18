param(
    [switch]$NoBuild,
    [switch]$InstallBrowsers,
    [switch]$KeepRunning,
    [int]$TimeoutSeconds = 180
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$PreviousE2eBaseUrl = $env:E2E_BASE_URL
$PreviousE2eApiBaseUrl = $env:E2E_API_BASE_URL
$NpxCommand = if ($IsWindows -or $env:OS -eq "Windows_NT") { "npx.cmd" } else { "npx" }

Push-Location $RepoRoot
try {
    $DevScript = Join-Path "." (Join-Path "scripts" "dev.ps1")
    & $DevScript -NoBuild:$NoBuild -TimeoutSeconds $TimeoutSeconds
    if ($LASTEXITCODE -ne 0) {
        throw "scripts\dev.ps1 failed."
    }

    $env:E2E_BASE_URL = "http://127.0.0.1:5173"
    $env:E2E_API_BASE_URL = "http://127.0.0.1:8000"

    Push-Location "frontend"
    try {
        if ($InstallBrowsers) {
            & $NpxCommand playwright install chromium
            if ($LASTEXITCODE -ne 0) {
                throw "Playwright browser installation failed."
            }
        }

        & $NpxCommand playwright test
        if ($LASTEXITCODE -ne 0) {
            throw "Playwright E2E tests failed."
        }
    }
    finally {
        Pop-Location
    }
}
finally {
    if ($null -eq $PreviousE2eBaseUrl) {
        Remove-Item Env:\E2E_BASE_URL -ErrorAction SilentlyContinue
    }
    else {
        $env:E2E_BASE_URL = $PreviousE2eBaseUrl
    }

    if ($null -eq $PreviousE2eApiBaseUrl) {
        Remove-Item Env:\E2E_API_BASE_URL -ErrorAction SilentlyContinue
    }
    else {
        $env:E2E_API_BASE_URL = $PreviousE2eApiBaseUrl
    }

    if (-not $KeepRunning) {
        & docker compose down
    }
    Pop-Location
}
