param(
    [switch]$NoBuild,
    [switch]$SkipMigrations,
    [int]$TimeoutSeconds = 120
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

function Invoke-Docker {
    param([string[]]$Arguments)

    & docker @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "docker $($Arguments -join ' ') failed."
    }
}

function Wait-Http {
    param(
        [string]$Name,
        [string]$Uri,
        [int]$TimeoutSeconds
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
        try {
            $response = Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
                Write-Host "$Name is ready: $Uri"
                return
            }
        }
        catch {
            Start-Sleep -Seconds 2
        }
    } while ((Get-Date) -lt $deadline)

    throw "$Name did not become ready at $Uri within $TimeoutSeconds seconds."
}

Push-Location $RepoRoot
try {
    & docker info *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker daemon is not available. Start Docker Desktop and try again."
    }

    $upArgs = @("compose", "up", "-d")
    if (-not $NoBuild) {
        $upArgs += "--build"
    }

    Invoke-Docker $upArgs
    if (-not $SkipMigrations) {
        Invoke-Docker @("compose", "exec", "-T", "api", "python", "-m", "alembic", "upgrade", "head")
    }

    Wait-Http -Name "API readiness" -Uri "http://127.0.0.1:8000/api/ready" -TimeoutSeconds $TimeoutSeconds
    Wait-Http -Name "Frontend" -Uri "http://127.0.0.1:5173/" -TimeoutSeconds $TimeoutSeconds
    Invoke-Docker @("compose", "ps")
}
finally {
    Pop-Location
}
