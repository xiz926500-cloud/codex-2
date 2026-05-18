param(
    [Parameter(Mandatory = $true)][string]$Name,
    [string]$DestinationRoot = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..\..")) ""),
    [switch]$InitializeGit,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

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

function Test-TransformableFile {
    param([string]$Path)

    $leaf = Split-Path -Leaf $Path
    $extension = [IO.Path]::GetExtension($Path).ToLowerInvariant()
    $textExtensions = @(
        ".css",
        ".dockerignore",
        ".editorconfig",
        ".example",
        ".gitattributes",
        ".gitignore",
        ".html",
        ".ini",
        ".json",
        ".mako",
        ".md",
        ".ps1",
        ".py",
        ".toml",
        ".ts",
        ".tsx",
        ".txt",
        ".yaml",
        ".yml"
    )
    $textNames = @("Dockerfile", "SECURITY")

    return ($textExtensions -contains $extension) -or ($textNames -contains $leaf)
}

function Update-TextFile {
    param(
        [string]$Path,
        [hashtable]$Replacements
    )

    if (-not (Test-TransformableFile -Path $Path)) {
        return
    }

    $content = [IO.File]::ReadAllText($Path)
    $updated = $content
    foreach ($key in $Replacements.Keys) {
        $updated = [regex]::Replace($updated, [regex]::Escape($key), $Replacements[$key])
    }

    if ($updated -ne $content) {
        [IO.File]::WriteAllText($Path, $updated)
    }
}

if ($Name -notmatch "^[A-Za-z0-9][A-Za-z0-9._-]*$") {
    throw "Name must start with a letter or number and may only contain letters, numbers, dots, underscores, or hyphens."
}

$projectSlug = Convert-ToProjectSlug -Value $Name
$compactName = $projectSlug -replace "[^a-z0-9]", ""
$dbName = $compactName
if (-not $dbName) {
    $dbName = "app"
}

$destinationRootPath = Resolve-Path -LiteralPath $DestinationRoot
$targetPath = Join-Path $destinationRootPath $projectSlug
$targetFullPath = [IO.Path]::GetFullPath($targetPath)
$repoFullPath = [IO.Path]::GetFullPath($RepoRoot)
$repoPrefix = $repoFullPath.TrimEnd("\") + "\"

if ($targetFullPath.Equals($repoFullPath, [StringComparison]::OrdinalIgnoreCase) -or
    $targetFullPath.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to create a template copy inside the source repository: $targetFullPath"
}

if (Test-Path -LiteralPath $targetFullPath) {
    $existingChildren = Get-ChildItem -LiteralPath $targetFullPath -Force -ErrorAction SilentlyContinue
    if ($existingChildren) {
        throw "Target directory already exists and is not empty: $targetFullPath"
    }
}

$trackedFiles = @(& git -C $RepoRoot ls-files)
if (-not $trackedFiles) {
    throw "No tracked files found. Run this from a Git checkout."
}

Write-Host "Template source: $repoFullPath"
Write-Host "New project:     $targetFullPath"
Write-Host "Project slug:    $projectSlug"
Write-Host "Tracked files:   $($trackedFiles.Count)"

if ($DryRun) {
    Write-Host "Dry run only; no files were copied."
    return
}

New-Item -ItemType Directory -Path $targetFullPath -Force | Out-Null

foreach ($file in $trackedFiles) {
    $source = Join-Path $RepoRoot $file
    $destination = Join-Path $targetFullPath $file
    $destinationDirectory = Split-Path -Parent $destination
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination
}

$replacements = [ordered]@{
    "xiz926500-cloud/codex-2" = "your-github-owner/$projectSlug"
    "codex-2-web" = "$projectSlug-web"
    "codex2-api" = "$projectSlug-api"
    "codex-2 API" = "$projectSlug API"
    "codex-2 starter project" = "$projectSlug starter project"
    "codex-2" = $projectSlug
    "codex2" = $compactName
    "postgresql+asyncpg://codex:codex@localhost:5432/codex" = "postgresql+asyncpg://${dbName}:${dbName}@localhost:5432/${dbName}"
    '${POSTGRES_USER:-codex}' = '${POSTGRES_USER:-' + $dbName + '}'
    '${POSTGRES_PASSWORD:-codex}' = '${POSTGRES_PASSWORD:-' + $dbName + '}'
    '${POSTGRES_DB:-codex}' = '${POSTGRES_DB:-' + $dbName + '}'
    "POSTGRES_USER=codex" = "POSTGRES_USER=$dbName"
    "POSTGRES_PASSWORD=codex" = "POSTGRES_PASSWORD=$dbName"
    "POSTGRES_DB=codex" = "POSTGRES_DB=$dbName"
}

Get-ChildItem -LiteralPath $targetFullPath -Recurse -File -Force |
    ForEach-Object {
        Update-TextFile -Path $_.FullName -Replacements $replacements
    }

if ($InitializeGit) {
    git -C $targetFullPath init
    git -C $targetFullPath config core.hooksPath .githooks
    git -C $targetFullPath add .
    Write-Host "Initialized Git and staged the generated project."
}

Write-Host "Project created. Next:"
Write-Host "  cd `"$targetFullPath`""
Write-Host "  .\scripts\bootstrap.ps1"
