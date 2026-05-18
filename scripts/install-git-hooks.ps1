$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

Push-Location $RepoRoot
try {
    git config core.hooksPath .githooks
    Write-Host "Git hooks installed from .githooks."
}
finally {
    Pop-Location
}
