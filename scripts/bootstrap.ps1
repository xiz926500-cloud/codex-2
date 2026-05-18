param(
    [switch]$SkipInstall,
    [switch]$SkipPlaywright,
    [switch]$SkipHooks,
    [switch]$SkipVerify,
    [switch]$SkipEnv,
    [switch]$RequireDocker,
    [switch]$ForceNpmInstall
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

function Write-Step {
    param([string]$Title)

    Write-Host ""
    Write-Host "=== $Title ==="
}

function Resolve-Tool {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string[]]$FallbackPaths = @()
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    foreach ($fallback in $FallbackPaths) {
        if (Test-Path -LiteralPath $fallback -PathType Leaf) {
            return $fallback
        }
    }

    return $null
}

function Require-Tool {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$InstallHint,
        [string[]]$FallbackPaths = @()
    )

    $tool = Resolve-Tool -Name $Name -FallbackPaths $FallbackPaths
    if ($tool) {
        Write-Host "$Name -> $tool"
        return $tool
    }

    if ($InstallHint) {
        throw "$Name is required but was not found. $InstallHint"
    }

    throw "$Name is required but was not found."
}

function Invoke-External {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$Arguments = @(),
        [string]$WorkingDirectory = (Get-Location).Path
    )

    Push-Location $WorkingDirectory
    try {
        & $FilePath @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "Command failed with exit code ${LASTEXITCODE}: $FilePath $($Arguments -join ' ')"
        }
    }
    finally {
        Pop-Location
    }
}

Push-Location $RepoRoot
try {
    Write-Step "Toolchain"
    $gitExe = Require-Tool -Name "git" -InstallHint "Install Git and reopen PowerShell."
    $pythonExe = Require-Tool -Name "python" -InstallHint "Install Python 3.12+ and ensure python is on PATH."
    $nodeExe = Require-Tool -Name "node" -InstallHint "Install Node.js and reopen PowerShell."
    $npmExe = Require-Tool -Name "npm.cmd" -InstallHint "Install Node.js. Use npm.cmd on Windows to avoid npm.ps1 execution-policy issues."
    $npxExe = Resolve-Tool -Name "npx.cmd"
    $ghExe = Resolve-Tool -Name "gh" -FallbackPaths @("C:\Program Files\GitHub CLI\gh.exe")
    $dockerExe = Resolve-Tool -Name "docker" -FallbackPaths @("C:\Program Files\Docker\Docker\resources\bin\docker.exe")

    Invoke-External -FilePath $gitExe -Arguments @("--version")
    Invoke-External -FilePath $pythonExe -Arguments @("--version")
    Invoke-External -FilePath $nodeExe -Arguments @("--version")
    Invoke-External -FilePath $npmExe -Arguments @("--version")

    if ($ghExe) {
        Write-Host "gh -> $ghExe"
        Invoke-External -FilePath $ghExe -Arguments @("--version")
    }
    else {
        Write-Host "gh not found. GitHub PR/repo automation will be unavailable until GitHub CLI is installed."
    }

    if ($dockerExe) {
        Write-Host "docker -> $dockerExe"
        Invoke-External -FilePath $dockerExe -Arguments @("--version")
        $dockerInfoExitCode = 0
        try {
            & $dockerExe info *> $null
            $dockerInfoExitCode = $LASTEXITCODE
        }
        catch {
            $dockerInfoExitCode = 1
        }

        if ($dockerInfoExitCode -ne 0) {
            if ($RequireDocker) {
                throw "Docker CLI exists, but Docker Desktop/daemon is not ready."
            }
            Write-Host "Docker CLI exists, but Docker Desktop/daemon is not ready. Skipping Docker readiness enforcement."
        }
    }
    elseif ($RequireDocker) {
        throw "Docker is required but was not found. Install Docker Desktop and reopen PowerShell."
    }
    else {
        Write-Host "Docker not found. Docker-backed scripts will be unavailable until Docker Desktop is installed."
    }

    if (-not $SkipEnv) {
        Write-Step "Environment File"
        $envFile = Join-Path $RepoRoot ".env"
        $envExample = Join-Path $RepoRoot ".env.example"
        if (Test-Path -LiteralPath $envFile -PathType Leaf) {
            Write-Host ".env already exists; leaving it unchanged."
        }
        elseif (Test-Path -LiteralPath $envExample -PathType Leaf) {
            Copy-Item -LiteralPath $envExample -Destination $envFile
            Write-Host "Created .env from .env.example."
        }
        else {
            Write-Host ".env.example is missing; no .env was created."
        }
    }

    if (-not $SkipInstall) {
        Write-Step "Backend Dependencies"
        Invoke-External -FilePath $pythonExe -Arguments @("-m", "pip", "install", "-e", ".[dev]") -WorkingDirectory (Join-Path $RepoRoot "backend")

        Write-Step "Frontend Dependencies"
        $frontendDir = Join-Path $RepoRoot "frontend"
        $nodeModules = Join-Path $frontendDir "node_modules"
        $packageLock = Join-Path $frontendDir "package-lock.json"
        if ($ForceNpmInstall -or -not (Test-Path -LiteralPath $nodeModules -PathType Container)) {
            if (Test-Path -LiteralPath $packageLock -PathType Leaf) {
                Invoke-External -FilePath $npmExe -Arguments @("ci") -WorkingDirectory $frontendDir
            }
            else {
                Invoke-External -FilePath $npmExe -Arguments @("install") -WorkingDirectory $frontendDir
            }
        }
        else {
            Write-Host "frontend\node_modules exists; skipping npm install. Use -ForceNpmInstall to refresh."
        }

        if (-not $SkipPlaywright) {
            Write-Step "Playwright Browser"
            if (-not $npxExe) {
                throw "npx.cmd is required to install Playwright browsers but was not found."
            }
            Invoke-External -FilePath $npxExe -Arguments @("playwright", "install", "chromium") -WorkingDirectory $frontendDir
        }

        Write-Step "Generated API Client"
        & ".\scripts\generate-api.ps1" -SkipInstall
    }
    else {
        Write-Host "Dependency installation skipped."
    }

    if (-not $SkipHooks) {
        Write-Step "Git Hooks"
        & ".\scripts\install-git-hooks.ps1"
    }

    if (-not $SkipVerify) {
        Write-Step "Repository Verification"
        & ".\scripts\verify.ps1"
    }

    Write-Step "Done"
    Write-Host "Bootstrap completed. Use .\scripts\dev.ps1 to start the local stack."
}
finally {
    Pop-Location
}
