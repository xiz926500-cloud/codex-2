param(
    [switch]$SkipInstall
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

Push-Location (Join-Path $RepoRoot "backend")
try {
    python .\scripts\export_openapi.py
}
finally {
    Pop-Location
}

Push-Location (Join-Path $RepoRoot "frontend")
try {
    if (-not $SkipInstall -and -not (Test-Path -LiteralPath "node_modules" -PathType Container)) {
        npm.cmd install
    }

    npm.cmd run generate:api
}
finally {
    Pop-Location
}
