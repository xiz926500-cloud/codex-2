param(
    [string]$ProjectName = "generated-smoke",
    [string]$DestinationRoot = $env:TEMP
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

function Assert-FileContains {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Pattern
    )

    $content = Get-Content -LiteralPath $Path -Raw
    if ($content -notmatch [regex]::Escape($Pattern)) {
        throw "Expected '$Path' to contain '$Pattern'."
    }
}

function Assert-FileNotContains {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Pattern
    )

    $content = Get-Content -LiteralPath $Path -Raw
    if ($content -match [regex]::Escape($Pattern)) {
        throw "Expected '$Path' not to contain '$Pattern'."
    }
}

function Assert-NoPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (Test-Path -LiteralPath $Path) {
        throw "Path should not exist in generated project: $Path"
    }
}

function Convert-ToProjectSlug {
    param([string]$Value)

    $slug = $Value.ToLowerInvariant() -replace "[^a-z0-9._-]", "-"
    $slug = $slug.Trim(".", "-", "_")
    $slug = $slug -replace "[-_.]{2,}", "-"
    if (-not $slug) {
        throw "Project name does not contain any usable characters."
    }

    return $slug
}

$destinationRootPath = Resolve-Path -LiteralPath $DestinationRoot
$tempRoot = Join-Path $destinationRootPath ("codex-template-smoke-" + [guid]::NewGuid().ToString("N"))
$projectSlug = Convert-ToProjectSlug -Value $ProjectName
$generatedRoot = Join-Path $tempRoot $projectSlug
$compactName = $projectSlug -replace "[^a-z0-9]", ""

Write-Host "Template smoke root: $tempRoot"

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    & (Join-Path $RepoRoot "scripts\new-project.ps1") `
        -Name $ProjectName `
        -DestinationRoot $tempRoot `
        -InitializeGit

    if (-not (Test-Path -LiteralPath $generatedRoot -PathType Container)) {
        throw "Generated project directory is missing: $generatedRoot"
    }

    & (Join-Path $generatedRoot "scripts\verify.ps1")

    Assert-NoPath (Join-Path $generatedRoot ".env")
    Assert-NoPath (Join-Path $generatedRoot "frontend\node_modules")
    Assert-NoPath (Join-Path $generatedRoot "logs\template-smoke.log")

    Assert-FileContains (Join-Path $generatedRoot "README.md") $projectSlug
    Assert-FileContains (Join-Path $generatedRoot "frontend\package.json") "$projectSlug-web"
    Assert-FileContains (Join-Path $generatedRoot "backend\pyproject.toml") "$projectSlug-api"
    Assert-FileContains (Join-Path $generatedRoot ".env.example") "POSTGRES_USER=$compactName"
    Assert-FileNotContains (Join-Path $generatedRoot "README.md") "xiz926500-cloud/codex-2"

    $gitStatus = & git -C $generatedRoot status --short
    if (-not $gitStatus) {
        throw "Generated project should have staged files after -InitializeGit."
    }

    Write-Host "Template smoke test passed."
}
finally {
    $resolvedTemp = [IO.Path]::GetFullPath($tempRoot)
    $allowedRoot = [IO.Path]::GetFullPath($destinationRootPath).TrimEnd("\") + "\"

    if ($resolvedTemp.StartsWith($allowedRoot, [StringComparison]::OrdinalIgnoreCase) -and
        (Test-Path -LiteralPath $resolvedTemp)) {
        Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
    }
}
