$ErrorActionPreference = "Stop"

function Assert-File {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file is missing: $Path"
    }
}

function Assert-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Required directory is missing: $Path"
    }
}

function Assert-ReadmeLinks {
    $readme = Get-Content -LiteralPath "README.md" -Raw
    $matches = [regex]::Matches($readme, '\[[^\]]+\]\(([^)]+)\)')

    foreach ($match in $matches) {
        $target = $match.Groups[1].Value
        if ($target -match '^(https?:|mailto:|#)') {
            continue
        }

        $normalized = $target -replace '/', [IO.Path]::DirectorySeparatorChar
        if (-not (Test-Path -LiteralPath $normalized)) {
            throw "README link target does not exist: $target"
        }
    }
}

Write-Host "Checking required project files..."
Assert-File "README.md"
Assert-File "AGENTS.md"
Assert-File ".dockerignore"
Assert-File ".editorconfig"
Assert-File ".gitattributes"
Assert-File ".gitignore"
Assert-File ".env.example"
Assert-File "docker-compose.yml"
Assert-File ".github\pull_request_template.md"
Assert-File ".github\ISSUE_TEMPLATE\bug_report.md"
Assert-File ".github\dependabot.yml"
Assert-File ".github\workflows\ci.yml"
Assert-File ".github\workflows\codeql.yml"
Assert-File ".github\workflows\dependency-review.yml"
Assert-File "docs\CODEX_WORKFLOW.md"
Assert-File "docs\ENGINEERING_STANDARDS.md"
Assert-File "docs\DELIVERY_CHECKLIST.md"
Assert-File "docs\PROJECT_STACK.md"
Assert-File "docs\SECURITY_BASELINE.md"
Assert-File "SECURITY.md"
Assert-File "backend\pyproject.toml"
Assert-File "backend\Dockerfile"
Assert-File "backend\app\main.py"
Assert-File "backend\tests\test_health.py"
Assert-File "frontend\package.json"
Assert-File "frontend\package-lock.json"
Assert-File "frontend\Dockerfile"
Assert-File "frontend\index.html"
Assert-File "frontend\src\App.tsx"
Assert-File "frontend\src\lib\api.ts"
Assert-File "scripts\codex-check.ps1"
Assert-File "scripts\secret-scan.ps1"
Assert-File "scripts\verify.ps1"
Assert-Directory ".github"
Assert-Directory "backend"
Assert-Directory "frontend"
Assert-Directory "docs"
Assert-Directory "scripts"

Write-Host "Checking README links..."
Assert-ReadmeLinks

Write-Host "Checking git whitespace rules..."
git diff --check
if ($LASTEXITCODE -ne 0) {
    throw "git diff --check failed"
}

Write-Host "Checking for obvious secret patterns..."
& ".\scripts\secret-scan.ps1"

Write-Host "Repository verification passed."
