$ErrorActionPreference = "Continue"

function Run-Step {
    param(
        [string]$Title,
        [scriptblock]$Block
    )
    Write-Host ""
    Write-Host "=== $Title ==="
    try {
        & $Block
    }
    catch {
        Write-Host "Step failed: $($_.Exception.Message)"
    }
}

Run-Step "Repository" {
    git rev-parse --show-toplevel
    git branch --show-current
}

Run-Step "Git Status" {
    git status --short
}

if (Test-Path -LiteralPath ".\scripts\verify.ps1") {
    Run-Step "Repository Verification" {
        & ".\scripts\verify.ps1"
    }
}

function Resolve-Gh {
    $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
    if ($ghCmd) {
        return $ghCmd.Source
    }

    $defaultGh = "C:\Program Files\GitHub CLI\gh.exe"
    if (Test-Path -LiteralPath $defaultGh) {
        return $defaultGh
    }

    return $null
}

$ghExe = Resolve-Gh

if ($ghExe) {
    Run-Step "GitHub Auth" {
        & $ghExe auth status
    }

    Run-Step "PR Status" {
        & $ghExe pr status
    }

    Run-Step "Recent Workflow Runs" {
        & $ghExe run list --limit 5
    }
}
else {
    Write-Host ""
    Write-Host "=== GitHub CLI ==="
    Write-Host "gh not found in PATH. Install GitHub CLI or reopen terminal."
}
