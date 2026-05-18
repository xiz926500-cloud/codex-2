param(
    [switch]$Local
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

if ($Local) {
    Push-Location (Join-Path $RepoRoot "backend")
    try {
        python -m alembic upgrade head
    }
    finally {
        Pop-Location
    }

    return
}

Push-Location $RepoRoot
try {
    & docker compose run --rm api python -m alembic upgrade head
    if ($LASTEXITCODE -ne 0) {
        throw "docker compose run --rm api python -m alembic upgrade head failed."
    }
}
finally {
    Pop-Location
}
