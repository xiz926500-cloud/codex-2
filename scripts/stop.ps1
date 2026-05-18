param(
    [switch]$Volumes
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

Push-Location $RepoRoot
try {
    $downArgs = @("compose", "down")
    if ($Volumes) {
        $downArgs += "--volumes"
    }

    & docker @downArgs
    if ($LASTEXITCODE -ne 0) {
        throw "docker $($downArgs -join ' ') failed."
    }
}
finally {
    Pop-Location
}
