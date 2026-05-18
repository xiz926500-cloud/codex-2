param(
    [switch]$Full
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$NpmCommand = if ($IsWindows -or $env:OS -eq "Windows_NT") { "npm.cmd" } else { "npm" }

function Invoke-Step {
    param(
        [string]$Name,
        [scriptblock]$Command
    )

    Write-Host "pre-commit: $Name"
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "pre-commit step failed: $Name"
    }
}

Push-Location $RepoRoot
try {
    $VerifyScript = Join-Path "." (Join-Path "scripts" "verify.ps1")
    Invoke-Step "repository verification" { & $VerifyScript }

    Push-Location "backend"
    try {
        Invoke-Step "backend ruff" { python -m ruff check . }
        if ($Full) {
            Invoke-Step "backend tests" { python -m pytest }
        }
    }
    finally {
        Pop-Location
    }

    Push-Location "frontend"
    try {
        Invoke-Step "frontend lint" { & $NpmCommand run lint }
        if ($Full) {
            Invoke-Step "frontend build" { & $NpmCommand run build }
        }
    }
    finally {
        Pop-Location
    }
}
finally {
    Pop-Location
}
